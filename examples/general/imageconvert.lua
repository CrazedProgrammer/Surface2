-- Loads Surface 2.
-- Change this path to wherever the surface 2 file is.
local surface = dofile("Surface2/target/surface") 

-- Loads the font.nfp image.
local surf = surface.load("Surface2/examples/font.nfp")

-- Converts the surface to RGB.
surf:toRGB(surface.palette.cc)

-- Saves the surface to font.bmp
surf:save("Surface2/examples/font.bmp", "bmp")