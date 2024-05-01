shader_type canvas_item;

uniform vec3 sun_dir = vec3(.2, .2, .5);

uniform sampler2D height_map;

void fragment()
{
	vec3 pixel_cords = vec3(UV.x, UV.y, COLOR.r);
	vec3 start_pos = pixel_cords;
	
	float step_size = .005;
	
	if (COLOR.a == .0)
	{
		COLOR.a = .2;
		COLOR.rgb = vec3(.9, .0, .0);
	}
	
	COLOR = vec4(.0, .0, .0, .0);
	
	while (pixel_cords.z < 1.0)
	{
		pixel_cords += sun_dir * step_size;
		
		float local_height = texture(height_map, pixel_cords.xy).r;
		
		if (local_height > pixel_cords.z)
		{
			
			float distance_to_start = length(start_pos - pixel_cords);
			
			COLOR.a = .6 * (1.1 - distance_to_start);
			break;
		}
		
		if (pixel_cords.x < .0 || pixel_cords.x > 1.0 || pixel_cords.y < .0 || pixel_cords.y > 1.0)
		{
			break;
		}
	}
}
