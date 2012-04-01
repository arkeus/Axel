package org.axgl {
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
		public var terminal:AxVector;
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
			
			center = new AxPoint(x + width / 2, y + height / 2);
			previous = new AxPoint(x, y);
			velocity = new AxVector;
			pvelocity = new AxVector;
			acceleration = new AxVector;
			terminal = new AxVector(Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
			angle = 0;
			drag = new AxVector;
			offset = new AxRect;
			phased = false;
			stationary = false;
			worldBounds = null;
		}

		/**
		 * Every frame update is called once on every object. This method should be override by your objects, and should
		 * contain the game logic that the object should execute every frame.
		 */
		public function update():void {
			// override as needed
		}

		/**
		 * Every frame, systemUpdate is called once on every object immediately after update. This method handles updating
		 * the motion and position for objects that are <code>active</code> and not <code>stationary</code>. If you override
		 * this method, but want your object to still move, you must call <code>super.systemUpdate()</code>.
		 */
		public function systemUpdate():void {
			touched = touching;
			touching = NONE;

			previous.x = x;
			previous.y = y;
			pvelocity.x = velocity.x;
			pvelocity.y = velocity.y;

			if (stationary || (velocity.x == 0 && velocity.y == 0 && velocity.a == 0 && acceleration.x == 0 && acceleration.y == 0 && acceleration.a == 0)) {
				return;
			}
			
			velocity.x = calculateVelocity(velocity.x, acceleration.x, drag.x, terminal.x);
			velocity.y = calculateVelocity(velocity.y, acceleration.y, drag.y, terminal.y);
			velocity.a = calculateVelocity(velocity.a, acceleration.a, drag.a, terminal.a);

			x += (velocity.x * Ax.dt) + ((pvelocity.x - velocity.x) * Ax.dt / 2);
			y += (velocity.y * Ax.dt) + ((pvelocity.y - velocity.y) * Ax.dt / 2);
			angle += velocity.a * Ax.dt;
			
			center.x = x + width / 2;
			center.y = y + height / 2;
			
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
		 * Any class that holds onto external resources that should be cleaned up upon deletion should delete those
		 * resources in the dispose method. Be sure to call <code>super.dispose()</code> for parent classes to do their cleanup.
		 */
		public function dispose():void {
			velocity = null;
			pvelocity = null;
			acceleration = null;
			terminal = null;
			previous = null;
			previous = null;
			offset = null;
			drag = null;
			worldBounds = null;
		}
	}
}
