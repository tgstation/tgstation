/datum/heretic_knowledge_tree_column/lock_to_flesh
	id = HKT_UUID_LOCK_TO_FLESH
	neighbour_id_0 = HKT_UUID_LOCK
	neighbour_id_1 = HKT_UUID_FLESH

	route = PATH_SIDE

	tier1 = /datum/heretic_knowledge/dummy_lock_to_flesh
	tier2 = /datum/heretic_knowledge/spell/opening_blast
	tier3 = /datum/heretic_knowledge/spell/apetra_vulnera

/datum/heretic_knowledge/dummy_lock_to_flesh
	name = "Flesh and Lock ways"
	desc = "Research this to gain access to the other path"
	gain_text = "There are ways from feasting to wounding, the power of birth is close to the power of opening."
	cost = 1
/*
/datum/heretic_knowledge/markings
	name = "True Markings"
	desc = "Allows you to transmute a knife, a gauze and a bible to gain a special marking on a limb (one per limb), \
	 they are visible on examine and give you special effects"
	cost = 1
	gain_text = "Every wound will close, but they may yet be opened, if I balance things just right, my wounds will never stop closing."
	required_atoms = list(/obj/item/bible = 1,/obj/item/knife = 1, /obj/item/stack/medical/gauze = 1)

/datum/heretic_knowledge/markings/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/carbon_user = user
	var/list/possible_limbs = list()
	for(var/obj/item/bodypart/limb as anything in carbon_user.bodyparts)
		if( limb.bodytype & BODYTYPE_ORGANIC )
			possible_limbs += limb
	return possible_limbs.len > 0

/datum/heretic_knowledge/markings/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/list/possible_limbs = list()
	for(var/obj/item/bodypart/limb as anything in carbon_user.bodyparts)
		if( limb.bodytype & BODYTYPE_ORGANIC )
			possible_limbs += limb
*/
// Sidepaths for knowledge between Knock and Flesh.
/datum/heretic_knowledge/spell/opening_blast
	name = "Wave Of Desperation"
	desc = "Grants you Wave Of Desparation, a spell which can only be cast while restrained. \
		It removes your restraints, repels and knocks down adjacent people, and applies the Mansus Grasp to everything nearby. \
		However, you will fall unconscious a short time after casting this spell."
	gain_text = "My shackles undone in dark fury, their feeble bindings crumble before my power."

	spell_to_add = /datum/action/cooldown/spell/aoe/wave_of_desperation
	cost = 1

/datum/heretic_knowledge/spell/apetra_vulnera
	name = "Apetra Vulnera"
	desc = "Grants you Apetra Vulnera, a spell \
		which causes heavy bleeding on all bodyparts of the victim that have more than 15 brute damage. \
		Wounds a random limb if no limb is sufficiently damaged."
	gain_text = "Flesh opens, and blood spills. My master seeks sacrifice, and I shall appease."

	spell_to_add = /datum/action/cooldown/spell/pointed/apetra_vulnera
	cost = 1


