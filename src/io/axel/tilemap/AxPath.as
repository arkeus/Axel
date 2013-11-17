package io.axel.tilemap {
	import io.axel.AxPoint;

	/**
	 * A class to represent a path through a tilemap. It consists of a series of points, where
	 * each point is the next step in the path.
	 */
	public class AxPath {
		/** The list of nodes in the path. */
		public var nodes:Vector.<AxPoint>;
		
		/**
		 * Creates a new empty path.
		 */
		public function AxPath() {
			nodes = new Vector.<AxPoint>;
		}
		
		/**
		 * Removes the front node and returns it.
		 */
		public function shift():AxPoint {
			return nodes.shift();
		}
		
		/**
		 * Pushes a new node to the front of the list.
		 */
		public function unshift(x:Number, y:Number):void {
			nodes.unshift(new AxPoint(x, y));
		}
		
		/**
		 * Pushes a new node to the end of the list.
		 */
		public function push(x:Number, y:Number):void {
			nodes.push(new AxPoint(x, y));
		}
		
		/**
		 * Removes and returns the last node in the path.
		 */
		public function pop():AxPoint {
			return nodes.pop();
		}
		
		/**
		 * Returns the node at the passed index.
		 */
		public function get(index:uint):AxPoint {
			if (nodes.length <= index) {
				return null;
			}
			return nodes[index];
		}
		
		/**
		 * Returns the path as a string in a human readable format.
		 */
		public function toString():String {
			return nodes.join(" -> ");
		}
	}
}
