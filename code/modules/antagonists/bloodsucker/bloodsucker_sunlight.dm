#define TIME_BLOODSUCKER_NIGHT	7200 		// 12 minutes
#define TIME_BLOODSUCKER_DAY	900 		// 1.5 minutes // 10 is a second, 600 is a minute.
#define TIME_BLOODSUCKER_DAY_WARN	900 	// 1.5 minutes
#define TIME_BLOODSUCKER_DAY_FINAL_WARN	250 // 25 sec
#define TIME_BLOODSUCKER_BURN_INTERVAL	100 // 10 sec


// Over Time, tick down toward a "Solar Flare" of UV buffeting the station. This period is harmful to vamps.
/obj/effect/sunlight
	//var/amDay = FALSE
	var/cancel_me = FALSE
	var/amDay = FALSE
	var/time_til_cycle = 0

/obj/effect/sunlight/Initialize()
	message_admins("Created Sun")
	countdown()
	hud_tick()

/obj/effect/sunlight/proc/countdown()
	set waitfor = FALSE

	while(!cancel_me)

		time_til_cycle = TIME_BLOODSUCKER_NIGHT / 10

		// Part 1: Night (all is well)
		sleep(TIME_BLOODSUCKER_NIGHT - TIME_BLOODSUCKER_DAY_WARN)
		warn_daylight("<span class = 'danger'>Solar Flares will bombard the station with dangerous UV in [TIME_BLOODSUCKER_DAY_WARN / 600] minutes. Prepare to seek cover in a coffin or closet.</span>")  // time2text <-- use Help On

		// Part 2: Night Ending
		sleep(TIME_BLOODSUCKER_DAY_WARN - TIME_BLOODSUCKER_DAY_FINAL_WARN)
		warn_daylight("<span class = 'userdanger'>Solar Flares are about to bombard the station! You have [TIME_BLOODSUCKER_DAY_FINAL_WARN / 10] seconds to find cover!</span>",\
					  "<span class = 'danger'>In [TIME_BLOODSUCKER_DAY_FINAL_WARN / 10], your master will be at risk of a Solar Flare. Make sure they find cover!</span>")

		// Part 3: Night Ending
		sleep(TIME_BLOODSUCKER_DAY_FINAL_WARN)
		warn_daylight("<span class = 'userdanger'>Solar flares bombard the station with deadly UV light!</span><br><span class = ''>Stay in cover for the next [TIME_BLOODSUCKER_DAY / 600] minutes or risk Final Death!</span>",\
				  	  "<span class = 'danger'>Solar flares bombard the station with UV light!</span>")

		// Part 4: Day
		amDay = TRUE
		time_til_cycle = TIME_BLOODSUCKER_DAY / 10
		sleep(10) // One second grace period.
		var/daylight_time = TIME_BLOODSUCKER_DAY
		var/issued_XP = FALSE
		while(daylight_time > 0)
			punish_vamps()
			sleep(TIME_BLOODSUCKER_BURN_INTERVAL)
			daylight_time -= TIME_BLOODSUCKER_BURN_INTERVAL
			// Issue Level Up!
			if (!issued_XP && daylight_time <= 100)
				issued_XP = TRUE
				vamps_rank_up()

		warn_daylight("<span class = 'announce'>The solar flare has ended, and the daylight danger has passed...for now.</span>",\
				  	  "<span class = 'announce'>The solar flare has ended, and the daylight danger has passed...for now.</span>")
		amDay = FALSE

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

/obj/effect/sunlight/proc/warn_daylight(vampwarn = "", vassalwarn = "")
	for (var/datum/mind/M in SSticker.mode.bloodsuckers)
		if (!istype(M))
			continue
		to_chat(M,vampwarn)
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
				M.current.adjustFireLoss(2)
				SEND_SIGNAL(M.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/daylight_1)
		else
			if (M.current.fire_stacks <= 0)
				M.current.fire_stacks = 0
				to_chat(M, "<span class='userdanger'>The solar flare sets your skin ablaze!</span>")
			M.current.adjust_fire_stacks(0.25 + bloodsuckerdatum.vamplevel / 5)
			M.current.adjustFireLoss(1 + bloodsuckerdatum.vamplevel / 5)
			M.current.IgniteMob()
			SEND_SIGNAL(M.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/daylight_2)


/obj/effect/sunlight/proc/vamps_rank_up()
	// Cycle through all vamp antags and check if they're inside a closet.
	for (var/datum/mind/M in SSticker.mode.bloodsuckers)
		if (!istype(M) || !istype(M.current))
			continue
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = M.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
		if (istype(bloodsuckerdatum))
			bloodsuckerdatum.RankUp()	// Rank up! Must still be in a coffin to level!