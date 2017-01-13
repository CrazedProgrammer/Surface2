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

local function calcStack(stack, width, height)
	local sx, sy, cx, cy, cwidth, cheight = 0, 0, 0, 0, width, height
	for i = 1, #stack do
		if stack[i].shift then
			sx = sx + stack[i].x
			sy = sy + stack[i].y
		end
		cx = cx + stack[i].x
		cy = cy + stack[i].y
		cwidth = stack[i].width
		cheight = stack[i].height
	end
	return sx, sy, cx, cy, cwidth, cheight
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
	surface.sx, surface.sy, surface.cx, surface.cy, surface.cwidth, surface.cheight = calcStack(surface.stack)
	
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

function surf:output(display, x, y, ox, oy, owidth, oheight)
	display = display or (term or gpu)
	if love then display = display or love.graphics end
	x = x or 0
	y = y or 0
	ox = ox or 0
	oy = oy or 0
	owidth = owidth or self.width
	oheight = oheight or self.height
	ox, oy, owidth, oheight = clipRect(ox, oy, owidth, oheight, 0, 0, self.width, self.height)
	
	local buffer = self.buffer

	if display.blit and display.setCursorPos then
		-- CC
		

	elseif display.write and display.setCursorPos and display.setTextColor and display.setBackgroundColor then
		-- CC old
	
	elseif display.drawPixel then
		-- Riko 4
	
	elseif display.points and display.setColor then
		-- Love2D
	
	else
		error("unsupported display object")
	end
end

end
return surface