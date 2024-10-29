/**
 * # Sound Emitter Component
 *
 * A component that emits a sound when it receives an input.
 */
/obj/item/circuit_component/soundemitter
	display_name = "Sound Emitter"
	desc = "A component that emits a sound when it receives an input. The frequency is a multiplier which determines the speed at which the sound is played"
	category = "Action"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// Sound to play
	var/datum/port/input/option/sound_file

	/// Volume of the sound when played
	var/datum/port/input/volume

	/// Whether to play the sound backwards
	var/datum/port/input/backwards

	/// Frequency of the sound when played
	var/datum/port/input/frequency

	/// The cooldown for this component of how often it can play sounds.
	var/sound_cooldown = 2 SECONDS

	/// The maximum pitch this component can play sounds at.
	var/max_pitch = 50
	/// The minimum pitch this component can play sounds at.
	var/min_pitch = -50
	/// The maximum volume this component can play sounds at.
	var/max_volume = 30

	var/list/options_map

/obj/item/circuit_component/soundemitter/get_ui_notices()
	. = ..()
	. += create_ui_notice("Sound Cooldown: [DisplayTimeText(sound_cooldown)]", "orange", "stopwatch")
	if(CONFIG_GET(flag/disallow_circuit_sounds))
		. += create_ui_notice("Non-functional", "red", "exclamation")


/obj/item/circuit_component/soundemitter/populate_ports()
	volume = add_input_port("Volume", PORT_TYPE_NUMBER, default = 35)
	frequency = add_input_port("Frequency", PORT_TYPE_NUMBER, default = 0)
	backwards = add_input_port("Play Backwards", PORT_TYPE_NUMBER, default = 0)

/obj/item/circuit_component/soundemitter/populate_options()
	var/static/component_options = list(
		"Buzz" = 'sound/machines/buzz/buzz-sigh.ogg',
		"Buzz Twice" = 'sound/machines/buzz/buzz-two.ogg',
		"Chime" = 'sound/machines/chime.ogg',
		"Honk" = 'sound/items/bikehorn.ogg',
		"Ping" = 'sound/machines/ping.ogg',
		"Sad Trombone" = 'sound/misc/sadtrombone.ogg',
		"Warn" = 'sound/machines/warning-buzzer.ogg',
		"Slow Clap" = 'sound/machines/slowclap.ogg',
		"Moth Buzz" = 'sound/mobs/humanoids/moth/scream_moth.ogg',
		"Squeak" = 'sound/items/toy_squeak/toysqueak1.ogg',
		"Rip" = 'sound/items/poster/poster_ripped.ogg',
		"Coinflip" = 'sound/items/coinflip.ogg',
		"Megaphone" = 'sound/items/megaphone.ogg',
		"Warpwhistle" = 'sound/effects/magic/warpwhistle.ogg',
		"Hiss" = 'sound/mobs/non-humanoids/hiss/hiss1.ogg',
		"Lizard" = 'sound/mobs/humanoids/lizard/lizard_scream_1.ogg',
		"Flashbang" = 'sound/items/weapons/flashbang.ogg',
		"Flash" = 'sound/items/weapons/flash.ogg',
		"Whip" = 'sound/items/weapons/whip.ogg',
		"Laugh Track" = 'sound/items/sitcom_laugh/sitcomLaugh1.ogg',
		"Gavel" = 'sound/items/gavel.ogg',
	)
	sound_file = add_option_port("Sound Option", component_options)
	options_map = component_options

/obj/item/circuit_component/soundemitter/pre_input_received(datum/port/input/port)
	volume.set_value(clamp(volume.value, 0, 100))
	frequency.set_value(clamp(frequency.value, min_pitch, max_pitch))
	backwards.set_value(clamp(backwards.value, 0, 1))

/obj/item/circuit_component/soundemitter/input_received(datum/port/input/port)
	if(CONFIG_GET(flag/disallow_circuit_sounds))
		ui_color = "red"
		return
	else
		ui_color = initial(ui_color)

	if(!parent.shell)
		return

	if(TIMER_COOLDOWN_RUNNING(parent.shell, COOLDOWN_CIRCUIT_SOUNDEMITTER))
		return

	var/sound_to_play = options_map[sound_file.value]
	if(!sound_to_play)
		return

	var/actual_frequency = 1 + (frequency.value/100)
	var/actual_volume = max_volume * (volume.value/100)

	if(backwards.value)
		actual_frequency = -actual_frequency

	playsound(src, sound_to_play, actual_volume, TRUE, frequency = actual_frequency)

	TIMER_COOLDOWN_START(parent.shell, COOLDOWN_CIRCUIT_SOUNDEMITTER, sound_cooldown)
