extends ThrowingObject
class_name Keglia

@onready var fire_on_keglia: GPUParticles2D = $FireOnKeglia

func set_on_fire():
	fire_on_keglia.emitting = true
