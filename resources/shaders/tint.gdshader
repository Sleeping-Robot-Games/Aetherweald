shader_type canvas_item;

uniform bool enabled = false;
uniform vec4 tint : source_color = vec4(1., 1., 0., 1.);

void fragment() {
	if(enabled) {
		vec4 previous_color = texture(TEXTURE, UV);
		if(previous_color.a > 0.) {
			COLOR.rgb = vec3(COLOR.r + COLOR.g + COLOR.b) / 3.0;
			COLOR.rgb = (COLOR.rgb + tint.rgb) / 2.0;
		}
	}
}