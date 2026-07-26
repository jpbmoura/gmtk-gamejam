shader_type canvas_item;

uniform vec4 colorize_color : source_color = vec4(0.0, 0.5, 1.0, 1.0);
uniform float alpha : hint_range(0.0, 1.0) = 0.6;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	
	float luminence = tex.r * 0.299 + tex.g * 0.587 + tex.b * 0.114;
	vec3 tinted = colorize_color.rgb * luminence;
	
	COLOR = vec4(tinted, tex.a * alpha);
}