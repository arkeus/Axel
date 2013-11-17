package io.axel.render {
	import com.adobe.utils.AGALMiniAssembler;
	
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Program3D;
	
	import io.axel.Ax;

	/**
	 * A descriptor holding the information required for rendering, including the vertex shader, the fragment
	 * shader, and the size of each row in the vertex buffer.
	 */
	public class AxShader {
		/**
		 * The Program3D holding the vertex and fragment shaders.
		 */
		public var program:Program3D;
		/**
		 * The size of each row in the vertex buffer.
		 */
		public var rowSize:uint;

		/**
		 * Creates a new AxShader containing the shaders and buffer row size.
		 *
		 * @param vertexShader The vertex shader.
		 * @param fragmentShader The fragment shader.
		 * @param rowSize The size of each row in the vertex buffer.
		 *
		 */
		public function AxShader(vertexShader:Array, fragmentShader:Array, rowSize:uint) {
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, vertexShader.join("\n"));

			var fragmentShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble(Context3DProgramType.FRAGMENT, fragmentShader.join("\n"));

			program = Ax.context.createProgram();
			program.upload(vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
			this.rowSize = rowSize;
		}
	}
}
