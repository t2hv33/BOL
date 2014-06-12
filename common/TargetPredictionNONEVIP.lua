--

class'TargetPredictionNONEVIP'
function TargetPredictionNONEVIP:__init(range, proj_speed, delay, width, fromPos)
    self.WayPointManager = WayPointManager()
    self.Spell = { Source = fromPos or myHero, RangeSqr = range and (range ^ 2) or math.huge, Speed = proj_speed or math.huge, Delay = delay or 0, Width = width }
    self.Cache = {}
end

function TargetPredictionNONEVIP:GetPrediction(target)
    if os.clock() - (self.Cache[target.networkID] and self.Cache[target.networkID].Time or 0) >= 1 / 60 then self.Cache[target.networkID] = { Time = os.clock() }
    else return self.Cache[target.networkID].HitPosition, self.Cache[target.networkID].HitTime, self.Cache[target.networkID].ShootPosition
    end
    local wayPoints, hitPosition, hitTime = self.WayPointManager:GetSimulatedWayPoints(target, self.Spell.Delay + ((GetLatency() / 2) /1000)), nil, nil
    assert(self.Spell.Speed > 0 and self.Spell.Delay >= 0, "TargetPredictionNONEVIP:GetPrediction : SpellDelay must be >=0 and SpellSpeed must be >0")
    local vec
    if #wayPoints == 1 or self.Spell.Speed == math.huge then --Target not moving
        hitPosition = { x = wayPoints[1].x, y = target.y, z = wayPoints[1].y };
        hitTime = GetDistance(wayPoints[1], self.Spell.Source) / self.Spell.Speed
        vec = self.Spell.Width and hitPosition
    else --Target Moving
        local travelTimeA = 0
        for i = 1, #wayPoints - 1 do
            local A, B = wayPoints[i], wayPoints[i + 1]
            local wayPointDist = GetDistance(wayPoints[i], wayPoints[i + 1])
            local travelTimeB = travelTimeA + wayPointDist / target.ms
            local v1, v2 = target.ms, self.Spell.Speed
            local r, S, j, K = self.Spell.Source.x - A.x, v1 * (B.x - A.x) / wayPointDist, self.Spell.Source.z - A.y, v1 * (B.y - A.y) / wayPointDist
            local vv, jK, rS, SS, KK = v2 * v2, j * K, r * S, S * S, K * K
            local t = (jK + rS - math.sqrt(j * j * (vv - 1) + SS + 2 * jK * rS + r * r * (vv - KK))) / (KK + SS - vv)
            if travelTimeA <= t and t <= travelTimeB then
                hitPosition = { x = A.x + t * S, y = target.y, z = A.y + t * K }
                hitTime = t
                if self.Spell.Width then
                    local function rotate2D(vec, vec2, phi)
                        local vec = { x = vec.x - vec2.x, y = vec.y, z = vec.z - vec2.z }
                        vec.x, vec.z = math.cos(phi) * vec.x - math.sin(phi) * vec.z + vec2.x, math.sin(phi) * vec.x + math.cos(phi) * vec.z + vec2.z
                        return vec
                    end
                    local alpha = (math.atan2(B.y - A.y, B.x - A.x) - math.atan2(self.Spell.Source.z - hitPosition.z, self.Spell.Source.x - hitPosition.x)) % (2 * math.pi) --angle between movement and spell
                    local total = 1 - (math.abs((alpha % math.pi) - math.pi / 2) / (math.pi / 2)) --0 if the player walks in your direction or away from your direction, 1 if he walks orthogonal to you
                    local phi = alpha < math.pi and math.atan((self.Spell.Width / 2) / (self.Spell.Speed * hitTime)) or -math.atan((self.Spell.Width / 2) / (self.Spell.Speed * hitTime))
                    vec = rotate2D({ x = hitPosition.x, y = hitPosition.y, z = hitPosition.z }, self.Spell.Source, phi * total)
                end
                break
            end
            --Logic In Case there is no prediction 'till the last wayPoint
            if i == #wayPoints - 1 then
                hitPosition = { x = B.x, y = target.y, z = B.y };
                hitTime = travelTimeB
                vec = self.Spell.Width and hitPosition
            end
            --no prediction in the current segment, go to next waypoint
            travelTimeA = travelTimeB
        end
    end
    if hitPosition and self.Spell.RangeSqr >= GetDistanceSqr(hitPosition, self.Spell.Source) then
        self.Cache[target.networkID].HitPosition, self.Cache[target.networkID].HitTime, self.Cache[target.networkID].ShootPosition = hitPosition, hitTime, vec
        return hitPosition, hitTime, vec
    end
