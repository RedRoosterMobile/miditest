shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled, world_vertex_coords;
uniform sampler2D texture_albedo : source_color;
uniform vec4 transmission : source_color;
// https://docs.godotengine.org/en/stable/tutorials/shaders/making_trees.html
uniform float sway_speed = 1.0;
uniform float sway_strength = 0.05;
uniform float sway_phase_len = 8.0;
uniform float y_threshold = 0.75;

void vertex() {
    float strength = COLOR.r * sway_strength;
	if ( VERTEX.y >= y_threshold) {
	    VERTEX.x += sin(VERTEX.x * sway_phase_len * 1.123 + TIME * sway_speed) * strength;
	    VERTEX.y += sin(VERTEX.y * sway_phase_len + TIME * sway_speed * 1.12412) * strength;
	    VERTEX.z += sin(VERTEX.z * sway_phase_len * 0.9123 + TIME * sway_speed * 1.3123) * strength;
	}
}
void fragment() {
    vec4 albedo_tex = texture(texture_albedo, UV);
    ALBEDO = albedo_tex.rgb;
    //ALPHA = albedo_tex.a;
	//ALPHA=1.0;
	//ALBEDO=vec3(1.0,.5,.5);
    //METALLIC = 0.0;
    //ROUGHNESS = 1.0;
    //TRANSMISSION = transmission.rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
