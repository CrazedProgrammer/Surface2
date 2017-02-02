function surf:flip(horizontal, vertical)
	local ox, oy, nx, ny, tb, tt, tc
	if horizontal then
		for i = 0, math.ceil(self.cwidth / 2) - 1 do
			for j = 0, self.cheight - 1 do
				ox, oy, nx, ny = i + self.cx, j + self.cy, self.cx + self.cwidth - i - 1, j + self.cy
				tb = self.buffer[(oy * self.width + ox) * 3 + 1]
				tt = self.buffer[(oy * self.width + ox) * 3 + 2]
				tc = self.buffer[(oy * self.width + ox) * 3 + 3]
				self.buffer[(oy * self.width + ox) * 3 + 1] = self.buffer[(ny * self.width + nx) * 3 + 1]
				self.buffer[(oy * self.width + ox) * 3 + 2] = self.buffer[(ny * self.width + nx) * 3 + 2]
				self.buffer[(oy * self.width + ox) * 3 + 3] = self.buffer[(ny * self.width + nx) * 3 + 3]
				self.buffer[(ny * self.width + nx) * 3 + 1] = tb
				self.buffer[(ny * self.width + nx) * 3 + 2] = tt
				self.buffer[(ny * self.width + nx) * 3 + 3] = tc
			end
		end
	end
	if vertical then
		for j = 0, math.ceil(self.cheight / 2) - 1 do
			for i = 0, self.cwidth - 1 do
				ox, oy, nx, ny = i + self.cx, j + self.cy, i + self.cx, self.cy + self.cheight - j - 1
				tb = self.buffer[(oy * self.width + ox) * 3 + 1]
				tt = self.buffer[(oy * self.width + ox) * 3 + 2]
				tc = self.buffer[(oy * self.width + ox) * 3 + 3]
				self.buffer[(oy * self.width + ox) * 3 + 1] = self.buffer[(ny * self.width + nx) * 3 + 1]
				self.buffer[(oy * self.width + ox) * 3 + 2] = self.buffer[(ny * self.width + nx) * 3 + 2]
				self.buffer[(oy * self.width + ox) * 3 + 3] = self.buffer[(ny * self.width + nx) * 3 + 3]
				self.buffer[(ny * self.width + nx) * 3 + 1] = tb
				self.buffer[(ny * self.width + nx) * 3 + 2] = tt
				self.buffer[(ny * self.width + nx) * 3 + 3] = tc
			end
		end
	end
end

function surf:shift(x, y, b, t, c)
	local hdir, vdir = x < 0, y < 0
	local xstart, xend = self.cx, self.cx + self.cwidth - 1
	local ystart, yend = self.cy, self.cy + self.cheight - 1
	local nx, ny
	for j = vdir and ystart or yend, vdir and yend or ystart, vdir and 1 or -1 do
		for i = hdir and xstart or xend, hdir and xend or xstart, hdir and 1 or -1 do
			nx, ny = i - x, j - y
			if nx >= 0 and nx < self.width and ny >= 0 and ny < self.height then
				self.buffer[(j * self.width + i) * 3 + 1] = self.buffer[(ny * self.width + nx) * 3 + 1]
				self.buffer[(j * self.width + i) * 3 + 2] = self.buffer[(ny * self.width + nx) * 3 + 2]
				self.buffer[(j * self.width + i) * 3 + 3] = self.buffer[(ny * self.width + nx) * 3 + 3] 
			else
				self.buffer[(j * self.width + i) * 3 + 1] = b
				self.buffer[(j * self.width + i) * 3 + 2] = t
				self.buffer[(j * self.width + i) * 3 + 3] = c
			end
		end
	end
end

function surf:map(colors)
	local c
	for j = self.cy, self.cy + self.cheight - 1 do
		for i = self.cx, self.cx + self.cwidth - 1 do
			c = colors[self.buffer[(j * self.width + i) * 3 + 1]]
			if c or self.overwrite then
				self.buffer[(j * self.width + i) * 3 + 1] = c
			end
		end
	end
end