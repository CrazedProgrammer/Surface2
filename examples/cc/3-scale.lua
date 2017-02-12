-- Loads Surface 2.
-- Change this path to wherever the Surface 2 file is.
local surface = dofile("Surface2/target/surface") 

-- Loads the image, change path if needed.
local image = surface.load("Surface2/examples/cc/crazed.nfp")

-- Creates a new black surface with a size of 102x57 pixels (2 times wider and 3 times higher than the screen).
local surf = surface.create(102, 57, colors.black)

-- Draws the image 4 times.
surf:drawSurface(image, 7, 11)
surf:drawSurface(image, 29, 11)
surf:drawSurface(image, 7, 32)
surf:drawSurface(image, 29, 32)

-- Draws the image twice as large.
surf:drawSurface(image, 62, 13, 32, 32)


-- Creates the screen surface.
local screen = surface.create(51, 19)

-- Draws the surface onto the screen surface with teletext characters.
screen:drawSurfaceSmall(surf, 0, 0)

-- Outputs the screen surface to the screen.
screen:output()

-- Waits for a mouse click.
os.pullEvent("mouse_click")
