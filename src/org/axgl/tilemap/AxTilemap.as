package org.axgl.tilemap {
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	
	import org.axgl.Ax;
	import org.axgl.AxEntity;
	import org.axgl.AxModel;
	import org.axgl.AxPoint;
	import org.axgl.AxRect;
	import org.axgl.AxU;
	import org.axgl.util.AxCache;
	import org.axgl.util.AxProfiler;

	/**
	 * A tilemap class representing a set of tiles. A tilemap is much more much more efficient representation of a large
	 * number of objects. Building a level is possible using a large number of AxSprites, but both drawing and colliding
	 * against a tilemap is many times faster. Each tilemap has to be made up of tiles of a single image. Note that the
	 * tiles in the tilemap are 1-based indexed; an index of 0 means no tile. Also, while tilemaps can be scaled for drawing,
	 * their scale will not affect overlapping and collision.
	 */
	public class AxTilemap extends AxModel {
		private static const INDEX_SET_LENGTH:uint = 6;
		private static const VERTEX_SET_LENGTH:uint = 16;
		
		/**
		 * The index of the first collideable tile in the tilemap. All tiles with an index below this will, by default,
		 * not be solid. This allows you to easily mass define a set of non-solid tiles by making them the first set of
		 * tiles in the tileset, and setting the collisionIndex to the first solid tile.
		 * 
		 * @default 1 
		 */
		public var solidIndex:uint;

		/**
		 * The width of each tile in the tilemap.
		 */
		protected var tileWidth:uint;
		/**
		 * The height of each tile in the tilemap.
		 */
		protected var tileHeight:uint;
		/**
		 * The number of rows in the tiles image.
		 */
		protected var tileRows:uint;
		/**
		 * The number of columns in the tiles image.
		 */
		protected var tileCols:uint;
		/**
		 * The number of rows in the map.
		 */
		protected var rows:uint;
		/**
		 * The number of columns in the map.
		 */
		protected var cols:uint;
		/**
		 * The list of tiles, one for each type of tile in the tiles image.
		 */
		protected var tiles:Vector.<AxTile>;
		/**
		 * The list of tiles in the map. Each one is an index into the tiles vector. 
		 */
		protected var data:Vector.<uint>;
		/**
		 * The offset into the buffers where this tile location maps to.
		 */
		protected var bufferOffsets:Vector.<int>;
		/**
		 * The number of sets of quad data stored in the buffers.
		 */
		protected var bufferSize:uint;
		/**
		 * The width of the uv box for each tile.
		 */
		protected var uvWidth:Number;
		/**
		 * The height of the uv box for each tile.
		 */
		protected var uvHeight:Number;
		/**
		 * Whether or not the buffers have changed and must be reuploaded.
		 */
		protected var dirty:Boolean;

		/**
		 * The frame used to calculate collisions against other objects.
		 */
		protected var frame:AxRect;
		
		/**
		 * ID marking a path node as unvisited.
		 */
		protected static const PATH_NONE:uint = 0;
		/**
		 * ID marking a path node as in the open list.
		 */
		protected static const PATH_OPEN:uint = 1;
		/**
		 * ID marking a path node as in the closed list.
		 */
		protected static const PATH_CLOSED:uint = 2;
		protected static const PATH_ADJACENT_LENGTH:uint = 10;
		protected static const PATH_DIAGONAL_LENGTH:uint = 14;
		/**
		 * List of distances for pathfinding.
		 */
		protected var pathDistances:Vector.<uint>;
		/**
		 * List of distances to the target for pathfinding.
		 */
		protected var pathTargetDistances:Vector.<uint>;
		/**
		 * List of list ids for pathfinding.
		 */
		protected var pathVisited:Vector.<uint>;
		/**
		 * List of parents for pathfinding.
		 */
		protected var pathParents:Vector.<uint>;

		/**
		 * Creates a new tilemap at the location specified.
		 * 
		 * @param x The x-coordinate of the tilemap.
		 * @param y The y-coordinate of the tilemap.
		 *
		 */
		public function AxTilemap(x:Number = 0, y:Number = 0) {
			super(x, y, VERTEX_SHADER, FRAGMENT_SHADER, 4);
			frame = new AxRect;
			bufferSize = 0;
			dirty = false;
		}

		/**
		 * Builds the tilemap from the data and tileset you pass.
		 * 
		 * @param mapString The comma separated list of tiles in the tilemap.
		 * @param graphic The tileset graphic.
		 * @param tileWidth The width of each tile in the tileset graphic.
		 * @param tileHeight The height of each tile in the tileset graphic.
		 * @param collisionIndex The index of the first solid tile.
		 *
		 * @return The tilemap object.
		 */
		public function build(mapString:String, graphic:Class, tileWidth:uint, tileHeight:uint, solidIndex:uint = 1):AxTilemap {
			this.texture = AxCache.texture(graphic);
			this.tileWidth = tileWidth;
			this.tileHeight = tileHeight;
			this.solidIndex = solidIndex;

			this.tileCols = Math.floor(texture.rawWidth / tileWidth);
			this.tileRows = Math.floor(texture.rawHeight / tileHeight);
			this.tiles = new Vector.<AxTile>;
			this.data = new Vector.<uint>;
			this.bufferOffsets = new Vector.<int>;
			
			this.uvWidth = 1 / (texture.width / tileWidth);
			this.uvHeight = 1 / (texture.height / tileWidth);

			indexData = new Vector.<uint>;
			vertexData = new Vector.<Number>;

			var rowArray:Array = mapString.split("\n");
			var index:uint = 0;
			
			rows = rowArray.length;
			for (var y:uint = 0; y < rows; y++) {
				var row:Array = rowArray[y].split(",");
				cols = Math.max(cols, row.length);
				for (var x:uint = 0; x < cols; x++) {
					var tid:uint = row[x];
					if (tid == 0) {
						data.push(0);
						bufferOffsets.push(-1);
						continue;
					}
					
					data.push(tid);
					bufferOffsets.push(bufferSize++);
					tid -= 1;
					
					var tx:uint = x * tileWidth;
					var ty:uint = y * tileHeight;
					var u:Number = (tid % tileCols) * uvWidth;
					var v:Number = Math.floor(tid / tileCols) * uvHeight;
					
					indexData.push(index, index + 1, index + 2, index + 1, index + 2, index + 3);
					vertexData.push(
						tx, 				ty,					u,				v,
						tx + tileWidth,		ty,					u + uvWidth,	v,
						tx,					ty + tileHeight,	u,				v + uvHeight,
						tx + tileWidth,		ty + tileHeight,	u + uvWidth,	v + uvHeight
					);
					index += 4;
				}
			}

			width = cols * tileWidth;
			height = rows * tileHeight;

			tiles.push(null);
			for (index = 1; index <= tileCols * tileRows; index++) { 
				var tile:AxTile = new AxTile(this, index, tileWidth, tileHeight);
				tile.collision = index >= solidIndex ? ANY : NONE;
				tiles.push(tile);
			}
			
			dirty = true;
			return this;
		}
		
		private function upload():void {
			var vertexLength:uint = vertexData.length / shader.rowSize;
			indexBuffer = Ax.context.createIndexBuffer(indexData.length);
			indexBuffer.uploadFromVector(indexData, 0, indexData.length);
			vertexBuffer = Ax.context.createVertexBuffer(vertexLength, shader.rowSize);
			vertexBuffer.uploadFromVector(vertexData, 0, vertexLength);
			triangles = indexData.length / 3;
			dirty = false;
		}

		override public function draw():void {
			if (dirty) {
				upload();
			}
			
			matrix.identity();
			matrix.appendScale(scale.x, scale.y, 1);
			matrix.appendTranslation(Math.round(x - Ax.camera.position.x * scroll.x + AxU.EPSILON), Math.round(y - Ax.camera.position.y * scroll.x + AxU.EPSILON), 0);
			matrix.append(zooms ? Ax.camera.projection : Ax.camera.baseProjection);
			
			colorTransform[RED] = color.red;
			colorTransform[GREEN] = color.green;
			colorTransform[BLUE] = color.blue;
			colorTransform[ALPHA] = color.alpha;

			if (shader != Ax.shader) {
				Ax.context.setProgram(shader.program);
				Ax.shader = shader;
			}
			
			Ax.context.setTextureAt(0, texture.texture);
			Ax.context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			Ax.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);
			Ax.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, colorTransform);
			Ax.context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.drawTriangles(indexBuffer, 0, triangles);
			
			if (countTris) {
				Ax.debugger.tris += triangles;
			}
		}

		/**
		 * Overlaps a single entity against this tilemap and executes the passed callback on the other entity and the
		 * colliding tile if they overlap. The tile is passed as the first argument while the object is passed as the
		 * second.
		 * 
		 * @param target The object to overlap.
		 * @param callback The callback to execute upon overlap.
		 *
		 * @return Whether or not an overlap occured.
		 */
		public function overlap(target:AxEntity, callback:Function = null, collide:Boolean = false):Boolean {
			var tdx:Number = target.x - target.previous.x;
			var tdy:Number = target.y - target.previous.y;
			frame.x = (target.x < target.previous.x ? target.x : target.previous.x);
			frame.y = (target.y < target.previous.y ? target.y : target.previous.y);
			frame.width = (AxU.abs(tdx) + target.width);
			frame.height = (AxU.abs(tdy) + target.height);

			var sx:int = Math.floor((frame.x - this.x) / tileWidth);
			var sy:int = Math.floor((frame.y - this.y) / tileHeight);
			var ex:int = Math.floor((frame.x + frame.width - this.x - AxU.EPSILON) / tileWidth);
			var ey:int = Math.floor((frame.y + frame.height - this.y - AxU.EPSILON) / tileHeight);

			if (sx < 0) {
				sx = 0;
			}
			if (sy < 0) {
				sy = 0;
			}
			if (ex > cols - 1) {
				ex = cols - 1;
			}
			if (ey > rows - 1) {
				ey = rows - 1;
			}

			var overlapped:Boolean = false;
			for (var x:uint = sx; x <= ex; x++) {
				for (var y:uint = sy; y <= ey; y++) {
					var tid:uint = data[y * cols + x];
					if (tid == 0) {
						continue;
					}

					var tile:AxTile = tiles[tid];
					if (tile == null) {
						continue;
					}

					tile.x = x * tileWidth + this.x;
					tile.y = y * tileHeight + this.y;
					tile.previous.x = tile.x;
					tile.previous.y = tile.y;
					
					if (collide) {
						if (tile.collision != NONE && callback != null) {
							if (callback(target, tile)) {
								overlapped = true;
							}
						}
					} else {
						overlapped = true;
					}
					
					if (tile.callback != null) {
						tile.callback(tile, target);
					}
				}
			}

			return overlapped;
		}

		/**
		 * Gets a tile object by its index into the tileset image. This tile represents the object for all
		 * tiles of that type in the tilemap, and changing it will affect all of them.
		 * 
		 * @param tileID The index of the tile in the tileset image.
		 *
		 * @return The tile object, null if it isn't part of the tileset.
		 */
		public function getTile(tileID:uint):AxTile {
			if (tileID < tiles.length) {
				return tiles[tileID];
			}
			return null;
		}

		/**
		 * Returns a set of tile objects. This is the same as the <code>tile</code> function, but takes in
		 * an array of tile ids, and returns each of the corresponding tiles in a vector, for ease of use.
		 * 
		 * @param tileIDs The array of tile ids to grab.
		 *
		 * @return A vector containing all the corresponding tiles.
		 */
		public function getTiles(tileIDs:Array):Vector.<AxTile> {
			var result:Vector.<AxTile> = new Vector.<AxTile>;
			for (var i:uint = 0; i < tileIDs.length; i++) {
				result.push(tiles[tileIDs[i]]);
			}
			return result;
		}
		
		/**
		 * Given a position on the map in tiles (0, 0 is the upper left), returns the AxTile representing
		 * the tile at that position. If there is no tile, returns null.
		 * 
		 * @param x The x coordinate in tiles.
		 * @param y The y coordinate in tiles.
		 * 
		 * @return The AxTile representing the tile at the position.
		 */
		public function getTileAt(x:uint, y:uint):AxTile {
			if (x < 0 || x >= cols || y < 0 || y > rows) {
				throw new Error("Tile location (" + x + "," + y + ") is out of bounds");
			}
			return tiles[data[y * cols + x]];
		}
		
		/**
		 * Given a pixel position, returns the AxTile representing the tile at that position. If your
		 * tiles are 16x16, then calling this with 20, 20 is identical to calling getTileAt(1, 1).
		 * 
		 * @param x The x coordinate in pixels.
		 * @param y The y coordinate in pixels.
		 * 
		 * @return The AxTile representing the tile at the position.
		 */
		public function getTileAtPixelCoordinates(x:uint, y:uint):AxTile {
			return getTileAt(x / tileWidth, y / tileHeight);
		}
		
		
		/**
		 * Given a location, changes the tile to the passed tile index.
		 * 
		 * @param x The x coordinate in tiles.
		 * @param y The y coordinate in tiles.
		 * @param index The index of the tile to change to.
		 */
		public function setTileAt(x:uint, y:uint, index:uint):void {
			if (index == 0) {
				removeTileAt(x, y);
				return;
			}
			
			var offset:uint = y * cols + x;
			index--;
			
			var bufferOffset:int = bufferOffsets[y * cols + x];
			var u:Number = (index % tileCols) * uvWidth;
			var v:Number = Math.floor(index / tileCols) * uvHeight;
			
			if (bufferOffset == -1) {
				data[offset] = index;
				bufferOffsets[offset] = bufferSize++;
				
				var tx:uint = x * tileWidth;
				var ty:uint = y * tileHeight;
				
				var idx:uint = vertexData.length / 4;
				indexData.push(idx, idx + 1, idx + 2, idx + 1, idx + 2, idx + 3);
				vertexData.push(
					tx, 				ty,					u,				v,
					tx + tileWidth,		ty,					u + uvWidth,	v,
					tx,					ty + tileHeight,	u,				v + uvHeight,
					tx + tileWidth,		ty + tileHeight,	u + uvWidth,	v + uvHeight
				);
			} else {
				vertexData[bufferOffset * VERTEX_SET_LENGTH + 2]  = u;
				vertexData[bufferOffset * VERTEX_SET_LENGTH + 3]  = v;
				vertexData[bufferOffset * VERTEX_SET_LENGTH + 6]  = u + uvWidth;
				vertexData[bufferOffset * VERTEX_SET_LENGTH + 7]  = v;
				vertexData[bufferOffset * VERTEX_SET_LENGTH + 10] = u;
				vertexData[bufferOffset * VERTEX_SET_LENGTH + 11] = v + uvHeight;
				vertexData[bufferOffset * VERTEX_SET_LENGTH + 14] = u + uvWidth;
				vertexData[bufferOffset * VERTEX_SET_LENGTH + 15] = v + uvHeight;
			}
			
			dirty = true;
		}
		
		/**
		 * Given a coordinate on the map, completely removes the tile.
		 * Note: It's more efficient to change the tile to a non-solid transparent tile if possible.
		 * 
		 * @param x The x coordinate in tiles.
		 * @param y The y coordinate in tiles.
		 *
		 */
		public function removeTileAt(x:uint, y:uint):void {
			var index:uint = y * cols + x;
			var bufferOffset:int = bufferOffsets[index];
			if (bufferOffset == -1) {
				return;
			}
			vertexData.splice(bufferOffset * VERTEX_SET_LENGTH, VERTEX_SET_LENGTH);
			indexData.splice(bufferOffset * INDEX_SET_LENGTH, INDEX_SET_LENGTH);
			for (var i:uint = 0; i < bufferOffsets.length; i++) {
				if (bufferOffsets[i] > bufferOffset) {
					bufferOffsets[i] = bufferOffsets[i] == -1 ? -1 : bufferOffsets[i] - 1;
				}
			}
			for (i = bufferOffset * INDEX_SET_LENGTH; i < indexData.length; i++) {
				indexData[i] -= 4;
			}
			bufferOffsets[index] = -1;
			data[index] = 0;
			bufferSize--;
			dirty = true;
		}
		
		/**
		 * Warning, this implementation is incomplete and is thus set to private. Use at your own risk.
		 */
		public function findPath(sourceX:uint, sourceY:uint, targetX:uint, targetY:uint):AxPath {
			var calls:uint = 0;
			var sourceTileX:uint = sourceX / tileWidth;
			var sourceTileY:uint = sourceY / tileHeight;
			var targetTileX:uint = targetX / tileWidth;
			var targetTileY:uint = targetY / tileHeight;
			var sourceIndex:uint = sourceTileY * cols + sourceTileX;
			var targetIndex:uint = targetTileY * cols + targetTileX;
			
			var numTiles:uint = cols * rows;
			pathDistances = new Vector.<uint>(numTiles);
			pathTargetDistances = new Vector.<uint>(numTiles);
			pathVisited = new Vector.<uint>(numTiles);
			pathParents = new Vector.<uint>(numTiles);
			
			var queue:Vector.<uint> = new Vector.<uint>;
			queue.push(sourceIndex);
			
			var current:uint, currentIndex:uint, currentDistance:uint, distance:uint;
			var up:int, down:int, right:int, left:int;
			var tx:uint, ty:uint;
			var i:uint;
			var goalFound:Boolean = false;
			while (queue.length > 0) {
				currentDistance = uint.MAX_VALUE;
				for (i = 0; i < queue.length; i++) {
					if (pathTargetDistances[queue[i]] < currentDistance) {
						currentIndex = i;
						currentDistance = pathTargetDistances[queue[i]];
					}
				}
				
				current = queue[currentIndex];
				queue.splice(currentIndex, 1);
				if (current == targetIndex) {
					goalFound = true;
					break;
				}
				
				up = current - cols;
				down = current + cols;
				right = current + 1;
				left = current - 1;
				
				if (up > 0 && pathVisited[up] == 0) {calls++;
					handlePathNode(queue, up, current, targetTileX, targetTileY);
				}
				if (down < numTiles && pathVisited[down] == 0) {calls++;
					handlePathNode(queue, down, current, targetTileX, targetTileY);
				}
				if (current % cols > 0 && pathVisited[left] == 0) {calls++;
					handlePathNode(queue, left, current, targetTileX, targetTileY);
				}
				if (current % cols < cols - 1 && pathVisited[right] == 0) {calls++;
					handlePathNode(queue, right, current, targetTileX, targetTileY);
				}
				
				pathVisited[current] = PATH_CLOSED;
			}
			
			if (!goalFound) {
				return null;
			}
			
			var path:AxPath = new AxPath;
			var node:uint = targetIndex;
			while (node != sourceIndex) {
				path.push(node % cols, Math.floor(node / cols));
				node = pathParents[node];
			}
			path.push(node % cols, Math.floor(node / cols));
			return path;
		}
		
		/**
		 * Warning, this implementation is incomplete and is thus set to private. Use at your own risk.
		 */
		protected function handlePathNode(queue:Vector.<uint>, index:uint, current:uint, targetTileX:uint, targetTileY:uint):void {
			if (tiles[data[index]] != null && tiles[data[index]].collision != NONE) {
				return;
			}
			
			var tx:uint = index / cols;
			var ty:uint = index % cols;
			var distanceFromSource:uint = pathDistances[current] + PATH_ADJACENT_LENGTH;
			var distanceToTarget:uint = pathDistances[index] + AxU.abs(tx - targetTileX) + AxU.abs(ty - targetTileY);
			if (pathVisited[index] == PATH_NONE || distanceFromSource < pathDistances[index]) {
				pathDistances[index] = distanceFromSource;
				pathTargetDistances[index] = distanceToTarget;
				pathParents[index] = current;
				if (pathVisited[index] == PATH_NONE) {
					queue.push(index);
					pathVisited[index] = PATH_OPEN;
				}
			}
		}
		
		/**
		 * The vertex shader for drawing tilemaps. 
		 */
		private static const VERTEX_SHADER:Array = [
			// va0 = [x, y, , ]
			// va1 = [u, v, , ]
			// vc0 = transform matrix
			"mov v1, va1",			// move uv to fragment shader
			"m44 op, va0, vc0"		// multiply position by transform matrix 
		];
		
		/**
		 * The fragment shader for drawing tilemaps.
		 */
		private static const FRAGMENT_SHADER:Array = [
			// ft0 = tilemap texture
			// v1  = uv
			// fs0 = something
			// fc0 = color
			"tex ft0, v1, fs0 <2d,nearest,mipnone>",	// sample texture
			"mul oc, fc0, ft0",							// multiply by color+alpha
		];
	}
}
