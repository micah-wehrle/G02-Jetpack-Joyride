extends Control

@onready var top = $TextureRect;
@onready var bot = $Label3;
@onready var target_y = -top.position.y - 2000;
var moving = false;
var vel = 0;
var accel = 10;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Thrust"):
		moving = true;
	if moving:
		vel += accel;
		top.position.y -= vel;
		bot.position.y += vel;
		
		if top.position.y < target_y:
			get_tree().change_scene_to_file("res://scene.tscn");
