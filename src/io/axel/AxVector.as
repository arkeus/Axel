package io.axel {

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
		
		/**
		 * Provides a more useful string representation when printing this object.
		 * 
		 * @return The string in the format (x,y,a)
		 */
		public function toString():String {
			return "(" + x + "," + y + "," + a + ")";
		}
	}
}
