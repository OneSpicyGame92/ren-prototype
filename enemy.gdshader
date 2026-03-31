shader_type canvas_item;

uniform float flash_amount : hint_range(0.0, 1.0);
uniform float outline_size : hint_range(0.5, 15.0) = 60.0;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	float alpha_up = texture(TEXTURE, UV + vec2(0.0, -outline_size) * TEXTURE_PIXEL_SIZE).a;
	float alpha_down = texture(TEXTURE, UV + vec2(0.0, outline_size) * TEXTURE_PIXEL_SIZE).a;
	float alpha_left = texture(TEXTURE, UV + vec2(-outline_size, 0.0) * TEXTURE_PIXEL_SIZE).a;
	float alpha_right = texture(TEXTURE, UV + vec2(outline_size, 0.0) * TEXTURE_PIXEL_SIZE).a;

	bool is_edge = false;

	if (tex.a > 0.0) {
		if (alpha_up == 0.0 || alpha_down == 0.0 || alpha_left == 0.0 || alpha_right == 0.0) {
			is_edge = true;
		}
	}

	vec3 final_color = tex.rgb;

	if (is_edge) {
		final_color = mix(tex.rgb, vec3(1.0), flash_amount);
	}

	COLOR = vec4(final_color, tex.a);
}
