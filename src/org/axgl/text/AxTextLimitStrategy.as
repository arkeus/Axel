package org.axgl.text {
	/**
	 * A structure containing information for how to limit the number of lines in an AxText. If you
	 * set the string to something that ends up being split to more than {limit} lines, the extra
	 * lines are discarded, either from the start or end, based on {keepType}.
	 */
	public class AxTextLimitStrategy {
		public static const START:uint = 0;
		public static const END:uint = 1;
		
		/**
		 * The keep type. If START, keeps X lines from the start; if END, keeps X lines from the end.
		 */
		public var keepType:uint;
		/**
		 * The number of lines to limit the text to. If the text ends up being more than this amount
		 * of lines, the extra lines are discarded.
		 * Note this only affects drawing, the actual value of the text will be completely intact.
		 */
		public var limit:uint;
		
		public function AxTextLimitStrategy(limit:uint, keepType:uint = END) {
			this.limit = limit;
			this.keepType = keepType;
		}
	}
}
