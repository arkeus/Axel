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