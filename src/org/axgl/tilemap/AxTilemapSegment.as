package org.axgl.tilemap {
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	
	import org.axgl.Ax;
	import org.axgl.AxModel;

	public class AxTilemapSegment {
		/** The index data used for the mesh of this model. */
		internal var indexData:Vector.<uint>;
		/** The index buffer used for the mesh of this model. */
		internal var indexBuffer:IndexBuffer3D;
		/** The vertex data used for the mesh of this model. */
		internal var vertexData:Vector.<Number>;
		/** The vertex buffer used to draw this model. */
		internal var vertexBuffer:VertexBuffer3D;
		
		internal var bufferOffsets:Vector.<int>;
		internal var bufferSize:uint;
		internal var index:uint;
		
		internal var triangles:uint = 0;
		internal var tilemap:AxTilemap;
		internal var dirty:Boolean = true;
		
		public function AxTilemapSegment(tilemap:AxTilemap) {
			this.tilemap = tilemap;
			indexData = new Vector.<uint>;
			vertexData = new Vector.<Number>;
			bufferOffsets = new Vector.<int>;
			bufferSize = 0;
			index = 0;
		}
		
		public function draw():void {
			if (indexData.length == 0) {
				return;
			}
			
			if (dirty) {
				upload();
				dirty = false;
			}
			
			Ax.context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2);
			Ax.context.drawTriangles(indexBuffer, 0, triangles);
		}
		
		private function upload():void {
			var vertexLength:uint = vertexData.length / tilemap.shader.rowSize;
			indexBuffer = Ax.context.createIndexBuffer(indexData.length);
			indexBuffer.uploadFromVector(indexData, 0, indexData.length);
			vertexBuffer = Ax.context.createVertexBuffer(vertexLength, tilemap.shader.rowSize);
			vertexBuffer.uploadFromVector(vertexData, 0, vertexLength);
			triangles = indexData.length / 3;
		}
	}
}
