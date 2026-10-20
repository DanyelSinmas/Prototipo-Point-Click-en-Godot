shader_type canvas_item;

uniform bool is_active = false;
uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 1.0, 0.35); // Blanco transparente

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    if (is_active) {
        // Aplica el tinte blanco manteniendo la transparencia original de la imagen
        vec3 blended = mix(tex_color.rgb, highlight_color.rgb, highlight_color.a);
        COLOR = vec4(blended, tex_color.a);
    } else {
        COLOR = tex_color;
    }
}