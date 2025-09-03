function start()
	dofile(wd .. "malachite/malachite.lua")
	dofile(wd .. "src/main.lua")
end

wd = nil
wd = debug.getinfo(start).source:match("@?(.*[/\\])") or ""
start()