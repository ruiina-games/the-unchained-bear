extends Node

# Визначаємо типи кількостей для квитків і жетонів
enum AMOUNT_TYPE {
	SMALL,   # Мала кількість (шанс 0.6)
	MEDIUM,  # Середня кількість (шанс 0.3)
	LARGE    # Велика кількість (шанс 0.1)
}

# Шанси для кількостей
var amount_chances: Dictionary = {
	AMOUNT_TYPE.SMALL: 0.6,
	AMOUNT_TYPE.MEDIUM: 0.3,
	AMOUNT_TYPE.LARGE: 0.1
}

# Значення кількостей для квитків і жетонів
var ticket_amounts: Dictionary = {
	AMOUNT_TYPE.SMALL: 5,   # Мала кількість квитків
	AMOUNT_TYPE.MEDIUM: 15,  # Середня кількість квитків
	AMOUNT_TYPE.LARGE: 30    # Велика кількість квитків
}

var token_amounts: Dictionary = {
	AMOUNT_TYPE.SMALL: 1,  # Мала кількість жетонів
	AMOUNT_TYPE.MEDIUM: 3, # Середня кількість жетонів
	AMOUNT_TYPE.LARGE: 5   # Велика кількість жетонів
}

# Функція для отримання випадкової кількості (SMALL, MEDIUM, LARGE)
func get_random_amount_type() -> AMOUNT_TYPE:
	var random_value = randf()  # Випадкове число від 0 до 1
	var cumulative_chance = 0.0

	# Перевіряємо, до якого діапазону потрапляє random_value
	for amount_type in amount_chances.keys():
		cumulative_chance += amount_chances[amount_type]
		if random_value <= cumulative_chance:
			return amount_type

	# Якщо щось пішло не так, повертаємо SMALL за замовчуванням
	return AMOUNT_TYPE.SMALL

# Функція для генерації масиву квитків
# Викликаєш її в колесі фортуни залежно від того, скільки є полів на квитки.
# Поля на квитки можуть попастися лише в полях для бонусів.
# Повертає ЗНАЧЕННЯ, тобтко КІЛЬКІСТЬ квитків.
func generate_tickets_array(count: int) -> Array:
	var tickets_array: Array = []

	for i in range(count):
		var amount_type = get_random_amount_type()
		tickets_array.append(ticket_amounts[amount_type])

	return tickets_array

# Функція для генерації масиву жетонів
# Викликаєш її в колесі фортуни залежно від того, скільки є полів на жетони.
# count - кількість полів на жетони.
# Повертає ЗНАЧЕННЯ, тобтко КІЛЬКІСТЬ жетонів.
func generate_tokens_array(count: int) -> Array:
	var tokens_array: Array = []

	for i in range(count):
		var amount_type = get_random_amount_type()
		tokens_array.append(token_amounts[amount_type])

	return tokens_array
