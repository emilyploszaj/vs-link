local m = Malachite
local endpoints = {}

function callEndpoint(req, res)
	local method = req.method
	local path = req.path

	if path:sub(-1) == "/" then
		path = path:sub(1, #path - 1)
	end
	if endpoints[method] == nil or endpoints[method][path] == nil then
		res.code = 404
		res.content = "Unknown endpoint " .. method .. " " .. path
		return
	end
	local game = getCurrentGame()
	local json, err = req:getJson()
	local data = {
		game = game,
		json = json,
		req = req,
		res = res
	}
	endpoints[method][path](data)
end

function addEndpoint(method, path, callback)
	if endpoints[method] == nil then
		endpoints[method] = {}
	end
	endpoints[method][path] = callback
end

-- Generic info

addEndpoint("GET", "/vs/info", function(data) 
	data.res.content = {
		name = "Vs. Link",
		version = VERSION
	}
end)

-- Game info

addEndpoint("GET", "/vs/game", function(data) 
	data.res.content = data.game.game.getInfo()
end)

addEndpoint("GET", "/vs/badges", function(data) 
	data.res.content = getBadges()
end)

addEndpoint("GET", "/vs/party", function(data) 
	data.res.content = data.game.game.getParty()
end)
