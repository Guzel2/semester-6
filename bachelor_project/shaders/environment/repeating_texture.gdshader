shader_type canvas_item;

uniform vec2 offset;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 uv = UV;
	uv += offset;
	
	while (uv.x > 1.0) {uv.x -= 1.0;}
	while (uv.x < .0) {uv.x += 1.0;}
	while (uv.y > 1.0) {uv.y -= 1.0;}
	while (uv.y < .0) {uv.y += 1.0;}
	
	vec4 color = texture(TEXTURE, uv);
	COLOR = color;
}