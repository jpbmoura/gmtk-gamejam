shader_type canvas_item;

// Velocidade do fluxo lateral
uniform float scroll_speed = 0.05;
// Força da ondulação (quanto a superfície distorce)
uniform float wave_strength = 0.015;
// Velocidade da ondulação
uniform float wave_speed = 2.0;
// Frequência das ondas (quantas ondulações ao longo da largura)
uniform float wave_freq = 8.0;
// Intensidade do brilho pulsante
uniform float glow = 0.20;

void fragment() {
	vec2 uv = UV;

	// distorção horizontal baseada em seno — o "borbulhar"
	uv.x += sin(uv.y * wave_freq + TIME * wave_speed) * wave_strength;
	// distorção vertical, defasada, pra não ficar mecânico
	uv.y += cos(uv.x * wave_freq * 0.7 + TIME * wave_speed * 0.8) * wave_strength;

	// scroll lateral contínuo (o fluxo)
	uv.x += TIME * scroll_speed;

	vec4 tex = texture(TEXTURE, uv);

	// brilho pulsante — a lava "respira" luz
	float pulse = 1.0 + sin(TIME * 1.5) * glow;
	tex.rgb *= pulse;

	COLOR = tex;
}
