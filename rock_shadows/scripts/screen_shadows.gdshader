shader_type canvas_item;

uniform vec3 sun_dir = vec3(.2, .2, .5);

uniform sampler2D test;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 color = textureLod(screen_texture, SCREEN_UV, 0.0);
	
	vec3 pixel_cords = vec3(UV.x, UV.y, 1.0 - color.r);
	
	float step_size = .01;
	
	COLOR.rgb = vec3(.0, .0, .0);
	COLOR.a = .0;
	
	while (pixel_cords.z < 1.0)
	{
		pixel_cords += sun_dir * step_size;
		
		float local_height = 1.0 - textureLod(screen_texture, pixel_cords.xy, 0.0).r;
		
		if (local_height > pixel_cords.z)
		{
			COLOR.a = .1;
			break;
		}
		
		if (pixel_cords.x < .0 || pixel_cords.x > 1.0 || pixel_cords.y < .0 || pixel_cords.y > 1.0)
		{
			break;
		}
	}
}
