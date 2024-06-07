shader_type canvas_item;

uniform sampler2D last_texture;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment()
{
	COLOR = texture(last_texture, UV);
	COLOR.a = .5;
}