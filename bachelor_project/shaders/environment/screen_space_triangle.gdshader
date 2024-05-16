shader_type canvas_item;

uniform int color_sample_points : hint_range(1, 256, 1) = 5;
uniform int color_compare_points : hint_range(1, 256, 1) = 5;

uniform float pixel_count : hint_range(1.0, 256.0, 1.0) = 2.0;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec4 quadrant(sampler2D tex, vec2 tile_offset, float x_dir, float y_dir)
{
	vec3 average_color = vec3(0,0,0);
	
	// since x_dir and y_dir are -1 or 1 respectively this results in either 0 or .5 as offset
	vec2 quadrant_offset = vec2((1.0 + x_dir) / 4.0, (1.0 + y_dir) / 4.0);
	
	for (int x = 0; x < color_sample_points; x ++)
	{
		float _x = float(x) / float(color_sample_points - 1);
		_x /= 2.0;
		_x += quadrant_offset.x;
		_x /= pixel_count;
		_x += tile_offset.x;
		
		for (int y = 0; y < color_sample_points; y ++)
		{
			float _y = float(y) / float(color_sample_points - 1);
			_y /= 2.0;
			_y += quadrant_offset.y;
			_y /= pixel_count;
			_y += tile_offset.y;
			
			average_color += texture(tex, vec2(_x, _y)).rgb;
		}
	}
	
	average_color /= float(color_sample_points * color_sample_points);
	
	float total_deviation = .0;
	
	for (int x = 0; x < color_compare_points; x ++)
	{
		float _x = float(x) / float(color_compare_points - 1);
		_x /= 2.0;
		_x += quadrant_offset.x;
		_x /= pixel_count;
		_x += tile_offset.x;
		
		for (int y = 0; y < color_compare_points; y ++)
		{
			float _y = float(y) / float(color_compare_points - 1);
			_y /= 2.0;
			_y += quadrant_offset.y;
			_y /= pixel_count;
			_y += tile_offset.y;
			
			vec3 local_color = texture(tex, vec2(_x, _y)).rgb;
			total_deviation += abs(local_color.r - average_color.r);
			total_deviation += abs(local_color.g - average_color.g);
			total_deviation += abs(local_color.b - average_color.b);
		}
	}
	
	//divide by the total compare points times 3 for each color channel
	total_deviation /= float(color_compare_points * color_compare_points * 3);
	
	//return texture(tex, uv);
	return vec4(average_color.r, average_color.g, average_color.b, total_deviation);
}

void fragment()
{
	vec2 resolution = vec2(textureSize(TEXTURE, 0));
	float height_modifier = resolution.y / resolution.x;
	
	vec2 uv = UV;
	
	vec2 tile_uv = uv * vec2(pixel_count, pixel_count * height_modifier);
	tile_uv = floor(tile_uv);
	tile_uv /= vec2(pixel_count, pixel_count * height_modifier);
	
	vec2 local_uv = uv - tile_uv;
	local_uv *= vec2(pixel_count, pixel_count * height_modifier);
	
	// Get the mean and standard deviation of all quadrants around the current pixel
	vec4 quadrants[4] = {
		quadrant(screen_texture, tile_uv, -1.0, -1.0),
		quadrant(screen_texture, tile_uv, 1.0, -1.0),
		quadrant(screen_texture, tile_uv, -1.0, 1.0),
		quadrant(screen_texture, tile_uv, 1.0, 1.0)
	};
	
	//this is the deviation for a spread from bottom left to top right
	float down_up_deviation = quadrants[0].a + quadrants[2].a;
	//this is the deviation for a spread from top left to bottom right
	float up_down_deviation = quadrants[1].a + quadrants[3].a;
	
	if (up_down_deviation < down_up_deviation)
	{
		//down up spread (from left to right)
		if (local_uv.x + local_uv.y < 1.0)
		{
			COLOR.rgb = quadrants[0].rgb;
		}
		else
		{
			COLOR.rgb = quadrants[2].rgb;
		}
	}
	else
	{
		//up down spread (from left to right)
		if (local_uv.x + (1.0 - local_uv.y) < 1.0)
		{
			COLOR.rgb = quadrants[3].rgb;
		}
		else
		{
			COLOR.rgb = quadrants[1].rgb;
		}
	}
}