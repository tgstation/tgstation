/obj/structure/hivebot_beacon
	name = "beacon"
	desc = "Some odd beacon thing."
	icon = 'icons/mob/simple/hivebot.dmi'
	icon_state = "def_radar-off"
	anchored = TRUE
	density = TRUE
	var/bot_type = "norm"
	var/bot_amt = 10

/obj/structure/hivebot_beacon/Initialize(mapload)
	. = ..()
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(2, holder = src, location = loc)
	smoke.start()
	visible_message(span_boldannounce("[src] warps in!"))
	playsound(src.loc, 'sound/effects/empulse.ogg', 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(warpbots)), rand(10, 600))

/obj/structure/hivebot_beacon/proc/warpbots()
	icon_state = "def_radar"
	visible_message(span_danger("[src] turns on!"))
	while(bot_amt > 0)
		bot_amt--
		switch(bot_type)
			if("norm")
				new /mob/living/simple_animal/hostile/hivebot(get_turf(src))
			if("range")
				new /mob/living/simple_animal/hostile/hivebot/range(get_turf(src))
			if("rapid")
				new /mob/living/simple_animal/hostile/hivebot/rapid(get_turf(src))
	sleep(10 SECONDS)
	visible_message(span_boldannounce("[src] warps out!"))
	playsound(src.loc, 'sound/effects/empulse.ogg', 25, TRUE)
	qdel(src)
	return