end

function TargetPredictionNONEVIP:GetHitChance(target)
    local pos, t = self:GetPrediction(target)
	if self.Cache[target.networkID] and self.Cache[target.networkID].Chance then return self.Cache[target.networkID].Chance end
	local function sum(t) local n = 0 for i, v in pairs(t) do n = n + v end return n end
    local hitChance = 0
    local hC = {}
    --Track if the enemy arrived at its last waypoint and is invisible (lower hitchance)
    local wps, arrival = self.WayPointManager:GetSimulatedWayPoints(target)
    hC[#hC + 1] = target.visible and 1 or (arrival ~= 0 and 0.5 or 0)
    if target.visible then
        --Track how often the enemy moves. If he constantly moves, the hitchance is lower
        local rate = 1 - math.max(0, (self.WayPointManager:GetWayPointChangeRate(target) - 1)) / 5
        hC[#hC + 1] = rate; hC[#hC + 1] = rate; hC[#hC + 1] = rate
		--Track the time the spell needs to hit the target. the higher it is, the lower the hitchance
		if t then hC[#hC + 1] = math.min(math.max(0, 1 - t / 1), 1) end
    end
    --Generate a value between 0 (no chance) and 100 (you'll hit for sure)
    hitChance = math.min(1, math.max(0, sum(hC) / #hC))
	if self.Cache[target.networkID] then self.Cache[target.networkID].Chance = hitChance end
	return hitChance
end

function TargetPredictionNONEVIP:DrawPrediction(target, color, size)
    local pos, time, shoot = self:GetPrediction(target)
    if not pos then return end
    DrawLine3D(pos.x, target.y, pos.z, self.Spell.Source.x, self.Spell.Source.y, self.Spell.Source.z, size, color, true)
end

function TargetPredictionNONEVIP:DrawPredictionRectangle(target, color, size)
    local pos, time, shoot = self:GetPrediction(target)
    if not shoot then return end
    DrawLineBorder3D(shoot.x, target.y, shoot.z, self.Spell.Source.x, self.Spell.Source.y, self.Spell.Source.z, self.Spell.Width, color, size or 1)
end

function TargetPredictionNONEVIP:DrawAnimatedPrediction(target, color1, color2, size1, size2, drawspeed)
    drawspeed = drawspeed or 1
    local pos, time = self:GetPrediction(target)
    if pos then
        local r = GetDrawClock(drawspeed)
        DrawLine3D(self.Spell.Source.x, self.Spell.Source.y, self.Spell.Source.z, self.Spell.Source.x + r * (pos.x - self.Spell.Source.x), target.y, self.Spell.Source.z + r * (pos.z - self.Spell.Source.z), size1, color1)
        local points = {}
        for i, v in ipairs(WayPointManager:GetSimulatedWayPoints(target, 0, (self.Spell.Delay + time) * r)) do
            local c = WorldToScreen(D3DXVECTOR3(v.x, target.y, v.y))
            points[#points + 1] = D3DXVECTOR2(c.x, c.y)
        end
        DrawLines2(points, size2 or 1, color2 or 4294967295)
    end
end

function TargetPredictionNONEVIP:GetCollision(target)
    assert(self.Spell.Width and self.Spell.Width >= 0, "SpellWidth needed for MinionCollision detection")
    if not self.MinionManager then self.MinionManager = minionManager(MINION_ENEMY, math.sqrt(self.Spell.RangeSqr) + 300) end
    local prediction, hitTime, enhPrediction = self:GetPrediction(target)
    if self.Cache[target.networkID].Collision then return self.Cache[target.networkID].Collision end
    prediction = enhPrediction or prediction
	if not prediction then return false end
    local o = { x = -(prediction.z - self.Spell.Source.z), y = prediction.x - self.Spell.Source.x }
    local len = math.sqrt(o.x ^ 2 + o.y ^ 2)
	local minionHitBoxRadius = 100
    o.x, o.y = ((self.Spell.Width / 2) + minionHitBoxRadius) * o.x / len, ((self.Spell.Width / 2) + minionHitBoxRadius) * o.y / len
    local spellBorder = {
        D3DXVECTOR2(self.Spell.Source.x + o.x, self.Spell.Source.z + o.y),
        D3DXVECTOR2(self.Spell.Source.x - o.x, self.Spell.Source.z - o.y),
        D3DXVECTOR2(prediction.x - o.x, prediction.z - o.y),
        D3DXVECTOR2(prediction.x + o.x, prediction.z + o.y),
        D3DXVECTOR2(self.Spell.Source.x + o.x, self.Spell.Source.z + o.y),
    }
    self.MinionManager:update()
    for index, minion in pairs(self.MinionManager.objects) do
        local wayPoints = self.WayPointManager:GetSimulatedWayPoints(minion, self.Spell.Delay + GetLatency() / 2000, self.Spell.Delay + GetLatency() / 2000 + hitTime + 1)
        if wayPoints and #wayPoints > 0 then
            local function intersect(A, B, C, D)
                local function ccw(A, B, C) return (C.y - A.y) * (B.x - A.x) > (B.y - A.y) * (C.x - A.x) end
                return ccw(A, C, D) ~= ccw(B, C, D) and ccw(A, B, C) ~= ccw(A, B, D)
            end
            local function getSpellHitTime(position)
                local pointSegment, pointLine, isOnSegment = VectorPointProjectionOnLineSegment(self.Spell.Source, prediction, position)
                return isOnSegment and GetDistanceSqr(pointLine, position) < (self.Spell.Width / 2) ^ 2, GetDistance(self.Spell.Source, pointLine) / self.Spell.Speed
            end

            local absTimeTravelled = 0
            for i = 1, #wayPoints - 1 do
                local A, B = wayPoints[i], wayPoints[i + 1]
                local minionIn, minionOut, minSpellT, maxSpellT = math.huge, -math.huge, math.huge, -math.huge
                local isInRect, hitStartT = getSpellHitTime(A) -- If minion starts in occupied area
                if isInRect then
                    minionIn, minionOut = math.min(minionIn, absTimeTravelled), math.max(minionOut, absTimeTravelled)
                    minSpellT, maxSpellT = math.min(hitStartT, minSpellT), math.max(hitStartT, maxSpellT)
                end
                for i = 1, #spellBorder - 1 do
                    local C, D = spellBorder[i], spellBorder[i + 1]
                    if intersect(A, B, C, D) then
						local intersection = VectorIntersection(A, B, C, D)
						local cTimeTravelled = absTimeTravelled + GetDistance(A, intersection) / minion.ms
						local isInRect, hitMinionT = getSpellHitTime(intersection)
                        minionIn, minionOut = math.min(minionIn, cTimeTravelled), math.max(minionOut, cTimeTravelled)
                        minSpellT, maxSpellT  = math.min(hitMinionT, minSpellT), math.max(hitMinionT, maxSpellT)
                    end
                end

                if not (minionIn > maxSpellT or minSpellT > minionOut) then
                    self.Cache[target.networkID].Collision = true
                    return true
                end
                absTimeTravelled = absTimeTravelled + GetDistance(A, B) / minion.ms
            end
            local isInRect, hitEndT = getSpellHitTime(wayPoints[#wayPoints]) -- If minion ends his movement in occupied area
            if isInRect and hitEndT < hitTime then
                self.Cache[target.networkID].Collision = true
                return true
            end
        end
    end

    self.Cache[target.networkID].Collision = false
    return false
end