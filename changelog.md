## 0.9.3 / 2013-??-??
* AxTilemaps are now split into segments, and you should be able to create arbitrarily big tilemaps now
* Added a flash() camera effect (implemented using the fade effect)
* The create() method of your main state is now called before your first state is initialized
* Camera effect offset should is now stored separately from position
* AxClouds are now properly effected by the scroll attribute
* Added a second optional parameter to AxGroup.add to allow you not to inherit the scroll factor
* General logger added, you can now log to Ax.logger.log/warn/error which will log to browser console in addition to trace, when available
* The default background color is now gray rather than white
* Added a reset method to AxCache
* Fixed an issue where the shake screen effect was being affected by the scroll attribute
* Fixed an issue where scaled sprites could be rendering 1 pixel off
* Fixed an issue where the screen attribute of an AxSprite wasn't set until the first update after creation
* Fixed an issue where removing an entity that doesn't belong to an AxGroup was incorrect
* Fixed an issue where setTile wouldn't update the tiles array when changing an existing tile
* Fixed an issue where fps was greater than requested fps in the debugger display (cosmetic change)
* Fixed an issue where the external logger could prevent the game from loading
* Made the fade effect more accurate

## 0.9.3 beta / 2012-01-22
* Entities now have a simple parenting system. When adding to groups, its parent will be set and position based off of the parent
* To support parenting, entities now have setParent and removeParent functionality (note: collision does not support parent offsets yet)
* Positions on entities with parents are now relative to the parent, to support this, globalX and globalY setters have been added to AxEntity
* When the game loses focus it now switched to a default pause screen. This can be changed via Ax.pauseState
* You can now define a callback for animations that is called when (and every time) the animation completes
* AxClouds now update their position based on acceleration, velocity, and drag, affecting all children positions
* Simple animation set has been added to AxSprite, accessible via addEffect() and clearEffects()
* AxSprites now implement the following effects:
** sprite.startFlicker() and sprite.stopFlicker()
** sprite.fadeIn() and sprite.fadeOut()
** sprite.grow() for scaling up and down over time
* AxClouds now have freeze() and unfreeze() methods to alias settings actions to NONE and ALL, respectively
* AxClouds and AxGroups now have a clear() method that will clear the group of all members, optionally disposing them 
* AxEntitys now have a revive() function that mirrors the destroy() functionality by setting exists to true
* AxParallaxSprite is a new type of sprite that repeats itself as it scrolls with the camera, useful for parallax backgrounds
* You can now set the blend mode of AxSprites, AxTexts, and AxClouds using the blend property
* All entities now have an addTimer functionality for creating events that are delayed, or events that repeat every X seconds
* You can now set the scroll on an AxGroup and have it affect all entities current and future (with some caveats, see documentation)
* Added helper functions noScroll() to AxGroup and AxModel to cover the common use case of setting scroll.x and scroll.y to 0
* AxStates now include an onPause() and onResume() that fire when they lose/gain focus from adding/popping states
* AxEntity now have a stop() function that sets horizontal, vertical, and angular components of velocity to 0
* When setting a color using @[] notation in AxText, you can use html codes as rrggbb or aarrggbb (eg. @[ff0000] instead of @[255,0,0] for red)
* You can now pass a vertical offset for the label when calling text() on an AxButton
* You can now set the offset property of the camera to offset the camera by a fixed amount
* The camera now has the following effects available:
** Ax.camera.shake - shakes the camera
** Ax.camera.fade/fadeOut/fadeIn - fades the camera in/out to a color
* AxGroup constructor no longer takes a width and height
* The debugger menu now displays the size of the state stack in brackets on the bottom right
* Fixed an issue with AxSprite when you do not load a resource
* Fixed an issue where the center of sprites were not being updated if you moved manually rather than using velocity
* Fixed an issue where screen coordinates were incorrect at non-default scroll values
* Fixed incorrect positions of AxText objects with scale != 1 when alignment was "center" or "right"
* Fixed an issue with AxText not properly getting width and height set
* Fixed an issue where the screen coordinates of the mouse weren't correctly taking into account the zoom level
* Fixed an issue where releaseAll on an input would cause everything to be justReleased rather than resetting the input
* Fixed an AxText width issue where the width is equal to the greatest width since creation
* Fixed an issue where destroy events on sounds/music were attached to the wrong object
* Fixed an issue where the sounds group would never be cleaned up, using unnecessary memory
* Fixed an issue where the centers of objects weren't being updated for stationary objects
* Fixed an issue where the center of an object recently affected by a world bound check would be incorrect

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