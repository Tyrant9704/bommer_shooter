shader_type spatial;

uniform float rotation_range = 10.0;

void vertex() {
    float angle = radians(rotation_range);
    float c = cos(angle);
    float s = sin(angle);

    mat3 rotation_matrix = mat3(
        vec3(1, 0, 0),
        vec3(0, c, -s),
        vec3(0, s, c)
    );

    VERTEX = rotation_matrix * VERTEX;
}

