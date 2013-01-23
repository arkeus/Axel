package org.axgl.util {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.display3D.textures.Texture;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getQualifiedClassName;
	
	import org.axgl.Ax;
	import org.axgl.AxSprite;
	import org.axgl.render.AxShader;
	import org.axgl.render.AxTexture;
	
	public class AxCache {
		private static var vertexBuffers:Object;
		private static var debugVertexBuffers:Object;
		private static var textures:Object;
		private static var shaders:Object;
		
		{
			vertexBuffers = new Object;
			debugVertexBuffers = new Object;
			textures = new Object;
			shaders = new Object;
		}
		
		public static function shader(shaderKey:*, vertex:Array, fragment:Array, rowSize:uint):AxShader {
			var key:String = shaderKey is String ? shaderKey : getQualifiedClassName(shaderKey);
			var shader:AxShader = shaders[key] as AxShader;
			if (shader == null) {
				if (key == "null") {
					throw new Error();
				}
				shader = new AxShader(vertex, fragment, rowSize);
				shaders[key] = shader;
			}
			return shader;
		}
		
		public static function vertexBuffer(width:uint, height:uint, uvWidth:Number, uvHeight:Number):VertexBuffer3D {
			var key:String = width + "_" + height + "_" + uvWidth + "_" + uvHeight;
			var cached:VertexBuffer3D = vertexBuffers[key] as VertexBuffer3D;
			if (cached == null) {
				var vertexData:Vector.<Number> = Vector.<Number>([ // x, y, u, v
					0, 		0, 			0, 			0,
					width,  0, 			uvWidth, 	0,
					0, 		height, 	0, 			uvHeight,
					width,  height, 	uvWidth, 	uvHeight,
				]);
				cached = Ax.context.createVertexBuffer(vertexData.length / 4, 4);
				cached.uploadFromVector(vertexData, 0, vertexData.length / 4);
				vertexBuffers[key] = cached;
			}
			return cached;
		}
		
		public static function debugVertexBuffer(width:uint, height:uint, uvWidth:Number, uvHeight:Number):VertexBuffer3D {
			var key:String = width + "_" + height + "_" + uvWidth + "_" + uvHeight;
			var cached:VertexBuffer3D = debugVertexBuffers[key] as VertexBuffer3D;
			if (cached == null) {
				var debugBorderWidth:uint = 1;
				var vertexData:Vector.<Number> = Vector.<Number>([ // x, y, z, u, v
					// top
					0, 							0, 							0,
					width, 						0, 							0,
					width,  					debugBorderWidth, 			0,
					0, 							debugBorderWidth, 			0,
					// left
					0, 							0, 							0,
					debugBorderWidth,  			0, 							0,
					debugBorderWidth,  			height, 					0,
					0, 							height, 					0,
					// bottom
					0, 							height-debugBorderWidth,	0,
					width, 						height-debugBorderWidth, 	0,
					width, 				 		height, 					0,
					0, 							height, 					0,
					// right
					width-debugBorderWidth, 	0, 							0,
					width,  					0, 							0,
					width,  					height, 					0,
					width-debugBorderWidth, 	height, 					0,
				]);
				cached = Ax.context.createVertexBuffer(vertexData.length / 3, 3);
				cached.uploadFromVector(vertexData, 0, vertexData.length / 3);
				debugVertexBuffers[key] = cached;
			}
			return cached;
		}
		
		public static function texture(resource:*):AxTexture {
			var rawBitmap:BitmapData;
			if (resource is Class) {
				if (textures[resource] != null) {
					return textures[resource];
				}
				rawBitmap = (new resource() as Bitmap).bitmapData;
			} else if (resource is BitmapData) {
				rawBitmap = resource;
			} else {
				throw new Error("Invalid resource:", resource);
			}
			
			var textureWidth:uint = nextPowerOfTwo(rawBitmap.width);
			var textureHeight:uint = nextPowerOfTwo(rawBitmap.height);
			
			var textureBitmap:BitmapData;
			if (textureWidth == rawBitmap.width && textureHeight == rawBitmap.height) {
				textureBitmap = rawBitmap;
			} else {
				textureBitmap = new BitmapData(textureWidth, textureHeight, true, 0x0);
				textureBitmap.copyPixels(rawBitmap, new Rectangle(0, 0, rawBitmap.width, rawBitmap.height), new Point(0, 0));
			}
			
			var texture:Texture = Ax.context.createTexture(textureWidth, textureHeight, Context3DTextureFormat.BGRA, false);
			texture.uploadFromBitmapData(textureBitmap);
			
			textures[resource] = new AxTexture(texture, textureWidth, textureHeight, rawBitmap.width, rawBitmap.height);
			return textures[resource];
		}
		
		private static function nextPowerOfTwo(current:uint):uint {
			current--;
			current = (current >> 1) | current;
			current = (current >> 2) | current;
			current = (current >> 4) | current;
			current = (current >> 8) | current;
			current = (current >> 16) | current;
			current++;
			return current;
		}
	}
}
