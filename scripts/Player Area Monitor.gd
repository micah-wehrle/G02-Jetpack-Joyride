extends Area2D

@onready var HUD = $"../../../CanvasLayer/HUD";
@onready var twinkle_anim = load("res://img/sheets/twinkle1.tres");
@onready var obstacle_parent = $"../../../Obstacle Parent";
@onready var sound_cloud = $"../../Sound Cloud";
@onready var player = $"..";

var twinkles = [];
var twinkle_times = [];
var twinkle_lifespan = 500;
# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect('area_shape_entered', _on_area_shape_entered);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if twinkles.size() > 0 and Time.get_ticks_msec() - twinkle_times[0] > twinkle_lifespan:
		twinkle_times.pop_front();
		twinkles.pop_front().queue_free();
	pass 

# RID area_rid, Area2D area, int area_shape_index, int local_shape_index
func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	if (area.name.contains('zapper') or area.name.contains('missile')) and player.alive:
		if !Input.is_action_pressed("Shift"):
			player.kill_player();
			pass
	elif area.name.contains('coins'):
		HUD.add_coin();
		var coin = area.get_child(area_shape_index);
		var twinkle = AnimatedSprite2D.new();
		obstacle_parent.add_child(twinkle); 
		twinkle.global_position = coin.global_position;
		twinkle.sprite_frames = twinkle_anim;
		twinkle.scale = Vector2(0.4,0.4);
		twinkle.play();
		twinkles.push_back(twinkle);
		twinkle_times.push_back(Time.get_ticks_msec());
		coin.queue_free();
		sound_cloud.play_coin_pickup();
		pass
