local sheet = { }
surface.sheet = sheet 

function surface.loadSheet(surf, spwidth, spheight, sprites)
	if surf.width % spwidth ~= 0 or surf.height % spheight ~= 0 then
		error("sprite width/height does not match sheet width/height")
	end

	local sheet = setmetatable({ }, {__index = surface.sheet})
	sheet.surf = surf
	sheet.spwidth = spwidth
	sheet.spheight = spheight
	sheet.sprites = sprites or ((surf.width / spwidth) * (surf.height / spheight))
	sheet.perline = surf.width / spwidth

	return sheet
end

function sheet:pos(index, scale)
	if index < 0 or index >= self.sprites then
		error("sprite index out of bounds")
	end

	return (index % self.perline) * self.spwidth, math.floor(index / self.perline) * self.spheight
end

function sheet:sprite(index, x, y, width, height)
	local sx, sy = self:pos(index)
	return self.surf, x, y, width or self.spwidth, height or self.spheight, sx, sy, self.spwidth, self.spheight
end