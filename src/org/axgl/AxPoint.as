package org.axgl {
	import flash.geom.Point;

	/**
	 * Stores the x and y values of a 2 dimensional point as numbers.
	 */
	public class AxPoint {
		/**
		 * The x value of this object.
		 *
		 * @default 0
		 */
		public var x:Number;
		/**
		 * The y value of this object.
		 *
		 * @default 0
		 */
		public var y:Number;

		/**
		 * Creates a new AxPoint with the passed values.
		 *
		 * @param x The x value of this object.
		 * @param y The y value of this object.
		 */
		public function AxPoint(x:Number = 0, y:Number = 0) {
			this.x = x;
			this.y = y;
		}

		/**
		 * Creates a new <code>flash.geom.Point</code> class with the values in this AxPoint and returns it.
		 *
		 * @param point The point to fill the values in for; will create a new instance of a Point if null.
		 * 
		 * @return The instance of the flash Point.
		 * 
		 * @see flash.geom.Point
		 */
		public function toPoint(point:Point = null):Point {
			if (point == null) {
				point = new Point(x, y);
			} else {
				point.x = x;
				point.y = y;
			}
			return point;
		}

		/**
		 * Copies the contents of the passed <code>flash.geom.Point</code> class into this AxPoint.
		 *
		 * @param point The <code>flash.geom.Point</code> to copy the values from.
		 *
		 * @return The AxPoint.
		 * 
		 * @see flash.geom.Point
		 */
		public function fromPoint(point:Point):AxPoint {
			x = point.x;
			y = point.y;
			return this;
		}
		
		/**
		 * Provides a more useful string representation when printing this object.
		 * 
		 * @return The string in the format (x,y)
		 */
		public function toString():String {
			return "(" + x + "," + y + ")";
		}
	}
}
