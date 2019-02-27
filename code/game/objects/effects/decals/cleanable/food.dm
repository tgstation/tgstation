
/obj/effect/decal/cleanable/food
	icon = 'icons/effects/tomatodecal.dmi'
	gender = NEUTER

/obj/effect/decal/cleanable/food/tomato_smudge
	name = "tomato smudge"
	desc = "It's red."
	icon_state = "tomato_floor1"
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/food/plant_smudge
	name = "plant smudge"
	desc = "Chlorophyll? More like borophyll!"
	icon_state = "smashed_plant"

/obj/effect/decal/cleanable/food/egg_smudge
	name = "smashed egg"
	desc = "Seems like this one won't hatch."
	icon_state = "smashed_egg1"
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/obj/effect/decal/cleanable/food/pie_smudge //honk
	name = "smashed pie"
	desc = "It's pie cream from a cream pie."
	icon_state = "smashed_pie"

/obj/effect/decal/cleanable/food/salt
	name = "salt pile"
	desc = "A sizable pile of table salt. Someone must be upset."
	icon_state = "salt_pile"

/obj/effect/decal/cleanable/food/salt/CanPass(atom/movable/AM, turf/target)
	if(is_species(AM, /datum/species/snail))
		var/mob/living/carbon/human/H = AM
		if(H.stat == CONSCIOUS && !H.IsStun())
			to_chat(H, "<span class='danger'>Your path is obstructed by <span class='phobia'>salt</span>.</span>")
			return FALSE
	return TRUE

/obj/effect/decal/cleanable/food/salt/Crossed(atom/movable/AM)//will only really happen when a snail is teleported onto salt
	if(is_species(AM, /datum/species/snail)) //all sanity checks are evaluated there
		var/mob/living/carbon/human/H = AM
		H.adjustFireLoss(25)
		playsound(H, 'sound/weapons/sear.ogg', 30, 1)
		to_chat(H, "<span class='danger'>The <span class='phobia'>salt</span> is absorbed into your wet, snailly body!</span>")
		H.emote("scream")
		qdel(src)

/obj/effect/decal/cleanable/food/flour
	name = "flour"
	desc = "It's still good. Four second rule!"
	icon_state = "flour"
