package org.axgl.tilemap {
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	
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
	 * tiles in the tilemap are 1-based indexed; an index of 0 means no tile.
	 */
	public class AxTilemap extends AxModel {
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
		 * The frame used to calculate collisions against other objects.
		 */
		protected var frame:AxRect;

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

			indexData = new Vector.<uint>;
			vertexData = new Vector.<Number>;

			var rowArray:Array = mapString.split("\n");
			var index:uint = 0;
			var uvWidth:Number = 1 / (texture.width / tileWidth);
			var uvHeight:Number = 1 / (texture.height / tileWidth);
			rows = rowArray.length;
			for (var y:uint = 0; y < rows; y++) {
				var row:Array = rowArray[y].split(",");
				cols = Math.max(cols, row.length);
				for (var x:uint = 0; x < cols; x++) {
					var tid:uint = row[x];
					if (tid == 0) {
						data.push(0);
						continue;
					}
					
					data.push(tid);
					tid -= 1;
					
					var tx:uint = x * tileWidth;
					var ty:uint = y * tileHeight;
					var u:Number = (tid % tileCols) * uvWidth;
					var v:Number = Math.floor(tid / tileCols) * uvHeight;
					
					indexData.push(index, index + 1, index + 2, index + 1, index + 2, index + 3);
					vertexData.push(
						tx + AxU.EPSILON, 	ty + AxU.EPSILON,	u,				v,
						tx + tileWidth,		ty + AxU.EPSILON,	u + uvWidth,	v,
						tx + AxU.EPSILON,	ty + tileHeight,	u,				v + uvHeight,
						tx + tileWidth,		ty + tileHeight,	u + uvWidth,	v + uvHeight
					);
					index += 4;
				}
			}

			var vertexLength:uint = vertexData.length / shader.rowSize;
			indexBuffer = Ax.context.createIndexBuffer(indexData.length);
			indexBuffer.uploadFromVector(indexData, 0, indexData.length);
			vertexBuffer = Ax.context.createVertexBuffer(vertexLength, shader.rowSize);
			vertexBuffer.uploadFromVector(vertexData, 0, vertexLength);
			triangles = indexData.length / 3;

			width = cols * tileWidth;
			height = rows * tileHeight;

			tiles.push(null);
			for (index = 1; index <= tileCols * tileRows; index++) { 
				var tile:AxTile = new AxTile(this, index, tileWidth, tileHeight);
				tile.collision = index >= solidIndex ? ANY : NONE;
				tiles.push(tile);
			}

			return this;
		}

		override public function draw():void {
			matrix.identity();
			//trace(1);
			//matrix.appendTranslation(-Ax.camera.x, -Ax.camera.y, 0);
			matrix.appendTranslation(x - Math.round(Ax.camera.x), y - Math.round(Ax.camera.y), 0);
			matrix.append(Ax.camera.projection);
			
			colorTransform[RED] = color.red;
			colorTransform[GREEN] = color.green;
			colorTransform[BLUE] = color.blue;
			colorTransform[ALPHA] = color.alpha;

			Ax.context.setProgram(shader.program);
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
