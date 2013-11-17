package io.axel.tilemap {
	import io.axel.AxEntity;

	/**
	 * A class describing a single tile in a tilemap. Each tilemap will have one of these for each different
	 * type of tile in the map, not for each actual tile.
	 */
	public class AxTile extends AxEntity {
		/**
		 * The tilemap this tile type belongs to.
		 */
		public var map:AxTilemap;
		/**
		 * The possible collision directions for this tile. Setting it to ANY means that the
		 * tile is completely solid and will collide on all sides. You can set sides to be
		 * solid by setting this to directions such as UP or UP | RIGHT.
		 */
		public var collision:uint;
		/**
		 * Whether or not the collision sides are one way or not. If you set a tile to be one
		 * way and the collision is set to UP, then something can land on top the tile as the
		 * tile will be solid on that side, but you can jump up through the tile from below.
		 * If not one way, you can land on ton, but if you come from below, the top will also
		 * be solid.
		 */
		public var oneWay:Boolean;
		/**
		 * The callback function that should be called if this tile is collided against.
		 */
		public var callback:Function;
		/**
		 * The tile type index that this tile represents.
		 */
		public var index:uint;
		/**
		 * General properties you can set on each tile. When setting a property, it sets the
		 * property for all tiles of that type.
		 */
		public var properties:Object;

		/**
		 * Creates a new AxTile.
		 * 
		 * @param map The tilemap this tile type belongs to.
		 * @param index The tile type index that this tile represents.
		 * @param width The width of this tile.
		 * @param height The height of this tile.
		 */
		public function AxTile(map:AxTilemap, index:uint, width:uint, height:uint) {
			super();
			this.map = map;
			this.index = index;
			this.width = width;
			this.height = height;
			this.collision = NONE;
			this.oneWay = false;
			this.callback = null;
			this.properties = {};
		}
		
		/**
		 * Sets the callback function that will be called if this tile is collided against.
		 * 
		 * @param callback The callback function to call on collision.
		 */
		public function setCallback(callback:Function):void {
			this.callback = callback;
		}
		
		/**
		 * Sets a general untyped property on the tile.
		 * 
		 * @param key The name of the property to set.
		 * @param value The value to set the property to.
		 */
		public function setProperty(key:String, value:*):void {
			properties[key] = value;
		}
		
		/**
		 * Gets a general untyped property set on the tile. Returns null if that
		 * property has not been set. If you want to know whether the property has
		 * been set or not (even if it was set to null), use tile.hasProperty(key).
		 * 
		 * @param key The name of the property to get.
		 * @return The value for the property, or null if not set.
		 */
		public function getProperty(key:String):* {
			return properties[key];
		}
		
		/**
		 * Returns whether or not the passed property has been set on this tile.
		 * 
		 * @param key The name of the property to check.
		 * @return Whether or not the passed property has been set on this tile.
		 */
		public function hasProperty(key:String):Boolean {
			return properties.hasOwnProperty(key);
		}
	}
}
