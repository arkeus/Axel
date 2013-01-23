package org.axgl.util {
	import flash.system.System;
	
	import org.axgl.Ax;
	import org.axgl.AxGroup;
	import org.axgl.AxSprite;
	import org.axgl.resource.AxResource;
	import org.axgl.text.AxText;

	public class AxDebugger extends AxGroup {
		private static const MEGABYTES_IN_BYTES:uint = 1024 * 1024;
		private var topBar:AxSprite;
		private var bottomBar:AxSprite;
		private var fpsText:AxText;
		private var memoryText:AxText;
		private var libraryText:AxText;
		private var modeText:AxText;
		private var timeText:AxText;
		private var titleText:AxText;
		
		private var updateTime:uint = 0;
		private var drawTime:uint = 0;
		public var tris:uint = 0;
		public var draws:uint = 0;
		public var updates:uint = 0;
		
		private var displayUpdateTime:uint = 0;
		private var displayDrawTime:uint = 0;
		private var displayTris:uint = 0;
		private var displayDraws:uint = 0;
		private var displayUpdates:uint = 0;
		
		private static const HEIGHT:uint = 15;
		
		public function AxDebugger() {			
			var topBar:AxSprite = new AxSprite(0, 0).create(Ax.width, 15, 0xcc000000);
			topBar.scroll.x = topBar.scroll.y = 0;
			topBar.zooms = topBar.countTris = false;
			this.add(topBar);
			
			var bottomBar:AxSprite = new AxSprite(0, Ax.height - 15).create(Ax.width, 15, 0xcc000000);
			bottomBar.scroll.x = bottomBar.scroll.y = 0;
			bottomBar.zooms = bottomBar.countTris = false;
			this.add(bottomBar);
			
			var version:Array = Ax.LIBRARY_VERSION.split(".");
			var debugMode:String = Ax.debug ? "@[255,90,90]Debug" : "@[200,200,200]Release";
			libraryText = new AxText(4, 3, AxResource.FONT, Ax.LIBRARY_NAME + " @[160,160,160]Version @[150,150,255]" + version[0] + "@[10,255,255].@[180,180,255]" + version[1] + "@[255,255,255].@[210,210,255]" + version[2] + " " + debugMode);
			libraryText.scroll.x = libraryText.scroll.y = 0;
			libraryText.zooms = libraryText.countTris = false;
			this.add(libraryText);
			
			fpsText = new AxText(4, Ax.height - HEIGHT + 3, AxResource.FONT, "FPS: 0/0");
			fpsText.scroll.x = fpsText.scroll.y = 0;
			fpsText.zooms = fpsText.countTris = false;
			this.add(fpsText);
			
			memoryText = new AxText(70, Ax.height - HEIGHT + 3, AxResource.FONT, "Memory: 0MB");
			memoryText.scroll.x = memoryText.scroll.y = 0;
			memoryText.zooms = memoryText.countTris = false;
			this.add(memoryText);
			
			modeText = new AxText(0, 3, AxResource.FONT, "---", Ax.width - 3, "right");
			modeText.scroll.x = modeText.scroll.y = 0;
			modeText.zooms = modeText.countTris = false;
			this.add(modeText);
			
			timeText = new AxText(0, Ax.height - HEIGHT + 3, AxResource.FONT, "---", Ax.width - 5, "right");
			timeText.scroll.x = timeText.scroll.y = 0;
			timeText.zooms = timeText.countTris = false;
			this.add(timeText);
			
			titleText = new AxText(0, 3, AxResource.FONT, "", Ax.width, "center");
			titleText.scroll.x = titleText.scroll.y = 0;
			titleText.zooms = titleText.countTris = false;
			this.add(titleText);
			
			active = false;
			countUpdate = countDraw = false;
		}
		
		public function setUpdateTime(time:uint):void {
			if (time < 1) {
				time = 1;
			}
			updateTime = time;
		}
		
		public function setDrawTime(time:uint):void {
			if (time < 1) {
				time = 1;
			}
			drawTime = time;
		}
		
		public function resetStats():void {
			updates = 0;
			draws = 0;
			tris = 0;
		}
		
		public function heartbeat():void {
			if (!active) {
				return;
			}
			
			displayUpdateTime = updateTime;
			displayUpdates = updates;
			displayDrawTime = drawTime;
			displayDraws = draws;
			displayTris = tris;
			
			var colorRatio:uint = Math.floor(Ax.fps / Ax.requestedFramerate * 255);
			fpsText.text = "@[190,190,190]FPS: @[" + (255 - colorRatio) + "," + colorRatio + ",0]" + Ax.fps + "@[90,90,90]/" + Ax.requestedFramerate;
			memoryText.text = "@[190,190,190]Memory: @[100,150,255]" + (System.totalMemory / MEGABYTES_IN_BYTES).toFixed(1) + "@[130,130,130] MB";
			timeText.text = "@[190,190,190]Updates: @[100,150,255]" + displayUpdates + " @[170,170,170](@[100,140,200]" + displayUpdateTime + "@[130,130,130]ms@[170,170,170]) @[190,190,190]Draws: @[100,150,255]" + displayDraws + " @[170,170,170](@[100,140,200]" + displayDrawTime + "@[130,130,130]ms@[170,170,170]) @[190,190,190][@[100,150,255]" + Ax.states.length + "@[190,190,190]]";
			
			var renderMode:String = Ax.mode == "Software Mode" ? "@[255,0,0]Software Rendering" : "@[150,180,255]Hardware Rendering";
			modeText.text = renderMode + " @[190,190,190]Tris: @[100,150,255]" + displayTris;
			
			if (title != null) {
				titleText.text = title;
			}
		}
		
		public function set title(title:String):void {
			titleText.text = title;
		}
		
		public function get title():String {
			return titleText.text;
		}
	}
}
