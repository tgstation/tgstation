
//override procs in children as necessary
/datum/artifact_effect
	var/effecttype = "unknown"		//purely used for admin checks ingame
	var/effect = EFFECT_TOUCH
	var/effectrange = 4
	var/trigger = TRIGGER_TOUCH
	var/atom/holder
	var/activated = 0
	var/chargelevel = 0
	var/chargelevelmax = 10
	var/artifact_id = ""

/datum/artifact_effect/New(var/atom/location)
	..()
	holder = location
	effect = rand(0,MAX_EFFECT)
	trigger = rand(0,MAX_TRIGGER)

	//random charge time and distance
	switch(pick(100;1, 50;2, 25;3))
		if(1)
			//short range, short charge time
			chargelevelmax = rand(3, 20)
			effectrange = rand(1, 3)
		if(2)
			//medium range, medium charge time
			chargelevelmax = rand(15, 40)
			effectrange = rand(5, 15)
		if(3)
			//large range, long charge time
			chargelevelmax = rand(20, 120)
			effectrange = rand(20, 200)

/datum/artifact_effect/proc/ToggleActivate(var/reveal_toggle = 1)
	//so that other stuff happens first
	spawn(0)
		if(activated)
			activated = 0
		else
			activated = 1
		if(holder && istype(holder, /obj/machinery/artifact))
			var/obj/machinery/artifact/A = holder
			var/display_msg
			if(activated)
				display_msg = pick("momentarily glows brightly!","distorts slightly for a moment!","flickers slightly!","vibrates!","shimmers slightly for a moment!")
			else
				display_msg = pick("grows dull!","fades in intensity!","suddenly becomes very still!","suddenly becomes very quiet!")

			if(reveal_toggle)
				A.icon_state = "ano[A.icon_num][activated]"
				A.visible_message("\red \icon[A] [A] [display_msg]")

/datum/artifact_effect/proc/DoEffectTouch(var/mob/user)
/datum/artifact_effect/proc/DoEffectAura(var/atom/holder)
/datum/artifact_effect/proc/DoEffectPulse(var/atom/holder)
/datum/artifact_effect/proc/UpdateMove()

/datum/artifact_effect/proc/process()
	if(chargelevel < chargelevelmax)
		chargelevel++

	if(activated)
		if(effect == EFFECT_AURA)
			DoEffectAura()
		else if(effect == EFFECT_PULSE && chargelevel >= chargelevelmax)
			chargelevel = 0
			DoEffectPulse()
