/**
 * A simple component that spawns a mob of the same type and transfers itself to it when parent dies.
 * For more complex behaviors, use the COMSIG_ON_MULTIPLE_LIVES_RESPAWN comsig.
 */
/datum/component/multiple_lives
	can_transfer = TRUE
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// The number of respawns the living mob has left.
	var/lives_left

/datum/component/multiple_lives/Initialize(lives_left)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.lives_left = lives_left

/datum/component/multiple_lives/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(respawn))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_LIVING_WRITE_MEMORY, PROC_REF(on_write_memory))

/datum/component/multiple_lives/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_DEATH, COMSIG_ATOM_EXAMINE, COMSIG_LIVING_WRITE_MEMORY))

/// Stops a dying station pet from overriding persistence data before we respawn it and thus causing issues.
/datum/component/multiple_lives/proc/on_write_memory(mob/living/source, dead, gibbed)
	if(dead && !HAS_TRAIT(source, TRAIT_SUICIDED))
		return COMPONENT_DONT_WRITE_MEMORY

/datum/component/multiple_lives/proc/respawn(mob/living/source, gibbed)
	SIGNAL_HANDLER
	if(HAS_TRAIT(source, TRAIT_SUICIDED)) //Freed from this mortail coil.
		qdel(src)
		return
	//Gives the old mob this trait in case it gets revived, so we won't end up eventually overriding data
	//that would be read by the current holder when he respawns if the old corpse is ever revived.
	ADD_TRAIT(source, TRAIT_DONT_WRITE_MEMORY, EXPIRED_LIFE_TRAIT)
	var/mob/living/respawned_mob = new source.type (source.drop_location())
	source.mind?.transfer_to(respawned_mob)
	lives_left--
	if(lives_left <= 0)
		qdel(src)
	source.TransferComponents(respawned_mob)
	SEND_SIGNAL(source, COMSIG_ON_MULTIPLE_LIVES_RESPAWN, respawned_mob, gibbed, lives_left)

/datum/component/multiple_lives/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(isobserver(user) || source == user)
		examine_list += "[source.p_They()] [source.p_have()] [lives_left] extra lives left."

/datum/component/multiple_lives/InheritComponent(datum/component/multiple_lives/new_comp , lives_left)
	src.lives_left += new_comp ? new_comp.lives_left : lives_left

/datum/component/multiple_lives/PostTransfer(datum/new_parent)
	if(!isliving(new_parent))
		return COMPONENT_INCOMPATIBLE
