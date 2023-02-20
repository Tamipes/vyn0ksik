async function run() {
	const glcanvas = document.getElementById("glcanvas");
	const gl = glcanvas.getContext("webgl");

	function resizeCanvas() {
		glcanvas.width = window.innerWidth;
		glcanvas.height = window.innerHeight;
		gl.viewport(0, 0, glcanvas.width, glcanvas.height);
		gl.uniform2f(
			resolutionUniformLocation,
			glcanvas.width,
			glcanvas.height
		);
	}

	window.addEventListener("resize", resizeCanvas);

	function loadShader(gl, type, source) {
		const shader = gl.createShader(type);

		gl.shaderSource(shader, source);

		gl.compileShader(shader);

		if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
			console.error(
				"An error occurred compiling the shaders: " +
				gl.getShaderInfoLog(shader)
			);
			gl.deleteShader(shader);
			return null;
		}

		return shader;
	}

	// request text of shader files from server
	function fetchShader(url) {
		return fetch(url)
			.then((response) => response.text())
			.catch((error) =>
				console.error(`Error fetching shader at ${url}:`, error)
			);
	}

	// load shader source files
	const vsUrl = "vert.glsl";
	const fsUrl = "frag.glsl";

	const vSource = await fetchShader(vsUrl);
	const fSource = await fetchShader(fsUrl);

	// create and compile shaders from source
	const vertexShader = loadShader(gl, gl.VERTEX_SHADER, vSource);
	const fragmentShader = loadShader(gl, gl.FRAGMENT_SHADER, fSource);

	// attach shaders to shader program and verify compatibility
	const shaderProgram = gl.createProgram();
	gl.attachShader(shaderProgram, vertexShader);
	gl.attachShader(shaderProgram, fragmentShader);
	gl.linkProgram(shaderProgram);

	// error handling
	if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
		console.error(
			"Unable to initialize the shader program: " +
			gl.getProgramInfoLog(shaderProgram)
		);
	}

	// create buffer, bind it then upload data into it
	const positionBufferID = gl.createBuffer(); // create buffer on gpu and get it's id
	gl.bindBuffer(gl.ARRAY_BUFFER, positionBufferID); // set current buffer as target for upload

	const positions = [-1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0]; // the data itself
	gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW); // upload buffer data

	// use program to set its splitting/notation of attributes and uniforms
	gl.useProgram(shaderProgram);

	// get the id of specific attributes
	const positionAttributeLocation = gl.getAttribLocation(
		shaderProgram,
		"aVertexPosition"
	);

	// set attribute (of program) as target for splitting/notation
	gl.enableVertexAttribArray(positionAttributeLocation); // bind
	// set attribute splitting/notation
	gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0); // set 'data'

	// get id of uniform (of program) and set its value(s)
	const resolutionUniformLocation = gl.getUniformLocation(
		shaderProgram,
		"uResolution"
	);

	resizeCanvas();

	gl.uniform2f(resolutionUniformLocation, glcanvas.width, glcanvas.height);

	requestAnimationFrame(render);

	// main render function
	let then = 0;
	function render(now) {
		now *= 0.001;
		const deltaTime = now - then;
		then = now;

		gl.clearColor(0.0, 0.0, 0.0, 1.0); // when clearing, make the color (0.0, 0.0, 0.0, 1.0)
		gl.clear(gl.COLOR_BUFFER_BIT); //do the clearing

		// set uniforms every frame
		const timeUniformLocation = gl.getUniformLocation(
			shaderProgram,
			"uTime"
		);
		gl.uniform1f(timeUniformLocation, now);

		gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);

		requestAnimationFrame(render);
	}
}

run();