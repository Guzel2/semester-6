shader_type canvas_item;

uniform float own: hint_range(.0, 1.0, .01) = 1.0;
uniform float top: hint_range(.0, 1.0, .01) = 1.0;
uniform float left: hint_range(.0, 1.0, .01) = 1.0;
uniform float right: hint_range(.0, 1.0, .01) = 1.0;
uniform float down: hint_range(.0, 1.0, .01) = 1.0;

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
	vec2 uv = rotate(UV, -PI / 4.0);
	
	if (uv.x < .5)
	{
		if (uv.y < .5) //top
		{
			vec2 target_pos = vec2(.0, .0);
			
			vec2 difference = target_pos - uv;
			
			float distance_from_center = 
			sqrt(difference.x * difference.x + difference.y * difference.y);
			
			COLOR.a = 1.0 - distance_from_center;
		}
		else //left
		{
			COLOR.a = left * own;
		}
	}
	else
	{
		if (uv.y < .5) //right
		{
			COLOR.a = right * own;
		}
		else //down
		{
			COLOR.a = down * own;
		}
	}
	
}
