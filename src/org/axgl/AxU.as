package org.axgl {
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	/**
	 * The Ax Utility class, containing various utility functions to make your life easier. Some of these
	 * are duplicates of flash functions, and are here as they provide much better performance.
	 */
	public class AxU {
		/**
		 * Read-only. Epsilon, a tiny constant value to offset rounding errors.
		 */
		public static const EPSILON:Number = 0.00000001;

		/**
		 * Returns a random integer between min and max, inclusive.
		 *
		 * @example The following code returns an integer between 3 and 7 (3, 4, 5, 6, or 7):
		 *
		 * <listing version="3.0">
		 * AxU.rand(3, 7);
		 * </listing>
		 *
		 * @param min The minimum integer to return.
		 * @param max The maximum integer to return.
		 *
		 * @return The randomly choosen integer.
		 */
		public static function rand(min:int, max:int):int {
			return Math.floor(Math.random() * (max - min + 1)) + min;
		}
		
		/**
		 * Returns a random floating point number between min and max, inclusive. Use toPrecision() to round it
		 * to a specific number of decimal places if needed.
		 *
		 * @example The following code returns a Number between 3.5 and 7.165 (eg. 3.9, 5.4, 3.8, or 6.5):
		 *
		 * <listing version="3.0">
		 * AxU.rand(3.5, 7.165);
		 * </listing>
		 *
		 * @param min The minimum number to return.
		 * @param max The maximum number to return.
		 *
		 * @return The randomly choosen number.
		 */
		public static function randf(min:Number, max:Number):Number {
			return Math.random() * (max - min) + min;
		}

		/**
		 * Returns the absolute value of the passed number.
		 *
		 * @param n The number to get the absolute value of.
		 *
		 * @return The absolute value.
		 */
		public static function abs(n:Number):Number {
			if (n < 0) {
				n = -n;
			}
			return n;
		}

		/**
		 * Clamps the passed <code>value</code> between min and max. If value is less than min, returns
		 * min, if it is greater than max, returns max, else it returns the value itself.
		 *
		 * @param value The value to clamp.
		 * @param min The minimum value.
		 * @param max The maximum value.
		 *
		 * @return The clamped value.
		 */
		public static function clamp(value:Number, min:Number, max:Number):Number {
			if (value > max) {
				return max;
			}
			if (value < min) {
				return min;
			}
			return value;
		}

		/**
		 * Returns the passed duration in the string format of "03:13:45" indicating 3 hours, 13 minutes, and
		 * 45 seconds. If <code>includeHours</code> is false, only returns minutes and seconds (eg. 13:45).
		 * The start and end times are in seconds, and the string returned represents how long has passed between
		 * the two values. If you simply want to convert seconds into duration, pass 0 for start and the number of
		 * seconds for end.
		 *
		 * @param start The start time.
		 * @param end The end time.
		 * @param includeHours Whether or not to include hours in the output.
		 *
		 * @return
		 */
		public static function duration(start:int, end:int, includeHours:Boolean = true):String {
			var dx:int = Math.ceil(end - start);
			var seconds:Number = dx % 60;
			dx /= 60;
			var minutes:Number = dx % 60;
			dx /= 60
			var hours:Number = dx;

			return (includeHours ? ((hours < 10 ? "0" + hours : hours.toString()) + ":") : "") + (minutes < 10 ? "0" + minutes : minutes.toString()) + ":" + (seconds < 10 ? "0" + seconds : seconds.toString());
		}
		
		/**
		 * Opens a URL in a new window.
		 * 
		 * @param url The URL to open.
		 */
		public static function openURL(url:String):void {
			navigateToURL(new URLRequest(url), "_blank");
		}

		/**
		 * Return the angle (in radians) between the source position and the target position.
		 * 
		 * @param sourceX The source x position.
		 * @param sourceY The source y position.
		 * @param targetX The target x position.
		 * @param targetY The target y position.
		 *
		 * @return The angle in radians.
		 */
		public static function getAngle(sourceX:Number, sourceY:Number, targetX:Number, targetY:Number):Number {
			return Math.atan2(targetY - sourceY, targetX - sourceX);
		}
		
		/**
		 * Return the angle (in radians) between the source position and the mouse.
		 * 
		 * @param sourceX The source x position.
		 * @param sourceY The source y position.
		 *
		 * @return The angle in radians.
		 */
		public static function getAngleToMouse(sourceX:Number, sourceY:Number):Number {
			return Math.atan2(Ax.mouse.y - sourceY, Ax.mouse.x - sourceX);
		}
		
		/**
		 * Returns the distance (in pixels) between the source position and the mouse position.
		 * 
		 * @param sourceX The source x position.
		 * @param sourceY The source y position.
		 *
		 * @return The distance in pixels.
		 */
		public static function distanceToMouse(sourceX:Number, sourceY:Number):Number {
			return Math.sqrt((Ax.mouse.x - sourceX) * (Ax.mouse.x - sourceX) + (Ax.mouse.y - sourceY) * (Ax.mouse.y - sourceY));
		}
		
		/**
		 * Calculate the distance between two points.
		 * 
		 * @param Point1	A <code>AxPoint</code> object referring to the first location.
		 * @param Point2	A <code>AxPoint</code> object referring to the second location.
		 * 
		 * @return	The distance between the two points as a floating point <code>Number</code> object.
		 */
		static public function getDistance( Point1:AxPoint, Point2:AxPoint ):Number
		{
			var dx:Number = Point1.x - Point2.x;
			var dy:Number = Point1.y - Point2.y;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		static public function scrambleEntityVector( inVec:Vector.<AxEntity> ):Vector.<AxEntity>
		{
			return inVec.sort( shuffleEntities );
		}
		
		public static function shuffleEntities( a:AxEntity, b:AxEntity ):int 
		{
			return int( Math.round( Math.random() * 2 ) - 1 );
		}
		
		/**
		 * Get the <code>String</code> name of any <code>Object</code>.
		 * 
		 * @param	Obj		The <code>Object</code> object in question.
		 * @param	Simple	Returns only the class name, not the package or packages.
		 * 
		 * @return	The name of the <code>Class</code> as a <code>String</code> object.
		 */
		static public function getClassName(Obj:Object,Simple:Boolean=false):String
		{
			var string:String = getQualifiedClassName(Obj);
			string = string.replace("::",".");
			if(Simple)
				string = string.substr(string.lastIndexOf(".")+1);
			return string;
		}
		
		
		/**
		 * Check to see if two objects have the same class name.
		 * 
		 * @param	Object1		The first object you want to check.
		 * @param	Object2		The second object you want to check.
		 * 
		 * @return	Whether they have the same class name or not.
		 */
		static public function compareClassNames(Object1:Object,Object2:Object):Boolean
		{
			return getQualifiedClassName( Object1 ) == getQualifiedClassName( Object2 );
		}
		
		/**
		 * Look up a <code>Class</code> object by its string name.
		 * 
		 * @param	Name	The <code>String</code> name of the <code>Class</code> you are interested in.
		 * 
		 * @return	A <code>Class</code> object.
		 */
		static public function getClass(Name:String):Class
		{
			return getDefinitionByName( Name ) as Class;
		}
		
		public static function getClassForObject( obj:Object ):Class
		{
			return getClass( getClassName( obj ) );
		}
		
	}
}
