package org.axgl {
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.utils.getTimer;
	
	
	/**
	 * AxCloud is a group that allows you to draw many sprites that use the same texture efficiently. By changing the actions
	 * field, you can control how efficient it is, and which limitations you place upon it. If you are adding static images, you
	 * should set actions to NONE to ensure high efficiency. Note that even if you turn off features such as coloring and
	 * transforming, this only turns it off on a per frame basis. When you add a new sprite, or set dirty to true, it will update
	 * all sprites with every feature for 1 frame. All sprites added to this cloud will use the texture that the first sprite
	 * added has.
	 */
	public class AxCloud extends AxModel {
		/** The maximum capacity of an AxCloud */
		private static const MAX_CAPACITY:uint = 16000;
		
		/**
		 * When actions is set to NONE, no updates happen to sprites added to this cloud. Using this, it is treated much like
		 * a tilemap, except you are adding sprites however you like, and aren't limited to a grid structure.
		 */
		public static const NONE:uint = 0;
		/**
		 * When actions has the MOVE flag set, every frame the positions will be updated based on its velocity and acceleration.
		 */
		public static const MOVE:uint = 1;
		/**
		 * When actions has the COLOR flag set, every frame the colors and alpha values will be updated.
		 */
		public static const COLOR:uint = 2;
		/**
		 * When actions has the TRANSFORM flag set, every frame the rotation and scaling values will be updatesd.
		 */
		public static const TRANSFORM:uint = 4;
		/**
		 * When actions has the ANIMATE flag set, every frame the animations of the members will be updated.
		 */
		public static const ANIMATE:uint = 8;
		/**
		 * A helper flag equivalent to setting all the flags to true.
		 */
		public static const ALL:uint = MOVE | COLOR | TRANSFORM | ANIMATE;
		/**
		 * The actions that this AxCloud should take. Examples of use are:
		 * 
		 * <listing version="3.0">cloud.actions = AxCloud.NONE;
		 * cloud.actions = AxCloud.MOVE | AxCloud.COLOR;
		 * cloud.actions = AxCloud.ALL;</listing>
		 * 
		 * You should set the actions to the minimum number of features you need updated every frame. If you set it to NONE,
		 * the performance will be many many times greater than if you have any flags set, as no updates will need to happen.
		 * 
		 * @default AxCloud.ALL
		 */
		public var actions:uint = ALL;
		
		/** The maximum number of sprites that can be added to this cloud. */
		public var capacity:uint;
		/** Whether or not this cloud is full (no more sprites can be added). */
		public var full:Boolean = false;
		/** Whether or not this cloud needs to be updated (such as each time a sprite is added). */
		public var dirty:Boolean = true;
		/** The members of this cloud. */
		public var members:Vector.<AxSprite>;
		/** Temporary members used for cleanup. */
		public var tempMembers:Vector.<AxSprite>;
		/** The number of non-destroyed members of this cloud. */
		public var activeMembers:uint;
		/** The number of destroyed members of this cloud. */
		public var inactiveMembers:uint;
		
		/**
		 * Creates a new AxCloud. Note that the texture used to draw everything in this cloud will be the texture that the
		 * first sprite added has.
		 * 
		 * <p>When removing an object from an AxCloud, you must set dirty to true if you want that removal to be recognized.</p>
		 * 
		 * @param x The global x offset of the cloud.
		 * @param y The global y offset of the cloud.
		 * @param capacity The maximum number of objects that can be added to this cloud. Lower is more efficient.
		 */
		public function AxCloud(x:Number = 0, y:Number = 0, capacity:uint = MAX_CAPACITY) {
			super(x, y, VERTEX_SHADER, FRAGMENT_SHADER, 8);
			
			if (capacity > MAX_CAPACITY) {
				throw new Error("Maximum capacity of an AxCloud is " + MAX_CAPACITY + " sprites");
			}
			
			this.capacity = capacity;
			this.activeMembers = 0;
			
			members = new Vector.<AxSprite>;
			tempMembers = new Vector.<AxSprite>;
			indexData = new Vector.<uint>(capacity * 6);
			vertexData = new Vector.<Number>(capacity * (4 * shader.rowSize));
		}
		
		/**
		 * Adds a new entity to this cloud. Sets the dirty flag to true and all members will be fully updated.
		 *
		 * @param entity The entity to add.
		 * @param linkParent Whether or not to set the parent of the entity to this cloud.
		 * @param prepend Whether or not to prepend the object to the start, rather than the end. Prepending is slower.
		 *
		 * @return This map.
		 */
		public function add(entity:AxSprite, linkParent:Boolean = true, prepend:Boolean = false):AxCloud {
			if (entity == null) {
				throw new ArgumentError("Cannot add a null object to a cloud.");
			}
			
			if (members.length >= capacity) {
				full = true;
				return this;
			}
			
			if (texture == null && entity.texture != null) {
				texture = entity.texture;
			}
			
			if (prepend) {
				members.unshift(entity);
			} else {
				members.push(entity);
			}
			
			if (linkParent) {
				entity.setParent(this);
			}
			
			dirty = true;
			return this;
		}
		
		/**
		 * An alias for settings actions to AxCloud.NONE in order for this group to stop updating its members.
		 * This increases the performance by orders of magnitude, and draws much more efficient if all of its
		 * members are frozen.
		 * 
		 * @return This map.
		 */
		public function freeze():AxCloud {
			actions = NONE;
			return this;
		}
		
		/**
		 * Unfreezes this group and sets actions to AxCloud.ALL.
		 * 
		 * @return This map.
		 */
		public function unfreeze():AxCloud {
			actions = ALL;
			return this;
		}
		
		/**
		 * Builds the vertex buffer used to batch the drawing.
		 */
		private function build():void {
			if (vertexBuffer == null) {
				vertexBuffer = Ax.context.createVertexBuffer(vertexData.length / shader.rowSize, shader.rowSize);
			}
			
			var index:uint = 0;
			var r0:uint = 0;
			var r1:uint = shader.rowSize;
			var r2:uint = r1 + r1;
			var r3:uint = r2 + r1;
			
			var moves:Boolean = dirty || (actions & MOVE) > 0;
			var colors:Boolean = dirty || (actions & COLOR) > 0;
			var transforms:Boolean = dirty || (actions & TRANSFORM) > 0;
			var animates:Boolean = dirty || (actions & ANIMATE) > 0;
			
			activeMembers = 0;
			inactiveMembers = 0;
			for (var i:uint = 0; i < members.length; i++) {
				var sprite:AxSprite = members[i];
				if (!sprite.exists || !sprite.visible) {
					inactiveMembers++;
					continue;
				}
				activeMembers++;
				
				var ri0:uint = index + r0;
				var ri1:uint = index + r1;
				var ri2:uint = index + r2;
				var ri3:uint = index + r3;
				
				if (moves) {
					vertexData[ri0 + 0 ] = sprite.x;
					vertexData[ri0 + 1 ] = sprite.y;
					
					vertexData[ri1 + 0 ] = sprite.x + sprite.frameWidth;
					vertexData[ri1 + 1 ] = sprite.y;
					
					vertexData[ri2 + 0 ] = sprite.x;
					vertexData[ri2 + 1 ] = sprite.y + sprite.frameHeight;
					
					vertexData[ri3 + 0 ] = sprite.x + sprite.frameWidth;
					vertexData[ri3 + 1 ] = sprite.y + sprite.frameHeight;
				}
				
				if (colors) {
					vertexData[ri0 + 4 ] = sprite.color.red;
					vertexData[ri0 + 5 ] = sprite.color.green;
					vertexData[ri0 + 6 ] = sprite.color.blue;
					vertexData[ri0 + 7 ] = sprite.color.alpha;
					
					vertexData[ri1 + 4 ] = sprite.color.red;
					vertexData[ri1 + 5 ] = sprite.color.green;
					vertexData[ri1 + 6 ] = sprite.color.blue;
					vertexData[ri1 + 7 ] = sprite.color.alpha;
					
					vertexData[ri2 + 4 ] = sprite.color.red;
					vertexData[ri2 + 5 ] = sprite.color.green;
					vertexData[ri2 + 6 ] = sprite.color.blue;
					vertexData[ri2 + 7 ] = sprite.color.alpha;
					
					vertexData[ri3 + 4 ] = sprite.color.red;
					vertexData[ri3 + 5 ] = sprite.color.green;
					vertexData[ri3 + 6 ] = sprite.color.blue;
					vertexData[ri3 + 7 ] = sprite.color.alpha;
				}
				
				if (transforms) {
					var angle:Number = sprite.angle * Math.PI / 180;
					var cos:Number = Math.cos(angle);
					var sin:Number = Math.sin(angle);
					
					var px:Number = sprite.pivot.x;
					var py:Number = sprite.pivot.y;
					var ox:Number = sprite.origin.x;
					var oy:Number = sprite.origin.y;
					var sx:Number = sprite.scale.x;
					var sy:Number = sprite.scale.y;
					
					var xo:Number = vertexData[ri0 + 0 ];
					var yo:Number = vertexData[ri0 + 1 ];
					
					var x1:Number = vertexData[ri0 + 0 ] - xo;
					var y1:Number = vertexData[ri0 + 1 ] - yo;
					var x2:Number = vertexData[ri1 + 0 ] - xo;
					var y2:Number = vertexData[ri1 + 1 ] - yo;
					var x3:Number = vertexData[ri2 + 0 ] - xo;
					var y3:Number = vertexData[ri2 + 1 ] - yo;
					var x4:Number = vertexData[ri3 + 0 ] - xo;
					var y4:Number = vertexData[ri3 + 1 ] - yo;
					
					vertexData[ri0 + 0 ] = xo + ((x1 - ox + px) * sx - px + ox) * cos - ((y1 - oy + py) * sy - py + oy) * sin;
					vertexData[ri0 + 1 ] = yo + ((x1 - ox + px) * sx - px + ox) * sin + ((y1 - oy + py) * sy - py + oy) * cos;
					
					vertexData[ri1 + 0 ] = xo + ((x2 - ox + px) * sx - px + ox) * cos - ((y2 - oy + py) * sy - py + oy) * sin;
					vertexData[ri1 + 1 ] = yo + ((x2 - ox + px) * sx - px + ox) * sin + ((y2 - oy + py) * sy - py + oy) * cos;
					
					vertexData[ri2 + 0 ] = xo + ((x3 - ox + px) * sx - px + ox) * cos - ((y3 - oy + py) * sy - py + oy) * sin;
					vertexData[ri2 + 1 ] = yo + ((x3 - ox + px) * sx - px + ox) * sin + ((y3 - oy + py) * sy - py + oy) * cos;
					
					vertexData[ri3 + 0 ] = xo + ((x4 - ox + px) * sx - px + ox) * cos - ((y4 - oy + py) * sy - py + oy) * sin;
					vertexData[ri3 + 1 ] = yo + ((x4 - ox + px) * sx - px + ox) * sin + ((y4 - oy + py) * sy - py + oy) * cos;
				}
				
				if (animates) {
					var uvWidth:Number = sprite.frameWidth / sprite.texture.width;
					var uvHeight:Number = sprite.frameHeight / sprite.texture.height;
					var u:Number = (sprite.frame % sprite.framesPerRow) * uvWidth;
					var v:Number = Math.floor(sprite.frame / sprite.framesPerRow) * uvHeight;
					
					vertexData[ri0 + 2 ] = u;
					vertexData[ri0 + 3 ] = v;
					
					vertexData[ri1 + 2 ] = u + uvWidth;
					vertexData[ri1 + 3 ] = v;
					
					vertexData[ri2 + 2 ] = u;
					vertexData[ri2 + 3 ] = v + uvHeight;
					
					vertexData[ri3 + 2 ] = u + uvWidth;
					vertexData[ri3 + 3 ] = v + uvHeight;
				}
				
				index += shader.rowSize * 4;
			}
			
			vertexBuffer.uploadFromVector(vertexData, 0, vertexData.length / shader.rowSize);
			
			if (indexBuffer == null) {
				indexBuffer = Ax.context.createIndexBuffer(capacity * 6);
				index = 0;
				for (i = 0; i < capacity * 6; i += 6) {
					indexData[i] = index;
					indexData[i + 1] = index + 1;
					indexData[i + 2] = index + 2;
					indexData[i + 3] = index + 1;
					indexData[i + 4] = index + 2;
					indexData[i + 5] = index + 3;
					index += 4;
				}
				indexBuffer.uploadFromVector(indexData, 0, indexData.length);
			}
			
			if (inactiveMembers > activeMembers) {
				cleanup();
			}
			
			dirty = false;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function update():void {
			if (actions == NONE) {
				return;
			}
			
			super.update();
			
			for (var i:uint = 0; i < members.length; i++) {
				var entity:AxSprite = members[i];
				
				if (!entity.exists || !entity.active) {
					continue;
				}
				
				entity.update();
				if (countUpdate) {
					Ax.debugger.updates++;
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function draw():void {
			if (members.length == 0) {
				return;
			}
			
			if (dirty || actions != NONE) {
				build();
			}
			
			if (activeMembers == 0) {
				return;
			}
			
			colorTransform[RED] = color.red;
			colorTransform[GREEN] = color.green;
			colorTransform[BLUE] = color.blue;
			colorTransform[ALPHA] = color.alpha * parentEntityAlpha;
			
			matrix.identity();
			matrix.appendTranslation(x - Math.round(Ax.camera.position.x) + parentOffset.x, y - Math.round(Ax.camera.position.y) + parentOffset.y, 0);
			matrix.append(Ax.camera.projection);
			
			if (shader != Ax.shader) {
				Ax.context.setProgram(shader.program);
				Ax.shader = shader;
			}
			
			if (blend == null) {
				Ax.context.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			} else {
				Ax.context.setBlendFactors(blend.source, blend.destination);
			}
			
			Ax.context.setTextureAt(0, texture.texture);
			Ax.context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);
			Ax.context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, colorTransform);
			Ax.context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // x, y
			Ax.context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // u, v
			Ax.context.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4); // r, g, b, a
			
			triangles = activeMembers * 2;
			Ax.context.drawTriangles(indexBuffer, 0, triangles);
			
			Ax.context.setVertexBufferAt(0, null, 0, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(1, null, 2, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(2, null, 4, Context3DVertexBufferFormat.FLOAT_4);
			
			if (countTris) {
				Ax.debugger.tris += triangles;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		override public function overlaps(other:AxRect):Boolean {
			if (!exists) {
				return false;
			}
			
			var overlapFound:Boolean = false;
			for (var i:uint = 0; i < members.length; i++) {
				if ((members[i] as AxSprite).exists && (members[i] as AxSprite).overlaps(other)) {
					overlapFound = true;
				}
			}
			return overlapFound;
		}
		
		/**
		 * Cleans up the group, removing all members that are null or have their <code>exists</code> flag set to false.
		 * This can be a much simpler option to increasing performance when recycling would be too complicated. If, for
		 * example, you are constantly adding different types of enemies to a group, recycling can be hard. Instead, you
		 * can call this sparingly (every few seconds, or possibly less), and it will remove all the dead entities from the
		 * group, keeping it small and performant.
		 * 
		 * <p>This is automatically calls any time you have more inactive than active members in the cloud.</p>
		 */
		public function cleanup():void {
			tempMembers.length = 0;
			for (var i:uint = 0; i < members.length; i++) {
				var entity:AxSprite = members[i];
				if (entity != null && entity.exists) {
					tempMembers.push(entity);
				}
			}
			
			var temp:Vector.<AxSprite> = members;
			members = tempMembers;
			tempMembers = temp;
			tempMembers.length = 0;
		}
		
		/**
		 * Clears out all members of the group. If <code>disposeMembers</code> is set to true, will call dispose on each
		 * member before removing all the members.
		 * 
		 * @param disposeMembers Whether or not to dispose all the members before removing them.
		 */
		public function clear(disposeMembers:Boolean = true):void {
			if (disposeMembers) {
				for (var i:uint = 0; i < members.length; i++) {
					var entity:AxSprite = members[i];
					entity.dispose();
				}
			}
			tempMembers.length = 0;
			members.length = 0;
			dirty = true;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			for (var i:uint = 0; i < members.length; i++) {
				var entity:AxSprite = members[i];
				entity.dispose();
			}
			
			members = null;
			tempMembers = null;
			super.dispose();
		}
		
		/**
		 * The vertex shader for drawing clouds. 
		 */
		private static const VERTEX_SHADER:Array = [
			// va0 = [x, y, , ]
			// va1 = [u, v, , ]
			// va2 = [r, g, b, a]
			// vc0 = transform matrix
			"mov v1, va1",			// move uv to fragment shader
			"mov v2, va2",			// move color transform to fragment shader
			"m44 op, va0, vc0"		// multiply position by transform matrix 
		];
		
		/**
		 * The fragment shader for drawing clouds.
		 */
		private static const FRAGMENT_SHADER:Array = [
			// ft0 = tilemap texture
			// v1  = uv
			// v2  = rgba
			// fs0 = something
			// fc0 = color
			"tex ft0, v1, fs0 <2d,nearest,mipnone>",	// sample texture
			"mul ft1, v2, fc0",						// multiple sprite color by global color
			"mul oc, ft0, ft1",							// multiply texture by color
		];
	}
}
