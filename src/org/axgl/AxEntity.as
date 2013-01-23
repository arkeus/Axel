package org.axgl {
	import avmplus.getQualifiedClassName;
	
	import org.axgl.util.AxTimer;

	/**
	 * A basic game entity. AxEntities do not render on the screen, but they can have velocities, accelerations, etc.
	 * Most classes extend this class, as only instances of this class can be collided and added to groups.
	 */
	public class AxEntity extends AxRect {
		/** Constant value for LEFT. */
		public static const LEFT:uint = 1;
		/** Constant value for RIGHT. */
		public static const RIGHT:uint = 2;
		/** Constant value for UP. */
		public static const UP:uint = 4;
		/** Constant value for DOWN. */
		public static const DOWN:uint = 8;
		/** Constant value meaning no directions. */
		public static const NONE:uint = 0;
		/** Constant value meaning all directions. */
		public static const ANY:uint = LEFT | RIGHT | UP | DOWN;

		/**
		 * Determines whether or not this object should be drawn. If this is false, the draw method will
		 * not be called.
		 *
		 * @default true
		 */
		public var visible:Boolean;
		/**
		 * Determines whether or not this entity should be updated. If this is false, both the update and
		 * the systemUpdate methods will not be called. Inactive entities are not collided against.
		 *
		 * @default true
		 */
		public var active:Boolean;
		/**
		 * Determines whether or not this object should be collided against. If you call collide and an entity
		 * collides against another entity, and either of them are not solid, the collision will not happen
		 * (when called with <code>Ax.collide</code>). When calling overlap (via <code>Ax.overlap</code>), callbacks
		 * will still happen on non-solid entities.
		 *
		 * @default true
		 */
		public var solid:Boolean;
		/**
		 * Determines whether or not this object exists. If an object doesn't exists, it won't be updated, drawn, and it
		 * is able to be recycled through the recycle method on an AxGroup. When you destroy() an object, this is set
		 * to false.
		 */
		public var exists:Boolean;
		/**
		 * The parents of this entity. An entity's position will be relative to its parent, unless it does not have a parent.
		 * When adding an entity to a group, by default it's parent will be set to the group, and it's position will become
		 * relative to that group. You can also manually set the parent on any entity to any other entity.
		 * Important: This should not be used with collision. Parent offsets are not taken into account when colliding, so
		 * if you are colliding objects, you should not change the position of their parents.
		 */
		public var parent:AxEntity;
		/**
		 * The position of the parent entity. Each frame this is propagated down by every entity setting it based on its
		 * parents properties. This allows an entity to keep separate its own local position and the position it is relative
		 * to.
		 */
		public var parentOffset:AxPoint;
		/**
		 * The alpha value of this entity. This value is used for parenting. Any objects whose parents is this object will
		 * take into account the entityAlpha, as it will be propagated to all children.
		 */
		public var entityAlpha:Number;
		/**
		 * The entityAlpha value of the parent entity. Each frame this is propagated down by every entity setting it based on its
		 * parents properties. This allows an entity to keep separate its own local alpha and the alpha it has inherited.
		 */
		public var parentEntityAlpha:Number;

		/**
		 * The velocity of this object. Contains the x, y, and angular velocities. Every frame, if this entity
		 * is <code>active</code> and is not <code>stationary</code>, this object will be moved at the rate contained
		 * in this vector.
		 *
		 * @default (0, 0, 0)
		 */
		public var velocity:AxVector;
		/**
		 * The acceleration of this object. Contains the x, y, and angular accelerations. Every frame, if this entity
		 * is <code>active</code> and is not <code>stationary</code>, this entity's velocity will be adjusted at
		 * the rate contained in this vector.
		 *
		 * @default (0, 0, 0)
		 */
		public var acceleration:AxVector;

		/**
		 * The current rotation, in degrees, of how the entity will be drawn. A rotation of 0 means the entity will be
		 * drawn in the same position as the image that was loaded. Positive rotations go clockwise.
		 *
		 * @default 0
		 */
		public var angle:Number;
		/**
		 * The terminal (or maximum) velocity of this object. If an entity has acceleration, that acceleration will only
		 * increase the objects velocity up until it reaches its terminal velocity. A terminal velocity of 10 means the
		 * terminal velocity in the opposite direction will be -10.
		 *
		 * @default INFINITY
		 */
		public var maxVelocity:AxVector;
		/**
		 * Drag is the amount that the object will slow down when not accelerating. If an object is accelerating, drag will
		 * have no effect on the object. However, once an object stops accelerating, drag will slow the velocity of an
		 * entity down until it reaches 0.
		 *
		 * @default (0, 0, 0)
		 */
		public var drag:AxVector;
		/**
		 * The offset of the bounding box of this entity.
		 * <p>If an entity is loaded with an image that is 100x100, you can use <code>offset, width, and height</code> to
		 * change the bounding box that will affect collisions. The width and height determine the size of the bounding box,
		 * and offset determines how far to the right and down the upper left corner of the bounding box is.</p>
		 */
		public var offset:AxPoint;
		/**
		 * Read-only. Contains the position that this entity had during the previous frame.
		 */
		public var previous:AxPoint;
		/**
		 * A phased entity will trigger collisions, but will act as if it is not solid. Set this to true if you must use
		 * <code>Ax.collide</code> instead of overlap, but you don't want the entities to be affected by colliding.
		 *
		 * @default false
		 */
		public var phased:Boolean;
		/**
		 * Contains which sides this entity is touching on, or'd together. For example, if an entity is standing on the floor
		 * and is moving against a wall to his right, the value of this entity will be DOWN | RIGHT. You can find if an entity
		 * is touching a side using either <code>if (touching &amp; LEFT)</code> or <code>if (isTouching(LEFT))</code>.
		 *
		 * @default NONE
		 */
		public var touching:uint;
		/**
		 * Contains the sides this object was touching the previous frame. See <code>touching</code> for more details.
		 *
		 * @default NONE
		 */
		public var touched:uint;
		/**
		 * For entities that should not move, set this to true in order to skip the calculations for movement. This can be a performance
		 * gain if you have a lot of entities that do not move.
		 *
		 * @default false
		 */
		public var stationary:Boolean;
		/**
		 * Read-only. Contains the midpoint of this entity, updated every frame.
		 */
		public var center:AxPoint;
		/**
		 * Read-only. Contains the velocity that this entity had during the previous frame.
		 */
		public var pvelocity:AxVector;
		/**
		 * The bounds limiting where this entity can move. If null, there are no bounds.
		 */
		public var worldBounds:AxRect;
		/** Counter that allow you to disable counting this function's update for the debugger */
		public var countUpdate:Boolean = true;
		/** Counter that allow you to disable counting this function's draw for the debugger */
		public var countDraw:Boolean = true;
		/** List of timers active on this entity. */
		public var timers:Vector.<AxTimer>;
		/** Temporary timer list used to clean up dead timers. */
		public var timersTemp:Vector.<AxTimer>;

		/**
		 * Creates a new AxEntity at the position passed.
		 *
		 * @param x The initial x value of this entity.
		 * @param y The initial y value of this entity.
		 */
		public function AxEntity(x:Number = 0, y:Number = 0) {
			super(x, y);

			visible = true;
			active = true;
			solid = true;
			exists = true;
			parent = null;
			parentOffset = new AxPoint;
			entityAlpha = 1;
			parentEntityAlpha = 1;
			
			center = new AxPoint(x + width / 2, y + height / 2);
			previous = new AxPoint(x, y);
			velocity = new AxVector;
			pvelocity = new AxVector;
			acceleration = new AxVector;
			maxVelocity = new AxVector(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
			angle = 0;
			drag = new AxVector;
			offset = new AxRect;
			phased = false;
			stationary = false;
			worldBounds = null;
			timers = null;
		}

		/**
		 * Every frame update is called once on every object. This method should be overriden by your objects, and should
		 * contain the game logic that the object should execute every frame. If you want the object to move and execute
		 * its main game logic, *be sure* to call super.update(). When you call super.update(), the state of the object
		 * flips (touching becomes touched, etc), so typically you should call super.update() at the *end* of your object's
		 * update function.
		 */
		public function update():void {
			var i:uint;
			
			if (parent != null) {
				parentOffset.x = parent.x + parent.parentOffset.x;
				parentOffset.y = parent.y + parent.parentOffset.y;
				parentEntityAlpha = parent.entityAlpha * parent.parentEntityAlpha;
			}
			
			if (timers != null) {
				var deadTimers:uint = 0;
				for (i = 0; i < timers.length; i++) {
					if (!timers[i].alive) {
						deadTimers++;
						continue;
					} else if (!timers[i].active) {
						continue;
					}
					timers[i].timer -= Ax.dt;
					while (timers[i].timer <= 0) {
						timers[i].timer += timers[i].delay;
						timers[i].repeat--;
						timers[i].callback();
						if (timers[i].repeat <= 0) {
							timers[i].stop();
							break;
						}
					}
				}
				if (deadTimers >= 5) {
					var temp:Vector.<AxTimer> = timersTemp;
					temp.length = 0;
					for (i = 0; i < timers.length; i++) {
						if (timers[i].alive) {
							temp.push(timers[i]);
						}
					}
					timersTemp = timers;
					timers = temp;
				}
			}
			
			touched = touching;
			touching = NONE;
			
			previous.x = x;
			previous.y = y;
			pvelocity.x = velocity.x;
			pvelocity.y = velocity.y;
			
			if (!(stationary || (velocity.x == 0 && velocity.y == 0 && velocity.a == 0 && acceleration.x == 0 && acceleration.y == 0 && acceleration.a == 0))) {
				velocity.x = calculateVelocity(velocity.x, acceleration.x, drag.x, maxVelocity.x);
				velocity.y = calculateVelocity(velocity.y, acceleration.y, drag.y, maxVelocity.y);
				velocity.a = calculateVelocity(velocity.a, acceleration.a, drag.a, maxVelocity.a);
				
				x += (velocity.x * Ax.dt) + ((pvelocity.x - velocity.x) * Ax.dt / 2);
				y += (velocity.y * Ax.dt) + ((pvelocity.y - velocity.y) * Ax.dt / 2);
				angle += velocity.a * Ax.dt;
				
				if (worldBounds != null) {
					if (x < worldBounds.x) {
						velocity.x = 0;
						acceleration.x = Math.max(0, acceleration.x);
						x = worldBounds.x;
					} else if (x + width > worldBounds.width) {
						velocity.x = 0;
						acceleration.x = Math.min(0, acceleration.x);
						x = worldBounds.width - width;
					}
					
					if (y < worldBounds.y) {
						velocity.y = 0;
						acceleration.y = Math.max(0, acceleration.y);
						y = worldBounds.y;
					} else if (y + height > worldBounds.height) {
						velocity.y = 0;
						acceleration.y = Math.min(0, acceleration.y);
						y = worldBounds.height - height;
					}
				}
			}
			
			center.x = x + width / 2;
			center.y = y + height / 2;
		}

		/**
		 * Every frame, draw is called once on every object in order to render it to the screen. <code>AxEntity</code> is never drawn
		 * to the screen, so this method must be override by any object that wants to be drawn.
		 */
		public function draw():void {
			// override as needed
		}
		
		/**
		 * Calculates the velocity for a single axis using the current velocity, acceleration, drag, and terminal velocity.
		 * 
		 * @param velocity The current velocity of this axis.
		 * @param acceleration The current acceleration of this axis.
		 * @param drag The current drag of this axis.
		 * @param terminal The current terminal velocity of this axis.
		 *
		 * @return The new velocity based on the inputs and the timestep.
		 */
		private function calculateVelocity(velocity:Number, acceleration:Number, drag:Number, terminal:Number):Number {
			if (acceleration != 0) {
				velocity += acceleration * Ax.dt;
			} else {
				var dragEffect:Number = drag * Ax.dt;
				if (velocity - dragEffect > 0) {
					velocity -= dragEffect;
				} else if (velocity + dragEffect < 0) {
					velocity += dragEffect;
				} else {
					velocity = 0;
				}
			}
			
			if (velocity > terminal) {
				velocity = terminal;
			} else if (velocity < -terminal) {
				velocity = -terminal;
			}
			
			return velocity;
		}

		/**
		 * Destroys this object, setting it not to be updated or drawn. Does not remove the object from memory,
		 * you can reuse any objects you destroy.
		 */
		public function destroy():void {
			exists = false;
		}
		
		/**
		 * Revives this object, setting it to be updated and drawn.
		 */
		public function revive():void {
			exists = true;
		}

		/**
		 * Returns whether or not this object is touching a solid object in the direction(s) passed. You can test
		 * a single direction (<code>isTouching(LEFT)</code>) or multiple at once (<code>isTouching(LEFT | DOWN)</code>).
		 *
		 * @param directions The direction flag(s) to test.
		 *
		 * @return True if this object is touching any of the directions passed.
		 *
		 * @see #wasTouching()
		 */
		public function isTouching(directions:uint):Boolean {
			return (touching & directions) > NONE;
		}

		/**
		 * Returns whether or not this object was touching a solid object in the direction(s) passed during the previous
		 * frame.
		 *
		 * @param directions The direction flag(s) to test.
		 *
		 * @return True if this object was touching any of the directions passed.
		 *
		 * @see #isTouching()
		 */
		public function wasTouching(directions:uint):Boolean {
			return (touched & directions) > NONE;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function contains(x:Number, y:Number):Boolean {
			return x >= this.x + parentOffset.x &&
				   y >= this.y + parentOffset.y &&
				   x <= this.right + parentOffset.x &&
				   y <= this.bottom + parentOffset.y;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function overlaps(other:AxRect):Boolean {
			var o:AxEntity = other as AxEntity;
			if (!exists || !o.exists) {
				return false;
			}
			return x + parentOffset.x + AxU.EPSILON < o.x + o.width + o.parentOffset.x &&
				   y + parentOffset.y + AxU.EPSILON < o.y + o.height + o.parentOffset.y &&
				   x + width + parentOffset.x - AxU.EPSILON > o.x + o.parentOffset.x &&
				   y + height + parentOffset.y - AxU.EPSILON > o.y + o.parentOffset.y;
		}
		
		/**
		 * Sets the parent of this entity to another entity.
		 * 
		 * @return This entity.
		 */
		public function setParent(parent:AxEntity):AxEntity {
			this.parent = parent;
			parentOffset.x = parent.x + parent.parentOffset.x;
			parentOffset.y = parent.y + parent.parentOffset.y;
			return this;
		}
		
		/**
		 * Unlinks this object from its parent. If the parent's position was non-zero, this will cause
		 * the object to appear to move, as its position will no longer be relative to the parent.
		 */
		public function removeParent():AxEntity {
			parent = null;
			parentOffset.x = parentOffset.y = 0;
			return this;
		}
		
		/**
		 * Returns the global x position of this entity. While the x value is relative to the parent
		 * entity, the global x is where the entity will be drawn in world space.
		 * 
		 * @return The global x position of this entity.
		 */
		public function get globalX():Number {
			return x + parentOffset.x;
		}
		
		/**
		 * Returns the global y position of this entity. While the y value is relative to the parent
		 * entity, the global y is where the entity will be drawn in world space.
		 * 
		 * @return The global y position of this entity.
		 */
		public function get globalY():Number {
			return y + parentOffset.y;
		}
		
		/**
		 * Sets the opacity value of this entity. A value of 0 means it is completely see through, while a value
		 * of 1 means it is completely opaque.
		 * 
		 * @param opacity The alpha value, between 0 and 1.
		 */
		public function set alpha(opacity:Number):void {
			entityAlpha = opacity;
		}
		
		/**
		 * Gets the opacity value of this entity. A value of 0 means it is completely see through, while a value
		 * of 1 means it is completely opaque.
		 * 
		 * @return The alpha value, between 0 and 1.
		 */
		public function get alpha():Number {
			return entityAlpha;
		}
		
		/**
		 * Helper method that sets horizontal, vertical, and angular velocity of this entity to 0.
		 */
		public function stop():void {
			velocity.x = velocity.y = velocity.a = 0;
		}
		
		/**
		 * Timers are repeatable functions that can be bound to any AxEntity. Take, for example,
		 * the following:
		 * 
		 * <code>sprite.addTimer(5, destroy);</code>
		 * 
		 * This would destroy the sprite after 5 seconds. You can also use timers to register repeating
		 * events. For example:
		 * 
		 * <code>sprite.addTimer(1, function():void { sprite.visible = !sprite.visible; }, 5, 3);</code>
		 * 
		 * This would cause the sprite to flicker visible/invisible 5 times, once per second. The 3 indicates
		 * that the first occurrence would not occur until after 3 seconds, and the following ones would be
		 * spaced 1 second apart.
		 * 
		 * @param delay The delay before this fires, or the delay between firing if set to repeat.
		 * @param callback The function called when the timer fires.
		 * @param repeat The number of times to repeat the timer. 0 indiciates repeat forever.
		 * @param start How long to delay the first execution if repeatable.
		 */
		public function addTimer(delay:Number, callback:Function, repeat:uint = 1, start:Number = -1):AxTimer {
			if (timers == null) {
				timers = new Vector.<AxTimer>;
				timersTemp = new Vector.<AxTimer>;
			}
			
			var timer:AxTimer = new AxTimer(delay, callback, repeat, start);
			timers.push(timer);
			return timer;
		}
		
		/**
		 * Any class that holds onto external resources that should be cleaned up upon deletion should delete those
		 * resources in the dispose method. Be sure to call <code>super.dispose()</code> for parent classes to do their cleanup.
		 */
		public function dispose():void {
			velocity = null;
			pvelocity = null;
			acceleration = null;
			maxVelocity = null;
			previous = null;
			previous = null;
			offset = null;
			drag = null;
			worldBounds = null;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function toString():String {
			return getQualifiedClassName(this) + " @ " + super.toString();
		}
	}
}
