package org.axgl.tilemap {
	import org.axgl.AxEntity;

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
		}
	}
}
