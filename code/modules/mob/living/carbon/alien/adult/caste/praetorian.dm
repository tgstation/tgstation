/mob/living/carbon/alien/adult/royal/praetorian
	name = "alien praetorian"
	caste = "p"
	maxHealth = 250
	health = 250
	icon_state = "alienp"
	alien_speed = 0.5

	default_organ_types_by_slot = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/brain/alien,
		ORGAN_SLOT_XENO_HIVENODE = /obj/item/organ/alien/hivenode,
		ORGAN_SLOT_TONGUE = /obj/item/organ/tongue/alien,
		ORGAN_SLOT_EYES = /obj/item/organ/eyes/alien,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver/alien,
		ORGAN_SLOT_EARS = /obj/item/organ/ears,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach/alien,
		ORGAN_SLOT_XENO_PLASMAVESSEL = /obj/item/organ/alien/plasmavessel/large,
		ORGAN_SLOT_XENO_RESINSPINNER = /obj/item/organ/alien/resinspinner,
		ORGAN_SLOT_XENO_ACIDGLAND = /obj/item/organ/alien/acid,
		ORGAN_SLOT_XENO_NEUROTOXINGLAND = /obj/item/organ/alien/neurotoxin,
		ORGAN_SLOT_EXTERNAL_TAIL = /obj/item/organ/tail/xeno,
	)

/mob/living/carbon/alien/adult/royal/praetorian/Initialize(mapload)
	real_name = name

	var/static/list/innate_actions = list(
		/datum/action/cooldown/alien/evolve_to_queen,
		/datum/action/cooldown/spell/aoe/repulse/xeno,
	)

	grant_actions_by_list(innate_actions)

	return ..()

/datum/action/cooldown/alien/evolve_to_queen
	name = "Evolve"
	desc = "Produce an internal egg sac capable of spawning children. Only one queen can exist at a time."
	button_icon_state = "alien_evolve_praetorian"
	plasma_cost = 500

/datum/action/cooldown/alien/evolve_to_queen/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!isturf(owner.loc))
		return FALSE

	if(get_alien_type(/mob/living/carbon/alien/adult/royal/queen))
		return FALSE

	var/mob/living/carbon/alien/adult/royal/evolver = owner
	var/obj/item/organ/alien/hivenode/node = evolver.get_organ_by_type(/obj/item/organ/alien/hivenode)
	if(!node || node.recent_queen_death)
		return FALSE

	return TRUE

/datum/action/cooldown/alien/evolve_to_queen/Activate(atom/target)
	var/mob/living/carbon/alien/adult/royal/evolver = owner
	var/mob/living/carbon/alien/adult/royal/queen/new_queen = new(owner.loc)
	evolver.alien_evolve(new_queen)
	return TRUE
