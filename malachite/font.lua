local m = Malachite

local Font = {}
m.Font = Font

function Font:new(img)
	local o = {
		i = img,
		map = {}
	}
	m:apply(Font, o)
	function addChar(c, x, y)
		local w = 1
		for ox = 1, 8 do
			local found = false
			for oy = 0, 7 do
				if o.i:getPixel(x + ox, y + oy) >= 0x01000000 then
					found = true
					break
				end
			end
			if found == false then
				break
			end
			w = ox + 1
		end
		local i = image.new(w, 8)
		i:drawImage(o.i, -x, -y)
		o.map[c] = {x = x, y = y, w = w, i = i}
	end
	function addChars(s, x, y)
		for i = 1, #s do
			local c = s:sub(i, i)
			addChar(c, x + (i - 1) * 8, y)
		end
	end
	addChars("ABCDEFGHIJKLMNOPQRSTUVWXYZ", 0, 0)
	addChars("abcdefghijklmnopqrstuvwxyz", 0, 8)
	addChars("0123456789", 0, 16)
	addChars(".,;:'\"?!/\\|()[]{}<>", 0, 24)
	addChars("@#$%^&+-*=_", 0, 32)
	o.map[" "] = {x = -1, y = -1, w = 4, i = image.new(4, 8)}

	return o
end

function Font:getWidth(s)
	local width = 0
	for i = 1, #s do
		local c = s:sub(i, i)
		local ch = self:getCharacter(c)
		width = width + ch.w
	end
	return width
end

function Font:getCharacter(c)
	local v = self.map[c]
	if v ~= nil then
		return v
	end
	return self:getCharacter("A")
end

function Font:getImage(out, s)
	local width = self:getWidth(s)
	local x = 0
	local painter = image.newPainter(out)
	painter:setFill(true)
	painter:setFillColor(0xffff00ff)
	for i = 1, #s do
		local c = s:sub(i, i)
		local ch = self:getCharacter(c)
		painter:drawMask(ch.i, x, 0)
		x = x + ch.w
	end
	return out
end
