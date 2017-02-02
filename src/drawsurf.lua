function surf:drawSurface(surf2, x, y, width, height, sx, sy, swidth, sheight)
	x, y, width, height, sx, sy, swidth, sheight = x + self.ox, y + self.oy, width or surf2.width, height or surf2.height, sx or 0, sy or 0, swidth or surf2.width, sheight or surf2.height

	if width == swidth and height == sheight then
		local nx, ny
		nx, ny, width, height = clipRect(x, y, width, height, self.cx, self.cy, self.cwidth, self.cheight)
		swidth, sheight = width, height
		if nx > x then
			sx = sx + nx - x
			x = nx
		end
		if ny > y then
			sy = sy + ny - y
			y = ny
		end
		nx, ny, swidth, sheight = clipRect(sx, sy, swidth, sheight, 0, 0, surf2.width, surf2.height)
		width, height = swidth, sheight
		if nx > sx then
			x = x + nx - sx
			sx = nx
		end
		if ny > sy then
			y = y + ny - sy
			sy = ny
		end

		local b, t, c
		for j = 0, height - 1 do
			for i = 0, width - 1 do
				b = surf2.buffer[((j + sy) * surf2.width + i + sx) * 3 + 1]
				t = surf2.buffer[((j + sy) * surf2.width + i + sx) * 3 + 2]
				c = surf2.buffer[((j + sy) * surf2.width + i + sx) * 3 + 3]
				if b or self.overwrite then
					self.buffer[((j + y) * self.width + i + x) * 3 + 1] = b
				end
				if t or self.overwrite then
					self.buffer[((j + y) * self.width + i + x) * 3 + 2] = t
				end
				if c or self.overwrite then
					self.buffer[((j + y) * self.width + i + x) * 3 + 3] = c
				end
			end
		end
	else
		local hmirror, vmirror = false, false
		if width < 0 then
			hmirror = true
			x = x + width
		end
		if height < 0 then
			vmirror = true
			y = y + height
		end
		if swidth < 0 then
			hmirror = not hmirror
			sx = sx + swidth
		end
		if sheight < 0 then
			vmirror = not vmirror
			sy = sy + sheight
		end
		width, height, swidth, sheight = math.abs(width), math.abs(height), math.abs(swidth), math.abs(sheight)
		
		local xscale, yscale, px, py, ssx, ssy, b, t, c = swidth / width, sheight / height
		for j = 0, height - 1 do
			for i = 0, width - 1 do
				px, py = math_floor((i + 0.5) * xscale), math_floor((j + 0.5) * yscale) 
				if hmirror then
					ssx = x + width - i - 1
				else
					ssx = i + x
				end
				if vmirror then
					ssy = y + height - j - 1
				else
					ssy = j + y
				end

				if ssx >= self.cx and ssx < self.cx + self.cwidth and ssy >= self.cy and ssy < self.cy + self.cheight and px >= 0 and px < surf2.width and py >= 0 and py < surf2.height then
					b = surf2.buffer[(py * surf2.width + px) * 3 + 1]
					t = surf2.buffer[(py * surf2.width + px) * 3 + 2]
					c = surf2.buffer[(py * surf2.width + px) * 3 + 3]
					if b or self.overwrite then
						self.buffer[(ssy * self.width + ssx) * 3 + 1] = b
					end
					if t or self.overwrite then
						self.buffer[(ssy * self.width + ssx) * 3 + 2] = t
					end
					if c or self.overwrite then
						self.buffer[(ssy * self.width + ssx) * 3 + 3] = c
					end
				end
			end
		end
	end
end

