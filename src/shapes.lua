function surf:drawLine(x1, y1, x2, y2, b, t, c)
	if x1 == x2 then
		x1, y1, x2, y2 = x1 + self.ox, y1 + self.oy, x2 + self.ox, y2 + self.oy
		if x1 < self.cx or x1 >= self.cx + self.cwidth then return end
		if y2 < y1 then
			local temp = y1
			y1 = y2
			y2 = temp
		end
		if y1 < self.cy then y1 = self.cy end
		if y2 >= self.cy + self.cheight then y2 = self.cy + self.cheight - 1 end
		if b or self.overwrite then
			for j = y1, y2 do
				self.buffer[(j * self.width + x1) * 3 + 1] = b
			end
		end
		if t or self.overwrite then
			for j = y1, y2 do
				self.buffer[(j * self.width + x1) * 3 + 2] = t
			end
		end
		if c or self.overwrite then
			for j = y1, y2 do
				self.buffer[(j * self.width + x1) * 3 + 3] = c
			end
		end
	elseif y1 == y2 then
		x1, y1, x2, y2 = x1 + self.ox, y1 + self.oy, x2 + self.ox, y2 + self.oy
		if y1 < self.cy or y1 >= self.cy + self.cheight then return end
		if x2 < x1 then
			local temp = x1
			x1 = x2
			x2 = temp
		end
		if x1 < self.cx then x1 = self.cx end
		if x2 >= self.cx + self.cwidth then x2 = self.cx + self.cwidth - 1 end
		if b or self.overwrite then
			for i = x1, x2 do
				self.buffer[(y1 * self.width + i) * 3 + 1] = b
			end
		end
		if t or self.overwrite then
			for i = x1, x2 do
				self.buffer[(y1 * self.width + i) * 3 + 2] = t
			end
		end
		if c or self.overwrite then
			for i = x1, x2 do
				self.buffer[(y1 * self.width + i) * 3 + 3] = c
			end
		end
	else
		local delta_x = x2 - x1
		local ix = delta_x > 0 and 1 or -1
		delta_x = 2 * math.abs(delta_x)
		local delta_y = y2 - y1
		local iy = delta_y > 0 and 1 or -1
		delta_y = 2 * math.abs(delta_y)
		self:drawPixel(x1, y1, b, t, c)
		if delta_x >= delta_y then
			local error = delta_y - delta_x / 2
			while x1 ~= x2 do
				if (error >= 0) and ((error ~= 0) or (ix > 0)) then
					error = error - delta_x
					y1 = y1 + iy
				end
				error = error + delta_y
				x1 = x1 + ix
				self:drawPixel(x1, y1, b, t, c)
			end
		else
			local error = delta_x - delta_y / 2
			while y1 ~= y2 do
				if (error >= 0) and ((error ~= 0) or (iy > 0)) then
					error = error - delta_y
					x1 = x1 + ix
				end
				error = error + delta_x
				y1 = y1 + iy
				self:drawPixel(x1, y1, b, t, c)
			end
		end
	end
end

function surf:drawRect(x, y, width, height, b, t, c)
	self:drawLine(x, y, x + width - 1, y, b, t, c)
	self:drawLine(x, y, x, y + height - 1, b, t, c)
	self:drawLine(x + width - 1, y, x + width - 1, y + height - 1, b, t, c)
	self:drawLine(x, y + height - 1, x + width - 1, y + height - 1, b, t, c)
end

function surf:fillRect(x, y, width, height, b, t, c)
	x, y, width, height = clipRect(x + self.ox, y + self.oy, width, height, self.cx, self.cy, self.cwidth, self.cheight)

	if b or self.overwrite then
		for j = 0, height - 1 do
			for i = 0, width - 1 do
				self.buffer[((j + y) * self.width + i + x) * 3 + 1] = b
			end
		end
	end
	if t or self.overwrite then
		for j = 0, height - 1 do
			for i = 0, width - 1 do
				self.buffer[((j + y) * self.width + i + x) * 3 + 2] = t
			end
		end
	end
	if c or self.overwrite then
		for j = 0, height - 1 do
			for i = 0, width - 1 do
				self.buffer[((j + y) * self.width + i + x) * 3 + 3] = c
			end
		end
	end
end

function surf:drawTriangle(x1, y1, x2, y2, x3, y3, b, t, c)
	self:drawLine(x1, y1, x2, y2, b, t, c)
	self:drawLine(x2, y2, x3, y3, b, t, c)
	self:drawLine(x3, y3, x1, y1, b, t, c)
end

