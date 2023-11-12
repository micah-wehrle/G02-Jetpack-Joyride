extends Node2D

@onready var coin_pickup = $"Coin Pickup";
@onready var step = $Step;
@onready var shot_fired = $"Shot Fired";
@onready var alert1 = $Alert1;
@onready var alert2 = $Alert2;
@onready var launch = $"Missile Launch";

@onready var shot_rate = $"../CharacterBody2D/Player Animation/Backpack/Particle Gun".shot_rate;
var step_rate = 330;
var shooting: bool = false;
var running: bool = true;
var last_shot_time = -1000000;
var last_step_time = -1000000;

var missile_counting = false;
var next_missile_beep = 0;
var missile_beeps_data = [];

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if shooting and Time.get_ticks_msec() - last_shot_time > shot_rate:
		last_shot_time = Time.get_ticks_msec();
		if !shot_fired.finished:
			shot_fired.stop();
		shot_fired.play();
	
	if running and Time.get_ticks_msec() - last_step_time > step_rate:
		last_step_time = Time.get_ticks_msec();
		if !step.finished:
			step.stop();
		step.play();
	
	if missile_counting:
		if Time.get_ticks_msec() > next_missile_beep:
			var beeps_data = missile_beeps_data.pop_front();
			call(beeps_data[1]);
			next_missile_beep = beeps_data[0] + Time.get_ticks_msec();
			
			if missile_beeps_data.size() == 0:
				missile_counting = false;
		pass;
	

func play_coin_pickup():
	if !coin_pickup.finished:
		coin_pickup.stop();
	coin_pickup.play();

func missile_countdown(length: int):
	if !missile_counting:
		missile_counting = true;
		next_missile_beep = 0; # this value is the time to the FIRST beep
		missile_beeps_data = [ # time to next beep, current beep sound
			[500, "play_alert1"],
			[500, "play_alert1"],
			[500, "play_alert1"],
			[500, "play_alert1"],
			[100, "play_alert2"],
			[0, "play_shot_fired"]
		];

func play_alert1():
	if !alert1.finished:
		alert1.stop();
	if !alert2.finished:
		alert2.stop();
	alert1.play();

func play_alert2():
	if !alert1.finished:
		alert1.stop();
	if !alert2.finished:
		alert2.stop();
	alert2.play();

func play_launch():
	if !launch.finished:
		launch.stop();
	launch.play();
