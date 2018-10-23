/datum/ghostmaster_power/locker_surprise
	name = "Locker Surprise"
	spook_cost = 2
	var/mobtype = /mob/living/simple_animal/hostile/skeleton
	var/amount = 1

/datum/ghostmaster_power/locker_surprise/valid_target(atom/A)
	return istype(A,/obj/structure/closet)

/datum/ghostmaster_power/locker_surprise/effect(obj/structure/closet/C, G)
	C.close()
	if(C.opened)
		return FALSE
	for(var/i in 1 to amount)
		var/mob/living/simple_animal/hostile/H = new mobtype(C)
		H.environment_smash = ENVIRONMENT_SMASH_NONE //If i were less lazy i'd make this wait with spawning until the locker is opened then target the opener.
	return TRUE

//Helper effect for stuff that stays around and needs a holder.
/obj/effect/haunt
	icon = 'icons/effects/ghostmaster.dmi'
	name = "haunt effect"
	invisibility = INVISIBILITY_MAXIMUM

// Turn this into delayed trap maybe?
/obj/effect/haunt/gravegrab
	name = "skeletal hands"
	desc = "Aaaah."
	icon_state = "gravegrab2"
	invisibility = 0
	layer = ABOVE_MOB_LAYER
	var/duration = 50

/obj/effect/haunt/gravegrab/Initialize()
	. = ..()
	for(var/mob/living/L in get_turf(src))
		L.SetImmobilized(duration)
	QDEL_IN(src,duration)

/datum/ghostmaster_power/gravegrab
	name = "Grave Grab"
	spook_cost = 1
	var/duration = 50

/datum/ghostmaster_power/gravegrab/valid_target(atom/A)
	return isliving(A)

/datum/ghostmaster_power/gravegrab/effect(mob/living/L, G)
	new /obj/effect/haunt/gravegrab(get_turf(L))
	return TRUE

// basically just vent clog with blood - remove copypaste later
/datum/ghostmaster_power/bloodpool
	name = "Blood Pool"
	spook_cost = 1

/datum/ghostmaster_power/bloodpool/valid_target(atom/A)
	var/area/R = get_area(A)
	return !istype(R,/area/space)

/datum/ghostmaster_power/bloodpool/effect(atom/A, G)
	var/area/ar = get_area(A)
	var/found_vent = FALSE
	for(var/obj/machinery/atmospherics/components/unary/vent in ar.contents)
		if(vent && vent.loc && !vent.welded)
			var/datum/reagents/R = new/datum/reagents(1000)
			R.my_atom = vent
			R.add_reagent("blood", 100)
			var/datum/effect_system/foam_spread/foam = new
			foam.set_up(200, get_turf(vent), R)
			foam.start()
			found_vent = TRUE
	return found_vent

// Confusion in area
/datum/ghostmaster_power/melody
	name = "Haunted Melody"
	spook_cost = 2

/datum/ghostmaster_power/melody/valid_target(atom/A)
	var/area/R = get_area(A)
	return !istype(R,/area/space)

/datum/ghostmaster_power/melody/effect(atom/A, G)
	new /obj/effect/haunt/melody(get_turf(A))
	return TRUE

/obj/effect/haunt/melody
	name = "haunted melody"
	var/duration = 600
	var/bgm
	var/old_bgm

/obj/effect/haunt/melody/Initialize()
	. = ..()
	START_PROCESSING(SSobj,src)
	var/area/A = get_area(src)
	old_bgm = A.ambientsounds
	A.ambientsounds = SPOOKY
	RegisterSignal(A,COMSIG_AREA_ENTERED,.proc/entered_check)
	for(var/mob/living/L in A.contents)
		if(L.can_hear())
			to_chat(L,"<span class='haunt'>You hear a haunting melody in the distance.</span>")
	QDEL_IN(src,duration)

/obj/effect/haunt/melody/proc/entered_check(atom/movable/AM)
	var/mob/living/L = AM
	if(istype(L) && L.can_hear())
		to_chat(L,"<span class='haunt'>You hear a haunting melody in the distance.</span>")

/obj/effect/haunt/melody/process()
	var/area/A = get_area(src)
	for(var/mob/living/L in A.contents)
		if(L.can_hear())
			L.confused = max(L.confused,10)

/obj/effect/haunt/melody/Destroy(force)
	STOP_PROCESSING(SSobj,src)
	if(old_bgm)
		var/area/A = get_area(src)
		A.ambientsounds = old_bgm
	. = ..()