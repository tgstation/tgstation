/**
 * # Sound Emitter Component
 *
 * A component that emits a sound when it receives an input.
 */
/obj/item/circuit_component/soundemitter
	display_name = "Sound Emitter"
	display_desc = "A component that emits a sound when it receives an input. The frequency is a multiplier which determines the speed at which the sound is played"
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	/// Volume of the sound when played
	var/datum/port/input/volume

	/// Frequency of the sound when played
	var/datum/port/input/frequency

	/// The cooldown for this component of how often it can play sounds.
	var/sound_cooldown = 2 SECONDS

	var/list/options_map

	COOLDOWN_DECLARE(next_sound)

/obj/item/circuit_component/soundemitter/get_ui_notices()
	. = ..()
	. += create_ui_notice("Sound Cooldown: [DisplayTimeText(sound_cooldown)]", "orange", "stopwatch")


/obj/item/circuit_component/soundemitter/Initialize()
	. = ..()
	volume = add_input_port("Volume", PORT_TYPE_NUMBER, default = 35)
	frequency = add_input_port("Frequency", PORT_TYPE_NUMBER, default = 0)

/obj/item/circuit_component/soundemitter/Destroy()
	frequency = null
	volume = null
	return ..()

/obj/item/circuit_component/soundemitter/populate_options()
	var/static/component_options = list(
		COMP_SOUND_BUZZ,
		COMP_SOUND_BUZZ_TWO,
		COMP_SOUND_CHIME,
		COMP_SOUND_HONK,
		COMP_SOUND_PING,
		COMP_SOUND_SAD,
		COMP_SOUND_WARN,
		COMP_SOUND_SLOWCLAP,
	)
	options = component_options

	var/static/options_to_sound = list(
		COMP_SOUND_BUZZ = 'sound/machines/buzz-sigh.ogg',
		COMP_SOUND_BUZZ_TWO = 'sound/machines/buzz-two.ogg',
		COMP_SOUND_CHIME = 'sound/machines/chime.ogg',
		COMP_SOUND_HONK = 'sound/items/bikehorn.ogg',
		COMP_SOUND_PING = 'sound/machines/ping.ogg',
		COMP_SOUND_SAD = 'sound/misc/sadtrombone.ogg',
		COMP_SOUND_WARN = 'sound/machines/warning-buzzer.ogg',
		COMP_SOUND_SLOWCLAP = 'sound/machines/slowclap.ogg',
	)
	options_map = options_to_sound


/obj/item/circuit_component/soundemitter/input_received(datum/port/input/port)
	. = ..()
	volume.set_input(clamp(volume.input_value, 0, 100), FALSE)
	frequency.set_input(clamp(frequency.input_value, -100, 100), FALSE)
	if(.)
		return

	if(!COOLDOWN_FINISHED(src, next_sound))
		return

	var/sound_to_play = options_map[current_option]
	if(!sound_to_play)
		return

	playsound(src, sound_to_play, volume.input_value, FALSE, frequency = frequency.input_value)

	COOLDOWN_START(src, next_sound, sound_cooldown)
