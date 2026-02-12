I want to refactor Rectangle so that its fields are named left_x, right_x, top_y, and bottom_y instead of x, y, width, and height.
This will necessitate changing all the getRect functions that construct Rectangles vas well as all the code that accesses Rectangle fields (e.g. `intersect`).

Finally, refactor the code so that Rectangle is named BoundingBox instead. Functions called getRect should be renamed to getBox.
