Malachite:init()
local m = Malachite

VERSION = "0.1.0"

wd = nil
buf = console:createBuffer("Vs. Link")

function start()
    m:log("\n\n\n\n\n\n\n\n\n\n\n\n")
    m:log("Vs. Link starting...")
	wd = debug.getinfo(start).source:match("@?(.*[/\\])") or ""
	dofile(wd .. "endpoints.lua")
	dofile(wd .. "engine/engine.lua")
	dofile(wd .. "engine/tables.lua")
	dofile(wd .. "engine/gen2.lua")
	dofile(wd .. "engine/gen3.lua")

    local server = m.Http.Server:new(nil, 31123, function(req, res)
        local game = getCurrentGame()
        local json, err = req:getJson()
        if req.path == "/badges" then
            res.content = getBadges()
        elseif req.path == "/party" then
            m:log(game);
            res.content = game.game.getParty()
        end
    end)
    server:start();
end

start()
