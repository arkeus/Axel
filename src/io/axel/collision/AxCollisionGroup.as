package io.axel.collision {
	import io.axel.AxCloud;
	import io.axel.AxEntity;
	import io.axel.AxGroup;
	import io.axel.AxRect;
	import io.axel.sprite.AxSprite;
	import io.axel.AxU;
	import io.axel.tilemap.AxTilemap;

	/**
	 * A collision group that defines how two AxEntities should collide. This is an abtract class that shouldn't be used
	 * itself, instead you should use one of its implementing subclasses.
	 */
	public class AxCollisionGroup {
		/**
		 * The frame of the source object used to detect collisions.
		 */
		protected var sourceFrame:AxRect;
		/**
		 * The frame of the target object used to detect collisions.
		 */
		protected var targetFrame:AxRect;
		/**
		 * The frame of the source object used to detect single axis collisions.
		 */
		protected var sourceAxisFrame:AxRect;
		/**
		 * The frame of the target object used to detect single axis collisions.
		 */
		protected var targetAxisFrame:AxRect;
		/**
		 * The callback function to call when a collision is detected.
		 */
		protected var callback:Function;
		/**
		 * The number of comparisons done between objects on the current frame.
		 */
		public var comparisons:uint;

		/**
		 * Sets up the basic variables used for the collision group upon instantiation. You should not use this constructor
		 * directly, but rather one of the subclasses's constructors.
		 */
		public function AxCollisionGroup() {
			this.sourceFrame = new AxRect;
			this.targetFrame = new AxRect;
			this.sourceAxisFrame = new AxRect;
			this.targetAxisFrame = new AxRect;
			comparisons = 0;
		}

		/**
		 * The implementation of this function should set up the data structures needed to collide by populating them with all
		 * subentities of the passed entities, taking into account that they may be recursively nested AxGroups.
		 * 
		 * @param source The source entities to collide.
		 * @param target The target entities to collide.
		 *
		 */
		public function build(source:AxEntity, target:AxEntity):void {
			// Override as needed
		}

		/**
		 * Overlaps the two groups of entities, separating any overlapping entities that are solid and executing the callback for
		 * any overlapping pair. This method simply uses overlap(), with the added step of separating objects.
		 * 
		 * @return Whether any overlaps were detected.
		 */
		public function collide():Boolean {
			// Override as needed
			return false;
		}

		/**
		 * Overlaps the two groups of entities, executing the callback for any overlapping pair.
		 * 
		 * @return Whether any overlaps were detected.
		 */
		public function overlap():Boolean {
			// Override as needed
			return false;
		}
		
		/**
		 * Resets the group, clearing all entities, so that it can be recycled each frame. This saves performance if you can recycle
		 * a group without recreating all the required objects.
		 */
		public function reset():void {
			// Override as needed
		}

		/**
		 * Sets the callback to be executing upon any two entities overlapping.
		 * 
		 * @param callback The callback to execute upon overlap.
		 */
		public function setCallback(callback:Function):void {
			this.callback = callback;
		}

		/**
		 * Adds all entities and subentities of the passed object to the passed group.
		 * 
		 * @param object The entity to add. If it's a group, recursively adds all members.
		 * @param group The group to add all entities to.
		 */
		protected function addAll(object:AxEntity, group:Vector.<AxEntity>):void {
			if (object is AxGroup) {
				var objects:Vector.<AxEntity> = (object as AxGroup).members;
				for each (var o:AxEntity in objects) {
					if (o.active && o.exists) {
						addAll(o, group);
					}
				}
			} else if (object is AxCloud) {
				var sprites:Vector.<AxSprite> = (object as AxCloud).members;
				for each (var s:AxSprite in sprites) {
					if (s.active && s.exists) {
						addAll(s, group);
					}
				}
			} else if (object != null) {
				group.push(object);
			}
		}

		/**
		 * Given two entities, checks to see if they overlap (only taking into account their movement on the x axis), and if they do,
		 * separate them upon that axis.
		 * 
		 * @param source The source entity to check.
		 * @param target The target entity to check.
		 *
		 * @return Whether or not an overlap was detected.
		 */
		protected function solveXCollision(source:AxEntity, target:AxEntity):Boolean {
			if (source is AxTilemap) {
				return (source as AxTilemap).overlap(target, solveXCollision, true);
			} else if (target is AxTilemap) {
				return (target as AxTilemap).overlap(source, solveXCollision, true);
			}

			var sfx:Number = source.x - source.previous.x;
			var tfx:Number = target.x - target.previous.x;

			sourceAxisFrame.x = (source.x > source.previous.x ? source.previous.x : source.x);
			sourceAxisFrame.y = source.previous.y;
			sourceAxisFrame.width = source.width + AxU.abs(sfx);
			sourceAxisFrame.height = source.height;

			targetAxisFrame.x = (target.x > target.previous.x ? target.previous.x : target.x);
			targetAxisFrame.y = target.previous.y;
			targetAxisFrame.width = target.width + AxU.abs(tfx);
			targetAxisFrame.height = target.height;

			var overlap:Number = 0;
			if ((sourceAxisFrame.x + sourceAxisFrame.width - AxU.EPSILON > targetAxisFrame.x) && (sourceAxisFrame.x + AxU.EPSILON < targetAxisFrame.x + targetAxisFrame.width) && (sourceAxisFrame.y + sourceAxisFrame.height - AxU.EPSILON > targetAxisFrame.y) && (sourceAxisFrame.y + AxU.EPSILON < targetAxisFrame.y + targetAxisFrame.height)) {
				if (sfx > tfx) {
					overlap = source.x + source.width - target.x;
					source.touching |= AxEntity.RIGHT;
					target.touching |= AxEntity.LEFT;
				}
				if (sfx < tfx) {
					overlap = source.x - target.width - target.x;
					target.touching |= AxEntity.RIGHT;
					source.touching |= AxEntity.LEFT;
				}
			}

			if (overlap != 0) {
				source.x -= overlap;
				source.velocity.x = 0;
				target.velocity.x = 0;
				return true;
			}

			return false;
		}

		/**
		 * Given two entities, checks to see if they overlap (only taking into account their movement on the y axis), and if they do,
		 * separate them upon that axis.
		 * 
		 * @param source The source entity to check.
		 * @param target The target entity to check.
		 *
		 * @return Whether or not an overlap was detected.
		 */
		protected function solveYCollision(source:AxEntity, target:AxEntity):Boolean {
			if (source is AxTilemap) {
				return (source as AxTilemap).overlap(target, solveYCollision, true);
			} else if (target is AxTilemap) {
				return (target as AxTilemap).overlap(source, solveYCollision, true);
			}

			var sfy:Number = source.y - source.previous.y;
			var tfy:Number = target.y - target.previous.y;

			sourceAxisFrame.x = source.x;
			sourceAxisFrame.y = (source.y > source.previous.y ? source.previous.y : source.y);
			sourceAxisFrame.width = source.width;
			sourceAxisFrame.height = source.height + AxU.abs(sfy);

			targetAxisFrame.x = target.x;
			targetAxisFrame.y = (target.y > target.previous.y ? target.previous.y : target.y);
			targetAxisFrame.width = target.width;
			targetAxisFrame.height = target.height + AxU.abs(tfy);

			var overlap:Number = 0;
			if ((sourceAxisFrame.x + sourceAxisFrame.width - AxU.EPSILON > targetAxisFrame.x) && (sourceAxisFrame.x + AxU.EPSILON < targetAxisFrame.x + targetAxisFrame.width) && (sourceAxisFrame.y + sourceAxisFrame.height - AxU.EPSILON > targetAxisFrame.y) && (sourceAxisFrame.y + AxU.EPSILON < targetAxisFrame.y + targetAxisFrame.height)) {
				if (sfy > tfy) {
					overlap = source.y + source.height - target.y;
					source.touching |= AxEntity.DOWN;
					target.touching |= AxEntity.UP;
				}
				if (sfy < tfy) {
					overlap = source.y - target.height - target.y;
					target.touching |= AxEntity.DOWN;
					source.touching |= AxEntity.UP;
				}
			}

			if (overlap != 0) {
				source.y -= overlap;
				source.velocity.y = 0;
				target.velocity.y = 0;
				return true;
			}

			return false;
		}
	}
}
