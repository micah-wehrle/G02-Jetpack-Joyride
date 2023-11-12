extends Node2D

var running = false;

@onready var scene = $"../../Obstacle Parent";
@onready var view_w = get_viewport().get_visible_rect().size.x;
@onready var HUD = $"../../CanvasLayer/HUD";
@onready var alert_controller = $"../Alert Controller";

var build_size: float = 520.0/10.0;

var last_spawn_x = 0;
var spawn_variance = [0.5, 0.6];
@onready var spawn_gap = view_w * randf_range(spawn_variance[0], spawn_variance[1]);
@onready var start_x = global_position.x;
var pixels_per_meter = 40.0;
var last_distance_meter: int = 0;

var action_list = [];

var scientist_odds = 0.5;

# Called when the node enters the scene tree for the first time.
func _ready():
	var actions = [
		['call rand_zapper', 30], 
		['call rand_coins', 20], 
		['missile', 8]
	];
	
	for act in actions:
		var temp_act = [];
		temp_act.resize(act[1]);
		temp_act.fill(act[0]);
		
		action_list.append_array(temp_act);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !running:
		return;
	if global_position.x - last_spawn_x > spawn_gap:
		last_spawn_x = global_position.x;
		spawn_gap = view_w * randf_range(spawn_variance[0], spawn_variance[1]);
		
		#add weighting
		var action: String = action_list.pick_random();
		
		if action.contains('call '):
			call(action.substr(5));
		elif action == 'missile':
			if !alert_controller.send_missile(): #if there's already a missile, just make a zapper
				rand_zapper();
		
		
		if randf() <= scientist_odds:
			rand_scientists();
	if global_position.x != 0 and round((global_position.x - start_x) / pixels_per_meter) > last_distance_meter:
		last_distance_meter = round((global_position.x - start_x) / pixels_per_meter);
		
		HUD.set_distance(last_distance_meter);

# For making a point, use 1-10
func pt(x: int, y: int):
	return Vector2(build_size * (x-1), build_size * (y-1));

################################################
#            Scientist Builder
################################################
@onready var scientist_anim = load("res://img/sheets/scientist2.tres");
@onready var scientist_script = load("res://scripts/Scientist.gd");

var sci_speed_range = [5, 10];
var max_sci = 5;
var sci_offset_range = 4
var sci_group_count = 0;

func rand_scientists():
	var sci_num = randi_range(1, max_sci);
	var sci_group = Area2D.new(); # making an area2d in case I decided to add hitboxes later
	scene.add_child(sci_group);
	sci_group_count += 1;
	sci_group.name = "scientists " + str(sci_group_count);
	sci_group.global_position = global_position;
	
	for i in sci_num:
		make_scientist(sci_group);
	pass;

func make_scientist(group: Area2D):
	var sci = CollisionShape2D.new();
	group.add_child(sci);
	sci.shape = RectangleShape2D.new();
	sci.shape.size.x = 30;
	sci.shape.size.y = 80;
	var sci_offset = pt(5 + randi_range(-sci_offset_range, sci_offset_range), 10);
	sci.global_position = global_position + sci_offset  - Vector2(0,randf_range(10,40));
	sci.set_script(scientist_script);
	sci.set_process(true);
	
	var sci_speed = randi_range(sci_speed_range[0], sci_speed_range[1]) * [-1,1].pick_random();
	sci.speed = sci_speed;
	
	var sci_anim = AnimatedSprite2D.new();
	sci.add_child(sci_anim);
	sci_anim.global_position = sci.global_position;
	sci_anim.sprite_frames = scientist_anim;
	sci_anim.play_backwards();
	if sci_speed < 0:
		sci_anim.scale.x = -sci_anim.scale.x;
	sci_anim.scale *= randf_range(1.2, 1.7);
	
	

################################################
#            Coin Builder
################################################
@onready var coin_sprite = load("res://img/coin1.png");

var coin_radius = 15;
var coin_group_count = 0;

func rand_coins():
	var coins = coins_db.pick_random();
	
	var coin_group = Area2D.new();
	scene.add_child(coin_group);
	coin_group_count += 1;
	coin_group.name = "coins " + str(coin_group_count);
	coin_group.global_position = global_position;
	coin_group.set_collision_layer_value(1, false);
	coin_group.set_collision_layer_value(2, true);
	coin_group.set_collision_mask_value(1, false);
	coin_group.set_collision_mask_value(2, true);
	
	var x = 0;
	var y = 1;
	for coin_i in coins:
		if coin_i == '\n':
			y += 1;
			x = -1;
		x += 1;
		if coin_i == '1':
			make_coin(pt(x, y), coin_group);

