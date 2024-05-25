shader_type canvas_item;

uniform float shadow_intensity: hint_range(.0, 5.0, .01) = 1.0;

uniform vec3 sun_dir = vec3(.0, .0, -1.0);

uniform float scale: hint_range(.0, 8.0, .01) = 1.0;

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
	vec2 uv = center_uv(UV);
	uv /= scale / 2.0;
	
	uv = get_sun_offset(uv);
	
	vec4 color = vec4(.0);
	
	if (!(uv.x < .0 || uv.x > 1.0 || uv.y < .0 || uv.y > 1.0))
	{
		color = texture(TEXTURE, uv);
	}
	
	COLOR = color;
	COLOR.a *= .2;
}