shader_type canvas_item;

uniform float consume_percentage: hint_range(.0, 1.0, .01) = 1.0;
uniform bool up = true;
uniform bool left = true;
uniform bool right = true;
uniform bool down = true;

uniform sampler2D offset_texture : repeat_enable;

vec2 rotate(vec2 uv, float rot)
{
	float cos_theta = cos(rot);
	float sin_theta = sin(rot);
	
	vec2 centered_uv = uv - vec2(.5);
	
	vec2 rotated_uv;
	rotated_uv.x = centered_uv.x * cos_theta - centered_uv.y * sin_theta;
	rotated_uv.y = centered_uv.x * sin_theta + centered_uv.y * cos_theta;
	
	rotated_uv += vec2(.5);
	
	return rotated_uv;
}

void fragment() {
	if (COLOR.a != .0)
	{
	
	vec2 uv = rotate(UV, -PI / 4.0);
	
	uv += (texture(offset_texture, uv).r - .5) * .3;
	
	vec2 center_uv = uv - vec2(.5);
	
	float distance_from_center = 
	sqrt(center_uv.x * center_uv.x + center_uv.y * center_uv.y);
	
	distance_from_center /= 1.0 - consume_percentage;
	
	if (distance_from_center < .5)
	{
		distance_from_center = 1.0;
	}
	else
	{
		distance_from_center = 0.0;
	}
	
	if (uv.x < .5)
	{
		if (uv.y < .5) //up
		{
			if (up != true)
			{
				COLOR.a = .0;
			}
			else
			{
				COLOR.a = 1.0 - distance_from_center;
			}
		}
		else //left
		{
			if (left != true)
			{
				COLOR.a = .0;
			}
			else
			{
				COLOR.a = 1.0 - distance_from_center;
			}
		}
	}
	else
	{
		if (uv.y < .5) //right
		{
			if (right != true)
			{
				COLOR.a = .0;
			}
			else
			{
				COLOR.a = 1.0 - distance_from_center;
			}
		}
		else //down
		{
			if (down != true)
			{
				COLOR.a = .0;
			}
			else
			{
				COLOR.a = 1.0 - distance_from_center;
			}
		}
	}
	
	/*
	if (COLOR.a < 1.0)
	{
		if (texture(offset_texture, uv).r > .8)
		{
			COLOR.a = 1.0;
		}
		
	}*/

	}
}
