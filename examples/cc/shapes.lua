-- Loads Surface 2.
-- Change this path to wherever the Surface 2 file is.
local surface = dofile("Surface2/target/surface") 

-- Creates a new blue surface with a size of 51x19 pixels.
local surf = surface.create(51, 19, colors.blue)

-- Draws a filled red rectangle with a pink # pattern.
surf:fillRect(3, 1, 20, 10, colors.red, colors.pink, "#")

-- Draws a green filled triangle, notice how it doesn't draw over the pink # pattern.
-- This is because every layer supports transparency, in this case the text colour 
-- and character are unspecified (nil) which means they are transparent.
surf:fillTriangle(30, 4, 12, 13, 34, 17, colors.green)

-- You can overwrite all layers by using surf.overwrite.
surf.overwrite = true
-- Draws an orange line from (1,15) to (19,2).
surf:drawLine(1, 15, 19, 2, colors.orange)
-- Sets overwrite back to false.
surf.overwrite = false

-- Draws an outline of an ellipse.
surf:drawEllipse(37, 2, 9, 6, colors.black)

-- Draws a pie (a part of an ellipse).
surf:fillArc(20, 3, 30, 15, -1, 0, colors.cyan)

-- Outputs the surface to the screen.
surf:output()

-- Waits for a mouse click.
os.pullEvent("mouse_click")
