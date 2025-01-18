shader_type canvas_item;

// Сила "трясіння"
uniform float shake_power = 0.03;
// Ймовірність "ривка"
uniform float shake_rate : hint_range(0.0, 1.0) = 0.2;
// Швидкість "ривків" (як швидко вони виникають з плином часу)
uniform float shake_speed = 5.0;
// Розмір блоків, за якими обчислюється зміщення (ефект "блоковості")
uniform float shake_block_size = 30.5;
// Ступінь "кольорового зсуву" (R і B канали)
uniform float shake_color_rate : hint_range(0.0, 1.0) = 0.01;

float random(float seed) {
    // Псевдовипадкова функція
    return fract(543.2543 * sin(dot(vec2(seed, seed), vec2(3525.46, -54.3415))));
}

void fragment() {
    // Визначаємо, чи буде "ривок" у цю конкретну мить (кадр)
    float enable_shift = float(
        random(trunc(TIME * shake_speed)) < shake_rate
    );

    // Початкові UV координати (для частинки чи спрайта)
    vec2 fixed_uv = UV;

    // Невеличкий зсув по X, який залежить від часу
    fixed_uv.x += (
        random(
            (trunc(UV.y * shake_block_size) / shake_block_size) + TIME
        ) - 0.5
    ) * shake_power * enable_shift;

    // Зчитуємо базовий колір з білої текстури
    vec4 tex_color = texture(TEXTURE, fixed_uv);

    // Зміщуємо окремо R- і B-канали (ефект кольорового "зсуву")
    float shifted_r = texture(TEXTURE, fixed_uv + vec2(shake_color_rate, 0.0)).r;
    float shifted_b = texture(TEXTURE, fixed_uv + vec2(-shake_color_rate, 0.0)).b;
    tex_color.r = mix(tex_color.r, shifted_r, enable_shift);
    tex_color.b = mix(tex_color.b, shifted_b, enable_shift);

    // Тепер множимо на COLOR:
    //  - COLOR тут містить колір, який ви задали в Particles2D (або через Modulate).
    //  - Це дозволить вашій білій текстурі зберігати той колір, який ви їй призначили в редакторі.
    tex_color *= COLOR;

    // Записуємо результат у фінальний колір фрагмента
    COLOR = tex_color;
}
