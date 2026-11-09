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
	do_smoke(2, src, loc)
	visible_message(span_bolddanger("[src] warps in!"))
	playsound(src.loc, 'sound/effects/empulse.ogg', 25, TRUE)
	addtimer(CALLBACK(src, PROC_REF(warpbots)), rand(1 SECONDS, 1 MINUTES))

/obj/structure/hivebot_beacon/proc/warpbots()
	icon_state = "def_radar"
	visible_message(span_danger("[src] turns on!"))
	while(bot_amt > 0)
		bot_amt--
		switch(bot_type)
			if("norm")
				new /mob/living/basic/hivebot(get_turf(src))
			if("range")
				new /mob/living/basic/hivebot/range(get_turf(src))
			if("rapid")
				new /mob/living/basic/hivebot/rapid(get_turf(src))
	sleep(10 SECONDS)
	visible_message(span_bolddanger("[src] warps out!"))
	playsound(src.loc, 'sound/effects/empulse.ogg', 25, TRUE)
	qdel(src)
	return
