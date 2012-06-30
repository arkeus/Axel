package org.axgl {

	/**
	 * AxGroup is the basic container object. When building a world, you'll often want to group objects
	 * together for more manageable code. With AxGroup, you can add any AxEntity into it, including other
	 * AxGroups, allowing you to create a hierarchy of objects. AxGroup is a simple group that will call
	 * draw separately for each object added. If you have a large number of static objects, you should
	 * consider using AxTilemap, AxMap, or AxCloud, as those will perform better. However, each of those
	 * have their own limitations.
	 * 
	 * <p>AxGroup is also perfect for grouping up objects for collision. In this case, if you are not adding
	 * them to your state, this is the best kind of group to use. However, if you add an object to multiple
	 * groups, only one of those groups should be added to your state, otherwise the object will be updated
	 * and drawn multiple times, causing unpredictable results.</p>
	 */
	public class AxGroup extends AxEntity {
		/** The vector containing all the entities within this group. */
		public var members:Vector.<AxEntity>;
		public var tempMembers:Vector.<AxEntity>;
		/** Keeps track of current position for recycling, for improved performance. */
		private var recyclePosition:uint = 0;

		/**
		 * Creates a new empty group object with the specified position and size. Note: The position and size
		 * does not have any effect on where the objects inside are rendered.
		 * TODO: Remove position/size of AxGroup?
		 *
		 * @param x The x position of this group.
		 * @param y The y position of this group;
		 * @param width The width of this group.
		 * @param height The height of this group.
		 */
		public function AxGroup(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0) {
			members = new Vector.<AxEntity>;
			tempMembers = new Vector.<AxEntity>;
			this.x = x;
			this.y = y;
			this.width = width;
			this.height = height;
		}

		/**
		 * Adds a new entity to this group.
		 *
		 * @param entity The entity to add.
		 *
		 * @return This group.
		 */
		public function add(entity:AxEntity):AxGroup {
			members.push(entity);
			return this;
		}

		/**
		 * Removes the specified entity from the group.
		 *
		 * @param entity The entity to remove.
		 *
		 * @return This group.
		 */
		public function remove(entity:AxEntity):AxGroup {
			var index:uint = members.indexOf(entity);
			if (index >= 0) {
				members.splice(index, 1);
			}
			return this;
		}

		/**
		 * @inheritDoc
		 */
		override public function update():void {
			for (var i:uint = 0; i < members.length; i++) {
				var entity:AxEntity = members[i];

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
			for (var i:uint = 0; i < members.length; i++) {
				var entity:AxEntity = members[i];

				if (!entity.exists || !entity.visible) {
					continue;
				}

				entity.draw();
				if (countDraw) {
					Ax.debugger.draws++;
				}
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
				if ((members[i] as AxEntity).exists && (members[i] as AxEntity).overlaps(other)) {
					overlapFound = true;
				}
			}
			return overlapFound;
		}
		
		/**
		 * Searches the group for an AxEntity whose <code>exists</code> flag is false, and returns that entity.
		 * If it can't find any nonexistent entities, returns null. You can use this to recycle used objects, as
		 * creating new objects is expensive, and having a large number of dead objects reduces performance. Simply
		 * call this, and if you get back an entity, use that, otherwise create a new one. Note that it will return
		 * any entity in the group, but will not recurse deeper into nested groups. As such, to use this for recycling,
		 * normally it is best to use it on a group only containing one type of entity. You can, however, check what
		 * type of object you get back using <code>instanceof</code>.
		 * 
		 * @return A recycled entity, null if there were none available.
		 */
		public function recycle():AxEntity {
			for (var i:uint = 0; i < members.length; i++) {
				if (recyclePosition > members.length - 1) {
					recyclePosition = 0;
				}
				
				var entity:AxEntity = members[recyclePosition++];
				if (entity != null && !entity.exists) {
					entity.exists = true;
					entity.active = true;
					entity.visible = true;
					return entity;
				}
			}
			
			return null;
		}
		
		/**
		 * Cleans up the group, removing all members that are null or have their <code>exists</code> flag set to false.
		 * This can be a much simpler option to increasing performance when recycling would be too complicated. If, for
		 * example, you are constantly adding different types of enemies to a group, recycling can be hard. Instead, you
		 * can call this sparingly (every few seconds, or possibly less), and it will remove all the dead entities from the
		 * group, keeping it small and performant.
		 */
		public function cleanup():void {
			tempMembers.length = 0;
			for (var i:uint = 0; i < members.length; i++) {
				var entity:AxEntity = members[i];
				if (entity != null && entity.exists) {
					tempMembers.push(entity);
				}
			}
			
			var temp:Vector.<AxEntity> = members;
			members = tempMembers;
			tempMembers = temp;
		}
		
		/**
		 * Removes all the objects from this group. If you pass in true, it will also dispose of those objects and clear them
		 * from memory. If you reference the members in other groups or elsewhere, you should not pass true.
		 */
		public function clear(dispose:Boolean = false):AxGroup {
			if (dispose) {
				for (var i:uint = 0; i < members.length; i++) {
					var entity:AxEntity = members[i];
					entity.dispose();
				}
			}
			members.length = 0;
			return this;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function dispose():void {
			clear(true);
			members = null;
			super.dispose();
		}
	}
}
