extends Node2D

@onready var view_w = get_viewport().get_visible_rect().size.x;
@onready var builder = $"../Room/Obstacle Builder";

var last_check = Time.get_ticks_msec();
var check_frequency = 1000;

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Time.get_ticks_msec() - last_check > check_frequency:
		last_check = Time.get_ticks_msec();
		for child in get_children():
			if builder.global_position.x - child.global_position.x > view_w:
				child.queue_free();
	pass
