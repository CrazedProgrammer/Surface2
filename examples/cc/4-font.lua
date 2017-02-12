-- Loads Surface 2.
-- Change this path to wherever the Surface 2 file is.
local surface = dofile("Surface2/target/surface") 

-- Loads the font image, change path if needed.
local image = surface.load("Surface2/examples/cc/font.nfp")

-- Loads the font from the image surface.
local font = surface.loadFont(image)

-- Creates a new black surface with a size of 102x57 pixels (2 times wider and 3 times higher than the screen).
local surf = surface.create(102, 57, colors.black)

-- Draws the text "Hello from Surface 2!".
surf:drawText("Hello from Surface 2!", font, 3, 5, colors.orange)

-- Calculates the width and height of the text "This text is centered.".
local w, h = surface.getTextSize("This is centered.", font)

-- Draws the text centered.
surf:drawText("This is centered.", font, math.floor(surf.width / 2 - w / 2), math.floor(surf.height / 2 - h / 2), colors.blue)

-- Creates the screen surface.
local screen = surface.create(51, 19)

-- Draws the surface onto the screen surface with teletext characters.
screen:drawSurfaceSmall(surf, 0, 0)

-- Outputs the screen surface to the screen.
screen:output()

-- Waits for a mouse click.
os.pullEvent("mouse_click")
