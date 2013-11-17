package io.axel.collision {
	import io.axel.AxCloud;
	import io.axel.AxEntity;
	import io.axel.AxGroup;
	import io.axel.AxSprite;
	import io.axel.tilemap.AxTilemap;

	/**
	 * A spacial hashing implementation of a collision group. This creates a grid over the playing field,
	 * and places each target object into the buckets representing the cells that the object overlaps. Then,
	 * all the source objects are collided against any buckets they overlap. Unless you have all your objects
	 * grouped up in a small area of the map, this is a very efficient method of collision. The default arguments
	 * are to use a 10 x 10 grid, but you can play with those numbers to see which gives you the best performance.
	 */
	public class AxGrid extends AxCollisionGroup {
		/**
		 * The source list containing all the source entities.
		 */
		private var sourceList:Vector.<AxEntity>;
		/**
		 * The grid, containing a bucket for every cell in the grid.
		 */
		private var grid:Vector.<Vector.<AxEntity>>;
		/**
		 * The width of each cell in pixels.
		 */
		private var cellWidth:uint;
		/**
		 * The height of each cell in pixels.
		 */
		private var cellHeight:uint;
		/**
		 * The number of columns in the grid.
		 */
		private var columns:uint;
		/**
		 * The number of rows in the grid.
		 */
		private var rows:uint;

		/**
		 * Creates a new grid with the passed arguments.
		 * 
		 * @param worldWidth Width of the world in pixels. Set it to the width of your entire world/level.
		 * @param worldHeight Height of the world in pixels. Set it to the height of your entire world/level.
		 * @param columns Number of columns in the grid.
		 * @param rows Number of rows in the grid.
		 */
		public function AxGrid(worldWidth:uint, worldHeight:uint, columns:uint = 10, rows:uint = 10) {
			if (worldWidth == 0 || worldHeight == 0) {
				throw new Error("World width and height cannot be 0.");
			}
			
			this.sourceList = new Vector.<AxEntity>;
			this.columns = columns;
			this.rows = rows;

			grid = new Vector.<Vector.<AxEntity>>(this.columns * this.rows, true);
			for (var i:uint = 0; i < this.columns * this.rows; i++) {
				grid[i] = new Vector.<AxEntity>;
			}

			cellWidth = worldWidth / this.columns;
			cellHeight = worldHeight / this.rows;
		}
		
		/**
		 * Resets by clearing the list and emptying the grid buckets.
		 */
		override public function reset():void {
			comparisons = 0;
			sourceList.length = 0;
			for (var i:uint = 0; i < this.columns * this.rows; i++) {
				grid[i].length = 0;
			}
		}

		/**
		 * Builds the collision group by adding all entities within <code>target</code> to the buckets in the grid, and
		 * adding all the entities in <code>source</code> to a list to collide against the buckets.
		 *
		 * @param source The source entities to collide against the grid.
		 * @param target The target entities to populate the grid with.
		 */
		override public function build(source:AxEntity, target:AxEntity):void {
			if (source is AxTilemap || target is AxTilemap) {
				throw new Error("Cannot use Spacial Hashing with a tilemap. Use AxCollider instead.");
			}

			addAll(source, sourceList);
			addToBucket(target);
		}

		/**
		 * Adds an entity to the buckets they overlap with, recursively.
		 * 
		 * @param object The entity to add.
		 */
		private function addToBucket(object:AxEntity):void {
			if (object is AxGroup) {
				var members:Vector.<AxEntity> = (object as AxGroup).members;
				for each (var o:AxEntity in members) {
					if (o.active && o.exists) {
						addToBucket(o);
					}
				}
			} else if (object is AxCloud) {
				var sprites:Vector.<AxSprite> = (object as AxCloud).members;
				for each (var s:AxSprite in sprites) {
					if (s.active && s.exists) {
						addToBucket(s);
					}
				}
			} else if (object != null) {
				for (var x:uint = Math.max(0, object.x / cellWidth); x < Math.min(columns, (object.x + object.width) / cellWidth); x++) {
					for (var y:uint = Math.max(0, object.y / cellHeight); y < Math.min(rows, (object.y + object.height) / cellHeight); y++) {
						grid[y * columns + x].push(object);
					}
				}
			}
		}

		/**
		 * @inheritDoc
		 */
		override public function overlap():Boolean {
			return overlapWithCallback(overlapAgainstBucket);
		}

		/**
		 * @inheritDoc
		 */
		override public function collide():Boolean {
			return overlapWithCallback(collideAgainstBucket);
		}
		
		private function overlapWithCallback(overlapFunction:Function):Boolean {
			var overlapFound:Boolean = false;
			
			for (var i:uint = 0; i < sourceList.length; i++) { 
				var object:AxEntity = sourceList[i];
				for (var x:uint = Math.max(0, object.x / cellWidth); x < Math.min(columns, (object.x + object.width) / cellWidth); x++) {
					for (var y:uint = Math.max(0, object.y / cellHeight); y < Math.min(rows, (object.y + object.height) / cellHeight); y++) {
						if (overlapFunction(object, grid[y * columns + x])) {
							overlapFound = true;
						}
					}
				}
			}
			
			return overlapFound;
		}

		/**
		 * Given a single entity and a bucket, collides that entity against all entities in the bucket.
		 * 
		 * @param source The source entity to collide.
		 * @param bucket The bucket to collide against.
		 */
		private function collideAgainstBucket(source:AxEntity, bucket:Vector.<AxEntity>):Boolean {
			if (!source.solid || !source.active || !source.exists) {
				return false;
			}

			var overlapFound:Boolean = false;

			sourceFrame.x = (source.x > source.previous.x ? source.previous.x : source.x);
			sourceFrame.y = (source.y > source.previous.y ? source.previous.y : source.y);
			sourceFrame.width = source.x + source.width - sourceFrame.x;
			sourceFrame.height = source.y + source.height - sourceFrame.y;
			
			// Handle collision on the X axis
			for each (var target:AxEntity in bucket) {
				if (!target.solid || !target.active || !target.exists || source == target) {
					continue;
				}
				
				comparisons++;

				targetFrame.x = (target.x > target.previous.x ? target.previous.x : target.x);
				targetFrame.y = (target.y > target.previous.y ? target.previous.y : target.y);
				targetFrame.width = target.x + target.width - targetFrame.x;
				targetFrame.height = target.y + target.height - targetFrame.y;

				if ((sourceFrame.x + sourceFrame.width > targetFrame.x) && (sourceFrame.x < targetFrame.x + targetFrame.width) && (sourceFrame.y + sourceFrame.height > targetFrame.y) && (sourceFrame.y < targetFrame.y + targetFrame.height)) {
					if (!target.phased && !source.phased) {
						if (solveXCollision(source, target)) {
							overlapFound = true;
						}
					}
					if (callback != null) {
						callback(source, target);
					}
				}
			}

			// Handle collision on the Y axis
			for each (target in bucket) {
				if (!target.solid || !target.active || !target.exists || source == target) {
					continue;
				}

				targetFrame.x = (target.x > target.previous.x ? target.previous.x : target.x);
				targetFrame.y = (target.y > target.previous.y ? target.previous.y : target.y);
				targetFrame.width = target.x + target.width - targetFrame.x;
				targetFrame.height = target.y + target.height - targetFrame.y;

				if ((sourceFrame.x + sourceFrame.width > targetFrame.x) && (sourceFrame.x < targetFrame.x + targetFrame.width) && (sourceFrame.y + sourceFrame.height > targetFrame.y) && (sourceFrame.y < targetFrame.y + targetFrame.height)) {
					if (!target.phased && !source.phased) {
						if (solveYCollision(source, target)) {
							overlapFound = true;
						}
					}
					if (callback != null) {
						callback(source, target);
					}
				}
			}
			
			return overlapFound;
		}
		
		/**
		 * Given a single entity and a bucket, overlaps that entity against all entities in the bucket.
		 * 
		 * @param source The source entity to overlap.
		 * @param bucket The bucket to overlap against.
		 */
		private function overlapAgainstBucket(source:AxEntity, bucket:Vector.<AxEntity>):Boolean {
			var overlapFound:Boolean = false;
			
			sourceFrame.x = (source.x > source.previous.x ? source.previous.x : source.x);
			sourceFrame.y = (source.y > source.previous.y ? source.previous.y : source.y);
			sourceFrame.width = source.x + source.width - sourceFrame.x;
			sourceFrame.height = source.y + source.height - sourceFrame.y;
			
			// Handle collision on the X axis
			for each (var target:AxEntity in bucket) {
				if (!target.active || !target.exists || source == target) {
					continue;
				}
				
				comparisons++;
				
				targetFrame.x = (target.x > target.previous.x ? target.previous.x : target.x);
				targetFrame.y = (target.y > target.previous.y ? target.previous.y : target.y);
				targetFrame.width = target.x + target.width - targetFrame.x;
				targetFrame.height = target.y + target.height - targetFrame.y;
				
				if ((sourceFrame.x + sourceFrame.width > targetFrame.x) && (sourceFrame.x < targetFrame.x + targetFrame.width) && (sourceFrame.y + sourceFrame.height > targetFrame.y) && (sourceFrame.y < targetFrame.y + targetFrame.height)) {
					if (callback != null) {
						callback(source, target);
					}
					overlapFound = true;
				}
			}
			
			return overlapFound;
		}
	}
}
