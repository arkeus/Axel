package org.axgl.util {
	import org.axgl.AxU;

	/**
	 * A utility class to represent a range between two numbers. Using a range, you can
	 * store the minimum and maximum for an arbitrary use case, and also quickly choose
	 * a random integer or float between the minimum and maximum.
	 */
	public class AxRange {
		/**
		 * The minimum value.
		 */
		public var min:Number;
		/**
		 * The maximum value.
		 */
		public var max:Number;

		/**
		 * Creates a new range with the given minimum and maximum values.
		 * 
		 * @param min The minimum value.
		 * @param max The maximum value.
		 */
		public function AxRange(min:Number, max:Number) {
			this.min = min;
			this.max = max;
		}

		/**
		 * Returns a random integer between minimum and maximum, inclusive. For example:
		 * 
		 * <listing version="3.0">new AxRange(3, 7).randomInt()</listing>
		 * 
		 * Would return one of: 3, 4, 5, 6, 7.
		 *
		 * @return The randomly chosen integer.
		 */
		public function randomInt():int {
			return AxU.rand(min, max);
		}

		/**
		 * Returns a random float between minimum and maximum, inclusive. For example:
		 * 
		 * <listing version="3.0">new AxRange(3, 7).randomNumber</listing>
		 * 
		 * Would return a number between 3 and 7 such as 4.291 or 6.288.
		 *
		 * @return The randomly chosen number.
		 */
		public function randomNumber():Number {
			return AxU.rand(min * 1000, max * 1000) / 1000;
		}
	}
}
