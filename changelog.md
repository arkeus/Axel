## 0.9.2 / 2012-06-30
* You can now dynamically change tiles in a tilemap dynamically via AxTilemap.setTileAt()
* You can now remove a tile in a tilemap via AxTilemap.removeTileAt()
* You can now get the AxTile at a map coordinate using AxTilemap.getTileAt(x, y)
* You can similar get the tile via pixel coordinates using AxTilemap.getTileAtPixelCoordinates(x, y)
* The index property of AxTiles is now public
* AxTilemap.tile() has been renamed AxTilemap.getTile()
* AxTilemap.tiles() has been renamed AxTilemap.getTiles()
* Tilemaps are now affected by scale (but scale will not affect collision/overlap, it is only for drawing)
* Ax.as's private properties are now protected, for easier extending
* Flipping sprites should now flip the graphic correctly, regardless of offsets
* Zooming should now display consistently at zoom levels greater than 1
* Zooming is now required to be at integer levels
* You can now enable/disable a fixed timestep using Ax.fixedTimestep
* You can access the size of the visible viewport via Ax.viewWidth and Ax.viewHeight
* Drawing is now aligned on pixel levels, pre-zooming
* Overlapping between sprites, groups, and clouds should work correctly, but Ax.overlap is still the preferred method
* Hovering should work correctly on AxButtons that set their scroll factor to something other than 1 now
* Button labels will now inherit the scroll factor of the button they are on
* A bug has been fixed in AxGrid that prevented multiple sprites from overlapping in the same frame
* Fixed a bug in AxColor when dealing with opaque colors that caused issues with the alpha
* Shaders will no longer be changed for each object if it uses the same shader to improve performance
* Added some minor error checking for parameters
* Removed certain book spoilers from comments
* Fixed erroneous comments
* AxSprite's dispose will now call its parent
* Fix crash when not putting a label on an AxButton (via rogerbraun)
* Don't ignore requested width and height (via rogerbraun)
* Don't draw a sprite if scale is set to zero (via rogerbraun)

## 0.9.1b / 2012-04-16
* AxColor.toHex() is now a getter, available via AxColor.hex (and works correctly now)
* You can now set a color by doing color.hex = 0xAARRGGBB rather than always constructing one via AxColor.fromHex
* AxFonts loaded from fonts now correctly default to white and can be color shifted via .color and @[] tags
* The main heartbeat function is now delayed for 1 second to help prevent crashes on OSX debugger player using air 3.2+
* The debugger heartbeat function no longer changes text when not active
* Opening the debugger now triggers its heartbeat immediately.
* Clouds and groups can now disable counting their updates/draws towards the debugger count
* The debugger no longer counts towards its own stats

## 0.9.1a / 2012-04-15
* You can now overlap and collide against AxClouds
* AxU now has a randf function to give a random floating point Number between its parameters
* Fixed a bug where popping a state during execution of that state could result in a crash
* Fixed a bug where AxSprites were only scaling in the y direction when in an AxGroup
* Fixed a bug where AxSprites in an AxCloud were being offset by their pivot
* AxSprites now use origin to determine the origin of scaling, rather than pivot, except when flipped (at which point it will use the center)

## 0.9.1 / 2012-04-14
* AxCloud is a new class that acts like an AxGroup, but batches all sprites into a single draw call
* The parameter ordering has changed for the main super() call, initial state now comes before width and height
* You can now not pass width and height (or pass them as 0) in order to indicate the game size should be determined by the size of the stage
* You should no longer instantiate your state when calling super in your main class, you should now pass the class instead
* AxEntity.systemUpdate() has been removed and resides in AxEntity.update(), this means you now MUST call super.update() (reason: performance)
* Tilemaps now use their x and y property to determine where to draw them and how to collide
* Tilemaps now use the colorTransform vector, and respond to the color/alpha methods to change their color and alpha values
* In AxTilemap, tile() has been renamed getTile() and tileset() has been renamed getTiles()
* You can now call frame() on a particle effect to set it to use a random particle from a sprite sheet, rather than the full spritesheet
* You can now set scroll.x and scroll.y on an AxParticleEffect
* When a state is popped it is now disposed of automatically, and is no longer returned
* Tilemaps widths are now based on the max number of tiles in any row, rather than the last row
* Tile callbacks are now called when overlapping or colliding with tilemaps, regardless of the solidness of the tile
* You no longer collide on the right with something you are standing next to when colliding against a tilemap
* Sprites without animations being disposed will no longer crash the application
* Colors now have a toHex() function to get their representation as a uint
* AxColor.fromHex now only supports 0xAARRGGBB
* You can now access the public color property of any model (sprite, tilemap, text, particle cloud)
* The components of AxColor have been expanded to their full name (r -> red for example)
* AxEntity.terminal is now AxEntity.maxVelocity
* Fixed and added missing documentation

## 0.9.0 / 2012-03-31
* Initial release