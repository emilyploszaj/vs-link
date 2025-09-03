Malachite = {}
local m = Malachite
local root

function Malachite:reload()
	local wd = debug.getinfo(Malachite.reload).source:match("@?(.*[/\\])") or ""
	dofile(root)
end

function Malachite:init()
	root = debug.getinfo(2).source:match("@?(.*)") or ""
	local wd = debug.getinfo(Malachite.reload).source:match("@?(.*[/\\])") or ""
	dofile(wd .. "util.lua")
	dofile(wd .. "debug.lua")
	dofile(wd .. "network.lua")
	dofile(wd .. "font.lua")
end
