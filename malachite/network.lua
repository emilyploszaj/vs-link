local m = Malachite

local Http = {}
m.Http = Http;
local Server = {}
Http.Server = Server
local HttpRequest = {}

function Server:new(address, port, handleRequest)
	local o = {
        address = address,
        port = port,
        handleRequest = handleRequest
	}
	m:apply(Server, o)

    return o;
end

function Server:start()
    server, err = socket.bind(self.address, self.port)
	if err then
		console:error("Bind error " .. err)
	else
		ok, err = server:listen()
		if err then
			server:close()
			console:error("Listen error " .. err)
		else
            local s = self
			server:add("received", function() s:connect() end)
            self.server = server
		end
	end
end

function Server:connect()
	local sock, err = server:accept()
	if err then
		console:error("Connection error " .. err)
		return
	end
    local s = self
	sock:add("received", function() s:receiveData(sock) end)
	sock:add("error", function() sock:close() end)
end

function Server:receiveData(sock)
	local data = ""
	while true do
		local p, err = sock:receive(1024)
		if p then
			data = data .. p
		else
			if err ~= socket.ERRORS.AGAIN then
				console:error("Socket error " .. err)
				sock:close()
			else
				local req = parseHttp(data)
				if not req then
					return
				end
                local request = HttpRequest:new(req.method, req.path, req.body)
                local response = {
                    code = 200,
                    content = nil,
                    mime = nil
                }
                self.handleRequest(request, response)
                if response.content == nil then
                    response.content = ""
                end
                if response.mime == nil then
	                if type(response.content) == "string" then
                        mime = "text/plain"
                    else
                        response.content = m:toJson(response.content)
                        mime = "application/json"
                    end
                end
                -- TODO response code
				sock:send(string.format(
					"HTTP/1.1 200 OK\r\n" ..
					"Access-Control-Allow-Origin: *\r\n" ..
					"Content-Length: %s\r\n" ..
					"Content-Type: %s charset=utf-8\r\n" ..
					"\r\n%s",
					response.content:len(),
                    response.mime,
					response.content
				))
                sock:close()
			end
			return
		end
	end
end

function parseHttp(data)
	local head, body = string.match(data, "(..-)\r\n\r\n(.*)")
	if not (head and body) then
		return nil
	end
	local heads = m:split(head, "\r\n")
    local headers = {}
    for i, v in ipairs(heads) do
        if i > 1 then
            local name, value = string.match(v, "(..-): (.+)")
            headers[name] = value
        end
    end
	local rawMethod, rawPath, rawVersion = string.match(heads[1], "(..-) (..-) (.+)")
	return {
		method = rawMethod,
		path = rawPath,
        headers = headers,
		version = rawVersion,
        body = body
	}
end


function HttpRequest:new(method, path, content)
	local o = {
        method = method,
        path = path,
        content = content
	}
	m:apply(HttpRequest, o)
    return o;
end

-- Parses the content's body as JSON and returns it as an equivalent Lua object
function HttpRequest:getJson()
    local json, err = m:fromJson(self.content)
    if err == nil then
        return json
    end
    return nil
end
