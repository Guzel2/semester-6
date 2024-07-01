shader_type canvas_item;

void fragment()
{
	vec2 uv = UV;
	
	uv.x += sin(TIME * uv.x) * .01;
	uv.y += sin(TIME * uv.y) * .01;
	
	COLOR = texture(TEXTURE, uv);
}