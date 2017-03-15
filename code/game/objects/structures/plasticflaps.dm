/obj/structure/plasticflaps
	name = "plastic flaps"
	desc = "Definitely can't get past those. No way."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "plasticflaps"
	armor = list(melee = 100, bullet = 80, laser = 80, energy = 100, bomb = 50, bio = 100, rad = 100, fire = 50, acid = 50)
	anchored = TRUE
	layer = ABOVE_MOB_LAYER

/obj/structure/plasticflaps/Initialize()
	density = FALSE
	..()

CONSTRUCTION_BLUEPRINT(/obj/structure/plasticflaps, TRUE)
	. = newlist(
		/datum/construction_state/first{
			//required_type_to_construct = /obj/item/stack/sheet/plastic
			required_amount_to_construct = 5
			one_per_turf = 1
			on_floor = 1
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/weapon/screwdriver
			required_type_to_deconstruct = /obj/item/weapon/wirecutters
			construction_delay = 100
			deconstruction_delay = 50
			anchored = 0
			construction_message = "screwing down"
			deconstruction_message = "cutting apart"
			examine_message = "They are unscrewed from the floor and can be cut apart."
		},
		/datum/construction_state/last{
			required_type_to_deconstruct = /obj/item/weapon/screwdriver
			deconstruction_delay = 100
			deconstruction_message = "removing the floor screws from"
			examine_message = "They are screwed to the floor."
		}
	)
	
	//This is here to work around a byond bug
	//http://www.byond.com/forum/?post=2220240
	//When its fixed clean up this copypasta across the codebase OBJ_CONS_BAD_CONST

	var/datum/construction_state/first/X = .[1]
	X.required_type_to_construct = /obj/item/stack/sheet/plastic

/obj/structure/plasticflaps/CanAStarPass(ID, to_dir, caller)
	if(isliving(caller))
		if(isbot(caller))
			return 1

		var/mob/living/M = caller
		if(!M.ventcrawler && M.mob_size != MOB_SIZE_TINY)
			return 0

	return 1 //diseases, stings, etc can pass

/obj/structure/plasticflaps/CanPass(atom/movable/A, turf/T)
	if(istype(A) && A.checkpass(PASSGLASS))
		return prob(60)

	var/obj/structure/bed/B = A
	if(istype(A, /obj/structure/bed) && (B.has_buckled_mobs() || B.density))//if it's a bed/chair and is dense or someone is buckled, it will not pass
		return 0

	if(istype(A, /obj/structure/closet/cardboard))
		var/obj/structure/closet/cardboard/C = A
		if(C.move_delay)
			return 0

	if(istype(A, /obj/mecha))
		return 0


	else if(isliving(A)) // You Shall Not Pass!
		var/mob/living/M = A
		if(isbot(A)) //Bots understand the secrets
			return 1
		if(M.buckled && istype(M.buckled, /mob/living/simple_animal/bot/mulebot)) // mulebot passenger gets a free pass.
			return 1
		if(!M.lying && !M.ventcrawler && M.mob_size != MOB_SIZE_TINY)	//If your not laying down, or a ventcrawler or a small creature, no pass.
			return 0
	return ..()

/obj/structure/plasticflaps/mining //A specific type for mining that doesn't allow airflow because of them damn crates
	name = "airtight plastic flaps"
	desc = "Heavy duty, airtight, plastic flaps."
	CanAtmosPass = ATMOS_PASS_NO

/obj/structure/plasticflaps/mining/New()
	air_update_turf(1)
	. = ..()

/obj/structure/plasticflaps/mining/Destroy()
	var/atom/oldloc = loc
	. = ..()
	if (oldloc)
		oldloc.air_update_turf(1)
