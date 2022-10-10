
static const std::string depthVertexShaderSource = R"(

//#version 330

in vec4 position;

// these are passed in from OF programmable renderer
uniform mat4 modelMatrix;

// depth camera's view projection matrix
#ifdef SINGLE_PASS
uniform mat4 lightsViewProjectionMatrix;
#endif

#ifdef CUBE_MAP_MULTI_PASS
uniform mat4 lightsViewProjectionMatrix;
out vec3 v_worldPosition;
#endif

void main() {
#ifdef SINGLE_PASS
	vec3 worldPosition = (modelMatrix * vec4(position.xyz, 1.0)).xyz;
	gl_Position = lightsViewProjectionMatrix * vec4(worldPosition, 1.0);
#endif
	
#ifdef CUBE_MAP_SINGLE_PASS
	gl_Position = modelMatrix * vec4(position.xyz, 1.0);
#endif
	
#ifdef CUBE_MAP_MULTI_PASS
	v_worldPosition = (modelMatrix * vec4(position.xyz, 1.0)).xyz;
	gl_Position = lightsViewProjectionMatrix * vec4(v_worldPosition, 1.0);
#endif
	
}
)";
