shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float outline_width : hint_range(0.0, 10.0) = 2.0;
uniform bool outline_enabled = false;
uniform float gray_amount : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec4 current_color = texture(TEXTURE, UV);
	
	if (outline_enabled) {
		vec2 size = outline_width / vec2(textureSize(TEXTURE, 0));
		
		float alpha_up = texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
		float alpha_down = texture(TEXTURE, UV + vec2(0.0, size.y)).a;
		float alpha_left = texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
		float alpha_right = texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
		float alpha_ul = texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
		float alpha_ur = texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
		float alpha_dl = texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
		float alpha_dr = texture(TEXTURE, UV + vec2(size.x, size.y)).a;
		
		float max_alpha = max(max(max(alpha_up, alpha_down), max(alpha_left, alpha_right)),
			max(max(alpha_ul, alpha_ur), max(alpha_dl, alpha_dr)));
		
		if (current_color.a < 0.1 && max_alpha > 0.1) {
			current_color = outline_color;
		}
	}
	
	// Ausgrauen: zwischen Original und entsättigter, dunklerer Version interpolieren
	if (gray_amount > 0.0) {
		float gray = (current_color.r + current_color.g + current_color.b) / 3.0;
		vec3 grayed = vec3(gray) * 0.5;  // halb so hell
		current_color.rgb = mix(current_color.rgb, grayed, gray_amount);
	}
	
	COLOR = current_color;
}