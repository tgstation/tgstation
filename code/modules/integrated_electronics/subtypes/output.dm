/obj/item/integrated_circuit/output
	category_text = "Output"

/obj/item/integrated_circuit/output/screen
	name = "small screen"
	desc = "This small screen can display a single piece of data, when the machine is examined closely."
	icon_state = "screen"
	inputs = list("displayed data" = IC_PINTYPE_ANY)
	outputs = list()
	activators = list("load data" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 10
	var/stuff_to_display = null


/obj/item/integrated_circuit/output/screen/disconnect_all()
	..()
	stuff_to_display = null

/obj/item/integrated_circuit/output/screen/any_examine(mob/user)
	to_chat(user, "There is a little screen labeled '[name]', which displays [!isnull(stuff_to_display) ? "'[stuff_to_display]'" : "nothing"].")

/obj/item/integrated_circuit/output/screen/do_work()
	var/datum/integrated_io/I = inputs[1]
	if(isweakref(I.data))
		var/datum/d = I.data_as_type(/datum)
		if(d)
			stuff_to_display = "[d]"
	else
		stuff_to_display = I.data

/obj/item/integrated_circuit/output/screen/medium
	name = "screen"
	desc = "This screen allows for people holding the device to see a piece of data."
	icon_state = "screen_medium"
	power_draw_per_use = 20

/obj/item/integrated_circuit/output/screen/medium/do_work()
	..()
	var/list/nearby_things = range(0, get_turf(src))
	for(var/mob/M in nearby_things)
		var/obj/O = assembly ? assembly : src
		to_chat(M, "<span class='notice'>\icon[O] [stuff_to_display]</span>")

/obj/item/integrated_circuit/output/screen/large
	name = "large screen"
	desc = "This screen allows for people able to see the device to see a piece of data."
	icon_state = "screen_large"
	power_draw_per_use = 40

/obj/item/integrated_circuit/output/screen/large/do_work()
	..()
	var/obj/O = assembly ? loc : assembly
	O.visible_message("<span class='notice'>\icon[O] [stuff_to_display]</span>")

/obj/item/integrated_circuit/output/light
	name = "light"
	desc = "This light can turn on and off on command."
	icon_state = "light"
	complexity = 4
	inputs = list()
	outputs = list()
	activators = list("toggle light" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/light_toggled = 0
	var/light_brightness = 3
	var/light_rgb = "#FFFFFF"
	power_draw_idle = 0 // Adjusted based on brightness.

/obj/item/integrated_circuit/output/light/do_work()
	light_toggled = !light_toggled
	update_lighting()

/obj/item/integrated_circuit/output/light/proc/update_lighting()
	if(light_toggled)
		if(assembly)
			assembly.set_light(l_range = light_brightness, l_power = light_brightness, l_color = light_rgb)
	else
		if(assembly)
			assembly.set_light(0)
	power_draw_idle = light_toggled ? light_brightness * 2 : 0

/obj/item/integrated_circuit/output/light/advanced/update_lighting()
	var/new_color = get_pin_data(IC_INPUT, 1)
	var/brightness = get_pin_data(IC_INPUT, 2)

	if(new_color && isnum(brightness))
		brightness = Clamp(brightness, 0, 6)
		light_rgb = new_color
		light_brightness = brightness

	..()

/obj/item/integrated_circuit/output/light/power_fail() // Turns off the flashlight if there's no power left.
	light_toggled = FALSE
	update_lighting()

/obj/item/integrated_circuit/output/light/advanced
	name = "advanced light"
	desc = "This light can turn on and off on command, in any color, and in various brightness levels."
	icon_state = "light_adv"
	complexity = 8
	inputs = list(
		"color" = IC_PINTYPE_COLOR,
		"brightness" = IC_PINTYPE_NUMBER
	)
	outputs = list()
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 3, TECH_DATA = 3)

/obj/item/integrated_circuit/output/light/advanced/on_data_written()
	update_lighting()

/obj/item/integrated_circuit/output/sound
	name = "speaker circuit"
	desc = "A miniature speaker is attached to this component."
	icon_state = "speaker"
	complexity = 8
	cooldown_per_use = 4 SECONDS
	inputs = list(
		"sound ID" = IC_PINTYPE_STRING,
		"volume" = IC_PINTYPE_NUMBER,
		"frequency" = IC_PINTYPE_BOOLEAN
	)
	outputs = list()
	activators = list("play sound" = IC_PINTYPE_PULSE_IN)
	power_draw_per_use = 20
	var/list/sounds = list()

/obj/item/integrated_circuit/output/text_to_speech
	name = "text-to-speech circuit"
	desc = "A miniature speaker is attached to this component."
	extended_desc = "This unit is more advanced than the plain speaker circuit, able to transpose any valid text to speech."
	icon_state = "speaker"
	complexity = 12
	cooldown_per_use = 4 SECONDS
	inputs = list("text" = IC_PINTYPE_STRING)
	outputs = list()
	activators = list("to speech" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 60

/obj/item/integrated_circuit/output/text_to_speech/do_work()
	text = get_pin_data(IC_INPUT, 1)
	if(!isnull(text))
		var/obj/O = assembly ? loc : assembly
		audible_message("\icon[O] \The [O.name] states, \"[text]\"")

/obj/item/integrated_circuit/output/sound/New()
	..()
	extended_desc = list()
	extended_desc += "The first input pin determines which sound is used. The choices are; "
	extended_desc += jointext(sounds, ", ")
	extended_desc += ". The second pin determines the volume of sound that is played"
	extended_desc += ", and the third determines if the frequency of the sound will vary with each activation."
	extended_desc = jointext(extended_desc, null)

/obj/item/integrated_circuit/output/sound/do_work()
	var/ID = get_pin_data(IC_INPUT, 1)
	var/vol = get_pin_data(IC_INPUT, 2)
	var/freq = get_pin_data(IC_INPUT, 3)
	if(!isnull(ID) && !isnull(vol))
		var/selected_sound = sounds[ID]
		if(!selected_sound)
			return
		vol = between(0, vol, 100)
		playsound(get_turf(src), selected_sound, vol, freq, -1)

/obj/item/integrated_circuit/output/sound/beeper
	name = "beeper circuit"
	desc = "A miniature speaker is attached to this component.  This is often used in the construction of motherboards, which use \
	the speaker to tell the user if something goes very wrong when booting up.  It can also do other similar synthetic sounds such \
	as buzzing, pinging, chiming, and more."
	sounds = list(
		"beep"			= 'sound/machines/twobeep.ogg',
		"chime"			= 'sound/machines/chime.ogg',
		"buzz sigh"		= 'sound/machines/buzz-sigh.ogg',
		"buzz twice"	= 'sound/machines/buzz-two.ogg',
		"ping"			= 'sound/machines/ping.ogg',
		"synth yes"		= 'sound/machines/synth_yes.ogg',
		"synth no"		= 'sound/machines/synth_no.ogg',
		"warning buzz"	= 'sound/machines/warning-buzzer.ogg'
		)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/output/sound/beepsky
	name = "securitron sound circuit"
	desc = "A miniature speaker is attached to this component.  Considered by some to be the essential component for a securitron."
	sounds = list(
		"creep"			= 'sound/voice/bcreep.ogg',
		"criminal"		= 'sound/voice/bcriminal.ogg',
		"freeze"		= 'sound/voice/bfreeze.ogg',
		"god"			= 'sound/voice/bgod.ogg',
		"i am the law"	= 'sound/voice/biamthelaw.ogg',
		"insult"		= 'sound/voice/binsult.ogg',
		"radio"			= 'sound/voice/bradio.ogg',
		"secure day"	= 'sound/voice/bsecureday.ogg',
		)
	spawn_flags = IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_ILLEGAL = 1)

/obj/item/integrated_circuit/output/sound/medbot
	name = "medbot sound circuit"
	desc = "A miniature speaker is attached to this component, used to annoy patients while they get pricked by a medbot."
	sounds = list(
		"surgeon"		= 'sound/voice/msurgeon.ogg',
		"radar"			= 'sound/voice/mradar.ogg',
		"feel better"	= 'sound/voice/mfeelbetter.ogg',
		"patched up"	= 'sound/voice/mpatchedup.ogg',
		"injured"		= 'sound/voice/minjured.ogg',
		"insult"		= 'sound/voice/minsult.ogg',
		"coming"		= 'sound/voice/mcoming.ogg',
		"help"			= 'sound/voice/mhelp.ogg',
		"live"			= 'sound/voice/mlive.ogg',
		"lost"			= 'sound/voice/mlost.ogg',
		"flies"			= 'sound/voice/mflies.ogg',
		"catch"			= 'sound/voice/mcatch.ogg',
		"delicious"		= 'sound/voice/mdelicious.ogg',
		"apple"			= 'sound/voice/mapple.ogg',
		"no"			= 'sound/voice/mno.ogg',
		)
	spawn_flags = IC_SPAWN_RESEARCH
	origin_tech = list(TECH_ENGINEERING = 2, TECH_DATA = 2, TECH_BIO = 1)

/obj/item/integrated_circuit/output/video_camera
	name = "video camera circuit"
	desc = "This small camera allows a remote viewer to see what it sees."
	extended_desc = "The camera is linked to the Research camera network."
	icon_state = "video_camera"
	w_class = WEIGHT_CLASS_SMALL
	complexity = 10
	inputs = list(
		"camera name" = IC_PINTYPE_STRING,
		"camera active" = IC_PINTYPE_BOOLEAN
		)
	inputs_default = list("1" = "video camera circuit")
	outputs = list()
	activators = list()
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_idle = 0 // Raises to 20 when on.
	var/obj/machinery/camera/camera

/obj/item/integrated_circuit/output/video_camera/New()
	..()
	camera = new(src)
	on_data_written()

/obj/item/integrated_circuit/output/video_camera/Destroy()
	QDEL_NULL(camera)
	return ..()

/obj/item/integrated_circuit/output/video_camera/proc/set_camera_status(var/status)
	if(camera)
		camera.set_status(status)
		power_draw_idle = camera.status ? 20 : 0
		if(camera.status) // Ensure that there's actually power.
			if(!draw_idle_power())
				power_fail()

/obj/item/integrated_circuit/output/video_camera/on_data_written()
	if(camera)
		var/cam_name = get_pin_data(IC_INPUT, 1)
		var/cam_active = get_pin_data(IC_INPUT, 2)
		if(!isnull(cam_name))
			camera.c_tag = cam_name
		set_camera_status(cam_active)

/obj/item/integrated_circuit/output/video_camera/power_fail()
	if(camera)
		set_camera_status(0)
		set_pin_data(IC_INPUT, 2, FALSE)

/obj/item/integrated_circuit/output/led
	name = "light-emitting diode"
	desc = "This a LED that is lit whenever there is TRUE-equivalent data on its input."
	extended_desc = "TRUE-equivalent values are: Non-empty strings, non-zero numbers, and valid refs."
	complexity = 0.1
	icon_state = "led"
	inputs = list("lit" = IC_PINTYPE_BOOLEAN)
	outputs = list()
	activators = list()
	power_draw_idle = 0 // Raises to 1 when lit.
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/led_color

/obj/item/integrated_circuit/output/led/on_data_written()
	power_draw_idle = get_pin_data(IC_INPUT, 1) ? 1 : 0

/obj/item/integrated_circuit/output/led/power_fail()
	set_pin_data(IC_INPUT, 1, FALSE)

/obj/item/integrated_circuit/output/led/any_examine(mob/user)
	var/text_output = list()
	var/initial_name = initial(name)

	// Doing all this work just to have a color-blind friendly output.
	text_output += "There is "
	if(name == initial_name)
		text_output += "\an [name]"
	else
		text_output += "\an ["\improper[initial_name]"] labeled '[name]'"
	text_output += " which is currently [get_pin_data(IC_INPUT, 1) ? "lit <font color=[led_color]>¤</font>" : "unlit."]"
	to_chat(user,jointext(text_output,null))

/obj/item/integrated_circuit/output/led/red
	name = "red LED"
	led_color = "#FF0000"

/obj/item/integrated_circuit/output/led/orange
	name = "orange LED"
	led_color = "#FF9900"

/obj/item/integrated_circuit/output/led/yellow
	name = "yellow LED"
	led_color = "#FFFF00"

/obj/item/integrated_circuit/output/led/green
	name = "green LED"
	led_color = "#008000"

/obj/item/integrated_circuit/output/led/blue
	name = "blue LED"
	led_color = "#0000FF"

/obj/item/integrated_circuit/output/led/purple
	name = "purple LED"
	led_color = "#800080"

/obj/item/integrated_circuit/output/led/cyan
	name = "cyan LED"
	led_color = "#00FFFF"

/obj/item/integrated_circuit/output/led/white
	name = "white LED"
	led_color = "#FFFFFF"

/obj/item/integrated_circuit/output/led/pink
	name = "pink LED"
	led_color = "#FF00FF"
