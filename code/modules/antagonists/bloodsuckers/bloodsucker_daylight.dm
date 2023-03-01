/// 45 seconds
#define TIME_BLOODSUCKER_DAY 45 
/// 10 minutes
#define TIME_BLOODSUCKER_NIGHT 600
/// 1.5 minutes
#define TIME_BLOODSUCKER_DAY_WARN 90
/// 30 seconds
#define TIME_BLOODSUCKER_DAY_FINAL_WARN 30
/// 5 seconds
#define TIME_BLOODSUCKER_BURN_INTERVAL 5

/// Over Time, tick down toward a "Solar Flare" of UV buffeting the station. This period is harmful to vamps.
/obj/effect/sunlight
	///If the Sun is currently out our not
	var/amDay = FALSE
	///The time between the next cycle
	var/time_til_cycle = TIME_BLOODSUCKER_NIGHT
	///If Bloodsuckers have been given their level yet
	var/issued_XP = FALSE

/obj/effect/sunlight/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/effect/sunlight/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/effect/sunlight/process()
	/// Update all Bloodsucker sunlight huds
	for(var/datum/mind/bloodsucker_minds as anything in get_antag_minds(/datum/antagonist/bloodsucker))
		if(!istype(bloodsucker_minds) || !istype(bloodsucker_minds.current))
			continue
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = bloodsucker_minds.has_antag_datum(/datum/antagonist/bloodsucker)
		if(istype(bloodsuckerdatum))
			bloodsuckerdatum.update_sunlight(max(0, time_til_cycle), amDay) // This pings all HUDs
	time_til_cycle--
	if(amDay)
		if(time_til_cycle > 0)
			punish_vamps()
			if(!issued_XP && time_til_cycle <= 15)
				issued_XP = TRUE
				/// Cycle through all vamp antags and check if they're inside a closet.
				for(var/datum/mind/bloodsucker_minds as anything in get_antag_minds(/datum/antagonist/bloodsucker))
					if(!istype(bloodsucker_minds) || !istype(bloodsucker_minds.current))
						continue
					var/datum/antagonist/bloodsucker/bloodsuckerdatum = bloodsucker_minds.has_antag_datum(/datum/antagonist/bloodsucker)
					if(bloodsuckerdatum)
						// Rank up! Must still be in a coffin to level!
						bloodsuckerdatum.RankUp()
		if(time_til_cycle <= 1)
			warn_daylight(5, span_announce("The solar flare has ended, and the daylight danger has passed...for now."), \
				span_announce("The solar flare has ended, and the daylight danger has passed...for now."), \
				"")
			amDay = FALSE
			issued_XP = FALSE
			time_til_cycle = TIME_BLOODSUCKER_NIGHT
			message_admins("BLOODSUCKER NOTICE: Daylight Ended. Resetting to Night (Lasts for [TIME_BLOODSUCKER_NIGHT / 60] minutes.)")
			for(var/datum/mind/bloodsucker_minds as anything in get_antag_minds(/datum/antagonist/bloodsucker))
				if(!istype(bloodsucker_minds) || !istype(bloodsucker_minds.current))
					continue
				var/datum/antagonist/bloodsucker/bloodsuckerdatum = bloodsucker_minds.has_antag_datum(/datum/antagonist/bloodsucker)
				if(!istype(bloodsuckerdatum))
					continue
				take_home_power()
	else
		switch(time_til_cycle)
			if(TIME_BLOODSUCKER_DAY_WARN)
				warn_daylight(1, span_danger("Solar Flares will bombard the station with dangerous UV in [TIME_BLOODSUCKER_DAY_WARN / 60] minutes. <b>Prepare to seek cover in a coffin or closet.</b>"), \
					"", \
					"")
				give_home_power()
			if(TIME_BLOODSUCKER_DAY_FINAL_WARN)
				message_admins("BLOODSUCKER NOTICE: Daylight beginning in [TIME_BLOODSUCKER_DAY_FINAL_WARN] seconds.")
				warn_daylight(2, span_userdanger("Solar Flares are about to bombard the station! You have [TIME_BLOODSUCKER_DAY_FINAL_WARN] seconds to find cover!"), \
					span_danger("In [TIME_BLOODSUCKER_DAY_FINAL_WARN / 10], your master will be at risk of a Solar Flare. Make sure they find cover!"), \
					"")
			if(TIME_BLOODSUCKER_BURN_INTERVAL)
				warn_daylight(3, span_userdanger("Seek cover, for Sol rises!"), \
					"", \
					"")
			if(0)
				amDay = TRUE
				time_til_cycle = TIME_BLOODSUCKER_DAY
				for(var/datum/mind/bloodsucker_minds as anything in get_antag_minds(/datum/antagonist/bloodsucker))
					if(!istype(bloodsucker_minds) || !istype(bloodsucker_minds.current))
						continue
					var/datum/antagonist/bloodsucker/bloodsuckerdatum = bloodsucker_minds.has_antag_datum(/datum/antagonist/bloodsucker)
					if(!istype(bloodsuckerdatum))
						continue
					if(bloodsuckerdatum.my_clan == CLAN_GANGREL)
						give_transform_power()
					if(!iscarbon(bloodsucker_minds.current))
						qdel(bloodsucker_minds.current)
					if(bloodsuckerdatum.altar_uses > 0)
						to_chat(bloodsuckerdatum, span_notice("Your Altar uses have been reset!"))
						bloodsuckerdatum.altar_uses = 0
				warn_daylight(4, span_userdanger("Solar flares bombard the station with deadly UV light!<br><span class = ''>Stay in cover for the next [TIME_BLOODSUCKER_DAY / 60] minutes or risk Final Death!"), \
					span_userdanger("Solar flares bombard the station with UV light!"), \
					span_userdanger("The sunlight is visible throughout the station, the Bloodsuckers must be asleep by now!"))
				message_admins("BLOODSUCKER NOTICE: Daylight Beginning (Lasts for [TIME_BLOODSUCKER_DAY / 60] minutes.)")

