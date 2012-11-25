package org.axgl.util {
	/**
	 * Timers are repeatable functions that can be bound to any AxEntity. Take, for example,
	 * the following:
	 * 
	 * <code>sprite.addTimer(5, destroy);</code>
	 * 
	 * This would destroy the sprite after 5 seconds. You can also use timers to register repeating
	 * events. For example:
	 * 
	 * <code>sprite.addTimer(1, function():void { sprite.visible = !sprite.visible; }, 5, 3);</code>
	 * 
	 * This would cause the sprite to flicker visible/invisible 5 times, once per second. The 3 indicates
	 * that the first occurrence would not occur until after 3 seconds, and the following ones would be
	 * spaced 1 second apart.
	 */
	public class AxTimer {
		public var delay:Number;
		public var callback:Function;
		public var repeat:uint;
		public var timer:Number;
		public var active:Boolean;
		public var alive:Boolean;
		
		/**
		 * Creates a new AxTimer.
		 * 
		 * @param delay The delay before this fires, or the delay between firing if set to repeat.
		 * @param callback The function called when the timer fires.
		 * @param repeat The number of times to repeat the timer. 0 indiciates repeat forever.
		 * @param start How long to delay the first execution if repeatable.
		 */
		public function AxTimer(delay:Number, callback:Function, repeat:uint = 1, start:Number = -1) {
			this.delay = delay;
			this.callback = callback;
			this.repeat = repeat;
			this.timer = start < 0 ? delay : start;
			this.active = true;
			this.alive = true;
		}
		
		/**
		 * Pauses the timer without changing its state. You can continue the timer later using start()
		 * if necessary.
		 * 
		 * @return This timer.
		 */
		public function pause():AxTimer {
			if (!alive) {
				return this;
			}
			active = false;
			return this;
		}
		
		/**
		 * Starts the timer after you have called pause() on it.
		 * 
		 * @return This timer.
		 */
		public function start():AxTimer {
			if (!alive) {
				return this;
			}
			active = true;
			return this;
		}
		
		/**
		 * Stops the timer permanently. This timer may be cleaned up eventually, and you cannot call
		 * start() on it.
		 * 
		 * @return This timer.
		 */
		public function stop():AxTimer {
			active = false;
			alive = false;
			return this;
		}
	}
}
