-- Loads Surface 2.
-- Change this path to wherever the Surface 2 file is.
local surface = dofile("Surface2/target/surface") 

-- Creates a new surface with a blue background with a size of 51x19 pixels.
local surf = surface.create(51, 19, colors.blue)

-- Draws the string "Hello, world!" at position (2,2).
surf:drawString("Hello, world!", 2, 2)

-- Outputs the surface to the screen.
surf:output()

-- Waits for a mouse click.
os.pullEvent("mouse_click")
