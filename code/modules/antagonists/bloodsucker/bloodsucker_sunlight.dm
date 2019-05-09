#define TIME_BLOODSUCKER_NIGHT	720 		// 12 minutes
#define TIME_BLOODSUCKER_DAY_WARN	90 		// 1.5 minutes
#define TIME_BLOODSUCKER_DAY_FINAL_WARN	25 	// 25 sec
#define TIME_BLOODSUCKER_DAY	60 			// 1.5 minutes // 10 is a second, 600 is a minute.
#define TIME_BLOODSUCKER_BURN_INTERVAL	4 	// 4 sec


// Over Time, tick down toward a "Solar Flare" of UV buffeting the station. This period is harmful to vamps.
/obj/effect/sunlight
	//var/amDay = FALSE
	var/cancel_me = FALSE
	var/amDay = FALSE
	var/time_til_cycle = 0

/obj/effect/sunlight/Initialize()
	countdown()
	hud_tick()

/obj/effect/sunlight/proc/countdown()
	set waitfor = FALSE

	while(!cancel_me)

		time_til_cycle = TIME_BLOODSUCKER_NIGHT

		// Part 1: Night (all is well)
		while (time_til_cycle > TIME_BLOODSUCKER_DAY_WARN)
			sleep(10)
			if (cancel_me)
				return
		//sleep(TIME_BLOODSUCKER_NIGHT - TIME_BLOODSUCKER_DAY_WARN)
		warn_daylight(1,"<span class = 'danger'>Solar Flares will bombard the station with dangerous UV in [TIME_BLOODSUCKER_DAY_WARN / 60] minutes. <b>Prepare to seek cover in a coffin or closet.</b></span>")  // time2text <-- use Help On

		// Part 2: Night Ending
		while (time_til_cycle > TIME_BLOODSUCKER_DAY_FINAL_WARN)
			sleep(10)
			if (cancel_me)
				return
		//sleep(TIME_BLOODSUCKER_DAY_WARN - TIME_BLOODSUCKER_DAY_FINAL_WARN)
		message_admins("BLOODSUCKER NOTICE: Daylight beginning in [TIME_BLOODSUCKER_DAY_FINAL_WARN] seconds.)")
		warn_daylight(2,"<span class = 'userdanger'>Solar Flares are about to bombard the station! You have [TIME_BLOODSUCKER_DAY_FINAL_WARN] seconds to find cover!</span>",\
					  "<span class = 'danger'>In [TIME_BLOODSUCKER_DAY_FINAL_WARN / 10], your master will be at risk of a Solar Flare. Make sure they find cover!</span>")

		// (FINAL LIL WARNING)
		while (time_til_cycle > 5)
			sleep(10)
			if (cancel_me)
				return
		//sleep(TIME_BLOODSUCKER_DAY_FINAL_WARN - 50)
		warn_daylight(3,"<span class = 'userdanger'>Seek cover, for Sol rises!</span>")

		// Part 3: Night Ending
		while (time_til_cycle > 0)
			sleep(10)
			if (cancel_me)
				return
		//sleep(50)
		warn_daylight(4,"<span class = 'userdanger'>Solar flares bombard the station with deadly UV light!</span><br><span class = ''>Stay in cover for the next [TIME_BLOODSUCKER_DAY / 60] minutes or risk Final Death!</span>",\
				  	  "<span class = 'danger'>Solar flares bombard the station with UV light!</span>")

		// Part 4: Day
		amDay = TRUE
		message_admins("BLOODSUCKER NOTICE: Daylight Beginning (Lasts for [TIME_BLOODSUCKER_DAY / 60] minutes.)")
		time_til_cycle = TIME_BLOODSUCKER_DAY
		sleep(10) // One second grace period.
		//var/daylight_time = TIME_BLOODSUCKER_DAY
		var/issued_XP = FALSE
		while(time_til_cycle > 0)
			punish_vamps()
			sleep(TIME_BLOODSUCKER_BURN_INTERVAL)
			if (cancel_me)
				return
			//daylight_time -= TIME_BLOODSUCKER_BURN_INTERVAL
			// Issue Level Up!
			if (!issued_XP && time_til_cycle <= 15)
				issued_XP = TRUE
				vamps_rank_up()

		warn_daylight(5,"<span class = 'announce'>The solar flare has ended, and the daylight danger has passed...for now.</span>",\
				  	  "<span class = 'announce'>The solar flare has ended, and the daylight danger has passed...for now.</span>")
		amDay = FALSE
		message_admins("BLOODSUCKER NOTICE: Daylight Ended. Resetting to Night (Lasts for [TIME_BLOODSUCKER_NIGHT / 60] minutes.)")


