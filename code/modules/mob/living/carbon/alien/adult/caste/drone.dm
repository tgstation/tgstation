/mob/living/carbon/alien/adult/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 125
	health = 125
	icon_state = "aliend"

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
	)

/mob/living/carbon/alien/adult/drone/Initialize(mapload)
	GRANT_ACTION(/datum/action/cooldown/alien/evolve_to_praetorian)
	return ..()

/datum/action/cooldown/alien/evolve_to_praetorian
	name = "Evolve to Praetorian"
	desc = "Praetorian"
	button_icon_state = "alien_evolve_drone"
	plasma_cost = 500

/datum/action/cooldown/alien/evolve_to_praetorian/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	if(!isturf(owner.loc))
		return FALSE

	if(get_alien_type(/mob/living/carbon/alien/adult/royal))
		return FALSE

	var/mob/living/carbon/alien/adult/royal/evolver = owner
	var/obj/item/organ/alien/hivenode/node = evolver.get_organ_by_type(/obj/item/organ/alien/hivenode)
	// Players are Murphy's Law. We may not expect
	// there to ever be a living xeno with no hivenode,
	// but they _WILL_ make it happen.
	if(!node || node.recent_queen_death)
		return FALSE

	return TRUE

/datum/action/cooldown/alien/evolve_to_praetorian/Activate(atom/target)
	var/mob/living/carbon/alien/adult/evolver = owner
	var/mob/living/carbon/alien/adult/royal/praetorian/new_xeno = new(owner.loc)
	evolver.alien_evolve(new_xeno)
	return TRUE
