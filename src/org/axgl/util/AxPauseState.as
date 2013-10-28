package org.axgl.util {
	import flash.system.System;
	
	import org.axgl.Ax;
	import org.axgl.AxPoint;
	import org.axgl.AxSprite;
	import org.axgl.AxState;
	import org.axgl.text.AxText;

	/**
	 * The default pause state. Tints the screen and adds a PAUSED text to the lower right.
	 * If you want to add your own pause state, be sure to extend this class and override
	 * the create function. Do not extend AxState, due to safeguards in the state management
	 * system.
	 */
	public class AxPauseState extends AxState {
		override public function create():void {
			// Create tint and text
			var tint:AxSprite = new AxSprite(0, 0).create(Ax.width, Ax.height, 0xbb000000);
			var text:AxText = new AxText(0, Ax.height - 55, null, "@[255,255,255]P@[190,190,190]AUSED");
			text.x = Ax.width - text.width * 4;
			var focus:AxText = new AxText(0, Ax.height - 17, null, "CLICK TO FOCUS");
			focus.x = Ax.width - focus.width - 48;
			// Set properties
			tint.scroll = text.scroll = focus.scroll = new AxPoint(0, 0);
			text.zooms = focus.zooms = false;
			text.scale.x = text.scale.y = 4;
			tint.alpha = 0;
			// Fade the tint in
			tint.fadeIn(0.5);
			// Add to state
			this.add(tint).add(text).add(focus);
			// Garbade collect as an added bonus
			System.gc();
		}
	}
}