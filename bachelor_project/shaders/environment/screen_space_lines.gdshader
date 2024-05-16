shader_type canvas_item;

uniform int color_count : hint_range(0, 256, 1) = 4;
uniform int shade_count : hint_range(0, 256, 1) = 2;

uniform float rotation : hint_range(-1.0, 1.0, .001);
uniform float rotation_offset : hint_range(.5, 10.0, .001);
uniform float thickness : hint_range(0.0, 1.0, .0001) = .5;
uniform float frequency : hint_range(0.0, 20.0, .0001) = 5.0;
uniform float max_blacknesss : hint_range(0.0, 1.0, .0001) = .5;
uniform float paper_stength : hint_range(0.0, 20.0, .0001) = .0;

uniform float line_strength : hint_range(0.0, 1.0, .0001) = .5;
uniform float brightness : hint_range(0.0, 20.0, .0001) = 1.0;
uniform float contrast : hint_range(0.0, 20.0, .0001) = 1.0;
uniform float saturation : hint_range(0.0, 20.0, .0001) = 1.0;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

float add_line_effect(vec3 color, vec2 uv)
{
	float luminosity = dot(color.rgb, vec3(0.21, 0.72, 0.07));
	
	luminosity = round(luminosity * float(color_count - 1)) / float(color_count - 1);
	
	int color_id = int(luminosity * float(color_count - 1) + .5);
	float pencil_color = 1.0;
	
	for (int i = color_id; i < shade_count; i++)
	{
		float rot = rotation + sin(float(i) * rotation_offset); 
		
		float x = uv.x * rot + uv.y * (1.0 - abs(rot));
		float y = uv.y * rot - uv.x * (1.0 - abs(rot));
		
		float frequency_multiplier = 1.0;
		
		if (abs(rot) < .5)
		{
			float temp_rotation = abs(rot) * 2.0;
			
			frequency_multiplier = 1.0 * (1.0 - temp_rotation) + sqrt(2.0) * temp_rotation;
		}
		else
		{
			float temp_rotation = abs(rot) * 2.0 - 1.0;
			
			frequency_multiplier = sqrt(2.0) * (1.0 - temp_rotation) + 1.0 * temp_rotation;
		}
		
		float _frequency = 200.0 * frequency * frequency_multiplier;
		
		float greyness = sin(x * _frequency) - 1.0 + thickness * 2.0;
		
		if (greyness > .0)
		{
			pencil_color = max_blacknesss;
			break;
			
			pencil_color *= 1.0 - greyness;
			if (pencil_color < max_blacknesss) {
				pencil_color = max_blacknesss;
				break;
			}
		}
	}
	
	return pencil_color;
}

void fragment() {
	vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;

	COLOR.rgb = c;
	
	vec2 texture_multiplier = 1.0 / TEXTURE_PIXEL_SIZE;
	texture_multiplier = normalize(texture_multiplier);
	
	vec2 uv = UV;
	uv *= texture_multiplier;
	
	float pencil_color = add_line_effect(COLOR.rgb, uv);
	
	//COLOR = vec4(pencil_color) * line_strength + COLOR * (1.0 - line_strength);
	
	COLOR.rgb = COLOR.rgb - (vec3(1.0) - vec3(pencil_color)) * line_strength;
	
}

void color_changing()
{
	vec4 COLOR;
	COLOR.rgb = mix(vec3(0.0), COLOR.rgb, brightness);
	COLOR.rgb = mix(vec3(0.5), COLOR.rgb, contrast);
	COLOR.rgb = mix(vec3(dot(vec3(1.0), COLOR.rgb) * (1.0 / 3.0)), COLOR.rgb, saturation);
}