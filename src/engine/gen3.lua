function gen3Party(partyLengthAddr, partyAddr)
    party = {}
    local len = emu:read32(partyLengthAddr)
    for i = 1, len do
        table.insert(party, readGen3Mon(partyAddr + (i - 1) * 100))
    end
    return party
end

function readGen3Mon(addr)
    local personality = emu:read32(addr + 0x00)
    local ot = emu:read32(addr + 0x04)
    -- nickname
    local language = emu:read8(addr + 0x12)
    local flags = emu:read8(addr + 0x13)
    local markings = emu:read8(addr + 0x1B)
    local checksum = emu:read16(addr + 0x1C)

	local substructSelector = { [0]=
		{ 0, 1, 2, 3 },
		{ 0, 1, 3, 2 },
		{ 0, 2, 1, 3 },
		{ 0, 3, 1, 2 },
		{ 0, 2, 3, 1 },
		{ 0, 3, 2, 1 },
		{ 1, 0, 2, 3 },
		{ 1, 0, 3, 2 },
		{ 2, 0, 1, 3 },
		{ 3, 0, 1, 2 },
		{ 2, 0, 3, 1 },
		{ 3, 0, 2, 1 },
		{ 1, 2, 0, 3 },
		{ 1, 3, 0, 2 },
		{ 2, 1, 0, 3 },
		{ 3, 1, 0, 2 },
		{ 2, 3, 0, 1 },
		{ 3, 2, 0, 1 },
		{ 1, 2, 3, 0 },
		{ 1, 3, 2, 0 },
		{ 2, 1, 3, 0 },
		{ 3, 1, 2, 0 },
		{ 2, 3, 1, 0 },
		{ 3, 2, 1, 0 },
	}
	local pSel = substructSelector[personality % 24]

    local gAddr = pSel[1] * 3
    local aAddr = pSel[2] * 3
    local eAddr = pSel[3] * 3
    local mAddr = pSel[4] * 3

    local data = {}
    local decryption = personality ~ ot
    for i = 0, 12 do
        data[i] = emu:read32(addr + 32 + i * 4) ~ decryption
    end

    local species = (data[gAddr] & 0x0000FFFF) >> 0
    local item = (data[gAddr] & 0xFFFF0000) >> 16
    local experience = data[gAddr + 1]
    local moves = {
        ENGINE_TABLES.MOVES_BY_INDEX[(data[aAddr + 0] & 0x0000FFFF)],
        ENGINE_TABLES.MOVES_BY_INDEX[(data[aAddr + 0] & 0xFFFF0000) >> 16],
        ENGINE_TABLES.MOVES_BY_INDEX[(data[aAddr + 1] & 0x0000FFFF)],
        ENGINE_TABLES.MOVES_BY_INDEX[(data[aAddr + 1] & 0xFFFF0000) >> 16]
    }

    return {
        species = ENGINE_TABLES.POKEMON_BY_INDEX_GEN_3[species],
        moves = moves
    }
end