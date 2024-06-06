shader_type canvas_item;

uniform float cut_off : hint_range(.0, 1.0, .001);
uniform bool left_to_right = true;

void fragment()
{
	float original_alpha = COLOR.a;
	
	vec2 uv = UV;
	
	if (!left_to_right)
	{
		uv.x = 1.0 - uv.x;
	}
	
	if (uv.x < cut_off)
	{
		float percentage = uv.x / cut_off;
		
		COLOR.a = percentage * original_alpha;
	}
}
