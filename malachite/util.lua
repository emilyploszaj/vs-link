local Stack = {
}

function Stack:new()
	local o = {
	}
	Malachite:apply(Stack, o)
    return o;
end

function Stack:push(value)
	self["obj"] = {
		prev = self.obj,
		value = value
	}
end

function Stack:pop()
	local value = self.obj.value
	self.obj = self.obj.prev
	return value
end

function Stack:peek()
	return self.obj.value
end

function Malachite:log(...)
	local out = ""
	for i = 1, select("#", ...) do
		out = out .. Malachite:toString(select(i, ...))
	end
	console:log(out)
end

function Malachite:copy(src)
	return Malachite:apply(src, {})
end

function Malachite:apply(src, dst)
	for k, v in pairs(src) do
		if type(v) ~= "table" then
			dst[k] = v
		else
			dst[k] = {}
			Malachite:apply(src[k], dst[k])
		end
	end
	return dst
end

function Malachite:toString(data)
	local function toStringInternal(data)
		if type(data) == "nil" then
			return "nil"
		elseif type(data) == "string" then
			return "\"" .. data .. "\""
		elseif type(data) == "boolean" or type(data) == "number" then
			return string.format("%s", data)
		elseif type(data) == "table" then
			if data[1] ~= nil then
				local ret = "["
				for _, v in ipairs(data) do
					if ret:len() ~= 1 then
						ret = ret .. ", "
					end
					ret = ret .. toStringInternal(v)
				end
				ret = ret .. "]"
				return ret
			else
				local ret = "{"
				for k, v in pairs(data) do
					if ret:len() ~= 1 then
						ret = ret .. ", "
					end
					ret = ret .. Malachite:toString(k) .. ": " .. toStringInternal(v)
				end
				ret = ret .. "}"
				return ret
			end
		elseif type(data) == "function" then
			return "function"
		else
			return "???"
		end
	end
	if type(data) == "string" then
		return data
	else
		return toStringInternal(data)
	end
end

function Malachite:toJson(data)
	if type(data) == "nil" then
		return "null"
	elseif type(data) == "string" then
		return "\"" .. data .. "\""
	elseif type(data) == "boolean" or type(data) == "number" then
		return string.format("%s", data)
	elseif type(data) == "table" then
		if data[1] ~= nil then
			local ret = "["
			for _, v in ipairs(data) do
				if ret:len() ~= 1 then
					ret = ret .. ","
				end
				ret = ret .. Malachite:toJson(v)
			end
			ret = ret .. "]"
			return ret
		else
			local ret = "{"
			for k, v in pairs(data) do
				local j = Malachite:toJson(v)
				if j ~= nil then
					if ret:len() ~= 1 then
						ret = ret .. ","
					end
					ret = ret .. string.format("\"%s\":%s", k, j)
				end
			end
			ret = ret .. "}"
			return ret
		end
	else
		return nil
	end
end

function Malachite:fromJson(data)
	-- 0 = value
	-- 1 = symbol
	-- 2 = string
	-- 3 = key
	-- 4 = obj comma
	-- 5 = array comma
	-- 6 = colon
	local buffer = ""
	local mode = 0
	local escaped = false
	local stringStart = false
	local stack = Stack:new()
	stack:push({
		context = 0,
		currentKey = "value",
		ret = {}
	})
	local function applyValue(value)
		local top = stack:peek()
		if top.context == 0 then -- obj
			top.ret[top.currentKey] = value
			top.currentKey = nil
			mode = 4
		elseif top.context == 1 then -- array
			table.insert(top.ret, value)
			mode = 5
		end
	end
	for c in data:gmatch(".") do
		if buffer == "" and c:match("[\\s ]") then
			goto continue
		end
		if mode == 1 then
			if c:match("[a-zA-Z0-9]") then
				buffer = buffer .. c
				goto continue
			else
				local val = ""
				if buffer == "null" then
					val = nil
				elseif buffer == "true" then
					val = true
				elseif buffer == "false" then
					val = false
				elseif buffer:match("[0-9]+") then
					val = tonumber(buffer)
				else
					return nil, "Unknown literal: " .. buffer
				end
				buffer = ""
				applyValue(val)
				-- parse next character
			end
		end
		if (mode == 0 or mode == 3 or mode == 4 or mode == 5) and (c == "]" or c == "}") then
			local top = stack:peek()
			if top.context == 0 and top.currentKey ~= nil then
				return nil, "Found closing bracket when searching for value"
			elseif (top.context == 0 and c == "]") or (top.context == 1 and c == "}") then
				return nil, "Wrong closing bracket used"
			else
				top = stack:pop()
				applyValue(top.ret)
				local c = stack:peek().context
				if c == 0 then
					mode = 4
				else
					mode = 5
				end
			end
			goto continue
		end
		if mode == 0 then
			if c == "{" then
				mode = 3
				stringStart = false
				stack:push({
					context = 0, -- obj
					ret = {}
				})
			elseif c == "[" then
				stack:push({
					context = 1, -- array
					ret = {}
				})
			elseif c == "\"" then
				mode = 2
				stringStart = true;
				goto continue
			else
				buffer = buffer .. c
				mode = 1
			end
		elseif mode == 2 or mode == 3 then -- string
			if stringStart ~= true then
				if c ~= "\"" then
					return nil, "Found " .. c .. " instead of \""
				end
				stringStart = true
			elseif c == "\"" and escaped == false then
				if mode == 2 then
					applyValue(buffer)
				else
					stack:peek().currentKey = buffer
					mode = 6
				end
				buffer = ""
			elseif c == "\\" and escaped == false then
				escaped = true
			else
				buffer = buffer .. c
				escaped = false
			end
		elseif mode == 4 or mode == 5 then
			if c == "," then
				if mode == 4 then
					mode = 3
					stringStart = false
				else
					mode = 0
				end
			else
				return nil, "Found " .. c .. " instead of ,"
			end
		elseif mode == 6 then
			if c == ":" then
				mode = 0
			else
				return nil, "Found " .. c .. " instead of :"
			end
		end
		::continue::
	end
	return stack:peek().ret.value, nil
end

function Malachite:split(str, delim)
	local v = {}
	while true do
		local start = string.find(str, delim)
		if start then
			table.insert(v, str:sub(0, start - 1))
			str = str:sub(start + string.len(delim))
		else
			break
		end
	end
	table.insert(v, str)
	return v
end
