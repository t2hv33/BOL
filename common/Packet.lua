class 'Packet' -- {
    function Packet:__init(packet)
        if type(packet) == "string" then
            self.name = packet

            self.decodeResult = {name = packet}
        else
            self.decodeResult = Packet.decodeFunctions[packet.header] and Packet.decodeFunctions[packet.header](packet) or { header = packet.header, name = "PKT_Unknown" }

            for k,v in pairs(self.decodeResult) do
                self[k] = v
            end
        end
    end

    function Packet:tostring()
        return Packet.tableToString(self.decodeResult)
    end

    -- Encoding functions ------------------------------------------------------

    Packet.encodeFunctions = {
        -- PKT_WaypointGroup
        [0x5E] = function(p)
        end
    }

    -- Decoding functions ------------------------------------------------------

    Packet.decodeFunctions = {
        -- PKT_WaypointGroup
        [0x5E] = function(p)
            p.pos = 5

            local packetResult = {
                header = p.header,
                name = "PKT_WaypointGroup",
                sequenceNumber = p:Decode4(),
                unitCount = p:Decode2(),
                wayPoints = {}
            }

            for h = 1, packetResult.unitCount do
                local waypointCount = p:Decode1() / 2
                local networkId = p:DecodeF()

                local modifierBits = {0, 0}
                for i = 1, math.ceil((waypointCount - 1) / 4) do
                    local bitMask = p:Decode1()

                    for j = 1, 8 do
                        table.insert(modifierBits, bit32.band(bitMask, 1))
                        bitMask = bit32.rshift(bitMask, 1)
                    end
                end

                packetResult.wayPoints[networkId] = {}
                for i = 1, waypointCount do
                    table.insert(packetResult.wayPoints[networkId], Packet.getNextWayPoint(p, modifierBits))
                end
            end

            return packetResult
        end
    }

    -- Internal helper functions -----------------------------------------------

    function Packet.tableToString(tableObject, indentLevel)
        indentLevel = indentLevel or 1

        local result = 'table: {'

        for k,v in pairs(tableObject) do
            if result == 'table: {' then
                result = result .. '\n'
            else
                result = result .. ',\n'
            end

            for i=1, indentLevel do
                result = result .. '  '
            end

            if type(v) == "table" then
                result = result .. k .. ' = ' .. Packet.tableToString(v, indentLevel + 1)
            elseif type(v) == "userdata" and v.tostring then
                result = result .. k .. ' = ' .. v:tostring()
            elseif type(v) ~= "userdata" then
                result = result .. k .. ' = ' .. tostring(v)
            end
        end

        result = result .. '\n'

        for i=1, indentLevel-1 do
            result = result .. '  '
        end

        result = result .. '}'

        return result
    end

    function Packet.getNextWayPoint(packet, modifierBits)
        coord = Point(Packet.getNextGridCoord(packet, modifierBits, coord and coord.x or 0), Packet.getNextGridCoord(packet, modifierBits, coord and coord.y or 0) )

        return Packet.gridToWorld(coord)
    end

    function Packet.getNextGridCoord(packet, modifierBits, relativeCoord)
        if table.remove(modifierBits, 1) == 1 then
            return relativeCoord + Packet.unsignedToSigned(packet:Decode1(), 1)
        else
            return Packet.unsignedToSigned(packet:Decode2(), 2)
        end
    end

    function Packet.unsignedToSigned(value, byteCount)
        byteCount = 2 ^ ( 8 * byteCount)

        return value >= byteCount / 2 and value - byteCount or value
    end

    function Packet.gridToWorld(coord)
        return Point(2 * coord.x + GetMap().grid.width, 2 * coord.y + GetMap().grid.heigth)
    end
-- }