function surf:drawSurfaceRotated(surf2, x, y, ox, oy, angle)
	local sin, cos, sx, sy, px, py = math.sin(angle), math.cos(angle)
	for j = math.floor(-surf2.height * 0.75), math.ceil(surf2.height * 0.75) do
		for i = math.floor(-surf2.width * 0.75), math.ceil(surf2.width * 0.75) do
			sx, sy, px, py = x + i, y + j, math_floor(cos * (i + 0.5) - sin * (j + 0.5) + ox), math_floor(sin * (i + 0.5) + cos * (j + 0.5) + oy)
			if sx >= self.cx and sx < self.cx + self.cwidth and sy >= self.cy and sy < self.cy + self.cheight and px >= 0 and px < surf2.width and py >= 0 and py < surf2.height then
				b = surf2.buffer[(py * surf2.width + px) * 3 + 1]
				t = surf2.buffer[(py * surf2.width + px) * 3 + 2]
				c = surf2.buffer[(py * surf2.width + px) * 3 + 3]
				if b or self.overwrite then
					self.buffer[(sy * self.width + sx) * 3 + 1] = b
				end
				if t or self.overwrite then
					self.buffer[(sy * self.width + sx) * 3 + 2] = t
				end
				if c or self.overwrite then
					self.buffer[(sy * self.width + sx) * 3 + 3] = c
				end
			end
		end
	end
end

function surf:drawSurfacesInterlaced(surfs, x, y, step)
	x, y, step = x + self.ox, y + self.oy, step or 0
	local width, height = surfs[1].width, surfs[1].height
	for i = 2, #surfs do
		if surfs[i].width ~= width or surfs[i].height ~= height then
			error("surfaces should be the same size")
		end
	end
	
	local sx, sy, swidth, sheight, index, b, t, c = clipRect(x, y, width, height, self.cx, self.cy, self.cwidth, self.cheight)
	for j = sy, sy + sheight - 1 do
		for i = sx, sx + swidth - 1 do
			index = (i + j + step) % #surfs + 1
			b = surfs[index].buffer[((j - sy) * surfs[index].width + i - sx) * 3 + 1]
			t = surfs[index].buffer[((j - sy) * surfs[index].width + i - sx) * 3 + 2]
			c = surfs[index].buffer[((j - sy) * surfs[index].width + i - sx) * 3 + 3]
			if b or self.overwrite then
				self.buffer[(j * self.width + i) * 3 + 1] = b
			end
			if t or self.overwrite then
				self.buffer[(j * self.width + i) * 3 + 2] = t
			end
			if c or self.overwrite then
				self.buffer[(j * self.width + i) * 3 + 3] = c
			end
		end
	end
end

function surf:drawSurfaceSmall(surf2, x, y)
	x, y = x + self.ox, y + self.oy
	if surf2.width % 2 ~= 0 or surf2.height % 3 ~= 0 then
		error("surface width must be a multiple of 2 and surface height a multiple of 3")
	end

	local sub, char, c1, c2, c3, c4, c5, c6 = 32768
	for j = 0, surf2.height / 3 - 1 do
		for i = 0, surf2.width / 2 - 1 do
			if i + x >= self.cx and i + x < self.cx + self.cwidth and j + y >= self.cy and j + y < self.cy + self.cheight then
				char, c1, c2, c3, c4, c5, c6 = 0,
				surf2.buffer[((j * 3) * surf2.width + i * 2) * 3 + 1],
				surf2.buffer[((j * 3) * surf2.width + i * 2 + 1) * 3 + 1],
				surf2.buffer[((j * 3 + 1) * surf2.width + i * 2) * 3 + 1],
				surf2.buffer[((j * 3 + 1) * surf2.width + i * 2 + 1) * 3 + 1],
				surf2.buffer[((j * 3 + 2) * surf2.width + i * 2) * 3 + 1],
				surf2.buffer[((j * 3 + 2) * surf2.width + i * 2 + 1) * 3 + 1]
				if c1 ~= c6 then
	                sub = c1
	                char = 1
	            end
	            if c2 ~= c6 then
	                sub = c2
	                char = char + 2
	            end
	            if c3 ~= c6 then
	                sub = c3
	                char = char + 4
	            end
	            if c4 ~= c6 then
	                sub = c4
	                char = char + 8
	            end
	            if c5 ~= c6 then
	                sub = c5
	                char = char + 16
	            end
	            self.buffer[((j + y) * self.width + i + x) * 3 + 1] = c6
	            self.buffer[((j + y) * self.width + i + x) * 3 + 2] = sub
	            self.buffer[((j + y) * self.width + i + x) * 3 + 3] = _chars[128 + char]
			end
		end
	end
end