package org.axgl.tilemap {
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	
	import org.axgl.Ax;
	import org.axgl.AxEntity;
	import org.axgl.AxModel;
	import org.axgl.AxRect;
	import org.axgl.AxU;
	import org.axgl.util.AxCache;

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
		protected var tilesetRows:uint;
		/**
		 * The number of columns in the tiles image.
		 */
		protected var tilesetCols:uint;
		/**
		 * The segments that make up this tilemap.
		 */
		protected var segments:Vector.<AxTilemapSegment>;
		/**
		 * The width of each tilemap segment in tiles.
		 */
		protected var segmentWidth:int;
		/**
		 * The height of each tilemap segment in tiles.
		 */
		protected var segmentHeight:int;
		/**
		 * The number of columns of segments in this tilemap.
		 */
		protected var segmentCols:uint;
		/**
		 * The number of rows of segments in this tilemap;
		 */
		protected var segmentRows:uint;
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
		 * The width of the uv box for each tile.
		 */
		protected var uvWidth:Number;
		/**
		 * The height of the uv box for each tile.
		 */
		protected var uvHeight:Number;

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
		 */
		public function AxTilemap(x:Number = 0, y:Number = 0) {
			super(x, y, VERTEX_SHADER, FRAGMENT_SHADER, 4);
			frame = new AxRect;
		}

		/**
		 * Builds the tilemap from the data and tileset you pass.
		 * 
		 * @param mapString The comma separated list of tiles in the tilemap.
		 * @param graphic The tileset graphic.
		 * @param tileWidth The width of each tile in the tileset graphic.
		 * @param tileHeight The height of each tile in the tileset graphic.
		 * @param solidIndex The index of the first solid tile.
		 * @param segmentWidth The width of each tilemap segment, defaults to number of tiles that fit in Ax.viewWidth
		 * @param segmentWidth The height of each tilemap segment, defaults to number of tiles that fit in Ax.viewHeight
		 *
		 * @return The tilemap object.
		 */
		public function build(mapData:*, graphic:Class, tileWidth:uint, tileHeight:uint, solidIndex:uint = 1, segmentWidth:int = -1, segmentHeight:int = -1):AxTilemap {
			if (tileWidth == 0 || tileHeight == 0) {
				throw new Error("Tile size cannot be 0");
			} else if (segmentWidth == 0 || segmentHeight == 0) {
				throw new Error("Segment size cannot be 0");
			}
			
			setGraphic(graphic);
			this.tileWidth = tileWidth;
			this.tileHeight = tileHeight;
			this.solidIndex = solidIndex;

			this.tilesetCols = Math.floor(texture.rawWidth / tileWidth);
			this.tilesetRows = Math.floor(texture.rawHeight / tileHeight);
			this.tiles = new Vector.<AxTile>;
			this.data = new Vector.<uint>;
			
			var rowArray:Array = mapData is String ? parseMapString(mapData) : mapData;
			var x:uint, y:uint;
			
			this.rows = rowArray.length;
			this.cols = Math.max.apply(null, rowArray.map(function(item:String, i:int, a:Array):int { return item.split(",").length; }));
			
			var viewWidthInTiles:uint = Ax.viewWidth / tileWidth;
			var viewHeightInTiles:uint = Ax.viewHeight / tileHeight;
			// By default the segment size is the size of the map that fits on the screen at once, unless the size of the map is less than
			// 2 screens, in which it is the entire size of the map.
			this.segmentWidth = segmentWidth == -1 ? (cols < viewWidthInTiles * 2 ? cols : viewWidthInTiles) : segmentWidth;
			this.segmentHeight = segmentHeight == -1 ? (rows < viewHeightInTiles * 2 ? rows : viewHeightInTiles) : segmentHeight;
			this.segmentCols = Math.ceil(this.cols / this.segmentWidth);
			this.segmentRows = Math.ceil(this.rows / this.segmentHeight);
			this.segments = new Vector.<AxTilemapSegment>(this.segmentCols * this.segmentRows, true);
			
			for (y = 0; y < this.segmentRows; y++) {
				for (x = 0; x < this.segmentCols; x++) {
					var sw:uint = x == this.segmentCols - 1 && this.cols % this.segmentWidth != 0 ? this.cols % this.segmentWidth : this.segmentWidth;
					var sh:uint = y == this.segmentRows - 1 && this.rows % this.segmentHeight != 0 ? this.rows % this.segmentHeight : this.segmentHeight;
					this.segments[y * this.segmentCols + x] = new AxTilemapSegment(this, sw, sh);
				}
			}
			
			this.uvWidth = 1 / (texture.width / tileWidth);
			this.uvHeight = 1 / (texture.height / tileWidth);

			indexData = new Vector.<uint>;
			vertexData = new Vector.<Number>;
			
			for (y = 0; y < rows; y++) {
				var row:Array = rowArray[y];
				for (x = 0; x < cols; x++) {
					var segmentRow:uint = y / this.segmentHeight;
					var segmentCol:uint = x / this.segmentWidth;
					var segmentOffset:uint = segmentRow * segmentCols + segmentCol;
					var segment:AxTilemapSegment = this.segments[segmentOffset];
					
					var tid:uint = row[x];
					if (tid == 0) {
						data.push(0);
						segment.bufferOffsets.push(-1);
						continue;
					}
					
					data.push(tid);
					segment.bufferOffsets.push(segment.bufferSize++);
					tid -= 1;
					
					var tx:uint = x * tileWidth;
					var ty:uint = y * tileHeight;
					var u:Number = (tid % tilesetCols) * uvWidth;
					var v:Number = Math.floor(tid / tilesetCols) * uvHeight;
					
					segment.indexData.push(segment.index, segment.index + 1, segment.index + 2, segment.index + 1, segment.index + 2, segment.index + 3);
					segment.vertexData.push(
						tx, 				ty,					u,				v,
						tx + tileWidth,		ty,					u + uvWidth,	v,
						tx,					ty + tileHeight,	u,				v + uvHeight,
						tx + tileWidth,		ty + tileHeight,	u + uvWidth,	v + uvHeight
					);
					segment.index += 4;
				}
			}

			width = cols * tileWidth;
			height = rows * tileHeight;

			tiles.push(null);
			for (var i:uint = 1; i <= tilesetCols * tilesetRows; i++) { 
				var tile:AxTile = new AxTile(this, i, tileWidth, tileHeight);
				tile.collision = i >= solidIndex ? ANY : NONE;
				tiles.push(tile);
			}
			
			return this;
		}
		
		/**
		 * Changes the graphic of the tilemap to a new graphic. The new graphic should be the
		 * same dimensions with the same tile size as the previous graphic.
		 * 
		 * @param graphic The tileset graphic.
		 *
		 * @return The tilemap object.
		 */
		public function setGraphic(graphic:Class):AxTilemap {
			this.texture = AxCache.texture(graphic);
			return this;
		}
		
		/**
		 * Parse map data from string format to array format. The expected string format is that each tile
		 * is an integer tile id separated by commas, with each row separated by a newline.
		 * 
		 * @param mapString The map string.
		 * 
		 * @return The parsed map data as an array of arrays.
		 */
		private function parseMapString(mapString:String):Array {
			return mapString.split("\n").map(function(item:String, i:int, a:Array):Array { return item.split(","); });
		}

		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			matrix.identity();
			matrix.appendScale(scale.x, scale.y, 1);
			matrix.appendTranslation(Math.round(x - Ax.camera.position.x * scroll.x - Ax.camera.effectOffset.x + AxU.EPSILON), Math.round(y - Ax.camera.position.y * scroll.x - Ax.camera.effectOffset.y + AxU.EPSILON), 0);
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
			// Draw segments that are at least partially visible on the screen, with default segment size this will be a max of 4
			var minXSegment:int = Math.floor((Ax.camera.x - x) / tileWidth / segmentWidth);
			var maxXSegment:int = Math.floor((Ax.camera.x + Ax.viewWidth - x) / tileWidth / segmentWidth);
			var minYSegment:int = Math.floor((Ax.camera.y - y) / tileHeight / segmentHeight);
			var maxYSegment:int = Math.floor((Ax.camera.y + Ax.viewWidth - y) / tileHeight / segmentHeight);
			for (var sx:int = minXSegment; sx <= maxXSegment; sx++) {
				for (var sy:int = minYSegment; sy <= maxYSegment; sy++) {
					var si:int = sy * segmentCols + sx;
					if (si < 0 || si >= segments.length) {
						continue;
					}
					segments[si].draw();
					if (countTris) {
						Ax.debugger.tris += segments[si].triangles;
					}
				}
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

					var tx:Number = tile.x = x * tileWidth + this.x;
					var ty:Number = tile.y = y * tileHeight + this.y;
					tile.previous.x = tile.x;
					tile.previous.y = tile.y;
					
					if (!collide) {
						overlapped = true;
					} else if (tile.collision != NONE && callback != null) {
						if (tile.collision == ANY) {
							overlapped = callback(target, tile);
						} else {
							var tw:Number = tx + tileWidth;
							var th:Number = ty + tileHeight;
							var ow:Number = target.x + target.width;
							var oh:Number = target.y + target.height;
							var opw:Number = target.previous.x + target.width;
							var oph:Number = target.previous.y + target.height;
							if (tile.collision & RIGHT && ow > tw && (!tile.oneWay || target.previous.x >= tw)) {
								if (ow >= opw) {
									tile.previous.x = tile.x = tw;
								}
								overlapped = callback(target, tile) || overlapped;
								tile.previous.x = tile.x = tx;
							} else if (tile.collision & LEFT && target.x < tx && (!tile.oneWay || opw <= tx)) {
								if (ow <= opw) {
									tile.previous.x = tile.x = tx - tileWidth;
								}
								overlapped = callback(target, tile) || overlapped;
								tile.previous.x = tile.x = tx;
							}
							if (tile.collision & DOWN && oh > th && (!tile.oneWay || target.previous.y >= th)) {
								if (oh >= oph) {
									tile.previous.y = tile.y = th;
								}
								overlapped = callback(target, tile) || overlapped;
								tile.previous.y = tile.y = ty;
							} else if (tile.collision & UP && target.y < ty && (!tile.oneWay || oph <= ty)) {
								if (oh <= oph) {
									tile.previous.y = tile.y = ty - tileHeight;
								}
								overlapped = callback(target, tile) || overlapped;
								tile.previous.y = tile.y = ty;
							}
						}
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
		 * Given a position on the map in tiles (0, 0 is the upper left), returns the tile id representing
		 * the tile at that position. If there is no tile, returns 0. The tile is is the index into the
		 * tileset image (the upper left tile is 1).
		 * 
		 * @param x The x coordinate in tiles.
		 * @param y The y coordinate in tiles.
		 * 
		 * @return The number representing the tile id at the position.
		 */
		public function getTileIndexAt(x:uint, y:uint):uint {
			if (x < 0 || x >= cols || y < 0 || y > rows) {
				throw new Error("Tile location (" + x + "," + y + ") is out of bounds");
			}
			return data[y * cols + x];
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
			
			var segmentRow:uint = y / segmentHeight;
			var segmentCol:uint = x / segmentWidth;
			var segmentOffset:uint = segmentRow * segmentCols + segmentCol;
			var segment:AxTilemapSegment = segments[segmentOffset];
			var sx:uint = x - segmentCol * segmentWidth;
			var sy:uint = y - segmentRow * segmentHeight;
			
			var offset:uint = sy * segment.width + sx;
			var bufferOffset:int = segment.bufferOffsets[offset];
			
			var u:Number = (index % tilesetCols) * uvWidth;
			var v:Number = Math.floor(index / tilesetCols) * uvHeight;
			
			data[y * cols + x] = index;
			index--;
			
			if (bufferOffset == -1) {
				segment.bufferOffsets[offset] = segment.bufferSize++;
				
				var tx:uint = x * tileWidth;
				var ty:uint = y * tileHeight;
				
				var idx:uint = segment.vertexData.length / 4;
				segment.indexData.push(idx, idx + 1, idx + 2, idx + 1, idx + 2, idx + 3);
				segment.vertexData.push(
					tx, 				ty,					u,				v,
					tx + tileWidth,		ty,					u + uvWidth,	v,
					tx,					ty + tileHeight,	u,				v + uvHeight,
					tx + tileWidth,		ty + tileHeight,	u + uvWidth,	v + uvHeight
				);
			} else {
				segment.vertexData[bufferOffset * VERTEX_SET_LENGTH + 2]  = u;
				segment.vertexData[bufferOffset * VERTEX_SET_LENGTH + 3]  = v;
				segment.vertexData[bufferOffset * VERTEX_SET_LENGTH + 6]  = u + uvWidth;
				segment.vertexData[bufferOffset * VERTEX_SET_LENGTH + 7]  = v;
				segment.vertexData[bufferOffset * VERTEX_SET_LENGTH + 10] = u;
				segment.vertexData[bufferOffset * VERTEX_SET_LENGTH + 11] = v + uvHeight;
				segment.vertexData[bufferOffset * VERTEX_SET_LENGTH + 14] = u + uvWidth;
				segment.vertexData[bufferOffset * VERTEX_SET_LENGTH + 15] = v + uvHeight;
			}
			
			segment.dirty = true;
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
			var segmentRow:uint = y / segmentHeight;
			var segmentCol:uint = x / segmentWidth;
			var segmentOffset:uint = segmentRow * segmentCols + segmentCol;
			var segment:AxTilemapSegment = segments[segmentOffset];
			var sx:uint = x - segmentCol * segmentWidth;
			var sy:uint = y - segmentRow * segmentHeight;
			
			var index:uint = sy * segment.width + sx;
			var bufferOffset:int = segment.bufferOffsets[index];
			if (bufferOffset == -1) {
				return;
			}
			segment.vertexData.splice(bufferOffset * VERTEX_SET_LENGTH, VERTEX_SET_LENGTH);
			segment.indexData.splice(bufferOffset * INDEX_SET_LENGTH, INDEX_SET_LENGTH);
			for (var i:uint = 0; i < segment.bufferOffsets.length; i++) {
				if (segment.bufferOffsets[i] > bufferOffset) {
					segment.bufferOffsets[i] = segment.bufferOffsets[i] == -1 ? -1 : segment.bufferOffsets[i] - 1;
				}
			}
			for (i = bufferOffset * INDEX_SET_LENGTH; i < segment.indexData.length; i++) {
				segment.indexData[i] -= 4;
			}
			segment.bufferOffsets[index] = -1;
			data[y * cols + x] = 0;
			segment.bufferSize--;
			segment.dirty = true;
		}
		
		/**
		 * Warning, this implementation is incomplete and is thus set to private. Use at your own risk.
		 */
		private function findPath(sourceX:uint, sourceY:uint, targetX:uint, targetY:uint):AxPath {
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
				
				if (up > 0 && pathVisited[up] == 0) {
					calls++;
					handlePathNode(queue, up, current, targetTileX, targetTileY);
				}
				if (down < numTiles && pathVisited[down] == 0) {
					calls++;
					handlePathNode(queue, down, current, targetTileX, targetTileY);
				}
				if (current % cols > 0 && pathVisited[left] == 0) {
					calls++;
					handlePathNode(queue, left, current, targetTileX, targetTileY);
				}
				if (current % cols < cols - 1 && pathVisited[right] == 0) {
					calls++;
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
			"mov v1, va1",		// move uv to fragment shader
			"m44 op, va0, vc0",	// multiply position by transform matrix 
		];
		
		/**
		 * The fragment shader for drawing tilemaps.
		 */
		private static const FRAGMENT_SHADER:Array = [
			// ft0 = tilemap texture
			// v1  = uv
			// fs0 = something
			// fc0 = color
			"tex ft0, v1, fs0 <2d,nearest,mipnone>", // sample texture
			"mul oc, fc0, ft0",						 // multiply by color+alpha
		];
	}
}
