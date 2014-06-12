_G.sTable = {}

for scriptName, environment in pairs(_G.environment) do
	if environment['OnSendPacket'] and type(environment['OnSendPacket']) == 'function' then
		table.insert(_G.sTable, environment['OnSendPacket'])
	end
end

_G.Packet.send = function(self, override)
	if self.blocked then return end
	local p = Packet.definition[self.values.name].encode(self)
	if override ~= nil then
		for i,v in ipairs(_G.sTable) do
			if v(p, true) == false then return end
		end
	end
	SendPacket(p)
	return self
end
