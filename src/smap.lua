local smap = { }
surface.smap = smap 

function surface.loadSpriteMap(surf, spwidth, spheight, sprites)
	if surf.width % spwidth ~= 0 or surf.height % spheight ~= 0 then
		error("sprite width/height does not match smap width/height")
	end

	local smap = setmetatable({ }, {__index = surface.smap})
	smap.surf = surf
	smap.spwidth = spwidth
	smap.spheight = spheight
	smap.sprites = sprites or ((surf.width / spwidth) * (surf.height / spheight))
	smap.perline = surf.width / spwidth

	return smap
end

function smap:pos(index, scale)
	if index < 0 or index >= self.sprites then
		error("sprite index out of bounds")
	end

	return (index % self.perline) * self.spwidth, math.floor(index / self.perline) * self.spheight
end

function smap:sprite(index, x, y, width, height)
	local sx, sy = self:pos(index)
	return self.surf, x, y, width or self.spwidth, height or self.spheight, sx, sy, self.spwidth, self.spheight
end