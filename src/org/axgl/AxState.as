package org.axgl {

	/**
	 * A class representing a game state. Each state in your game should be a subclass extending
	 * AxState. For example, you may have an AxState for your main menu, one for your game, one
	 * for your pause menu, etc. Each state should override create for code that should run when
	 * the state is create, and update for game logic that should be run every frame. If needed,
	 * you can also override draw for specialized drawing.
	 *
	 * <p>If you want to switch states permanently, use Ax.switchState. However, if you want to push a new
	 * state temporarily without losing the current state, use Ax.pushState to switch to the new state,
	 * and then Ax.popState to go back to the earlier state.</p>
	 */
	public class AxState extends AxGroup {
		/**
		 * Determines whether or not this state is updated even when it is not the active state. For
		 * example, if you have your game state first, and then you push a menu state on top of it,
		 * if this is set to true, the game state would continue to update in the background. By default
		 * this is false, so background states will be "paused" when they are not active.
		 * 
		 * @default false 
		 */
		public var persistantUpdate:Boolean;
		/**
		 * Determines whether or not this state is updated even when it is not the active state. For
		 * example, if you have your game state first, and then yuo push a menu state on top of it,
		 * if this is set to true, the game state would continue to be drawn behind the pause state.
		 * By default this is true, so background states will continue to be drawn behind the current
		 * state. If background states are not visible when you have a different state on top, you should
		 * set this to false for improved performance.
		 * 
		 * @default true 
		 */
		public var persistantDraw:Boolean;

		/**
		 * State constructor. State creation logic should be placed in create() and not here
		 * in the constructor.
		 */
		public function AxState() {
			this.persistantUpdate = false;
			this.persistantDraw = true;
		}

		/**
		 * Create runs every time you create a new state. By placing logic in create instead of the
		 * constructor, you ensure that the stage is set up and the engine is running when this logic
		 * runs, which will prevent issues that arrise when placing code in the constructor.
		 */
		public function create():void {
			// Override as needed
		}
		
		/**
		 * This function is called whenever this state loses focus due to another state being pushed
		 * on top of it. Override it to provide specific logic that fires just before the state is
		 * switched away from.
		 * 
		 * @param sourceState The class of the state that was pushed on the stack that now has focus.
		 */
		public function onPause(sourceState:Class):void {
			// Override as needed
		}
		
		/**
		 * This function is called whenever focus returns this to state due to another state being popped
		 * off the stack. Override it to provide specific logic that fires immediately when this state
		 * is switched to.
		 * 
		 * @param sourceState The class of the state that was popped off to reveal this state.
		 */
		public function onResume(sourceState:Class):void {
			// Override as needed
		}
	}
}
