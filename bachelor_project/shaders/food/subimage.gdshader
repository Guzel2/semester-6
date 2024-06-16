shader_type canvas_item;

uniform int cell_size : hint_range(1, 100, 1) = 1;

uniform int position_x : hint_range(0, 100, 1) = 0;
uniform int position_y : hint_range(0, 100, 1) = 0;

void fragment() {
	vec2 uv = UV;
	
	vec2 subdivisions = vec2(2.0);
	
	uv /= subdivisions;
	
	vec2 step_size = 1.0 / subdivisions;
	
	uv += step_size * vec2(float(position_x), float(position_y));
	
	COLOR = texture(TEXTURE, uv);
	
	COLOR.a = .8;
}
