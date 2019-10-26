#define RANDOM_GRAFFITI "Random Graffiti"
#define RANDOM_LETTER "Random Letter"
#define RANDOM_NUMBER "Random Number"
#define RANDOM_ORIENTED "Random Oriented"
#define RANDOM_RUNE "Random Rune"
#define RANDOM_ANY "Random Anything"

/obj/item/toy/crayon
	var/datum/team/gang/gang //For marking territory, spraycans are gang-locked to their initial gang due to colors

/obj/item/toy/crayon/proc/hippie_gang_check(mob/user, atom/target) // hooked into afterattack
	var/gang_mode = FALSE
	if(gang && user.mind)
		var/datum/antagonist/gang/G = user.mind.has_antag_datum(/datum/antagonist/gang)
		if(G)
			if(G.gang != gang)
				to_chat(user, "<span class='danger'>This spraycan's color isn't your gang's one! You cannot use it.</span>")
				return FALSE
			gang_mode = TRUE
			instant = FALSE
			. = "gang graffiti"
	// discontinue if we're not in gang modethe area isn't valid for tagging because gang "honour"
	if(gang_mode && (!can_claim_for_gang(user, target)))
		return FALSE
	return TRUE

/obj/item/toy/crayon/proc/gang_final(mob/user, atom/target, list/affected_turfs) // hooked into afterattack
	// Double check it wasn't tagged in the meanwhile
	if(!can_claim_for_gang(user, target))
		return TRUE
	tag_for_gang(user, target)
	affected_turfs += target

/obj/item/toy/crayon/proc/can_claim_for_gang(mob/user, atom/target)
	// Check area validity.
	// Reject space, player-created areas, and non-station z-levels.
	var/area/A = get_area(target)
	if(!A || (!is_station_level(A.z)) || !A.valid_territory)
		to_chat(user, "<span class='warning'>[A] is unsuitable for tagging.</span>")
		return FALSE

	var/spraying_over = FALSE
	for(var/G in target)
		var/obj/effect/decal/cleanable/crayon/gang/gangtag = G
		if(istype(gangtag))
			var/datum/antagonist/gang/GA = user.mind.has_antag_datum(/datum/antagonist/gang)
			if(gangtag.gang != GA.gang)
				spraying_over = TRUE
				break

	for(var/obj/machinery/power/apc in target)
		to_chat(user, "<span class='warning'>You can't tag an APC.</span>")
		return FALSE

	var/occupying_gang = territory_claimed(A, user)
	if(occupying_gang && !spraying_over)
		to_chat(user, "<span class='danger'>[A] has already been tagged by the [occupying_gang] gang! You must get rid of or spray over the old tag first!</span>")
		return FALSE

	// If you pass the gaunlet of checks, you're good to proceed
	return TRUE

/obj/item/toy/crayon/proc/territory_claimed(area/territory, mob/user)
	for(var/datum/team/gang/G in GLOB.gangs)
		if(territory.type in (G.territories|G.new_territories))
			. = G.name
			break

/obj/item/toy/crayon/proc/tag_for_gang(mob/user, atom/target)
	//Delete any old markings on this tile, including other gang tags
	for(var/obj/effect/decal/cleanable/crayon/old_marking in target)
		qdel(old_marking)

	var/datum/antagonist/gang/G = user.mind.has_antag_datum(/datum/antagonist/gang)
	var/area/territory = get_area(target)
	new /obj/effect/decal/cleanable/crayon/gang(target,G.gang,"graffiti",0,user)
	if(user.mind)
		LAZYADD(G.gang.tags_by_mind[user.mind], src)
	to_chat(user, "<span class='notice'>You tagged [territory] for your gang!</span>")

/obj/item/toy/crayon/spraycan/gang
	//desc = "A modified container containing suspicious paint."
	charges = 20
	gang = TRUE
	pre_noise = FALSE
	post_noise = TRUE

/obj/item/toy/crayon/spraycan/gang/Initialize(loc, datum/team/gang/G)
	.=..()
	if(G)
		gang = G
		paint_color = G.color
		update_icon()

/obj/item/toy/crayon/spraycan/gang/examine(mob/user)
	. = ..()
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/gang) || isobserver(user))
		. += "This spraycan has been specially modified for tagging territory."

#undef RANDOM_GRAFFITI
#undef RANDOM_LETTER
#undef RANDOM_NUMBER
#undef RANDOM_ORIENTED
#undef RANDOM_RUNE
#undef RANDOM_ANY
