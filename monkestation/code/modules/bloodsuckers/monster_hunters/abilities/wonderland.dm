/datum/action/cooldown/wonderland_drop
	name = "To Wonderland"
	button_icon = 'icons/turf/floors.dmi'
	button_icon_state = "junglegrass"
	cooldown_time = 5 MINUTES
	///where we will be teleporting the user too
	var/obj/effect/landmark/wonderland_mark/landmark
	///where the user originally was
	var/turf/original_loc

/datum/action/cooldown/wonderland_drop/New(Target)
	..()
	landmark =  GLOB.wonderland_marks["Wonderland landmark"]

/datum/action/cooldown/wonderland_drop/Activate()
	StartCooldown(360 SECONDS, 360 SECONDS)
	var/mob/living/sleeper = owner
	if(QDELETED(landmark))
		return
	original_loc = get_turf(sleeper)
	var/turf/theplace = get_turf(landmark)
	sleeper.forceMove(theplace)
	sleeper.Sleeping(2 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(awaken), sleeper), 3 SECONDS)

/datum/action/cooldown/wonderland_drop/proc/awaken(mob/living/sleeper)
	to_chat(sleeper, span_warning("You wake up in the Wonderland."))
	owner.playsound_local(sleeper, 'monkestation/sound/bloodsuckers/wonderlandmusic.ogg', vol = 10)
	addtimer(CALLBACK(src, PROC_REF(return_to_station), sleeper), 1 MINUTES)
	StartCooldown()

/datum/action/cooldown/wonderland_drop/proc/return_to_station(mob/living/sleeper)
	if(QDELETED(original_loc))
		return
	sleeper.forceMove(original_loc)
	to_chat(sleeper, span_warning("You feel like you have woken up from a deep slumber, was it all a dream?"))
	original_loc = null
