/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 125
	health = 125
	icon_state = "aliend"

/mob/living/carbon/alien/humanoid/drone/Initialize(mapload)
	var/datum/action/cooldown/alien/evolve_to_praetorian/evolution = new(src)
	evolution.Grant(src)
	return ..()

/mob/living/carbon/alien/humanoid/drone/create_internal_organs()
	internal_organs += new /obj/item/organ/internal/alien/plasmavessel/large
	internal_organs += new /obj/item/organ/internal/alien/resinspinner
	internal_organs += new /obj/item/organ/internal/alien/acid
	return ..()

/datum/action/cooldown/alien/evolve_to_praetorian
	name = "Evolve to Praetorian"
	desc = "Praetorian"
	button_icon_state = "alien_evolve_drone"
	plasma_cost = 500

/datum/action/cooldown/alien/evolve_to_praetorian/IsAvailable()
	. = ..()
	if(!.)
		return FALSE

	if(!isturf(owner.loc))
		return FALSE

	if(get_alien_type(/mob/living/carbon/alien/humanoid/royal))
		return FALSE

	var/mob/living/carbon/alien/humanoid/royal/evolver = owner
	var/obj/item/organ/internal/alien/hivenode/node = evolver.getorgan(/obj/item/organ/internal/alien/hivenode)
	// Players are Murphy's Law. We may not expect
	// there to ever be a living xeno with no hivenode,
	// but they _WILL_ make it happen.
	if(!node || node.recent_queen_death)
		return FALSE

	return TRUE

/datum/action/cooldown/alien/evolve_to_praetorian/Activate(atom/target)
	var/mob/living/carbon/alien/humanoid/evolver = owner
	var/mob/living/carbon/alien/humanoid/royal/praetorian/new_xeno = new(owner.loc)
	evolver.alien_evolve(new_xeno)
	return TRUE
