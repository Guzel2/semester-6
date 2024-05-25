shader_type canvas_item;

uniform float shadow_intensity: hint_range(.0, 5.0, .01) = 1.0;

uniform vec3 sun_dir = vec3(.0, .0, -1.0);

uniform float scale: hint_range(.0, 8.0, .01) = 1.0;
uniform float rotation : hint_range(-3.15, 3.15, .001) = .0;

uniform bool editor = false;

vec2 center_uv(vec2 uv)
{
	uv -= vec2(.5);
	uv += vec2(scale * .25);
	
	return uv;
}

vec2 get_sun_offset(vec2 uv)
{
	//remove this later on gaming
	if (editor)
	{
		vec3 sun_norm = normalize(sun_dir);
		uv += sun_norm.xy;
	}
	else
	{
		uv += sun_dir.xy;
	}
	
	return uv;
}

void fragment()
{
	vec3 sun_norm = normalize(sun_dir);
	
	vec2 uv = center_uv(UV);
	
	uv /= scale / 2.0;
	
	//uv = get_sun_offset(uv);
	
	vec4 color = vec4(.0);
	
	float cos_theta = cos(rotation);
	float sin_theta = sin(rotation);
	
	vec2 centered_uv = uv - vec2(.5);
	
	vec2 texture_multiplier = 1.0 / TEXTURE_PIXEL_SIZE;
	texture_multiplier = normalize(texture_multiplier);
	centered_uv *= texture_multiplier;
	
	vec2 rotated_uv;
	rotated_uv.x = centered_uv.x * cos_theta - centered_uv.y * sin_theta;
	rotated_uv.y = centered_uv.x * sin_theta + centered_uv.y * cos_theta;

	rotated_uv /= texture_multiplier;
	rotated_uv += vec2(.5);
	
	
	if (rotated_uv.x + rotated_uv.y > 1.0)
	{
		if (!(uv.x < .0 || uv.x > 1.0 || uv.y < .0 || uv.y > 1.0))
		{
			color = texture(TEXTURE, uv);
		}
	}
	
	COLOR = color;
	COLOR.a *= .2;
}