/obj/hivebot/tele//this still needs work
	name = "Beacon"
	desc = "Some odd beacon thing"
	icon = 'Hivebot.dmi'
	icon_state = "def_radar-off"
	health = 200
	task = "thinking"
	aggressive = 0
	wanderer = 0
	armor = 5

	var
		bot_type = "norm"
		bot_amt = 10
		spawn_delay = 600
		set_spawn = 0
		auto_spawn = 1
	proc
		warpbots()


	New()
		..()
		var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
		smoke.set_up(5, 0, src.loc)
		smoke.start()
		for(var/mob/O in viewers(src, null))
			O.show_message("\red <B>The [src] warps in!</B>", 1)
		playsound(src.loc, 'EMPulse.ogg', 25, 1)
		if(auto_spawn)
			spawn(spawn_delay)
				warpbots()


	warpbots()
		icon_state = "def_radar"
		for(var/mob/O in viewers(src, null))
			O.show_message("\red The [src] turns on!", 1)
		while(bot_amt > 0)
			bot_amt--
			switch(bot_type)
				if("norm")
					new /obj/hivebot(get_turf(src))
				if("range")
					new /obj/hivebot/range(get_turf(src))
				if("rapid")
					new /obj/hivebot/range/rapid(get_turf(src))
		spawn(100)
			del(src)
		return


	process()
		if(set_spawn)
			warpbots()
		..()


/obj/hivebot/tele/massive
	bot_type = "norm"
	bot_amt = 30
	auto_spawn = 0


/obj/hivebot/tele/range
	bot_type = "range"
	bot_amt = 10


/obj/hivebot/tele/rapid
	bot_type = "rapid"
	bot_amt = 10