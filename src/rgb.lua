surface.palette = { }
surface.palette.cc = {[1]="F0F0F0",[2]="F2B233",[4]="E57FD8",[8]="99B2F2",[16]="DEDE6C",[32]="7FCC19",[64]="F2B2CC",[128]="4C4C4C",[256]="999999",[512]="4C99B2",[1024]="B266E5",[2048]="3366CC",[4096]="7F664C",[8192]="57A64E",[16384]="CC4C4C",[32768]="191919"}
surface.palette.riko4 = {"181818","1D2B52","7E2553","008651","AB5136","5F564F","7D7F82","FF004C","FFA300","FFF023","00E755","29ADFF","82769C","FF77A9","FECCA9","ECECEC"}

local function setPalette(palette)
	if palette == _palette then return end
	_palette = palette
	_rgbpal, _palr, _palg, _palb = { }, { }, { }, { }

	local indices = { }
	for k, v in pairs(_palette) do
		if type(v) == "string" then
			_palr[k] = tonumber(v:sub(1, 2), 16) / 255
			_palg[k] = tonumber(v:sub(3, 4), 16) / 255
			_palb[k] = tonumber(v:sub(5, 6), 16) / 255
		elseif type(v) == "number" then
			_palr[k] = math.floor(v / 65536) / 255
			_palg[k] = (math.floor(v / 256) % 256) / 255
			_palb[k] = (v % 256) / 255
		end
		indices[#indices + 1] = k
	end

	local pr, pg, pb, dist, d, id
	for i = 0, _steps - 1 do
		for j = 0, _steps - 1 do
			for k = 0, _steps - 1 do
				pr = (i + 0.5) / _steps
				pg = (j + 0.5) / _steps
				pb = (k + 0.5) / _steps

				dist = 1e10
				for l = 1, #indices do
					d = (pr - _palr[indices[l]]) ^ 2 + (pg - _palg[indices[l]]) ^ 2 + (pb - _palb[indices[l]]) ^ 2
					if d < dist then
						dist = d
						id = l
					end
				end
				_rgbpal[i * _steps * _steps + j * _steps + k + 1] = indices[id]
			end
		end
	end
end



function surf:toRGB(palette)
	setPalette(palette)
	local c
	for j = 0, self.height - 1 do
		for i = 0, self.width - 1 do
			c = self.buffer[(j * self.width + i) * 3 + 1] 
			self.buffer[(j * self.width + i) * 3 + 1] = _palr[c]
			self.buffer[(j * self.width + i) * 3 + 2] = _palg[c]
			self.buffer[(j * self.width + i) * 3 + 3] = _palb[c]
		end
	end
end

function surf:toPalette(palette, dither)
	setPalette(palette)
	local scale, r, g, b, nr, ng, nb, c, dr, dg, db = _steps - 1
	for j = 0, self.height - 1 do
		for i = 0, self.width - 1 do
			r = self.buffer[(j * self.width + i) * 3 + 1]
			g = self.buffer[(j * self.width + i) * 3 + 2]
			b = self.buffer[(j * self.width + i) * 3 + 3]
			r = (r > 1) and 1 or r
			r = (r < 0) and 0 or r
			g = (g > 1) and 1 or g
			g = (g < 0) and 0 or g
			b = (b > 1) and 1 or b
			b = (b < 0) and 0 or b
			
			nr = (r == 1) and scale or math_floor(r * _steps)
			ng = (g == 1) and scale or math_floor(g * _steps)
			nb = (b == 1) and scale or math_floor(b * _steps)
			c = _rgbpal[nr * _steps * _steps + ng * _steps + nb + 1]
			if dither then
				dr = (r - _palr[c]) / 16
				dg = (g - _palg[c]) / 16
				db = (b - _palb[c]) / 16

				if i < self.width - 1 then
					self.buffer[(j * self.width + i + 1) * 3 + 1] = self.buffer[(j * self.width + i + 1) * 3 + 1] + dr * 7
					self.buffer[(j * self.width + i + 1) * 3 + 2] = self.buffer[(j * self.width + i + 1) * 3 + 2] + dg * 7
					self.buffer[(j * self.width + i + 1) * 3 + 3] = self.buffer[(j * self.width + i + 1) * 3 + 3] + db * 7
				end
				if j < self.height - 1 then
					if i > 0 then
						self.buffer[((j + 1) * self.width + i - 1) * 3 + 1] = self.buffer[((j + 1) * self.width + i - 1) * 3 + 1] + dr * 3
						self.buffer[((j + 1) * self.width + i - 1) * 3 + 2] = self.buffer[((j + 1) * self.width + i - 1) * 3 + 2] + dg * 3
						self.buffer[((j + 1) * self.width + i - 1) * 3 + 3] = self.buffer[((j + 1) * self.width + i - 1) * 3 + 3] + db * 3
					end
					self.buffer[((j + 1) * self.width + i) * 3 + 1] = self.buffer[((j + 1) * self.width + i) * 3 + 1] + dr * 5
					self.buffer[((j + 1) * self.width + i) * 3 + 2] = self.buffer[((j + 1) * self.width + i) * 3 + 2] + dg * 5
					self.buffer[((j + 1) * self.width + i) * 3 + 3] = self.buffer[((j + 1) * self.width + i) * 3 + 3] + db * 5
					if i < self.width - 1 then
						self.buffer[((j + 1) * self.width + i + 1) * 3 + 1] = self.buffer[((j + 1) * self.width + i + 1) * 3 + 1] + dr * 1
						self.buffer[((j + 1) * self.width + i + 1) * 3 + 2] = self.buffer[((j + 1) * self.width + i + 1) * 3 + 2] + dg * 1
						self.buffer[((j + 1) * self.width + i + 1) * 3 + 3] = self.buffer[((j + 1) * self.width + i + 1) * 3 + 3] + db * 1
					end
				end
			end
			self.buffer[(j * self.width + i) * 3 + 1] = c
			self.buffer[(j * self.width + i) * 3 + 2] = nil
			self.buffer[(j * self.width + i) * 3 + 3] = nil
		end
	end
end