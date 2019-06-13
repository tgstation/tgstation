#define DOOM_CLOCK_EVENT_DELAY 3000 // 6000 // 10 minutes per event
#define SAME_INFECTION_TYPE(check, typetocheck) (istype(check, typetocheck) || check.building == typetocheck)

/datum/antagonist/infection
	name = "Infection"
	roundend_category = "infections"
	antagpanel_category = "Infection"
	job_rank = ROLE_INFECTION

	var/starting_points_human_infection = 60
	var/point_rate_human_infection = 2

/datum/antagonist/infection/roundend_report()
	. = ..()
	//Display max infection points for infectiowns that lost
	var/mob/camera/commander/overmind = owner.current
	if(!overmind.victory_in_progress) //if it won this doesn't really matter
		var/point_report = "<br><b>[overmind.name]</b> left [GLOB.infection_beacons.len] beacons in its destructive path."
		. += point_report

/datum/antagonist/infection/greet()
	owner.current.playsound_local(get_turf(owner.current), 'sound/effects/blobattack.ogg',100,0)
	owner.current.playsound_local(get_turf(owner.current), 'sound/effects/attackblob.ogg',100,0)
	to_chat(owner,"<span class='userdanger'>You feel radiant.</span>")

/datum/antagonist/infection/on_gain()
	create_objectives()
	var/turf/start = pick(GLOB.infection_spawns)
	var/mob/newmob = create_mob_type(start)
	owner.transfer_to(newmob, TRUE)
	return ..()


/datum/antagonist/infection/proc/create_mob_type(var/turf/spawnturf)
	var/mob/camera/commander/C = new /mob/camera/commander(spawnturf)
	return C

/datum/antagonist/infection/proc/create_objectives()
	var/datum/objective/infection_takeover/main = new
	main.owner = owner
	objectives += main

/datum/antagonist/infection/antag_listing_status()
	. = ..()
	if(owner && owner.current)
		var/mob/I = owner.current
		if(istype(I))
			. += "(Progress: [GLOB.infection_beacons.len])"

/datum/objective/infection_takeover
	explanation_text = "Destroy all of the beacons!"

/datum/antagonist/infection/spore/roundend_report()
	return

/datum/antagonist/infection/spore/create_mob_type(var/turf/spawnturf)
	var/mob/camera/commander/C = GLOB.infection_commander
	var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/S = new /mob/living/simple_animal/hostile/infection/infectionspore/sentient(C, null, C)
	if(C.infection_core)
		S.forceMove(get_turf(C.infection_core))
	S.update_icons()
	S.infection_help()
	C.infection_mobs += S
	return S