/datum/action/cooldown/paradox
	name = "Paradox Rabbit"
	desc = "The rabbit's movements will be translated onto you, ignoring any solid objects in your way."
	button_icon = 'icons/mob/simple/rabbit.dmi'
	button_icon_state = "rabbit_white_dead"
	cooldown_time = 3 MINUTES
	///where we will be teleporting the rabbit too
	var/obj/effect/landmark/wonderchess_mark/chessmark
	///where the user will be while this whole ordeal is happening
	var/obj/effect/landmark/wonderland_mark/landmark
	///the rabbit in question if it exists
	var/mob/living/basic/rabbit/rabbit
	///where the user originally was
	var/turf/original_loc

/datum/action/cooldown/paradox/New(Target)
	..()
	chessmark = GLOB.wonderland_marks["Wonderchess landmark"]
	landmark =  GLOB.wonderland_marks["Wonderland landmark"]

/datum/action/cooldown/paradox/Activate()
	var/turf/owner_turf = get_turf(owner)
	if(!is_station_level(owner_turf.z))
		to_chat(owner, span_warning("The pull of the ice moon isn't strong enough here.."))
		return
	StartCooldown(360 SECONDS, 360 SECONDS)
	if(QDELETED(chessmark))
		return
	var/turf/theplace = get_turf(chessmark)
	var/turf/land_mark = get_turf(landmark)
	original_loc = get_turf(owner)
	var/mob/living/basic/rabbit/bunny = new(theplace)
	if(QDELETED(bunny))
		return
	owner.forceMove(land_mark) ///the user remains safe in the wonderland
	var/mob/living/master = owner
	owner.mind.transfer_to(bunny)
	playsound(bunny, 'monkestation/sound/bloodsuckers/paradoxskip.ogg', vol = 100)
	addtimer(CALLBACK(src, PROC_REF(return_to_station), master, bunny, theplace), 5 SECONDS)
	StartCooldown()

/datum/action/cooldown/paradox/proc/return_to_station(mob/user, mob/bunny, turf/mark)
	var/new_x = bunny.x - mark.x
	var/new_y = bunny.y - mark.y
	var/turf/new_location = locate((original_loc.x + new_x) , (original_loc.y + new_y) , original_loc.z)
	user.forceMove(new_location)
	bunny.mind.transfer_to(user)
	playsound(user, 'monkestation/sound/bloodsuckers/paradoxskip.ogg', vol = 100)
	rabbit = null
	original_loc = null
	qdel(bunny)