function surf:fillTriangle(x1, y1, x2, y2, x3, y3, b, t, c)
	if y1 > y2 then
		local tempx, tempy = x1, y1
		x1, y1 = x2, y2
		x2, y2 = tempx, tempy
	end
	if y1 > y3 then
		local tempx, tempy = x1, y1
		x1, y1 = x3, y3
		x3, y3 = tempx, tempy
	end
	if y2 > y3 then
		local tempx, tempy = x2, y2
		x2, y2 = x3, y3
		x3, y3 = tempx, tempy
	end
	if y1 == y2 and x1 > x2 then
		local temp = x1
		x1 = x2
		x2 = temp
	end
	if y2 == y3 and x2 > x3 then
		local temp = x2
		x2 = x3
		x3 = temp
	end

	local x4, y4
	if x1 <= x2 then
		x4 = x1 + (y2 - y1) / (y3 - y1) * (x3 - x1)
		y4 = y2
		local tempx, tempy = x2, y2
		x2, y2 = x4, y4
		x4, y4 = tempx, tempy
	else
		x4 = x1 + (y2 - y1) / (y3 - y1) * (x3 - x1)
		y4 = y2
	end

	local finvslope1 = (x2 - x1) / (y2 - y1)
	local finvslope2 = (x4 - x1) / (y4 - y1)
	local linvslope1 = (x3 - x2) / (y3 - y2)
	local linvslope2 = (x3 - x4) / (y3 - y4)

	local xstart, xend, dxstart, dxend
	for y = math.ceil(y1 + 0.5) - 0.5, math.floor(y3 - 0.5) + 0.5, 1 do
		if y <= y2 then -- first half
			xstart = x1 + finvslope1 * (y - y1)
			xend = x1 + finvslope2 * (y - y1)
		else -- second half
			xstart = x3 - linvslope1 * (y3 - y)
			xend = x3 - linvslope2 * (y3 - y)
		end

		dxstart, dxend = math.ceil(xstart - 0.5), math.floor(xend - 0.5)
		if dxstart <= dxend then
			self:drawLine(dxstart, y - 0.5, dxend, y - 0.5, b, t, c)
		end
	end
end

function surf:drawEllipse(x, y, width, height, b, t, c)
	for i = 0, _eprc - 1 do
		self:drawLine(math_floor(x + _ecos[i + 1] * (width - 1) + 0.5), math_floor(y + _esin[i + 1] * (height - 1) + 0.5), math_floor(x + _ecos[(i + 1) % _eprc + 1] * (width - 1) + 0.5), math_floor(y + _esin[(i + 1) % _eprc + 1] * (height - 1) + 0.5), b, t, c)
	end
end

function surf:fillEllipse(x, y, width, height, b, t, c)
	x, y = x + self.ox, y + self.oy

	for j = 0, height - 1 do
		for i = 0, width - 1 do
			if ((i + 0.5) / width * 2 - 1) ^ 2 + ((j + 0.5) / height * 2 - 1) ^ 2 <= 1 then
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
	end
end

function surf:drawArc(x, y, width, height, fromangle, toangle, b, t, c)
	if fromangle > toangle then
		local temp = fromangle
		fromangle = toangle
		temp = toangle
	end
	fromangle = math_floor(fromangle / math.pi / 2 * _eprc + 0.5)
	toangle = math_floor(toangle / math.pi / 2 * _eprc + 0.5) - 1
	
	for j = fromangle, toangle do
		local i = j % _eprc
		self:drawLine(math_floor(x + _ecos[i + 1] * (width - 1) + 0.5), math_floor(y + _esin[i + 1] * (height - 1) + 0.5), math_floor(x + _ecos[(i + 1) % _eprc + 1] * (width - 1) + 0.5), math_floor(y + _esin[(i + 1) % _eprc + 1] * (height - 1) + 0.5), b, t, c)
	end
end

function surf:fillArc(x, y, width, height, fromangle, toangle, b, t, c)
	x, y = x + self.ox, y + self.oy

	if fromangle > toangle then
		local temp = fromangle
		fromangle = toangle
		temp = toangle
	end
	local diff = toangle - fromangle
	fromangle = fromangle % (math.pi * 2)

	local fx, fy, dir
	for j = 0, height - 1 do
		for i = 0, width - 1 do
			fx, fy = (i + 0.5) / width * 2 - 1, (j + 0.5) / height * 2 - 1
			dir = math_atan2(-fy, fx) % (math.pi * 2)
			if fx ^ 2 + fy ^ 2 <= 1 and ((dir >= fromangle and dir - fromangle <= diff) or (dir <= (fromangle + diff) % (math.pi * 2))) then
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
	end
end