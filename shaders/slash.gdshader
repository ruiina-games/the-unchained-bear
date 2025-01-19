shader_type canvas_item;
render_mode blend_mix;

// Параметр від 0 до 1, керує, наскільки подряпина з’явилася (зверху донизу)
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// Якщо хочеться, щоб проявлення було з “певною нерівністю” (шумом),
// можна додати float scratch_wobble і зсувати UV по X для різних Y, але
// поки залишимо найпростішу версію.
void fragment() {
    // Зчитуємо піксель із текстури
    vec4 tex_color = texture(TEXTURE, UV);

    // Якщо біля верху (UV.y < progress), робимо піксель видимим,
    // інакше — прозорим (a=0), тобто ще “не з’явився”.
    // Зауважте, що у Godot UV.y=0 — верх, UV.y=1 — низ.
    if (UV.y > progress) {
        tex_color.a = 0.0;
    }

    // Результат
    COLOR = tex_color;
}
