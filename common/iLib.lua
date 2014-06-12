--[[ iClass
 
Trigonometry
Item Usage
Other
 
]]--
 
--[[ Trigonometry iClass 101 | A^2 + B^2 = C^2]]--
 
function isInsideSectorByAngle(Point, Center, Angle, AngleWidth, Radius)
        assert(VectorType(Point) and VectorType(Center) and type(Angle) == "number" and type(AngleWidth) == "number" and type(Radius) == "number", "isInsideSectorByAngle: wrong argument types (<Vector>, <Vector>, integer, integer, integer expected)")
        local TempPoint1 = FindPointOnCircle(Center, Angle-(AngleWidth/2), Radius)
        local TempPoint2 = FindPointOnCircle(Center, Angle+(AngleWidth/2), Radius)
        if isInsideSector(Point, Center, TempPoint1, TempPoint2, Radius) then return true else return false end
end
 
function sign(x)
        if x> 0 then return 1
        elseif x<0 then return -1
        end
end
 
function isInsideSector(point, center, sectorStart, sectorEnd, Radius)
        assert(VectorType(point) and VectorType(center) and VectorType(sectorStart) and VectorType(sectorEnd), "isInsideSector: wrong argument types (<Vector>, <Vector>, <Vector>, <Vector> expected)")
        local relPoint = {}
        relPoint.x = point.x - center.x
        relPoint.z = point.z - center.z
        if (not areClockwise(sectorStart, relPoint) and areClockwise(sectorEnd, relPoint) and GetDistance(relPoint) < Radius) then return true else return false end
end
 
function FindPointOnCircle(Center, Angle, Radius)
        assert(VectorType(Center) and type(Angle) == "number" and type(Radius) == "number", "FindPointOnCircle: wrong argument types (<Vector>, integer, integer expected)")
        if Angle < 0 then
                Angle = 360-(Angle%360)
        end
        local ReturnAngle = {}
        ReturnAngle.x = math.sin(math.rad(Angle))*Radius + Center.x
        ReturnAngle.y = Center.y
        ReturnAngle.z = math.cos(math.rad(Angle))*Radius + Center.z
        return ReturnAngle
end
 
function areClockwise(testv1, testv2)
        assert(VectorType(testv1) and VectorType(testv2), "areClockwise: wrong argument types (<Vector>, <Vector> expected)")
        if testv1.z ~= nil and testv2.z ~= nil then
                return -testv1.x * testv2.z + testv1.z * testv2.x>0
        else
                return -testv1.x * testv2.y + testv1.y * testv2.x>0
        end
end
 
--[[function FindDegrees(Vector1, Vector2)
        assert(VectorType(Vector1) and VectorType(Vector2), "FindDegrees: wrong argument types (<Vector>, <Vector> expected)")
        return math.deg(math.atan2((Vector2.x-Vector1.x),(Vector2.z-Vector1.z)))
end]]
 
