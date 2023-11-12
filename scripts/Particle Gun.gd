extends Node2D

var shoot = false;

var last_shot = 0;
var shot_rate = 100;

var starting_rot = 185;
var rot_range = 5;

@onready var frame_data = load("res://img/sheets/boom1.tres");
@onready var bullet_script = load("res://scripts/Bullet.gd");
@onready var bullet_img = load("res://img/bullet1.tres");

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shoot:
		if Time.get_ticks_msec() - last_shot > shot_rate:
			last_shot = Time.get_ticks_msec();
			var shot = create_shot();
			$"../../../../..".add_child(shot);
			pass;
		pass
	pass

func create_shot():
	var shot: Sprite2D = Sprite2D.new();
	var tex = bullet_img;
	shot.texture = tex;
	shot.scale = Vector2(0.03, 0.06);
	shot.rotation = deg_to_rad(rotation + randf_range(-rot_range, rot_range) + 180);
	shot.set_script(bullet_script);
	shot.global_position = global_position;
	shot.floor_object = $"../../../../Floor";
	shot.frame_data = frame_data;
	return shot;
