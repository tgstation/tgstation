/datum/species/fly
	name = "Flyperson"
	id = "fly"
	say_mod = "buzzes"
	species_traits = list(NOEYESPRITES)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	mutanttongue = /obj/item/organ/tongue/fly
	mutantliver = /obj/item/organ/liver/fly
	mutantstomach = /obj/item/organ/stomach/fly
	meat = /obj/item/food/meat/slab/human/mutant/fly
	disliked_food = null
	liked_food = GROSS
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/fly
	payday_modifier = 0.75

	mutantheart = /obj/item/organ/heart/fly
	mutantlungs = /obj/item/organ/lungs/fly
	mutantliver = /obj/item/organ/liver/fly
	mutantstomach = /obj/item/organ/stomach/fly
	mutantappendix = /obj/item/organ/appendix/fly
	mutant_organs = list(/obj/item/organ/fly, /obj/item/organ/fly/groin)

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM)
		return TRUE
	..()

/datum/species/fly/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 30 //Flyswatters deal 30x damage to flypeople.
	return 1

/obj/item/organ/heart/fly
	desc = "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."

/obj/item/organ/heart/fly/Initialize()
	. = ..()
	name = odd_organ_name()
	icon_state = pick("brain-x-d", "liver-x", "kidneys-x", "stomach-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

/obj/item/organ/heart/fly/update_icon_state()
	return //don't set icon thank you

/obj/item/organ/lungs/fly
	desc = "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."

/obj/item/organ/lungs/fly/Initialize()
	. = ..()
	name = odd_organ_name()
	icon_state = pick("brain-x-d", "liver-x", "kidneys-x", "stomach-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

/obj/item/organ/liver/fly
	desc = "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."
	alcohol_tolerance = 0.007 //flies eat vomit, so a lower alcohol tolerance is perfect!

/obj/item/organ/liver/fly/Initialize()
	. = ..()
	name = odd_organ_name()
	icon_state = pick("brain-x-d", "liver-x", "kidneys-x", "stomach-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

/obj/item/organ/stomach/fly
	desc = "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."

/obj/item/organ/stomach/fly/Initialize()
	. = ..()
	name = odd_organ_name()
	icon_state = pick("brain-x-d", "liver-x", "kidneys-x", "stomach-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

/obj/item/organ/stomach/fly/on_life()
	for(var/bile in reagents.reagent_list)
		if(!istype(bile, /datum/reagent/consumable))
			continue
		var/datum/reagent/consumable/chunk = bile
		if(chunk.nutriment_factor <= 0)
			continue
		var/mob/living/carbon/body = owner
		var/turf/pos = get_turf(owner)
		body.vomit(reagents.total_volume, FALSE, FALSE, 2, TRUE)
		playsound(pos, 'sound/effects/splat.ogg', 50, TRUE)
		body.visible_message("<span class='danger'>[body] vomits on the floor!</span>", \
					"<span class='userdanger'>You throw up on the floor!</span>")
	return ..()

/obj/item/organ/appendix/fly
	desc = "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."

/obj/item/organ/appendix/fly/Initialize()
	. = ..()
	name = odd_organ_name()
	icon_state = pick("brain-x-d", "liver-x", "kidneys-x", "stomach-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

/obj/item/organ/appendix/fly/update_icon()
	return //don't set name or icon thank you

//useless organs we throw in just to fuck with surgeons a bit more
/obj/item/organ/fly
	desc = "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."

/obj/item/organ/fly/Initialize()
	. = ..()
	name = odd_organ_name()
	icon_state = pick("brain-x-d", "liver-x", "kidneys-x", "stomach-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

/obj/item/organ/fly/groin //appendix is the only groin organ so we gotta have one of these too lol
	zone = BODY_ZONE_PRECISE_GROIN
