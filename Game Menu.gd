extends Control

var in_motion = false;

@onready var side_menu = $"Side Menu";
@onready var side_menu_show_x = side_menu.position.x;
@onready var side_menu_hide_x = side_menu.position.x + 1000;
var side_menu_targ = 0;
var side_menu_accel = 100;
var side_menu_bounce_mult = -0.3;
var should_bounce = true;
var side_menu_vel = 0;
var side_menu_dir = 0;
var side_menu_range = 10;

@onready var fading_background: ColorRect = $"Fading Background";
var target_alpha = 100.0 / 255;
var alpha_rate_per_ms = target_alpha / 876;
var last_ms = 0;

var is_paused = false;
var pause_lock = false;
var game_over = false;
var moving_coins = false;

@onready var hud = $"../HUD";

@onready var side_menu_header = $"Side Menu/Menu Content/Side Menu Header";
@onready var left_button = $"Side Menu/Menu Content/Button Box/Left Button";
@onready var right_button = $"Side Menu/Menu Content/Button Box/Right Button";

var total_coins = Persist.coins;
var record_distance = Persist.distance;

# Called when the node enters the scene tree for the first time.
func _ready():
	side_menu.position.x = side_menu_hide_x;
	
	left_button.pressed.connect(_left_button_pressed);
	right_button.pressed.connect(_right_button_pressed);
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("Pause") and !pause_lock:
		toggle_pause();
		
	
	if in_motion:
	#	fading_background.color.a += side_menu_dir * alpha_rate * delta;
		# Transition with current settings takes 876 ms
		
		if should_bounce or side_menu_dir == 1: # when to move (no bounce)
			var menu_progress = abs(side_menu.position.x - side_menu_hide_x) / abs(side_menu_show_x - side_menu_hide_x);
			fading_background.color.a = target_alpha * menu_progress;
			hud.shift_hud(menu_progress);
		
		side_menu_vel += side_menu_accel * side_menu_dir;
		side_menu.position.x += side_menu_vel * delta;
		#var side_pos = (side_menu_targ - side_menu.position.x)*side_menu_dir
		if (side_menu_targ - side_menu.position.x)*side_menu_dir < side_menu_range: #side_pos < side_menu_targ + side_menu_range and side_pos > side_menu_targ - side_menu_range:
			if should_bounce:
				side_menu_vel *= side_menu_bounce_mult;
				side_menu.position.x += side_menu.position.x - side_menu_targ + 1;
				should_bounce = false;
			else:
				side_menu.position.x = side_menu_targ;
				in_motion = false;
				fading_background.color.a = 0 if side_menu_dir > 0 else target_alpha;
				# do pausing stuff
				if game_over:
					move_coins_and_score();
				elif !is_paused:
					get_tree().paused = false;
		pass;
	
	if moving_coins:
		if hud.run_coins > 0:
			hud.run_coins -= 1;
			total_coins += 1;
			hud.update_hud();
			update_text();
		else:
			moving_coins = false;
			Persist.coins = total_coins;
			Persist.distance = record_distance;

func show_menu():
	in_motion = true;
	side_menu_targ = side_menu_show_x;
	side_menu_dir = -1;
	side_menu_vel = 0;
	should_bounce = true;
	

func hide_menu():
	in_motion = true;
	side_menu_targ = side_menu_hide_x;
	side_menu_dir = 1;
	side_menu_vel = 0;
	should_bounce = false;

func toggle_pause():
	is_paused = !is_paused;
	if is_paused:
		get_tree().paused = true;
		show_menu();
	else:
		hide_menu();

func _left_button_pressed():
	if in_motion:
		return;
	if left_button.text == 'RESTART':
		
		hud.reset_style();
		
		get_tree().reload_current_scene();
	else:
		toggle_pause();

func _right_button_pressed():
	if in_motion:
		return;
	get_tree().quit();

func set_game_over():
	game_over = true;
	left_button.text = 'RESTART';
	show_menu();
	side_menu_header.text = 'Game Over';

func move_coins_and_score():
	moving_coins = true;
	record_distance = hud.distance if record_distance < hud.distance else record_distance;
	update_text();
	pass

func update_text():
	hud.center_text.text = 'Total Coins: ' + str(total_coins) + '\nRecord Distance: ' + str(record_distance) + 'm';
