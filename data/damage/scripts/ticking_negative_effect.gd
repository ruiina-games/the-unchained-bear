extends NegativeEffect
class_name TickingNegativeEffect

@export var tick_interval: float = 0.5

# Повертає кількість "тиків", зазвичай цілочисельне значення
# Використовуємо ceil, якщо хочемо "округлити вгору" (щоб частковий залишок теж викликав додатковий "тик")
func get_ticks_amount() -> int:
	return int(ceil(duration / tick_interval))

func get_tick_interval() -> float:
	return tick_interval
