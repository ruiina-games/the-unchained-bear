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
 AMOUNT_TYPE.MEDIUM: 15, # Середня кількість квитків
 AMOUNT_TYPE.LARGE: 30   # Велика кількість квитків
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

# Функція для генерації словника з квитками
# Повертає словник, де ключ — PlayerStats.MONEY.TICKETS, а значення — масив кількостей квитків
func generate_tickets(count: int) -> Dictionary:
 var tickets_array: Array = []

 for i in range(count):
  var amount_type = get_random_amount_type()
  tickets_array.append(ticket_amounts[amount_type])

 return {PlayerStats.MONEY.TICKETS: tickets_array}

# Функція для генерації словника з жетонами
# Повертає словник, де ключ — PlayerStats.MONEY.TOKENS, а значення — масив кількостей жетонів
func generate_tokens(count: int) -> Dictionary:
 var tokens_array: Array = []

 for i in range(count):
  var amount_type = get_random_amount_type()
  tokens_array.append(token_amounts[amount_type])

 return {PlayerStats.MONEY.TOKENS: tokens_array}
