shader_type spatial;
render_mode blend_mix, cull_back, unshaded, diffuse_burley, specular_schlick_ggx;

uniform sampler2D texture_albedo : source_color, repeat_disable;
uniform vec4 retical_color: source_color;
uniform float tex_scale = 0.1;

varying vec3 vertex_pos;
varying vec3 vertex_normal;
varying vec3 vertex_tangent;

mat3 get_transpose_inverse(mat4 matrix) {
    return transpose(inverse(mat3(matrix)));
}

void vertex() {
	mat3 mv_transpose_inverse = get_transpose_inverse(MODELVIEW_MATRIX);
	
	vertex_pos = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vertex_normal = mv_transpose_inverse * NORMAL;
	vertex_tangent = mv_transpose_inverse * TANGENT;
}

void fragment() {
	vec3 normal = normalize(vertex_normal);
	vec3 tangent = normalize(vertex_tangent);
	vec3 cameraDir = normalize(vertex_pos);
	vec3 offset = cameraDir + normal;

	mat3 mat = mat3(
	    -tangent,
	    -cross(normal, tangent),
	    normal * vec3(1, -1 , 1)
	);

	offset = mat * offset;

	vec2 uv = (offset.xy / tex_scale) * vec2(1.0, -1.0);	// flip vertically
	vec4 tex = texture(texture_albedo, uv + vec2(0.5));
	ALBEDO = retical_color.rgb * tex.rgb;
	ALPHA = tex.a;
}