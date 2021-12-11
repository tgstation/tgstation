/datum/species/fly
	name = "Flyperson"
	id = SPECIES_FLY
	say_mod = "buzzes"
	species_traits = list(HAS_FLESH, HAS_BONE, TRAIT_ANTENNAE)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_CAN_USE_FLIGHT_POTION,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_BUG
	meat = /obj/item/food/meat/slab/human/mutant/fly
	mutanteyes = /obj/item/organ/eyes/fly
	liked_food = GROSS
	disliked_food = NONE
	toxic_food = NONE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/fly
	payday_modifier = 0.75

	mutanttongue = /obj/item/organ/tongue/fly
	mutantheart = /obj/item/organ/heart/fly
	mutantlungs = /obj/item/organ/lungs/fly
	mutantliver = /obj/item/organ/liver/fly
	mutantstomach = /obj/item/organ/stomach/fly
	mutantappendix = /obj/item/organ/appendix/fly
	mutant_organs = list(/obj/item/organ/fly, /obj/item/organ/fly/groin)

/datum/species/fly/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	if(chem.type == /datum/reagent/toxin/pestkiller)
		H.adjustToxLoss(3 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)
		return TRUE
	..()

/datum/species/fly/check_species_weakness(obj/item/weapon, mob/living/attacker)
	if(istype(weapon, /obj/item/melee/flyswatter))
		return 30 //Flyswatters deal 30x damage to flypeople.
	return 1

/obj/item/organ/heart/fly
	desc = "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."

/obj/item/organ/heart/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = pick("brain-x-d", "liver-x", "kidneys-x", "stomach-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

/obj/item/organ/heart/fly/update_icon_state()
	SHOULD_CALL_PARENT(FALSE)
	return //don't set icon thank you

/obj/item/organ/lungs/fly
	desc = "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."

/obj/item/organ/lungs/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = pick("brain-x-d", "liver-x", "kidneys-x", "stomach-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

/obj/item/organ/liver/fly
	desc = "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."
	alcohol_tolerance = 0.007 //flies eat vomit, so a lower alcohol tolerance is perfect!

/obj/item/organ/liver/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = pick("brain-x-d", "liver-x", "kidneys-x", "stomach-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

/obj/item/organ/stomach/fly
	desc = "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."

/obj/item/organ/stomach/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = pick("brain-x-d", "liver-x", "kidneys-x", "stomach-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

/obj/item/organ/stomach/fly/on_life(delta_time, times_fired)
	if(locate(/datum/reagent/consumable) in reagents.reagent_list)
		var/mob/living/carbon/body = owner
		// we do not loss any nutrition as a fly when vomiting out food
		body.vomit(0, FALSE, FALSE, 2, TRUE, force=TRUE, purge_ratio = 0.67)
		playsound(get_turf(owner), 'sound/effects/splat.ogg', 50, TRUE)
		body.visible_message(span_danger("[body] vomits on the floor!"), \
					span_userdanger("You throw up on the floor!"))
	return ..()

/obj/item/organ/appendix/fly
	desc = "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."

/obj/item/organ/appendix/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = pick("brain-x-d", "liver-x", "kidneys-x", "stomach-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

/obj/item/organ/appendix/fly/update_appearance(updates=ALL)
	return ..(updates & ~(UPDATE_NAME|UPDATE_ICON)) //don't set name or icon thank you

//useless organs we throw in just to fuck with surgeons a bit more
/obj/item/organ/fly
	desc = "You have no idea what the hell this is, or how it manages to keep something alive in any capacity."
	visual = FALSE

/obj/item/organ/fly/Initialize(mapload)
	. = ..()
	name = odd_organ_name()
	icon_state = pick("brain-x-d", "liver-x", "kidneys-x", "stomach-x", "lungs-x", "random_fly_1", "random_fly_2", "random_fly_3", "random_fly_4", "random_fly_5")

/obj/item/organ/fly/groin //appendix is the only groin organ so we gotta have one of these too lol
	zone = BODY_ZONE_PRECISE_GROIN
