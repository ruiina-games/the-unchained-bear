extends GPUParticles2D
class_name ParticleBase

# Масив текстур (можна завантажити вручну або через SpriteFrames)
@export var textures: Array[Texture2D] = []

# Функція, яка викликається при створенні партікла
func _ready():
	
	# Перевіряємо, чи є текстури
	if textures.size() == 0:
		print("Помилка: текстури не додані!")
		return

	# Встановлюємо випадкову текстуру
	var random_texture = textures[randi() % textures.size()]
	texture = random_texture