/obj/effect/sunlight/proc/hud_tick()
	set waitfor = FALSE

	while(!cancel_me)

		// Update all Bloodsucker sunlight huds
		for (var/datum/mind/M in SSticker.mode.bloodsuckers)
			if (!istype(M) || !istype(M.current))
				continue
			var/datum/antagonist/bloodsucker/bloodsuckerdatum = M.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
			if (istype(bloodsuckerdatum))
				bloodsuckerdatum.update_sunlight(max(0, time_til_cycle), amDay) // This pings all HUDs

		sleep(10)
		time_til_cycle --

/obj/effect/sunlight/proc/warn_daylight(danger_level=0, vampwarn = "", vassalwarn = "")
	for (var/datum/mind/M in SSticker.mode.bloodsuckers)
		if (!istype(M))
			continue
		to_chat(M,vampwarn)
		if (M.current)
			if (danger_level == 1)
				M.current.playsound_local(null, 'sound/chatter/griffin_3.ogg', 50 + danger_level, 1)
			else if (danger_level == 2)
				M.current.playsound_local(null, 'sound/chatter/griffin_5.ogg', 50 + danger_level, 1)
			else if (danger_level == 3)
				M.current.playsound_local(null, 'sound/effects/alert.ogg', 75, 1)
			else if (danger_level == 4)
				M.current.playsound_local(null, 'sound/ambience/ambimystery.ogg', 100, 1)
			else if (danger_level == 5)
				M.current.playsound_local(null, 'sound/spookoween/ghosty_wind.ogg', 90, 1)

	if (vassalwarn != "")
		for (var/datum/mind/M in SSticker.mode.vassals)
			if (!istype(M))
				continue
			to_chat(M,vassalwarn)


/obj/effect/sunlight/proc/punish_vamps()
	// Cycle through all vamp antags and check if they're inside a closet.
	for (var/datum/mind/M in SSticker.mode.bloodsuckers)
		if (!istype(M) || !istype(M.current))
			continue
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = M.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		if (!istype(bloodsuckerdatum))
			continue
		// Closets offer SOME protection
		if (istype(M.current.loc, /obj/structure))
			// Coffins offer the BEST protection
			if (istype(M.current.loc, /obj/structure/closet/crate/coffin))
				SEND_SIGNAL(M.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/coffinsleep)
				continue
			else
				to_chat(M, "<span class='warning'>Your skin sizzles. The [M.current] doesn't protect well against UV bombardment.</span>")
				M.current.fireloss += bloodsuckerdatum.vamplevel  //  Do DIRECT damage. Being spaced was causing this to not occur. setFireLoss(bloodsuckerdatum.vamplevel)
				M.current.updatehealth()
				SEND_SIGNAL(M.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/daylight_1)
		else
			if (M.current.fire_stacks <= 0)
				M.current.fire_stacks = 0
				to_chat(M, "<span class='userdanger'>The solar flare sets your skin ablaze!</span>")
			M.current.adjust_fire_stacks(0.4)
			M.current.IgniteMob()
			M.current.fireloss += 2 + bloodsuckerdatum.vamplevel   //  Do DIRECT damage. Being spaced was causing this to not occur.  //setFireLoss(2 + bloodsuckerdatum.vamplevel)
			M.current.updatehealth()
			SEND_SIGNAL(M.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/daylight_2)


/obj/effect/sunlight/proc/vamps_rank_up()
	set waitfor = FALSE
	// Cycle through all vamp antags and check if they're inside a closet.
	for (var/datum/mind/M in SSticker.mode.bloodsuckers)
		if (!istype(M) || !istype(M.current))
			continue
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = M.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		if (istype(bloodsuckerdatum))
			bloodsuckerdatum.RankUp()	// Rank up! Must still be in a coffin to level!