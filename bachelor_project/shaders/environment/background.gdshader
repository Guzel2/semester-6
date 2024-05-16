shader_type canvas_item;

uniform vec3 sun_dir = vec3(.0, .0, -1.0);

uniform vec2 offset;
uniform float zoom = 1.0;

uniform vec3 color_0 : source_color;
uniform vec3 color_1 : source_color;
uniform vec3 color_2 : source_color;
uniform vec3 color_3 : source_color;

uniform sampler2D visual_texture : repeat_enable;
uniform sampler2D normal_map : repeat_enable;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec2 offset_position(vec2 uv)
{
	vec2 position = uv;
	position -= vec2(.5);
	position /= zoom;
	position += offset;
	
	position /= 2.0;
	
	return position;
}

vec3 calculate_shadows(vec2 position)
{
	vec3 normal = normalize(texture(normal_map, position).rgb);
	vec3 normalized_sun = normalize(sun_dir);
	
	float dot_product = dot(normal, normalized_sun);
	
	float shadow_strength = dot_product + 1.0;
	shadow_strength = clamp(shadow_strength, .0, 1.0);
	
	return vec3(shadow_strength);
}

void fragment() {
	vec2 position = offset_position(UV);
	
	vec3 color = texture(visual_texture, position).rgb;
	
	if (color.r < .2)
	{
		color = color_0;
	}
	else if (color.r < .5)
	{
		color = color_1;
	}
	else if (color.r < .8)
	{
		color = color_2;
	}
	else
	{
		color = color_3;
	}
	
	color -= calculate_shadows(position);
	
	COLOR.rgb = color;
}