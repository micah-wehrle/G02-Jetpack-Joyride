extends Control

var run_coins = 0;
var distance = 0;

@onready var top_text = $"HUD Topleft Text";
@onready var center_text = $"HUD Text Center";
@onready var top_panel = $"HUD Topleft Text/Topleft Panel";
@onready var top_panel_style = top_panel.get("theme_override_styles/panel");
@onready var start_alpha = top_panel_style.bg_color.a;

@onready var center_panel = $"HUD Text Center/Center Panel";
@onready var center_panel_style = center_panel.get("theme_override_styles/panel");
@onready var targ_alpha = center_panel_style.bg_color.a;

@onready var top_text_start = top_text.position;
@onready var top_text_end = center_text.position - Vector2(0,300);

# Called when the node enters the scene tree for the first time.
func _ready():
	center_text.modulate.a = 0;
	set_name.call_deferred("HUD");
	center_text.text = 'Total Coins: ' + str(Persist.coins) + '\nRecord Distance: ' + str(Persist.distance) + 'm';
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_coin():
	run_coins += 1;
	
	update_hud();

# This is used by Obstacle Builder, as it already monitors the distance traveled.
func set_distance(dist: int):
	distance = dist;
	update_hud();

func update_hud():
	top_text.text = 'Coins: ' + str(run_coins) + '\nDistance: ' + str(distance) + 'm';

func shift_hud(percent: float):
	top_panel_style.bg_color.a = abs(targ_alpha - start_alpha) * percent + start_alpha;
	center_text.modulate.a = percent*1.1-0.2;
	top_text.position = top_text_start + (top_text_end - top_text_start) * percent;
	pass;

func reset_style():
	top_panel_style.bg_color.a = 0;
	
