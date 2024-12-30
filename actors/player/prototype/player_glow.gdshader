shader_type canvas_item;

void fragment() {
    // Get the color of the current pixel
    vec4 tex_color = texture(TEXTURE, UV);

    // Check if the pixel is red enough to glow
    if (tex_color.r > 0.5 && tex_color.g < 0.3 && tex_color.b < 0.3) {
        // Boost red component for glow effect
        COLOR = vec4(tex_color.rgb * 2.0, tex_color.a); // Amplify red
    } else {
        // Regular pixel color
        COLOR = tex_color;
    }
}