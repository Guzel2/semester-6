shader_type canvas_item;

uniform float roundness: hint_range(1.0, 18.0, .01) = 12.0;
uniform float threshhold: hint_range(.0, 1.0, .01) = .8;

void fragment()
{
	vec2 texture_size = 1.0 / TEXTURE_PIXEL_SIZE;
	vec4 color = COLOR;
	
	vec2 uv = UV;
	
	vec2 local_uv = uv;
	
	uv *= texture_size;
	uv = floor(uv);
	
	local_uv *= texture_size;
	local_uv -= uv;
	
	color.a *= -(pow((2.0 * local_uv.y - 1.0), 4.0)) + 1.0;
	
	if (texture(TEXTURE, (uv + vec2(1.0, .0)) / texture_size) != COLOR)
	{
		color.a *= -(pow((local_uv.x), roundness)) + 1.0;
		
		//color.a *= -(pow((2.0 * local_uv.y - 1.0), 4.0)) + 1.0;
	}
	
	if (texture(TEXTURE, (uv + vec2(-1.0, .0)) / texture_size) != COLOR)
	{
		color.a *= -(pow((1.0 - local_uv.x), roundness)) + 1.0;
	}
	
	color.a = step(threshhold, color.a);
	
	COLOR = color;
}