-- Minimum Enclosing Circle Sector | Credits to llama for the main function.
function GetMECS(Center, AngleDegree, Radius, Minimum)
        assert(VectorType(Center) and type(AngleDegree) == "number" and type(Radius) == "number" and type(Minimum) == "number", "GetMECS: wrong argument types (<Vector>, integer, integer, integer expected)" )
        local Points = {}
        local n = 1
        local v1,v2,v3 = 0,0,0
        local largeN,largeV1,largeV2 = 0,0,0
        local theta1,theta2,smallBisect = 0,0,0
        for i = 1, heroManager.iCount do
                local enemy = heroManager:getHero(i)
                if Center == myHero then
                        if ValidTarget(enemy, Radius) then
                                table.insert(Points, enemy)
                        end
                elseif GetDistance(Center, enemy) < Radius and not enemy.dead and enemy.team ~= myHero.team and enemy ~= nil and enemy.visible then
                        table.insert(Points, enemy)
                end
        end
        if #Points == 0 or #Points < Minimum then return nil end
        if #Points == 1 and #Points >= Minimum then
                return Points[1]
        end    
        --[[if EnemyCount == 2 and EnemyCount >= Minimum2 then
                local Point1 = Vector(Points[1])
                local Point2 = Vector(Points[2])
                TempPoint = Vector((Point2.x-Point1.x)/2+Point1.x, Center.y, (Point2.z-Point1.z)/2+Point1.z)
               
                return TempPoint
        end]]
        if #Points >= 2 and #Points >= Minimum then
                for i=1, #Points,1 do
                        for j=1,#Points, 1 do
                                if i~=j then
                                        v1 = Vector(Points[i].x-Center.x , Points[i].z-Center.z)
                                        v2 = Vector(Points[j].x-Center.x , Points[j].z-Center.z)
                                        thetav1 = sign(v1.y)*90-math.deg(math.atan(v1.x/v1.y))
                                        thetav2 = sign(v2.y)*90-math.deg(math.atan(v2.x/v2.y))
                                        thetaBetween = thetav2-thetav1                 
 
                                        if (thetaBetween) <= AngleDegree and thetaBetween>0 then
                                                if #Points == 2 then
                                                        largeV1 = v1
                                                        largeV2 = v2
                                                else                                           
                                                        tempN = 0
                                                        for k=1, #Points,1 do
                                                                if k~=i and k~=j then
                                                                        v3 = Vector(Points[k].x-Center.x , Points[k].z-Center.z)
                                                                        if areClockwise(v3,v1) and not areClockwise(v3,v2) then
                                                                                tempN = tempN+1
                                                                        end
                                                                end
                                                        end
                                                        if tempN > largeN then
                                                                largeN = tempN
                                                                largeV1 = v1
                                                                largeV2 = v2
                                                        end
                                                end
                                        end
                                end
                        end
                end
        end
       
        if largeV1 == 0 or largeV2 == 0 then
                return nil
        else
                if largeV1.y == 0 then
                        theta1 = 0
                else
                        theta1 = sign(largeV1.y)*90-math.deg(math.atan(largeV1.x/largeV1.y))
                end
                if largeV2.y == 0 then
                        theta2 = 0
                else
                        theta2 = sign(largeV2.y)*90-math.deg(math.atan(largeV2.x/largeV2.y))
                end
 
                smallBisect = math.rad((theta1 + theta2) / 2)
                vResult = {}
                vResult.x = Radius*math.cos(smallBisect)+myHero.x
                vResult.y = myHero.y
                vResult.z = Radius*math.sin(smallBisect)+myHero.z
                if largeN >= Minimum or #Points == 2 then
                        return vResult
                end
        end
end
 
--[[ Item Usage iClass ]]--
 
local items = {
        BRK = {id=3153, range = 500, reqTarget = true, slot = nil},
        BWC = {id=3144, range = 400, reqTarget = true, slot = nil},
        HGB = {id=3146, range = 400, reqTarget = true, slot = nil},
        DFG = {id=3128, range = 750, reqTarget = true, slot = nil},
        YGB = {id=3142, range = 350, reqTarget = false, slot = nil},
        STD = {id=3131, range = 350, reqTarget = false, slot = nil},
        RSH = {id=3074, range = 350, reqTarget = false, slot = nil},
        TMT = {id=3077, range = 350, reqTarget = false, slot = nil},
        EXE = {id=3123, range = 350, reqTarget = false, slot = nil},
        RAN = {id=3143, range = 350, reqTarget = false, slot = nil},
        MAR = {id=3042, range = 350, reqTarget = false, slot = nil}}
 
function UseAllItems(target)
        for _,item in pairs(items) do
                item.slot = GetInventorySlotItem(item.id)
                if item.slot ~= nil then
                        if reqTarget and GetDistance(target) < item.range then
                                CastSpell(item.slot, target)
                        elseif (GetDistance(target) - getHitBoxRadius(myHero) - getHitBoxRadius(target)) < 50 then
                                CastSpell(item.slot)
                        end
                end
        end
end
 
function UseTargetItems(target)
        for _,item in pairs(items) do
                item.slot = GetInventorySlotItem(item.id)
                if item.slot ~= nil then
                        if reqTarget and GetDistance(target) < item.range then
                                CastSpell(item.slot, target)
                        end
                end
        end
end
 
function UseSelfItems(target)
        for _,item in pairs(items) do
                item.slot = GetInventorySlotItem(item.id)
                if item.slot ~= nil then
                        if not reqTarget and (GetDistance(target) - getHitBoxRadius(myHero) - getHitBoxRadius(target)) < 50 then
                                CastSpell(item.slot)
                        end
                end
        end
end
 
--[[ Other ]]--
 
function getHitBoxRadius(target)
        return GetDistance(target.minBBox, target.maxBBox)/2
end