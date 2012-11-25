package org.axgl.text {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	
	import org.axgl.Ax;
	import org.axgl.AxPoint;
	import org.axgl.AxRect;
	import org.axgl.render.AxTexture;
	import org.axgl.util.AxCache;

	/**
	 * A font object representing a font in your game. When creating an AxText, you must supply an AxFont that the text
	 * should be drawn with. You can create an AxFont either from a bitmap (with all the glyphs) or from a system font.
	 * To construct a new AxFont, do not use the constructor, either use AxFont.fromBitmap or AxFont.fromFont.
	 *
	 * <p>To import from a bitmap, create a new image with all the glyphs of the font on a single row. Each glyph can be
	 * a different width. The upper left corner of the image should be a colored pixel that represents your delimiter. Then
	 * the upper right pixel of each glyph should be that same pixel. For an example of how to construct your bitmap font,
	 * look at org/axgl/resource/font.png. Importing from a bitmap is the best method, as your font is guaranteed to look
	 * the same across all platforms, and it is much more efficient.</p>
	 *
	 * <p>To import from a system font, use the fromFont method. If you are simply importing a font installed on the machine
	 * (not suggested, as it will be a different font on computers without that font), pass <code>embedded</code> as false. You should use
	 * the installed font's name as the font.
	 * You can also embed the font in the program as follows:
	 *
	 * <listing version="3.0">[Embed(source="/org/axgl/resource/fontfile.ttf", fontFamily="FAMILYNAME", embedAsCFF="false")] public static const font:String;</listing>
	 *
	 * And you would then use FAMILYNAME as your font name. This method is slower, and is not guaranteed to always appear
	 * the same on other computers, unless you embed the font in your SWF.</p>
	 */
	public class AxFont {
		/**
		 * The internal texture used to render the font glyphs.
		 */
		public var texture:AxTexture;
		/**
		 * The width of the font, 0 indicating variable width.
		 */
		public var width:uint;
		/**
		 * The height of the font.
		 */
		public var height:uint;
		/**
		 * The alphabet used by the font, indicating all the glyphs present on the glyph sheet.
		 */
		public var alphabet:String;
		/**
		 * A dictionary mapping each character in the alphabet to the AxCharacter representing it.
		 */
		public var characters:Dictionary;
		/**
		 * The spacing of this font, horizontal representing the spacing between each character, and vertical
		 * representing the spacing between each line.
		 */
		public var spacing:AxPoint;

		/**
		 * Creates a new AxFont. You should not use this, but use AxFont.fromBitmap and AxFont.fromFont instead.
		 */
		public function AxFont() {
			this.characters = new Dictionary;
		}

		/**
		 * Creates a new font from a bitmap image. Hspacing represents the extra spacing between each character, and the vspacing
		 * represents the extra spacing between each line, both of which can be negative. Width should only be set if you have
		 * a fixed-width font, while height should be set if you have more than one row of glyphs. Alphabet declares the list of glyphs
		 * in your font. If you only want to create a font for numbers, you can create the sprite sheet only to contain the
		 * glyphs for numbers, and set your alphabet to the numbers in the order they appear in your sprite sheet.
		 *
		 * <p>To import from a variable width bitmap, create a new image with all the glyphs of the font on a single row. Each glyph can be
		 * a different width. The upper left corner of the image should be a colored pixel that represents your delimiter. Then
		 * the upper right pixel of each glyph should be that same pixel. For an example of how to construct your bitmap font,
		 * look at org/axgl/resource/font.png. Importing from a bitmap is the best method, as your font is guaranteed to look
		 * the same across all platforms, and it is much more efficient.</p>
		 *
		 * <p>You can also create a fixed width bitmap. Create a sprite sheet with every character's box the same width and height, and load
		 * using the width and height parameters set appropriately. When using this method, you should not have an extra row at the top
		 * with delimiter pixels, and you may also have multiple rows of glyphs.</p>
		 *
		 * @param resource The embedded image file to load the glyphs from.
		 * @param hspacing The horizontal spacing to place between each character.
		 * @param vspacing The vertical spacing to place between each line of text.
		 * @param width The width of each character, 0 if you are loading a variable width font.
		 * @param height The height of each character, 0 if you have a single row of glyphs.
		 * @param alphabet The alphabet to use when loading glyphs, in the order they appear in the embedded image file.
		 *
		 * @return The AxFont you will use when creating AxText objects with this font.
		 * @throws Error If the number of characters in your alphabet doesn't match the number in the sprite sheet.
		 */
		public static function fromBitmap(resource:Class, hspacing:int = 0, vspacing:int = 2, width:uint = 0, height:uint = 0, alphabet:String = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-=_+[]{};':\\\",./<>?~!@#$%^&*()"):AxFont {
			var af:AxFont = new AxFont;
			var bitmap:BitmapData = (new resource() as Bitmap).bitmapData;

			af.texture = AxCache.texture(resource);
			af.width = width;
			af.height = height == 0 ? bitmap.height : height;
			af.alphabet = alphabet;
			af.spacing = new AxPoint(hspacing, vspacing);
			height = af.height;

			var offset:AxPoint = new AxPoint(0, 0);
			var characterArray:Array = alphabet.split("");
			var separator:uint = bitmap.getPixel(0, 0);
			var rows:uint = bitmap.height / height;
			var characterHeightPixels:Number = height;
			var characterHeight:Number = height / af.texture.height;
			var x:uint, y:uint, characterWidthPixels:uint, characterWidth:Number;
			var u:Number, v:Number, char:String;

			if (width == 0) { // variable width
				for (y = 1; y < bitmap.height; y += height) {
					for (x = 0; x < bitmap.width; x++) {
						if (x == 0 && y == 1) {
							offset.x = 1;
							continue;
						}
						var pixel:uint = bitmap.getPixel(x, y - 1);
						if (pixel == separator) {
							char = characterArray.shift();
							characterWidthPixels = x - offset.x;
							characterWidth = characterWidthPixels / af.texture.width;
							u = offset.x / af.texture.width;
							v = offset.y / af.texture.height;
							af.characters[char] = new AxCharacter(characterWidthPixels, characterHeightPixels, new AxRect(u, v, characterWidth, characterHeight));
							offset.x = x + 1;
						}
					}
					offset.y += height + 1;
					offset.x = 0;
				}
			} else { // fixed width
				characterWidthPixels = width;
				characterWidth = width / af.texture.width;

				for (y = 0; y < bitmap.height; y += height) {
					for (x = 0; x < bitmap.width; x += width) {
						char = characterArray.shift();
						u = x / af.texture.width;
						v = y / af.texture.height;
						af.characters[char] = new AxCharacter(characterWidthPixels, characterHeightPixels, new AxRect(u, v, characterWidth, characterHeight));
					}
				}
			}

			if (characterArray.length > 0) {
				throw new Error(characterArray.join(":") + "Invalid bitmap font image. Number of characters in image doesn't match alphabet.");
			}

			return af;
		}

		/**
		 * Creates a new AxFont from a system font, either installed on the player's machine or embedded within the SWF. This will create a sprite
		 * sheet from that font, used to draw any text. As such, the settings you use for this method (size, bold, italic) cannot be changed unless you
		 * create another font.
		 *
		 * <p>If you are simply importing a font installed on the machine (not suggested, as it will be a different font on computers without that font),
		 * passed embedded as false. You should use the installed font's name as the font. You can also embed the font in the program as follows:
		 *
		 * <listing version="3.0">[Embed(source="/org/axgl/resource/fontfile.ttf", fontFamily="FAMILYNAME", embedAsCFF="false")] public static const font:String;</listing>
		 *
		 * And you would then use FAMILYNAME as your font name. This method is slower, and is not guaranteed to always appear the same on other computers,
		 * unless you embed the font in your SWF.</p>
		 *
		 * @param font The family name of the font, eg. "arial".
		 * @param embedded Whether or not this font is embedded in your game. Must be set to the correct value to load the font.
		 * @param size The size of the font to use.
		 * @param bold Whether or not to bold the font.
		 * @param italic Whether or not to italicize the font.
		 * @param hspacing The horizontal spacing to place between each character.
		 * @param vspacing The vertical spacing to place between each line of text.
		 * @param alphabet The alphabet to use for the font. Simply a list of all character to use when making the spritesheet. The character must exist in the font.
		 *
		 * @return The AxFont you will use when creating AxText objects with this font.
		 */
		public static function fromFont(font:String, embedded:Boolean, size:uint, bold:Boolean = false, italic:Boolean = false, hspacing:int = 0, vspacing:int = 2, alphabet:String = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-=_+[]{};':\\\",./<>?~!@#$%^&*()"):AxFont {
			var af:AxFont = new AxFont;
			af.spacing = new AxPoint(hspacing, vspacing);

			var tf:TextField = new TextField;
			var format:TextFormat = new TextFormat;
			format.font = font;
			format.size = size;
			format.bold = bold;
			format.italic = italic;
			format.color = 0xffffff;
			tf.defaultTextFormat = format;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.border = false;
			tf.embedFonts = embedded;
			tf.antiAliasType = flash.text.AntiAliasType.NORMAL;
			tf.background = false;
			tf.selectable = false;

			var bitmaps:Vector.<BitmapData> = new Vector.<BitmapData>;
			var characters:Array = alphabet.split("");
			var bitmapWidth:uint = 0;
			var bitmapHeight:uint = 0;
			var padding:uint = 2; // there has to be somewhere better to pull this from
			var dpadding:uint = padding * 2;
			var translationMatrix:Matrix = new Matrix(1, 0, 0, 1, -padding, -padding);
			var colorTransform:ColorTransform = new ColorTransform(1, 1, 0, 1, 0, 0, 0, 0);

			for each (var character:String in characters) {
				tf.setTextFormat(format);
				tf.text = character;
				var characterBitmap:BitmapData = new BitmapData(tf.width - dpadding, tf.height - padding, true, 0x0);
				af.characters[character] = new AxCharacter(characterBitmap.width, characterBitmap.height, new AxRect(bitmapWidth, 0, characterBitmap.width, characterBitmap.height));
				characterBitmap.draw(tf, translationMatrix, colorTransform);
				bitmaps.push(characterBitmap);
				bitmapWidth += characterBitmap.width;
				bitmapHeight = characterBitmap.height > bitmapHeight ? characterBitmap.height : bitmapHeight;
			}

			var fontBitmap:BitmapData = new BitmapData(bitmapWidth, bitmapHeight, true, 0x0);
			var offset:uint = 0;
			af.height = bitmapHeight;
			for each (var bitmap:BitmapData in bitmaps) {
				fontBitmap.copyPixels(bitmap, new Rectangle(0, 0, bitmap.width, bitmap.height), new Point(offset, 0));
				offset += bitmap.width;
				bitmap.dispose();
			}

			af.texture = AxCache.texture(fontBitmap);
			fontBitmap.dispose();

			// Based on texture size, fix uv of each character
			for each (var axc:AxCharacter in af.characters) {
				axc.uv.x /= af.texture.width;
				axc.uv.width /= af.texture.width;
				axc.uv.y /= af.texture.height;
				axc.uv.height /= af.texture.height;
			}
			
			tf.text = "Test";
			tf.x = 100;
			tf.y = 125;
			//tf.scaleX = tf.scaleY = 2;
			Ax.stage2D.addChild(tf);

			return af;
		}

		/**
		 * Returns an AxCharacter representing a single character from this font.
		 *
		 * @param char The character to return.
		 *
		 * @return The AxCharacter for the passed character, null if that character was not part of the font.
		 */
		public function character(char:String):AxCharacter {
			return characters[char];
		}

		/**
		 * Returns the width of the passed character in pixels.
		 *
		 * @param char The character to get the width for.
		 *
		 * @return The character's width, 0 if that character was not part of the font.
		 */
		internal function characterWidth(char:String):uint {
			var character:AxCharacter = character(char);
			if (character == null) {
				return 0;
			}
			return character.width;
		}
	}
}
