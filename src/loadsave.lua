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
		if data:byte(#data) == 10 then
			height = height - 1
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
				buffer[(y * width + x) * 3 + 2] = t
				if b or t then
					buffer[(y * width + x) * 3 + 3] = data:sub(index, index)
				elseif data:sub(index, index) ~= " " then
					buffer[(y * width + x) * 3 + 3] = data:sub(index, index)
				end
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
		if data:byte(#data) == 10 then
			height = height - 1
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

function surf:save(file, format)
	format = format or "nfp"
	local data = { }
	if format == "nfp" then
		for j = 0, self.height - 1 do
			for i = 0, self.width - 1 do
				data[#data + 1] = _cc_color_to_hex[self.buffer[(j * self.width + i) * 3 + 1]] or " "
			end
			data[#data + 1] = "\n"
		end

	elseif format == "nft" then
		for j = 0, self.height - 1 do
			local b, t, pb, pt
			for i = 0, self.width - 1 do
				pb = self.buffer[(j * self.width + i) * 3 + 1]
				pt = self.buffer[(j * self.width + i) * 3 + 2]
				if pb ~= b then
					data[#data + 1] = "\30"..(_cc_color_to_hex[pb] or " ")
					b = pb
				end
				if pt ~= t then
					data[#data + 1] = "\31"..(_cc_color_to_hex[pt] or " ")
					t = pt
				end
				data[#data + 1] = self.buffer[(j * self.width + i) * 3 + 3] or " "
			end
			data[#data + 1] = "\n"
		end

	elseif format == "rif" then
		data[1] = "RIF"
		data[2] = string.char(math_floor(self.width / 256), self.width % 256)
		data[3] = string.char(math_floor(self.height / 256), self.height % 256)
		local byte, upper, c = 0, false
		for j = 0, self.width - 1 do
			for i = 0, self.height - 1 do
				c = self.buffer[(j * self.width + i) * 3 + 1] or 0
				if not upper then
					byte = c * 16
				else
					byte = byte + c
					data[#data + 1] = string.char(byte)
				end
				upper = not upper
			end
		end
		if upper then
			data[#data + 1] = string.char(byte)
		end

	elseif format == "bmp" then
		data[1] = "BM"
		data[2] = string.char(0, 0, 0, 0) -- file size, change later
		data[3] = string.char(0, 0, 0, 0, 0x36, 0, 0, 0, 0x28, 0, 0, 0) 
		data[4] = string.char(self.width % 256, math_floor(self.width / 256), 0, 0)
		data[5] = string.char(self.height % 256, math_floor(self.height / 256), 0, 0)
		data[6] = string.char(1, 0, 0x18, 0, 0, 0, 0, 0)
		data[7] = string.char(0, 0, 0, 0) -- pixel data size, change later
		data[8] = string.char(0x13, 0x0B, 0, 0, 0x13, 0x0B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

		local padchars = math.ceil((self.width * 3) / 4) * 4 - self.width * 3
		for j = 0, self.height - 1 do
			for i = 0, self.width - 1 do
				data[#data + 1] = string.char((self.buffer[(j * self.width + i) * 3 + 1] or 0) * 255)
				data[#data + 1] = string.char((self.buffer[(j * self.width + i) * 3 + 2] or 0) * 255)
				data[#data + 1] = string.char((self.buffer[(j * self.width + i) * 3 + 3] or 0) * 255)
			end
			data[#data + 1] = ("\0"):rep(padchars)
		end
		local size = #table_concat(data)
		data[2] = string.char(size % 256, math_floor(size / 256) % 256, math_floor(size / 65536), 0)
		size = size - 54
		data[7] = string.char(size % 256, math_floor(size / 256) % 256, math_floor(size / 65536), 0)
		 
	else
		error("format not supported")
	end

	data = table_concat(data)
	if file then
		local handle = io.open(file, "wb")
		for i = 1, #data do
			handle:write(data:byte(i))
		end
		handle:close()
	end
	return data
end