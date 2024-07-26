/obj/machinery/base_alarm
	name = "base alarm"
	desc = "Pull this to alert the guards!"
	icon = 'monkestation/code/modules/assault_ops/icons/alarm.dmi'
	icon_state = "alarm"
	max_integrity = 250
	integrity_failure = 0.4
	use_power = NO_POWER_USE
	resistance_flags = FIRE_PROOF

	light_power = 0
	light_outer_range = 4
	light_color = COLOR_VIVID_RED

	//Trick to get the glowing overlay visible from a distance
	luminosity = 1

	/// Is the alarm currently playing? WAIT WHY IS THIS NOT A LOOPING SOUND
	var/alarm_playing = FALSE
	/// Are we triggered?
	var/triggered = FALSE
	/// Currently connected alarms.
	var/list/obj/machinery/base_alarm/alarms = list()
	/// The area that we use to trigger other alarms.
	var/area/myarea = null
	/// Path to the alarm sound
	var/alarm_sound_file = 'monkestation/code/modules/assault_ops/sound/goldeneyealarm.ogg'
	/// Cooldown between each sound
	var/alarm_cooldown = 65

/obj/machinery/base_alarm/Initialize(mapload)
	. = ..()
	update_icon()
	myarea = get_area(src)
	for(var/obj/machinery/base_alarm/alarm in myarea)
		alarms.Add(alarm)

/obj/machinery/base_alarm/Destroy()
	LAZYREMOVE(alarms, src)
	return ..()

/obj/machinery/base_alarm/attack_hand(mob/user)
	add_fingerprint(user)
	to_chat(user, span_notice("You trigger [src]!"))
	playsound(src, 'sound/machines/pda_button1.ogg', 100)
	trigger_alarm()

/obj/machinery/base_alarm/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/base_alarm/attack_robot(mob/user)
	return attack_hand(user)

/obj/machinery/base_alarm/proc/trigger_alarm()
	if(triggered)
		reset()
	else
		alarm()

/obj/machinery/base_alarm/proc/alarm()
	for(var/obj/machinery/base_alarm/iterating_alarm in alarms)
		iterating_alarm.icon_state = "alarm_on"
		iterating_alarm.set_light(l_power = 2)
		iterating_alarm.triggered = TRUE
		if(!iterating_alarm.alarm_playing)
			iterating_alarm.alarm_playing = TRUE
			playsound(iterating_alarm, alarm_sound_file, 30)
			addtimer(CALLBACK(iterating_alarm, PROC_REF(alarm_sound)), alarm_cooldown)

/obj/machinery/base_alarm/proc/alarm_sound()
	if(!triggered)
		alarm_playing = FALSE
	else
		playsound(src, alarm_sound_file, 30)
		addtimer(CALLBACK(src, PROC_REF(alarm_sound)), alarm_cooldown)


/obj/machinery/base_alarm/proc/reset(mob/user)
	for(var/obj/machinery/base_alarm/iterating_alarm in alarms)
		iterating_alarm.icon_state = "alarm"
		iterating_alarm.set_light(l_power = 0)
		iterating_alarm.triggered = FALSE
