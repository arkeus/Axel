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
		/** Global scroll factor for the group. */
		public var scrollFactor:AxPoint;

		/**
		 * Creates a new empty group object with the specified position and size. Note: The position and size
		 * does not have any effect on where the objects inside are rendered.
		 *
		 * @param x The x position of this group.
		 * @param y The y position of this group;
		 */
		public function AxGroup(x:Number = 0, y:Number = 0) {
			members = new Vector.<AxEntity>;
			tempMembers = new Vector.<AxEntity>;
			scrollFactor = new AxPoint(-1, -1);
			this.x = x;
			this.y = y;
		}

		/**
		 * Adds a new entity to this group.
		 *
		 * @param entity The entity to add.
		 *
		 * @return This group.
		 */
		public function add(entity:AxEntity, linkParent:Boolean = true):AxGroup {
			if (entity == null) {
				throw new ArgumentError("Cannot add a null object to a group.");
			}
			
			members.push(entity);
			if (linkParent) {
				entity.setParent(this);
			}
			
			if (entity is AxModel) {
				if (scroll.x != -1 && (entity as AxModel).scroll.x == 1) {
					(entity as AxModel).scroll.x = scroll.x;
				}
				if (scroll.y != -1 && (entity as AxModel).scroll.y == 1) {
					(entity as AxModel).scroll.y = scroll.y;
				}
			} else if (entity is AxGroup) {
				if (scroll.x != -1 || scroll.y != -1) {
					(entity as AxGroup).scroll = new AxPoint(scroll.x, scroll.y);
				}
			}
			
			return this;
		}

		/**
		 * Removes the specified entity from the group.
		 *
		 * @param entity The entity to remove.
		 *
		 * @return This group.
		 */
		public function remove(entity:AxEntity, unlinkParent:Boolean = true):AxGroup {
			var index:uint = members.indexOf(entity);
			if (index >= 0) {
				if (unlinkParent) {
					(members[index] as AxEntity).removeParent();
				}
				members.splice(index, 1);
			}
			return this;
		}

		/**
		 * @inheritDoc
		 */
		override public function update():void {
			super.update();
			
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
		 * Returns the scroll factor for this group.
		 * 
		 * @return The scroll factor for this group.
		 */
		public function get scroll():AxPoint {
			return scrollFactor;
		}
		
		/**
		 * Sets the scroll factor for the group. Once you change this, all future objects added to
		 * the group will have their scroll factors inherited from this. If you change this after
		 * objects have been added, it will only affect the objects if you set it as a whole (set
		 * it to a new AxPoint). If you set the x and y separately it will not affect current items,
		 * only new items added to the group.
		 * 
		 * @param factor The new scroll factor.
		 */
		public function set scroll(scrollFactor:AxPoint):void {
			this.scrollFactor = scrollFactor;
			
			var member:AxEntity;
			for (var i:uint = 0; i < members.length; i++) {
				member = members[i];
				if (member is AxGroup) {
					(member as AxGroup).scroll = scrollFactor;
				} else if (member is AxModel) {
					(member as AxModel).scroll.x = scrollFactor.x;
					(member as AxModel).scroll.y= scrollFactor.y;
				}
			}
		}
		
		/**
		 * Shortcut to set this group's scroll factor in both directions to be 0.
		 * 
		 * @return This group.
		 */
		public function noScroll():AxGroup {
			scroll = new AxPoint(0, 0);
			return this;
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
