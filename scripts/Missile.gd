extends Area2D

var speed = 400;

var wiggle_rate = 0.012;
var wiggle_size = 18;

var rot_degrees = 1.5;

@onready var starting_y = global_position.y;
#var sprite_child: Sprite2D;

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(sprite_child);
	#starting_y = sprite_child.position.y
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position.x -= speed * delta;
	global_position.y = starting_y + sin(Time.get_ticks_msec() * wiggle_rate) * wiggle_size;
	
	rotation_degrees = cos(Time.get_ticks_msec() * wiggle_rate -90) * rot_degrees;
	pass
