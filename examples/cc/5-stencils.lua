-- Loads Surface 2.
-- Change this path to wherever the Surface 2 file is.
local surface = dofile("Surface2/target/surface") 

-- Creates a new blue surface with a size of 51x19 pixels.
local surf = surface.create(51, 19, colors.blue)

-- Pushes a stencil.
surf:push(2, 2, 15, 5)

-- Clears the area inside the stencil with the colour orange.
surf:clear(colors.orange)

-- Draws a string inside the stencil area, notice how the coordinates are offset.
-- and that the text gets cut off.
surf:drawString("Now look at this stencil", 1, 1)

-- Pops the stencil from the stencil stack, so now there are no more stencils on the stack.
surf:pop()

-- Pushes a stencil for the right half of the screen, but with the coordinates not offset.
surf:push(25, 0, 26, 19, true)

-- Draws an ellipse with the size of the entire screen, but half of the ellipse gets cut off.
surf:fillEllipse(0, 0, 51, 19, colors.red)

-- Pushes another stencil in the middle of the screen, notice how it respects the previous stencils' boundaries.
surf:push(15, 7, 20, 7)

-- Clears the area inside the stencil with green.
surf:clear(colors.green)

-- Draws the text, notice how it offsets coordinates and how it cuts off the text.
surf:drawString("Stencils are epic.", 1, 2)

-- Pops the two stencils.
surf:pop()
surf:pop()

-- Draws the surface to the screen.
surf:output()

-- Waits for a mouse click.
os.pullEvent("mouse_click")
