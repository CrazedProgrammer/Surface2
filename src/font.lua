function surface.loadFont(surf)
	local font = {width = surf.width, height = surf.height - 1}
	font.buffer =  { }
	font.indices = {0}
	font.widths = { }

	local startc, hitc, curc = surf.buffer[((surf.height - 1) * surf.width) * 3 + 1]
	for i = 0, surf.width - 1 do
		curc = surf.buffer[((surf.height - 1) * surf.width + i) * 3 + 1]
		if curc ~= startc then
			hitc = curc
			break
		end
	end

	for j = 0, surf.height - 2 do
		for i = 0, surf.width - 1 do
			font.buffer[j * font.width + i + 1] = surf.buffer[(j * surf.width + i) * 3 + 1] == hitc
		end
	end

	local curchar = 1
	for i = 0, surf.width - 1 do
		if surf.buffer[((surf.height - 1) * surf.width + i) * 3 + 1] == hitc then 
			font.widths[curchar] = i - font.indices[curchar]
			curchar = curchar + 1
			font.indices[curchar] = i + 1
		end
	end
	font.widths[curchar] = font.width - font.indices[curchar] + 1

	return font
end

function surface.getTextSize(str, font)
	local cx, cy, maxx = 0, 0, 0
	local ox, char = cx

	for i = 1, #str do
		char = str:byte(i) - 31

		if char + 31 == 10 then -- newline
			cx = ox
			cy = cy + font.height + 1
		elseif font.indices[char] then
			cx = cx + font.widths[char] + 1
		else
			cx = cx + font.widths[1]
		end
		if cx > maxx then
			maxx = cx
		end
	end

	return maxx - 1, cy + font.height
end

function surf:drawText(x, y, str, font, b, t, c)
	local cx, cy = x + self.ox, y + self.oy
	local ox, char, idx = cx

	for i = 1, #str do
		char = str:byte(i) - 31

		if char + 31 == 10 then -- newline
			cx = ox
			cy = cy + font.height + 1
		elseif font.indices[char] then
			for i = 0, font.widths[char] - 1 do
				for j = 0, font.height - 1 do
					x, y = cx + i, cy + j
					if font.buffer[j * font.width + i + font.indices[char] + 1] then
						if x >= self.cx and x < self.cx + self.cwidth and y >= self.cy and y < self.cy + self.cheight then
							idx = (y * self.width + x) * 3
							if b or self.overwrite then
								self.buffer[idx + 1] = b
							end
							if t or self.overwrite then
								self.buffer[idx + 2] = t
							end
							if c or self.overwrite then
								self.buffer[idx + 3] = c
							end
						end
					end
				end
			end
			cx = cx + font.widths[char] + 1
		else
			cx = cx + font.widths[1]
		end
	end
end