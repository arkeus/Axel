package org.axgl.util {
	import flash.utils.getTimer;

	/**
	 * A utility class to allow you to quickly profile some code to see how long it takes to run.
	 */
	public class AxProfiler {
		/**
		 * The start time of the profiling.
		 */
		private static var startTime:Number;
		/**
		 * The end time of the profiling.
		 */
		private static var endTime:Number;
		/**
		 * The name of this profiling block.
		 */
		private static var name:String;

		/**
		 * Starts the profiling timer and sets the name.
		 * 
		 * @param name The name of this blocked, used when viewing the result.
		 */
		public static function start(name:String):void {
			startTime = getTimer();
			AxProfiler.name = name;
		}

		/**
		 * Ends the profiling timer and returns how long has passed since you called start.
		 */
		public static function end():void {
			endTime = getTimer();
			trace("AxProfiler::END - " + name + "(" + (endTime - startTime) + "ms)");
		}

		/**
		 * Profiles the function passed to this, running it <code>times</code> times. This allows you
		 * to quickly profile a quick block of code by having it run many times. For example:
		 * 
		 * <listing version="3.0">
		 * AxProfiler.repeat("adding", 1000000, function():void { var x:uint = 5 + 11; });
		 * </listing>
		 * 
		 * This would time how long it takes to add 2 numbers one million times. This is useful when
		 * comparing two different solutions to see which would be more efficient.
		 * 
		 * @param name The name to use when outputting the results.
		 * @param times The number of times to run the given block.
		 * @param func The function to run repeatedly.
		 */
		public static function repeat(name:String, times:uint, func:Function):void {
			start(name);
			for (var i:uint = 0; i < times; i++) {
				func();
			}
			end();
		}
	}
}
