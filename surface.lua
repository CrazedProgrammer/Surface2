--[[
Surface version 2.0.0

The MIT License (MIT)
Copyright (c) 2016 CrazedProgrammer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

local surface = { }
do

local surf = { }
surface.surf = surf

local table_concat, math_floor = table.concat, math.floor

local _cc_color_to_hex, _cc_hex_to_color = { }, { }
for i = 0, 15 do
	_cc_color_to_hex[2 ^ i] = string.format("%01x", i)
	_cc_hex_to_color[string.format("%01x", i)] = 2 ^ i
end

local _chars = { }
for i = 0, 255 do
	_chars[i] = string.char(i)
end


local function calcStack(stack, width, height)
	local ox, oy, cx, cy, cwidth, cheight = 0, 0, 0, 0, width, height
	for i = 1, #stack do
		if stack[i].shift then
			ox = ox + stack[i].x
			oy = oy + stack[i].y
		end
		cx = cx + stack[i].x
		cy = cy + stack[i].y
		cwidth = stack[i].width
		cheight = stack[i].height
	end
	return ox, oy, cx, cy, cwidth, cheight
end

local function clipRect(x, y, width, height, cx, cy, cwidth, cheight)
	if x < cx then
		width = width + x - cx
		x = cx
	end
	if y < cy then
		height = height + y - cy
		y = cy
	end
	if x + width > cx + cwidth then
		width = cwidth + cx - x
	end
	if y + height > cy + cheight then
		height = cheight + cy - y
	end
	return x, y, width, height
end



function surface.create(width, height, b, t, c)
	local surface = setmetatable({ }, {__index = surface.surf})
	surface.width = width
	surface.height = height
	surface.buffer = { }
	surface.overwrite = false
	surface.stack = { }
	surface.ox, surface.oy, surface.cx, surface.cy, surface.cwidth, surface.cheight = calcStack(surface.stack, width, height)
	
	-- force array indeces instead of hashed indeces
	local buffer = surface.buffer
	for i = 1, width * height * 3, 3 do
		buffer[i] = b or false
		buffer[i + 1] = t or false
		buffer[i + 2] = c or false
	end
	buffer[width * height * 3 + 1] = false
	if not b then
		for i = 1, width * height * 3, 3 do
			buffer[i] = b
		end
	end
	if not c then
		for i = 2, width * height * 3, 3 do
			buffer[i] = c
		end
	end
	if not t then
		for i = 3, width * height * 3, 3 do
			buffer[i] = t
		end
	end
	
	return surface
end

function surface.load(strpath, isstr)
	local data = strpath
	if not isstr then
		local handle = io.open(strpath, "rb")
		if not handle then return end
		chars = { }
		local byte = handle:read(1)
		while byte do
			chars[#chars + 1] = _chars[byte]
			byte = handle:read(1)
		end
		handle:close()
		data = table_concat(chars)
	end
	
	if data:sub(1, 3) == "RIF" then
		-- Riko 4 image format
		local width, height = data:byte(4) * 256 + data:byte(5), data:byte(6) * 256 + data:byte(7)
		local surf = surface.create(width, height)
		local buffer = surf.buffer
		local upper, byte = 8, false
		local byte = data:byte(index)

		for j = 0, height - 1 do
			for i = 0, height - 1 do
				if not upper then
					buffer[(j * width + i) * 3 + 1] = math_floor(byte / 16)
				else
					buffer[(j * width + i) * 3 + 1] = byte % 16
					index = index + 1
					data = data:byte(index)
				end
				upper = not upper
			end
		end
		return surf

	elseif data:sub(1, 2) == "BM" then
		-- BMP format
		local width = data:byte(0x13) + data:byte(0x14) * 256
		local height = data:byte(0x17) + data:byte(0x18) * 256
		if data:byte(0xF) ~= 0x28 or data:byte(0x1B) ~= 1 or data:byte(0x1D) ~= 0x18 then
			error("unsupported bmp format, only uncompressed 24-bit rgb is supported.")
		end
		local offset, linesize = 0x36, math.ceil((width * 3) / 4) * 4
		
		local surf = surface.create(width, height)
		local buffer = surf.buffer
		for j = 0, height - 1 do
			for i = 0, width - 1 do
				buffer[(j * width + i) * 3 + 1] = data:byte((height - j - 1) * linesize + i * 3 + offset + 3) / 255
				buffer[(j * width + i) * 3 + 2] = data:byte((height - j - 1) * linesize + i * 3 + offset + 2) / 255
				buffer[(j * width + i) * 3 + 3] = data:byte((height - j - 1) * linesize + i * 3 + offset + 1) / 255
			end
		end
		return surf

	elseif data:find("\30") then
		-- NFT format
		local width, height, lwidth = 0, 1, 0
		for i = 1, #data do
			if data:byte(i) == 10 then -- newline
				height = height + 1
				if lwidth > width then
					width = lwidth
				end
				lwidth = 0
			elseif data:byte(i) == 30 or data:byte(i) == 31 then -- color control
				lwidth = lwidth - 1
			elseif data:byte(i) ~= 13 then -- not carriage return
				lwidth = lwidth + 1
			end
		end

		local surf = surface.create(width, height)
		local buffer = surf.buffer
		local index, x, y, b, t = 1, 0, 0

		while index <= #data do
			if data:byte(index) == 10 then
				x, y = 0, y + 1
			elseif data:byte(index) == 30 then
				index = index + 1
				b = _cc_hex_to_color[data:sub(index, index)]
			elseif data:byte(index) == 31 then
				index = index + 1
				t = _cc_hex_to_color[data:sub(index, index)]
			elseif data:byte(index) ~= 13 then
				buffer[(y * width + x) * 3 + 1] = b
				if b or t then
					buffer[(y * width + x) * 3 + 2] = data:sub(index, index)
				elseif data:sub(index, index) ~= " " then
					buffer[(y * width + x) * 3 + 2] = data:sub(index, index)
				end
				buffer[(y * width + x) * 3 + 3] = t
				x = x + 1
			end
			index = index + 1
		end

		return surf
	else
		-- NFP format
		local width, height, lwidth = 0, 1, 0
		for i = 1, #data do
			if data:byte(i) == 10 then -- newline
				height = height + 1
				if lwidth > width then
					width = lwidth
				end
				lwidth = 0
			elseif data:byte(i) ~= 13 then -- not carriage return
				lwidth = lwidth + 1
			end
		end

		local surf = surface.create(width, height)
		local buffer = surf.buffer
		local x, y = 0, 0
		for i = 1, #data do
			if data:byte(i) == 10 then
				x, y = 0, y + 1
			elseif data:byte(i) ~= 13 then
				buffer[(y * width + x) * 3 + 1] = _cc_hex_to_color[data:sub(i, i)]
				x = x + 1
			end
		end

		return surf
	end
end



function surf:output(output, x, y, sx, sy, swidth, sheight)
	output = output or (term or gpu)
	if love then output = output or love.graphics end
	x = x or 0
	y = y or 0
	sx = sx or 0
	sy = sy or 0
	swidth = swidth or self.width
	sheight = sheight or self.height
	sx, sy, swidth, sheight = clipRect(sx, sy, swidth, sheight, 0, 0, self.width, self.height)
	
	local buffer = self.buffer
	local bwidth = self.width

	if output.blit and output.setCursorPos then
		-- CC
		local dblit, dsetpos, cmd, str, text, back = output.blit, output.setCursorPos, { }, { }, { }, { }
		for j = 0, sheight - 1 do
			for i = 0, swidth - 1 do
				str[i + 1] = buffer[((j + sy) * bwidth + (i + sx)) * 3 + 2] or " "
				text[i + 1] = _cc_color_to_hex[buffer[((j + sy) * bwidth + (i + sx)) * 3 + 3] or 1]
				back[i + 1] = _cc_color_to_hex[buffer[((j + sy) * bwidth + (i + sx)) * 3 + 1]or 32768]
			end
			dsetpos(x + 1, y + j + 1)
			dblit(table_concat(str), table_concat(text), table_concat(back))
		end

	elseif output.write and output.setCursorPos and output.setTextColor and output.setBackgroundColor then
		-- CC old
	
	elseif output.blitPixels then
		-- Riko 4
		local pixels = { }
		for j = 0, sheight - 1 do
			for i = 0, swidth - 1 do
				pixels[j * swidth + i + 1] = buffer[((j + sy) * bwidth + (i + sx)) * 3 + 1] or 0
			end
		end
		output.blitPixels(x, y, swidth, sheight, pixels)
	
	elseif output.points and output.setColor then
		-- Love2D
		local pos, r, g, b, pr, pg, pb = { }
		for j = 0, sheight - 1 do
			for i = 0, swidth - 1 do
				pr = buffer[((j + sy) * bwidth + (i + sx)) * 3 + 1]
				pg = buffer[((j + sy) * bwidth + (i + sx)) * 3 + 2]
				pb = buffer[((j + sy) * bwidth + (i + sx)) * 3 + 3]
				if pr ~= r or pg ~= g or pb ~= b then 
					if #pos ~= 0 then
						output.setColor((r or 0) * 255, (g or 0) * 255, (b or 0) * 255, (r or g or b) and 255 or 0)
						output.points(pos)
					end
					r, g, b = pr, pg, pb
					pos = { }
				end
				pos[#pos + 1] = i + x
				pos[#pos + 1] = j + y
			end
		end
	
	else
		error("unsupported output object")
	end
end

function surf:drawString(x, y, str, b, t)
	x, y = x + self.ox, y + self.oy
	local sx = x
	for i = 1, #str do
		local c = str:sub(i, i)
		if c == "\n" then
			x = sx
			y = y + 1
		else
			if x >= self.cx  and x < self.cx + self.cwidth and y >= self.cy and y < self.cy + self.cheight then
				self.buffer[(y * self.width + x) * 3 + 2] = c
				self.buffer[(y * self.width + x) * 3 + 1] = b
				self.buffer[(y * self.width + x) * 3 + 3] = t
			end
			x = x + 1
		end
	end
end

end
return surface