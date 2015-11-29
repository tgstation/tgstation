/mob/living/silicon
	gender = NEUTER
	voice_name = "synthesized voice"
	can_butcher = 0
	var/syndicate = 0
	var/datum/ai_laws/laws = null//Now... THEY ALL CAN ALL HAVE LAWS
	var/list/alarms_to_show = list()
	var/list/alarms_to_clear = list()

	immune_to_ssd = 1

	var/obj/item/device/radio/borg/radio = null //AIs dont use this but this is at the silicon level to advoid copypasta in say()
	var/list/speech_synthesizer_langs = list()	//which languages can be vocalized by the speech synthesizer
	var/sensor_mode = 0 //Determines the current HUD.
	#define SEC_HUD 1 //Security HUD mode
	#define MED_HUD 2 //Medical HUD mode
	#define MESON_VISION 3 // Engineering borg and mommis
	#define NIGHT 4 // night vision
	#define THERMAL_VISION 5 // combat borgs thermals
	var/global/list/vision_types_list = list("Security Hud","Medical Hud", "Meson Vision", "Night Vision", "Thermal Vision")
	var/list/alarm_types_show = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)
	var/list/alarm_types_clear = list("Motion" = 0, "Fire" = 0, "Atmosphere" = 0, "Power" = 0, "Camera" = 0)

/mob/living/silicon/hasFullAccess()
	return 1

/mob/living/silicon/GetAccess()
	return get_all_accesses()

/mob/living/silicon/proc/cancelAlarm()
	return

/mob/living/silicon/proc/triggerAlarm()
	return

/mob/living/silicon/proc/show_laws()
	return

/mob/living/silicon/proc/write_laws()
	if(laws)
		var/text = src.laws.write_laws()
		return text

/mob/living/silicon/proc/queueAlarm(var/message, var/type, var/incoming = 1)
	var/in_cooldown = (alarms_to_show.len > 0 || alarms_to_clear.len > 0)
	if(incoming)
		alarms_to_show += message
		alarm_types_show[type] += 1
	else
		alarms_to_clear += message
		alarm_types_clear[type] += 1

	if(!in_cooldown)
		spawn(10 * 10) // 10 seconds

			if(alarms_to_show.len < 5)
				for(var/msg in alarms_to_show)
					to_chat(src, msg)
			else if(alarms_to_show.len)

				var/msg = "--- "

				if(alarm_types_show["Motion"])
					msg += "MOTION: [alarm_types_show["Motion"]] alarms detected. - "

				if(alarm_types_show["Fire"])
					msg += "FIRE: [alarm_types_show["Fire"]] alarms detected. - "

				if(alarm_types_show["Atmosphere"])
					msg += "ATMOSPHERE: [alarm_types_show["Atmosphere"]] alarms detected. - "

				if(alarm_types_show["Power"])
					msg += "POWER: [alarm_types_show["Power"]] alarms detected. - "

				if(alarm_types_show["Camera"])
					msg += "CAMERA: [alarm_types_show["Power"]] alarms detected. - "

				msg += "<A href=?src=\ref[src];showalerts=1'>\[Show Alerts\]</a>"
				to_chat(src, msg)

			if(alarms_to_clear.len < 3)
				for(var/msg in alarms_to_clear)
					to_chat(src, msg)

			else if(alarms_to_clear.len)
				var/msg = "--- "

				if(alarm_types_clear["Motion"])
					msg += "MOTION: [alarm_types_clear["Motion"]] alarms cleared. - "

				if(alarm_types_clear["Fire"])
					msg += "FIRE: [alarm_types_clear["Fire"]] alarms cleared. - "

				if(alarm_types_clear["Atmosphere"])
					msg += "ATMOSPHERE: [alarm_types_clear["Atmosphere"]] alarms cleared. - "

				if(alarm_types_clear["Power"])
					msg += "POWER: [alarm_types_clear["Power"]] alarms cleared. - "

				if(alarm_types_show["Camera"])
					msg += "CAMERA: [alarm_types_show["Power"]] alarms detected. - "

				msg += "<A href=?src=\ref[src];showalerts=1'>\[Show Alerts\]</a>"
				to_chat(src, msg)


			alarms_to_show = list()
			alarms_to_clear = list()
			for(var/i = 1; i < alarm_types_show.len; i++)
				alarm_types_show[i] = 0
			for(var/i = 1; i < alarm_types_clear.len; i++)
				alarm_types_clear[i] = 0

/mob/living/silicon/drop_item()
	return

/mob/living/silicon/generate_static_overlay()
	return

/mob/living/silicon/emp_act(severity)
	for(var/obj/item/stickybomb/B in src)
		if(B.stuck_to)
			visible_message("<span class='warning'>\the [B] stuck on \the [src] suddenly deactivates itself and falls to the ground.</span>")
			B.deactivate()
			B.unstick()

	if(flags & INVULNERABLE)
		return

	switch(severity)
		if(1)
			src.take_organ_damage(20)
			Stun(rand(5,10))
		if(2)
			src.take_organ_damage(10)
			Stun(rand(1,5))
	flick("noise", src:flash)
	to_chat(src, "<span class='danger'>*BZZZT*</span>")
	to_chat(src, "<span class='warning'>Warning: Electromagnetic pulse detected.</span>")
	..()

/mob/living/silicon/proc/damage_mob(var/brute = 0, var/fire = 0, var/tox = 0)
	return

/mob/living/silicon/IsAdvancedToolUser()
	return 1

/mob/living/silicon/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj.nodamage)	adjustBruteLoss(Proj.damage)
	Proj.on_hit(src,2)
	return 2

/mob/living/silicon/apply_effect(var/effect = 0,var/effecttype = STUN, var/blocked = 0)
	return 0//The only effect that can hit them atm is flashes and they still directly edit so this works for now
