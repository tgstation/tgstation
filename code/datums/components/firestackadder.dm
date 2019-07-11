/datum/component/firestackadder
	var/firestacks_per_hit = 1

/datum/component/firestackadder/Initialize(firestacks_override)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	if(ismovableatom(parent))
		RegisterSignal(parent, list(COMSIG_MOVABLE_IMPACT), .proc/hit_add_firestacks)
		if(isitem(parent))
			RegisterSignal(parent, list(COMSIG_ITEM_ATTACK), .proc/attack_add_firestacks)
			RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/attack_self_add_firestacks)

	if(firestacks_override)
		firestacks_per_hit = firestacks_override

/datum/component/firestackadder/proc/attack_add_firestacks(datum/source, atom/movable/target, mob/living/user)
	if(istype(target, /mob/living))
		var/mob/living/L = target
		L.adjust_fire_stacks(firestacks_per_hit)

/datum/component/firestackadder/proc/attack_self_add_firestacks(datum/source, mob/user)
	if(istype(user, /mob/living))
		var/mob/living/L = user
		L.adjust_fire_stacks(firestacks_per_hit)

/datum/component/firestackadder/proc/hit_add_firestacks(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	if(istype(hit_atom, /mob/living))
		var/mob/living/L = hit_atom
		L.adjust_fire_stacks(firestacks_per_hit)

