package org.axgl.util {

	/**
	 * A class representing a sprite's animation.
	 */
	public class AxAnimation {
		/** The name of the animation, used when you want to play the animation. */
		public var name:String;
		/** The list of frames in the animation. */
		public var frames:Vector.<uint>;
		/** The framerate the animation should play at. */
		public var framerate:uint;
		/** Whether or not this animation is looped.*/
		public var looped:Boolean;

		/**
		 * Creates a new animation.
		 * 
		 * @param name The name of the animation.
		 * @param frames The list of frames in the animation.
		 * @param framerate The framerate the animation should play at.
		 * @param looped Whether or not this animation is looped.
		 */
		public function AxAnimation(name:String, frames:Array, framerate:uint, looped:Boolean = true) {
			this.name = name;
			this.frames = Vector.<uint>(frames);
			this.framerate = framerate;
			this.looped = looped;
		}
		
		public function dispose():void {
			frames = null;
		}
	}
}
