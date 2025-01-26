shader_type canvas_item;


uniform vec2 center = vec2(0.5, 0.5);
uniform float force = 0.02;
uniform float size = 0.3;
uniform float thickness = 0.02;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // SCREEN_UV тут завжди від 0.0 до 1.0 по екрану, незалежно від руху камери
    float ratio = SCREEN_PIXEL_SIZE.x / SCREEN_PIXEL_SIZE.y;

    // Приклад вашого попереднього "ефекту лінзи"
    vec2 scaled_uv = (UV - vec2(0.5, 0.0)) / vec2(ratio, 1.0) + vec2(0.5, 0.0);

    float dist = length(scaled_uv - center);
    float mask = (1.0 - smoothstep(size - 0.1, size, dist)) *
                 smoothstep(size - thickness - 0.1, size - thickness, dist);

    vec2 disp = normalize(scaled_uv - center) * force * mask;
    COLOR = texture(SCREEN_TEXTURE, SCREEN_UV - disp);
}