/*
	if(!effect || (blocked >= 2))	return 0
	switch(effecttype)
		if(STUN)
			stunned = max(stunned,(effect/(blocked+1)))
		if(WEAKEN)
			weakened = max(weakened,(effect/(blocked+1)))
		if(PARALYZE)
			paralysis = max(paralysis,(effect/(blocked+1)))
		if(IRRADIATE)
			radiation += min((effect - (effect*getarmor(null, "rad"))), 0)//Rads auto check armor
		if(STUTTER)
			stuttering = max(stuttering,(effect/(blocked+1)))
		if(EYE_BLUR)
			eye_blurry = max(eye_blurry,(effect/(blocked+1)))
		if(DROWSY)
			drowsyness = max(drowsyness,(effect/(blocked+1)))
	updatehealth()
	return 1*/

/proc/islinked(var/mob/living/silicon/robot/bot, var/mob/living/silicon/ai/ai)
	if(!istype(bot) || !istype(ai))
		return 0
	if (bot.connected_ai == ai)
		return 1
	return 0

/mob/living/silicon/proc/system_integrity()
	return round((health / maxHealth) * 100)

// this function shows the health of a silicon in the Status panel
/mob/living/silicon/proc/show_system_integrity()
	if(stat == CONSCIOUS)
		stat(null, text("System integrity: [system_integrity()]%"))
	else
		stat(null, text("Systems nonfunctional"))

// This is a pure virtual function, it should be overwritten by all subclasses
/mob/living/silicon/proc/show_malf_ai()
	return 0

// this function displays the station time in the status panel
/mob/living/silicon/proc/show_station_time()
	stat(null, "Station Time: [worldtime2text()]")


// this function displays the shuttles ETA in the status panel if the shuttle has been called
/mob/living/silicon/proc/show_emergency_shuttle_eta()
	if(emergency_shuttle.online && emergency_shuttle.location < 2)
		var/timeleft = emergency_shuttle.timeleft()
		if (timeleft)
			stat(null, "ETA-[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]")


// This adds the basic clock, shuttle recall timer, and malf_ai info to all silicon lifeforms
/mob/living/silicon/Stat()
	..()
	if(statpanel("Status"))
		show_station_time()
		show_emergency_shuttle_eta()
		show_system_integrity()
		show_malf_ai()

// this function displays the stations manifest in a separate window
/mob/living/silicon/proc/show_station_manifest()
	var/dat
	dat += "<h4>Crew Manifest</h4>"
	if(data_core)
		dat += data_core.get_manifest(1) // make it monochrome
	dat += "<br>"
	src << browse(dat, "window=airoster")
	onclose(src, "airoster")

/mob/living/silicon/electrocute_act(const/shock_damage, const/obj/source, const/siemens_coeff = 1.0)
	if(istype(source, /obj/machinery/containment_field))
		var/damage = shock_damage * siemens_coeff * 0.75 // take reduced damage

		if(damage <= 0)
			damage = 0

		if(take_overall_damage(0, damage, "[source]") == 0) // godmode
			return 0

		visible_message( \
			"<span class='warning'>[src] was shocked by the [source]!</span>", \
			"<span class='danger'>Energy pulse detected, system damaged!</span>", \
			"<span class='warning'>You hear a heavy electrical crack.</span>" \
		)

		if(prob(20))
			Stun(2)

		var/datum/effect/effect/system/spark_spread/SparkSpread = new
		SparkSpread.set_up(5, 1, loc)
		SparkSpread.start()

		return damage

	return 0

/mob/living/silicon/assess_threat() //Secbots will not target silicons!
	return -10

/mob/living/silicon/put_in_hand_check(var/obj/item/W)
	return 0

/mob/living/silicon/can_speak_lang(datum/language/speaking)
	return universal_speak || (speaking in src.speech_synthesizer_langs)	//need speech synthesizer support to vocalize a language

/mob/living/silicon/add_language(var/language, var/can_speak=1)
	if (..(language) && can_speak)
		speech_synthesizer_langs |= (all_languages[language])
		return 1

/mob/living/silicon/remove_language(var/rem_language)
	..(rem_language)

	for (var/datum/language/L in speech_synthesizer_langs)
		if (L.name == rem_language)
			speech_synthesizer_langs -= L

/mob/living/silicon/check_languages()
	set name = "Check Known Languages"
	set category = "IC"
	set src = usr

	var/dat = "<b><font size = 5>Known Languages</font></b><br/><br/>"

	if(default_language)
		dat += "Current default language: [default_language] - <a href='byond://?src=\ref[src];default_lang=reset'>reset</a><br/><br/>"

	for(var/datum/language/L in languages)
		var/default_str
		if(L == default_language)
			default_str = " - default - <a href='byond://?src=\ref[src];default_lang=reset'>reset</a>"
		else
			default_str = " - <a href='byond://?src=\ref[src];default_lang=[L]'>set default</a>"

		var/synth = (L in speech_synthesizer_langs)
		dat += "<b>[L.name] (:[L.key])</b>[synth ? default_str : null]<br/>Speech Synthesizer: <i>[synth ? "YES" : "NOT SUPPORTED"]</i><br/>[L.desc]<br/><br/>"

	src << browse(dat, "window=checklanguage")
	return

/mob/living/silicon/dexterity_check()
	return 1

/mob/living/silicon/html_mob_check(var/typepath)
	for(var/atom/movable/AM in html_machines)
		if(typepath == AM.type)
			if(max(abs(AM.x-src.x),abs(AM.y-src.y)) <= client.view)
				return 1
	return 0

/mob/living/silicon/spook()
	to_chat(src, "<i>[pick(boo_phrases)]</i>")