/obj/effect/sunlight/proc/warn_daylight(danger_level = 0, vampwarn = "", vassalwarn = "", hunteralert = "")
	for(var/datum/mind/bloodsucker_minds as anything in get_antag_minds(/datum/antagonist/bloodsucker))
		if(!istype(bloodsucker_minds))
			continue
		to_chat(bloodsucker_minds, vampwarn)
		if(bloodsucker_minds.current)
			switch(danger_level)
				if(1)
					bloodsucker_minds.current.playsound_local(null, 'sound/effects/griffin_3.ogg', 50 + danger_level, 1)
				if(2)
					bloodsucker_minds.current.playsound_local(null, 'sound/effects/griffin_5.ogg', 50 + danger_level, 1)
				if(3)
					bloodsucker_minds.current.playsound_local(null, 'sound/effects/alert.ogg', 75, 1)
				if(4)
					bloodsucker_minds.current.playsound_local(null, 'sound/ambience/ambimystery.ogg', 100, 1)
				if(5)
					bloodsucker_minds.current.playsound_local(null, 'sound/spookoween/ghosty_wind.ogg', 90, 1)
	if(vassalwarn != "")
		for(var/datum/mind/vassal_minds as anything in get_antag_minds(/datum/antagonist/vassal))
			if(!istype(vassal_minds))
				continue
			if(vassal_minds.has_antag_datum(/datum/antagonist/bloodsucker))
				continue
			to_chat(vassal_minds, vassalwarn)
	if(hunteralert != "")
		for(var/datum/mind/monsterhunter_minds as anything in get_antag_minds(/datum/antagonist/monsterhunter))
			if(!istype(monsterhunter_minds))
				continue
			to_chat(monsterhunter_minds, hunteralert)

