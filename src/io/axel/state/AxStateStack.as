package io.axel.state {
	import io.axel.Ax;

	/**
	 * A class containing functionality for dealing with a stack of states. Allows you to push and pop states from
	 * the stack, along with gain information about the stack.
	 */
	public class AxStateStack {
		/**
		 * The stack of states. The topmost state is the current state. Depending on the value of persistantUpdate
		 * and persistantDraw the lower states may or may not be drawn and updated.
		 */
		public var states:Vector.<AxState>;
		/**
		 * When you pop off states, this holds those states until the end of the frame so that it can dispose of
		 * them cleanly without affecting any currently executing code.
		 */
		protected static var destroyed:Vector.<AxState>;

		/**
		 * Creates a new state stack.
		 */
		public function AxStateStack() {
			states = new Vector.<AxState>;
			destroyed = new Vector.<AxState>;
		}

		/**
		 * Pushes a state on top of the state stack. This does not destroy the previous state. If you'd
		 * like to return to the previous state, you can call popState to pop the new state off the top
		 * of the stack.
		 *
		 * @param state The state you want to push onto the stack.
		 *
		 * @return The newly pushed state.
		 */
		public function push(state:AxState):AxState {
			if (states.length > 0) {
				states[states.length - 1].onPause(Object(state).constructor);
			}

			Ax.keys.releaseAll();
			Ax.mouse.releaseAll();

			states.push(state);
			state.create();
			return state;
		}

		/**
		 * Pops the current state off the top of the stack and disposes it. Note that the state isn't disposed
		 * until we are done processing the current frame, which makes it safe to pop off a state while that
		 * state is actively executing.
		 */
		public function pop():void {
			Ax.keys.releaseAll();
			Ax.mouse.releaseAll();

			var previousState:AxState = states.pop();
			destroyed.push(previousState);

			if (states.length > 0) {
				current.onResume(Object(previousState).constructor);
			}
		}

		/**
		 * Switches between two states. This will destroy the previous state, and replace it with the new
		 * state. If you'd like to keep the current state allow in order to return to it later, use
		 * <code>push</code> instead.
		 *
		 * @param state The new state to switch to.
		 *
		 * @return The new state.
		 */
		public function change(state:AxState):AxState {
			pop();
			return push(state);
		}

		/**
		 * Returns the current state in the game.
		 *
		 * @return The current state.
		 */
		public function get current():AxState {
			if (states.length <= 0) {
				throw new Error("There are no states on the stack");
			}
			return states[states.length - 1];
		}

		/**
		 * Returns the number of states on the stack.
		 * 
		 * @return The number of states on the stack.
		 */
		public function get length():uint {
			return states.length;
		}

		/**
		 * Updates all the states on the stack that either have persistantUpdate set to true, or are the top
		 * (active) state. Updates are done from bottom to top.
		 */
		public function update():void {
			for (var i:uint = 0; i < states.length; i++) {
				var state:AxState = states[i];
				if (i == states.length - 1 || state.persistantUpdate) {
					state.update();
				}
			}
		}

		/**
		 * Draws all the states on the stack that either have persistantDraw set to true, or are the top
		 * (active) state. Drawing is done from bottom to top.
		 */
		public function draw():void {
			for (var i:uint = 0; i < states.length; i++) {
				var state:AxState = states[i];
				if (i == states.length - 1 || state.persistantDraw) {
					state.draw();
				}
			}
		}

		/**
		 * Disposes all destroyed states. Because a state can be popped off in the middle of being executed,
		 * we don't want to immediately dispose it. Instead if is stored until all processing for the frame
		 * is done, at which point we dispose of it.
		 */
		public function disposeDestroyedStates():void {
			for (var i:uint = 0; i < destroyed.length; i++) {
				destroyed.pop().dispose();
			}
		}
	}
}
