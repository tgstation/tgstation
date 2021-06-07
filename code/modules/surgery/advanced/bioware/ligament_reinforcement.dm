/datum/surgery/advanced/bioware/ligament_reinforcement
	name = "Ligament Reinforcement"
	desc = "A surgical procedure which adds a protective tissue and bone cage around the connections between the torso and limbs, preventing dismemberment. \
	However, the nerve connections as a result are more easily interrupted, making it easier to disable limbs with damage."
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/incise,
		/datum/surgery_step/incise,
		/datum/surgery_step/reinforce_ligaments,
		/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_LIGAMENTS

/datum/surgery_step/reinforce_ligaments
	name = "reinforce ligaments"
	accept_hand = TRUE
	time = 125

/datum/surgery_step/reinforce_ligaments/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You start reinforcing [target]'s ligaments.</span>",
		"<span class='notice'>[user] starts reinforce [target]'s ligaments.</span>",
		"<span class='notice'>[user] starts manipulating [target]'s ligaments.</span>")

/datum/surgery_step/reinforce_ligaments/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(user, target, "<span class='notice'>You reinforce [target]'s ligaments!</span>",
		"<span class='notice'>[user] reinforces [target]'s ligaments!</span>",
		"<span class='notice'>[user] finishes manipulating [target]'s ligaments.</span>")
	new /datum/bioware/reinforced_ligaments(target)
	return ..()

/datum/bioware/reinforced_ligaments
	name = "Reinforced Ligaments"
	desc = "The ligaments and nerve endings that connect the torso to the limbs are protected by a mix of bone and tissues, and are much harder to separate from the body, but are also easier to wound."
	mod_type = BIOWARE_LIGAMENTS

/datum/bioware/reinforced_ligaments/on_gain()
	..()
	ADD_TRAIT(owner, TRAIT_NODISMEMBER, EXPERIMENTAL_SURGERY_TRAIT)
	ADD_TRAIT(owner, TRAIT_EASILY_WOUNDED, EXPERIMENTAL_SURGERY_TRAIT)

/datum/bioware/reinforced_ligaments/on_lose()
	..()
	REMOVE_TRAIT(owner, TRAIT_NODISMEMBER, EXPERIMENTAL_SURGERY_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_EASILY_WOUNDED, EXPERIMENTAL_SURGERY_TRAIT)
