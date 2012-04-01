package org.axgl.text {
	/**
	 * A class representing a line of text. Used for splitting text into lines and aligning text.
	 */
	public class AxTextLine {
		/** The text of this line. */
		public var text:String;
		/** The width of this line. */
		public var width:int;

		/**
		 * Creates a new line of text with the given contents and width.
		 * 
		 * @param text The line of text.
		 * @param width The width of the line.
		 */
		public function AxTextLine(text:String, width:int) {
			this.text = text;
			this.width = width;
		}
	}
}
