package org.axgl {
	import org.axgl.input.AxMouseButton;

	/**
	 * Stores the x and y values, along with the width and height, of a rectangle object.
	 */
	public class AxRect extends AxPoint {
		/**
		 * The width of this object in pixels.
		 * @default 0
		 */
		public var width:Number;
		/**
		 * The height of this object in pixels.
		 * @default 0
		 */
		public var height:Number;

		/**
		 * Creates a new rectangle with the passed x, y, width, and height.
		 *
		 * @param x The x value of this object.
		 * @param y The y value of this object.
		 * @param width The width of this object in pixels.
		 * @param height The height of this object in pixels.
		 *
		 */
		public function AxRect(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0) {
			super(x, y);
			this.width = width;
			this.height = height;
		}

		/**
		 * Returns whether or not the passed x, y coordinates are contained within this rectangle.
		 *
		 * @param x The x value of the point to check.
		 * @param y The y value of the point to check.
		 *
		 * @return True if the passed point is contained within this rectangle, false otherwise.
		 */
		public function contains(x:Number, y:Number):Boolean {
			return x >= this.x && y >= this.y && x <= this.right && y <= this.bottom;
		}

		/**
		 * Checks whether or not this object overlaps the passed object.
		 *
		 * @param other The object to check.
		 *
		 * @return True if the passed object overlaps this object, false otherwise.
		 */
		public function overlaps(other:AxRect):Boolean {
			return left + AxU.EPSILON < other.right && top + AxU.EPSILON < other.bottom && right - AxU.EPSILON > other.left && bottom - AxU.EPSILON > other.top;
		}

		/**
		 * Check whether or not this object is currently being hovered by the mouse.
		 *
		 * @return True if the mouse is contained within this object, false otherwise.
		 */
		public function hover():Boolean {
			return contains(Ax.mouse.x, Ax.mouse.y);
		}

		/**
		 * Check whether or not this object has just been clicked.
		 *
		 * @return True if the mouse just left clicked this object, false otherwise.
		 */
		public function clicked():Boolean {
			return Ax.mouse.pressed(AxMouseButton.LEFT) && hover();
		}

		/**
		 * Check whether or not the mouse is currently being held down on top this object.
		 *
		 * @return True if the left mouse button is being held and is within this object, false otherwise.
		 */
		public function held():Boolean {
			return Ax.mouse.down(AxMouseButton.LEFT) && hover();
		}

		/**
		 * Check whether or not the mouse has just been released from this object.
		 *
		 * @return True if the left mouse button was just released and is within this object, false otherwise.
		 */
		public function released():Boolean {
			return Ax.mouse.released(AxMouseButton.LEFT) && hover();
		}

		/**
		 * Returns the x coordinate of the left side of this object. This is an alias for <code>x</code>.
		 *
		 * @return The x coordinate of the left side of this object.
		 */
		public function get left():Number {
			return x;
		}

		/**
		 * Returns the x coordinate of the right side of this object. This is an alias for <code>x + width</code>.
		 *
		 * @return The x coordinate of the right side of this object.
		 */
		public function get right():Number {
			return x + width;
		}

		/**
		 * Returns the y coordinate of the top side of this object. This is an alias for <code>y</code>.
		 *
		 * @return The y coordinate of the top side of this object.
		 */
		public function get top():Number {
			return y;
		}

		/**
		 * Returns the y coordinate of the bottom side of this object. This is an alias for <code>y + height</code>.
		 *
		 * @return The y coordinate of the bottom side of this object.
		 */
		public function get bottom():Number {
			return y + height;
		}
		
		override public function toString():String {
			return "(" + x + "," + y + "," + width + "," + height + ")";
		}
	}
}