/// Cycle through all vamp antags and check if they're inside a closet.
/obj/effect/sunlight/proc/punish_vamps()
	for(var/datum/mind/bloodsucker_minds as anything in get_antag_minds(/datum/antagonist/bloodsucker))
		if(!istype(bloodsucker_minds) || !istype(bloodsucker_minds.current))
			continue
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = bloodsucker_minds.has_antag_datum(/datum/antagonist/bloodsucker)
		if(!istype(bloodsuckerdatum))
			continue
		if(istype(bloodsucker_minds.current.loc, /obj/structure))
			if(istype(bloodsucker_minds.current.loc, /obj/structure/closet/crate/coffin)) // Coffins offer the BEST protection
				SEND_SIGNAL(bloodsucker_minds.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/coffinsleep)
				continue
			if(COOLDOWN_FINISHED(bloodsuckerdatum, bloodsucker_spam_sol_burn)) // Closets offer SOME protection
				to_chat(bloodsucker_minds, span_warning("Your skin sizzles. [bloodsucker_minds.current.loc] doesn't protect well against UV bombardment."))
				COOLDOWN_START(bloodsuckerdatum, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol
			bloodsucker_minds.current.adjustFireLoss(0.5 + bloodsuckerdatum.bloodsucker_level / 2)
			bloodsucker_minds.current.updatehealth()
			SEND_SIGNAL(bloodsucker_minds.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/daylight_1)
		else // Out in the Open?
			if(COOLDOWN_FINISHED(bloodsuckerdatum, bloodsucker_spam_sol_burn))
				if(bloodsuckerdatum.bloodsucker_level > 0)
					to_chat(bloodsucker_minds, span_userdanger("The solar flare sets your skin ablaze!"))
				else
					to_chat(bloodsucker_minds, span_userdanger("The solar flare scalds your neophyte skin!"))
				COOLDOWN_START(bloodsuckerdatum, bloodsucker_spam_sol_burn, BLOODSUCKER_SPAM_SOL) //This should happen twice per Sol
			if(bloodsucker_minds.current.fire_stacks <= 0)
				bloodsucker_minds.current.fire_stacks = 0
			if(bloodsuckerdatum.bloodsucker_level > 0)
				bloodsucker_minds.current.adjust_fire_stacks(0.2 + bloodsuckerdatum.bloodsucker_level / 10)
				bloodsucker_minds.current.IgniteMob()
			bloodsucker_minds.current.adjustFireLoss(2 + bloodsuckerdatum.bloodsucker_level)
			bloodsucker_minds.current.updatehealth()
			SEND_SIGNAL(bloodsucker_minds.current, COMSIG_ADD_MOOD_EVENT, "vampsleep", /datum/mood_event/daylight_2)

/// It's late, give the "Vanishing Act" (gohome) power to Bloodsuckers.
/obj/effect/sunlight/proc/give_home_power()
	for(var/datum/mind/bloodsucker_minds as anything in get_antag_minds(/datum/antagonist/bloodsucker))
		if(!istype(bloodsucker_minds) || !istype(bloodsucker_minds.current) || !iscarbon(bloodsucker_minds.current))
			continue
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = bloodsucker_minds.has_antag_datum(/datum/antagonist/bloodsucker)
		if(istype(bloodsuckerdatum) && bloodsuckerdatum.lair && !(locate(/datum/action/bloodsucker/gohome) in bloodsuckerdatum.powers))
			bloodsuckerdatum.BuyPower(new /datum/action/bloodsucker/gohome)

/// It's over now, remove the "Vanishing Act" (gohome) power from Bloodsuckers.
/obj/effect/sunlight/proc/take_home_power()
	for(var/datum/mind/bloodsucker_minds as anything in get_antag_minds(/datum/antagonist/bloodsucker))
		if(!istype(bloodsucker_minds) || !istype(bloodsucker_minds.current))
			continue
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = bloodsucker_minds.has_antag_datum(/datum/antagonist/bloodsucker)
		for(var/datum/action/bloodsucker/power in bloodsuckerdatum.powers)
			if(istype(power, /datum/action/bloodsucker/gohome))
				bloodsuckerdatum.powers -= power
				power.Remove(bloodsucker_minds.current)

/obj/effect/sunlight/proc/give_transform_power()
	for(var/datum/mind/bloodsucker_minds as anything in get_antag_minds(/datum/antagonist/bloodsucker))
		if(!istype(bloodsucker_minds) || !istype(bloodsucker_minds.current))
			continue
		var/datum/antagonist/bloodsucker/bloodsuckerdatum = bloodsucker_minds.has_antag_datum(/datum/antagonist/bloodsucker)
		if(!(locate(/datum/action/bloodsucker/gangrel/transform) in bloodsuckerdatum.powers))
			bloodsuckerdatum.BuyPower(new /datum/action/bloodsucker/gangrel/transform)
