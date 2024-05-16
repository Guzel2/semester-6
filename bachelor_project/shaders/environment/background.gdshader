shader_type canvas_item;

uniform vec2 offset;
uniform float zoom = 1.0;

uniform sampler2D visual_texture : repeat_enable;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 position = UV;
	position -= vec2(.5);
	position /= zoom;
	position += offset;
	
	position /= 2.0;
	
	vec3 color = texture(visual_texture, position).rgb;
	
	COLOR.rgb = color;
}