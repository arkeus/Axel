package org.axgl {
	import flash.geom.Point;

	/**
	 * A generic vector class consisting of an "x" component, "y" component, and "a" component. The
	 * "a" component denotes angle, and is used to set the angular velocity, angular acceleration, etc.
	 */
	public class AxVector {
		/**
		 * The x component of the vector.
		 * @default 0
		 */
		public var x:Number;
		/**
		 * The y component of the vector.
		 * @default 0
		 */
		public var y:Number;
		/**
		 * The angular component of the vector.
		 * @default 0
		 */
		public var a:Number;

		/**
		 * Creates a new vector with the passed values.
		 *
		 * @param x The x component.
		 * @param y The y component.
		 * @param a The angular component.
		 */
		public function AxVector(x:Number = 0, y:Number = 0, a:Number = 0) {
			this.x = x;
			this.y = y;
			this.a = a;
		}
		
		public function make( x:Number, y:Number, a:Number = 0 ):void
		{
			this.x = x;
			this.y = y;
			this.a = a;
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
		public function fromPoint(point:Point):AxVector {
			x = point.x;
			y = point.y;
			return this;
		}
		
		/**
		 * Provides a more useful string representation when printing this object.
		 * 
		 * @return The string in the format (x,y,a)
		 */
		public function toString():String {
			return "(" + x + "," + y + "," + a + ")";
		}
		
		public function copyFrom( fromPt:AxVector ):void
		{
			make( fromPt.x, fromPt.y, fromPt.a );
		}
	}
}
