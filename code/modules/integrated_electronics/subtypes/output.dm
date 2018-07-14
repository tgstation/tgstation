/obj/item/integrated_circuit/output
	category_text = "Output"

/obj/item/integrated_circuit/output/screen
	name = "small screen"
	extended_desc = " use &lt;br&gt; to start a new line"
	desc = "Takes any data type as an input, and displays it to the user upon examining."
	icon_state = "screen"
	inputs = list("displayed data" = IC_PINTYPE_ANY)
	outputs = list()
	activators = list("load data" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 10
	var/eol = "&lt;br&gt;"
	var/stuff_to_display = null

/obj/item/integrated_circuit/output/screen/disconnect_all()
	..()
	stuff_to_display = null

/obj/item/integrated_circuit/output/screen/any_examine(mob/user)
	var/shown_label = ""
	if(displayed_name && displayed_name != name)
		shown_label = " labeled '[displayed_name]'"

	to_chat(user, "There is \a [src][shown_label], which displays [!isnull(stuff_to_display) ? "'[stuff_to_display]'" : "nothing"].")

/obj/item/integrated_circuit/output/screen/do_work()
	var/datum/integrated_io/I = inputs[1]
	if(isweakref(I.data))
		var/datum/d = I.data_as_type(/datum)
		if(d)
			stuff_to_display = "[d]"
	else
		stuff_to_display = replacetext("[I.data]", eol , "<br>")

/obj/item/integrated_circuit/output/screen/medium
	name = "screen"
	desc = "Takes any data type as an input and displays it to the user upon examining, and to adjacent beings when pulsed."
	icon_state = "screen_medium"
	power_draw_per_use = 20

/obj/item/integrated_circuit/output/screen/medium/do_work()
	..()
	var/list/nearby_things = range(0, get_turf(src))
	for(var/mob/M in nearby_things)
		var/obj/O = assembly ? assembly : src
		to_chat(M, "<span class='notice'>[icon2html(O.icon, world, O.icon_state)] [stuff_to_display]</span>")
	if(assembly)
		assembly.investigate_log("displayed \"[html_encode(stuff_to_display)]\" with [type].", INVESTIGATE_CIRCUIT)
	else
		investigate_log("displayed \"[html_encode(stuff_to_display)]\" as [type].", INVESTIGATE_CIRCUIT)

/obj/item/integrated_circuit/output/screen/large
	name = "large screen"
	desc = "Takes any data type as an input and displays it to the user upon examining, and to all nearby beings when pulsed."
	icon_state = "screen_large"
	power_draw_per_use = 40
	cooldown_per_use = 10

/obj/item/integrated_circuit/output/screen/large/do_work()
	..()
	var/obj/O = assembly ? get_turf(assembly) : loc
	O.visible_message("<span class='notice'>[icon2html(O.icon, world, O.icon_state)]  [stuff_to_display]</span>")
	if(assembly)
		assembly.investigate_log("displayed \"[html_encode(stuff_to_display)]\" with [type].", INVESTIGATE_CIRCUIT)
	else
		investigate_log("displayed \"[html_encode(stuff_to_display)]\" as [type].", INVESTIGATE_CIRCUIT)

/obj/item/integrated_circuit/output/light
	name = "light"
	desc = "A basic light which can be toggled on/off when pulsed."
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

/obj/item/integrated_circuit/output/light/power_fail() // Turns off the flashlight if there's no power left.
	light_toggled = FALSE
	update_lighting()

/obj/item/integrated_circuit/output/light/advanced
	name = "advanced light"
	desc = "A light that takes a hexadecimal color value and a brightness value, and can be toggled on/off by pulsing it."
	icon_state = "light_adv"
	complexity = 8
	inputs = list(
		"color" = IC_PINTYPE_COLOR,
		"brightness" = IC_PINTYPE_NUMBER
	)
	outputs = list()
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/output/light/advanced/on_data_written()
	update_lighting()

/obj/item/integrated_circuit/output/light/advanced/update_lighting()
	var/new_color = get_pin_data(IC_INPUT, 1)
	var/brightness = get_pin_data(IC_INPUT, 2)

	if(new_color && isnum(brightness))
		brightness = CLAMP(brightness, 0, 6)
		light_rgb = new_color
		light_brightness = brightness

	..()

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
	power_draw_per_use = 10
	var/list/sounds = list()

/obj/item/integrated_circuit/output/sound/Initialize()
	.= ..()
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
		vol = CLAMP(vol ,0 , 100)
		playsound(get_turf(src), selected_sound, vol, freq, -1)
		if(assembly)
			assembly.investigate_log("played a sound ([selected_sound]) with [type].", INVESTIGATE_CIRCUIT)
		else
			investigate_log("played a sound ([selected_sound]) as [type].", INVESTIGATE_CIRCUIT)

/obj/item/integrated_circuit/output/sound/on_data_written()
	power_draw_per_use =  get_pin_data(IC_INPUT, 2) * 15

/obj/item/integrated_circuit/output/sound/beeper
	name = "beeper circuit"
	desc = "Takes a sound name as an input, and will play said sound when pulsed. This circuit has a variety of beeps, boops, and buzzes to choose from."
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
	desc = "Takes a sound name as an input, and will play said sound when pulsed. This circuit is similar to those used in Securitrons."
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

/obj/item/integrated_circuit/output/sound/medbot
	name = "medbot sound circuit"
	desc = "Takes a sound name as an input, and will play said sound when pulsed. This circuit is often found in medical robots."
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

/obj/item/integrated_circuit/output/sound/vox
	name = "ai vox sound circuit"
	desc = "Takes a sound name as an input, and will play said sound when pulsed. This circuit is often found in AI announcement systems."
	spawn_flags = IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/output/sound/vox/Initialize()
	.= ..()
	sounds = GLOB.vox_sounds
	extended_desc = "The first input pin determines which sound is used. It uses the AI Vox Broadcast word list. So either experiment to find words that work, or ask the AI to help in figuring them out. The second pin determines the volume of sound that is played, and the third determines if the frequency of the sound will vary with each activation."

/obj/item/integrated_circuit/output/text_to_speech
	name = "text-to-speech circuit"
	desc = "Takes any string as an input and will make the device say the string when pulsed."
	extended_desc = "This unit is more advanced than the plain speaker circuit, able to transpose any valid text to speech."
	icon_state = "speaker"
	cooldown_per_use = 10
	complexity = 12
	inputs = list("text" = IC_PINTYPE_STRING)
	outputs = list()
	activators = list("to speech" = IC_PINTYPE_PULSE_IN)
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	power_draw_per_use = 60

/obj/item/integrated_circuit/output/text_to_speech/do_work()
	text = get_pin_data(IC_INPUT, 1)
	if(!isnull(text))
		var/atom/movable/A = get_object()
		var/sanitized_text = sanitize(text)
		A.say(sanitized_text)
		if (assembly)
			log_say("[assembly] [REF(assembly)] : [sanitized_text]")
		else 
			log_say("[name] ([type]) : [sanitized_text]")

/obj/item/integrated_circuit/output/video_camera
	name = "video camera circuit"
	desc = "Takes a string as a name and a boolean to determine whether it is on, and uses this to be a camera linked to the research network."
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
	action_flags = IC_ACTION_LONG_RANGE
	power_draw_idle = 0 // Raises to 20 when on.
	var/obj/machinery/camera/camera
	var/updating = FALSE

/obj/item/integrated_circuit/output/video_camera/New()
	..()
	camera = new(src)
	camera.network = list("rd")
	on_data_written()

/obj/item/integrated_circuit/output/video_camera/Destroy()
	QDEL_NULL(camera)
	return ..()

/obj/item/integrated_circuit/output/video_camera/proc/set_camera_status(var/status)
	if(camera)
		camera.status = status
		GLOB.cameranet.updatePortableCamera(camera)
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

/obj/item/integrated_circuit/output/video_camera/ext_moved(oldLoc, dir)
	. = ..()
	update_camera_location(oldLoc)

#define VIDEO_CAMERA_BUFFER 10
/obj/item/integrated_circuit/output/video_camera/proc/update_camera_location(oldLoc)
	oldLoc = get_turf(oldLoc)
	if(!QDELETED(camera) && !updating && oldLoc != get_turf(src))
		updating = TRUE
		addtimer(CALLBACK(src, .proc/do_camera_update, oldLoc), VIDEO_CAMERA_BUFFER)
#undef VIDEO_CAMERA_BUFFER

/obj/item/integrated_circuit/output/video_camera/proc/do_camera_update(oldLoc)
	if(!QDELETED(camera) && oldLoc != get_turf(src))
		GLOB.cameranet.updatePortableCamera(camera)
	updating = FALSE

/obj/item/integrated_circuit/output/led
	name = "light-emitting diode"
	desc = "RGB LED. Takes a boolean value in, and if the boolean value is 'true-equivalent', the LED will be marked as lit on examine."
	extended_desc = "TRUE-equivalent values are: Non-empty strings, non-zero numbers, and valid refs."
	complexity = 0.1
	icon_state = "led"
	inputs = list(
		"lit" = IC_PINTYPE_BOOLEAN,
		"color" = IC_PINTYPE_COLOR
	)
	outputs = list()
	activators = list()
	inputs_default = list(
		"2" = "#FF0000"
	)
	power_draw_idle = 0 // Raises to 1 when lit.
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH
	var/led_color = "#FF0000"

/obj/item/integrated_circuit/output/led/on_data_written()
	power_draw_idle = get_pin_data(IC_INPUT, 1) ? 1 : 0
	led_color = get_pin_data(IC_INPUT, 2)

/obj/item/integrated_circuit/output/led/power_fail()
	set_pin_data(IC_INPUT, 1, FALSE)

/obj/item/integrated_circuit/output/led/external_examine(mob/user)
	var/text_output = "There is "

	if(name == displayed_name)
		text_output += "\an [name]"
	else
		text_output += "\an ["\improper[name]"] labeled '[displayed_name]'"
	text_output += " which is currently [get_pin_data(IC_INPUT, 1) ? "lit <font color=[led_color]>*</font>" : "unlit"]."
	to_chat(user, text_output)

/obj/item/integrated_circuit/output/diagnostic_hud
	name = "AR interface"
	desc = "Takes an icon name as an input, and will update the status hud when data is written to it."
	extended_desc = "Takes an icon name as an input, and will update the status hud when data is written to it, this means it can change the icon and have the icon stay that way even if the circuit is removed. The acceptable inputs are 'alert', 'move', 'working', 'patrol', 'called', and 'heart'. Any input other than that will return the icon to its default state."
	var/list/icons = list(
		"alert" = "hudalert",
		"move" = "hudmove",
		"working" = "hudworkingleft",
		"patrol" = "hudpatrolleft",
		"called" = "hudcalledleft",
		"heart" = "hudsentientleft"
		)
	complexity = 1
	icon_state = "led"
	inputs = list(
		"icon" = IC_PINTYPE_STRING
	)
	outputs = list()
	activators = list()
	power_draw_idle = 0
	spawn_flags = IC_SPAWN_DEFAULT|IC_SPAWN_RESEARCH

/obj/item/integrated_circuit/output/diagnostic_hud/on_data_written()
	var/ID = get_pin_data(IC_INPUT, 1)
	var/selected_icon = icons[ID]
	if(assembly)
		if(selected_icon)
			assembly.prefered_hud_icon = selected_icon
		else
			assembly.prefered_hud_icon = "hudstat"
		//update the diagnostic hud
		assembly.diag_hud_set_circuitstat()