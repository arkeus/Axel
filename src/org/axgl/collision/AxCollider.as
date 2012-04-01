package org.axgl.collision {
	import org.axgl.AxEntity;

	/**
	 * An exponential implemention of a collision group. Adds the first entities to a source list, the second
	 * entities to a target list, and collides every entity in the first group with every entity in the second
	 * group. This is an O(n^2) implementation, and is should never be used with many objects in both groups.
	 * However, it has very little overhead, so if you are colliding a single object against a set of other objects,
	 * or a small set of objects against a small set of objects (such as 3 objects against 10 objects), then
	 * using this implementation is the most efficient method.
	 */
	public class AxCollider extends AxCollisionGroup {
		/**
		 * The list of all source entities.
		 */
		private var sourceList:Vector.<AxEntity>;
		/**
		 * The list of all target entities.
		 */
		private var targetList:Vector.<AxEntity>;

		/**
		 * Constructs a new AxCollider collision group.
		 */
		public function AxCollider() {
			this.sourceList = new Vector.<AxEntity>;
			this.targetList = new Vector.<AxEntity>;
		}
		
		/**
		 * Clears the lists.
		 */
		override public function reset():void {
			sourceList.length = targetList.length = 0;
			comparisons = 0;
		}

		/**
		 * Builds the collision group by adding all of the source entities to the source list, and all of the
		 * target entities to the target group.
		 */
		override public function build(source:AxEntity, target:AxEntity):void {
			addAll(source, this.sourceList);
			addAll(target, this.targetList);
		}

		/**
		 * @inheritDoc
		 */
		override public function overlap():Boolean {
			var overlapFound:Boolean = false;
			for each (var source:AxEntity in sourceList) {
				if (!source.active || !source.exists) {
					continue;
				}
				comparisons++;
				
				sourceFrame.x = (source.x > source.previous.x ? source.previous.x : source.x);
				sourceFrame.y = (source.y > source.previous.y ? source.previous.y : source.y);
				sourceFrame.width = source.x + source.width - sourceFrame.x;
				sourceFrame.height = source.y + source.height - sourceFrame.y;
				
				for each (var target:AxEntity in targetList) {
					if (!target.active || !target.exists || source == target) {
						continue;
					}
					
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
			}

			return overlapFound;
		}

		/**
		 * @inheritDoc
		 */
		override public function collide():Boolean {
			var collisionFound:Boolean = false;
			for each (var source:AxEntity in sourceList) {
				if (!source.solid || !source.active || !source.exists) {
					continue;
				}

				comparisons++;

				sourceFrame.x = (source.x > source.previous.x ? source.previous.x : source.x);
				sourceFrame.y = (source.y > source.previous.y ? source.previous.y : source.y);
				sourceFrame.width = source.x + source.width - sourceFrame.x;
				sourceFrame.height = source.y + source.height - sourceFrame.y;

				// Handle collision on the X axis
				for each (var target:AxEntity in targetList) {
					if (!target.solid || !target.active || !target.exists || source == target) {
						continue;
					}

					targetFrame.x = (target.x > target.previous.x ? target.previous.x : target.x);
					targetFrame.y = (target.y > target.previous.y ? target.previous.y : target.y);
					targetFrame.width = target.x + target.width - targetFrame.x;
					targetFrame.height = target.y + target.height - targetFrame.y;

					if ((sourceFrame.x + sourceFrame.width > targetFrame.x) && (sourceFrame.x < targetFrame.x + targetFrame.width) && (sourceFrame.y + sourceFrame.height > targetFrame.y) && (sourceFrame.y < targetFrame.y + targetFrame.height)) {
						if (!target.phased && !source.phased) {
							if (solveXCollision(source, target)) {
								collisionFound = true;
							}
						}
						if (callback != null) {
							callback(source, target);
						}
					}
				}

				// Handle collision on the Y axis
				for each (target in targetList) {
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
								collisionFound = true;
							}
						}
						if (callback != null) {
							callback(source, target);
						}
					}
				}
			}

			return collisionFound;
		}
	}
}
