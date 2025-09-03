local PARTY_ADDR = 0xdcd7
local PARTY_END_ADDR = 0xde83

local BADGE_START = 0xd857

ckk = nil

function getBadges()
    local johto = emu:read8(BADGE_START)
    local kanto = emu:read8(BADGE_START + 1)
    local arr = {}
    local mask = 1
    for i = 1, 8 do
        table.insert(arr, {
            name = ENGINE_TABLES.BADGES.JOHTO[i - 1],
            obtained = (johto & mask) > 0
        })
        johto = johto >> 1
    end
    for i = 1, 8 do
        table.insert(arr, {
            name = ENGINE_TABLES.BADGES.KANTO[i - 1],
            obtained = (kanto & mask) > 0
        })
        kanto = kanto >> 1
    end
    return arr
end

function gen2Party(startAddr, endAddr)
	local data = emu:readRange(startAddr, endAddr - startAddr)
    return ckk:readList(data, 6)
end

local function readList(self, data, capacity)
	local count = string.byte(data, 1)
	local mons = {}
	for i = 1, count do
		local metaSpecies = string.byte(data, 1 + i)
		local addr = 3 + capacity + (48 * (i - 1))
		local species = ckk.mons[string.byte(data, addr + 0x00)]
		if metaSpecies == 0xFD then
			species = "egg"
		end
		local moves = {}
		for m = 0x02, 0x05 do
			local id = string.byte(data, addr + m)
			if id ~= 0 then
				table.insert(moves, ckk.moves[id])
			end
		end
		table.insert(mons, {
			species = species,
			level = string.byte(data, addr + 0x1F),
			moves = moves
		})
	end
	return mons
end

ckk = {
	mons = ENGINE_TABLES.POKEMON_BY_INDEX,
	moves = ENGINE_TABLES.MOVES_BY_INDEX,
	readList = readList
}