func make_coin(pos: Vector2, coin_group: Area2D):
	var col_shape = CollisionShape2D.new();
	coin_group.add_child(col_shape);
	col_shape.shape = CircleShape2D.new();
	col_shape.shape.radius = coin_radius;
	col_shape.global_position = global_position + pos;
	
	
	var sprite = Sprite2D.new();
	col_shape.add_child(sprite);
	sprite.texture = coin_sprite;
	sprite.global_position = global_position + pos;
	sprite.scale = Vector2(0.15, 0.15);
	pass;
	

var coins_db = [
	'\n\n11111\n0000011111\n11111\n0000011111\n11111\n0000011111',
	'\n0010001\n0010001\n0010001\n\n01001001\n01000001\n0010001\n000111',
	'0000000000\n0011000110\n0100101001\n10000100001\n10000000001\n0100000001\n0010000010\n0001000100\n0000101000\n0000010000\n',
	'0000000000\n0011000110\n0111101111\n11111111111\n11111111111\n0111111111\n0011111110\n0001111100\n0000111000\n0000010000\n',
]

'''
'
0000000000\n
0011000110\n
0100101001\n
10000100001\n
10000000001\n
01000000001\n
0010000010\n
0001000100\n
0000101000\n
0000010000\n
',
'''

################################################
#            Zapper Builder
################################################
@onready var zapper_sprite = load("res://img/Zapper1.png");
@onready var zapper_beam_anim = load("res://img/sheets/zapper beam1.tres");
#@onready var lethal_script = load("res://scripts/Lethal Collider.gd");

var zapper_count = 0;

func rand_zapper():
	var zappers = zappers_db.pick_random();
	
	for z_data in zappers:
		make_zapper(
			pt(z_data[0], z_data[1]),
			pt(z_data[2], z_data[3])
		);

func make_zapper(p1: Vector2, p2: Vector2):
	
	var body = Area2D.new();
	zapper_count += 1;
	body.name = "zapper " + str(zapper_count);
	body.set_collision_layer_value(1, false);
	body.set_collision_layer_value(2, true);
	body.set_collision_mask_value(1, false);
	body.set_collision_mask_value(2, true);
	scene.add_child(body);
	body.global_position = global_position;
	
	var col = CollisionShape2D.new();
	var rect_shape = RectangleShape2D.new();
	rect_shape.size.x = p1.distance_to(p2);
	rect_shape.size.y = 26;
	col.shape = rect_shape;
	body.add_child(col);
	col.global_position = global_position + (p1 + p2)/2;
	
	var z1 = make_zapper_ball(p1, body);
	var z2 = make_zapper_ball(p2, body);
	
	z1.rotation = p1.angle_to_point(p2) + 3.14159/2;
	z2.rotation = p2.angle_to_point(p1) + 3.14159/2;
	
	var beam1 = make_zapper_beam(p1, p2, body);
	var beam2 = make_zapper_beam(p2, p1, body);
	
	beam1.rotation = z1.rotation + 3.14159/2;
	beam2.rotation = z2.rotation + 3.14159/2;
	
	
	col.rotation = beam1.rotation;
	
	pass;

func make_zapper_ball(pos: Vector2, body: Area2D):
	var zap = Sprite2D.new();
	zap.texture = zapper_sprite;
	zap.scale = Vector2(0.05,0.05);
	body.add_child(zap);
	zap.global_position = global_position + pos;
	zap.z_index = 2;
	return zap;

func make_zapper_beam(p1: Vector2, p2: Vector2, body: Area2D):
	var beam = AnimatedSprite2D.new();
	beam.sprite_frames = zapper_beam_anim;
	beam.play();
	body.add_child(beam);
	
	var distance = p1.distance_to(p2);
	var difference = (p1 + p2)/2;
	beam.global_position = global_position + difference;
	
	var sprite_size = beam.sprite_frames.get_frame_texture(beam.sprite_frames.get_animation_names()[0],0).get_size();
	var targ_hei = distance - 26;
	var targ_wid = 26;
	var new_scale = Vector2( 
		( sprite_size.y/(sprite_size.y/targ_hei) )/350,
		( sprite_size.x/(sprite_size.x/targ_wid) )/100
	);
	beam.scale = new_scale;
	
	return beam;

var zappers_db = [
	[[1,1, 1,3]],
	[[1,1, 10,1]],
	[[1,10, 10,10]],
	[[1,10, 1,7]],
	[[1,10, 3,7]],
	[[1,5, 5,5]],
	[
		[1,1, 10,1],
		[1,10, 10,10]
	],
	[
		[10,1, 15,5],
		[1,5, 5,10]
	]
];

