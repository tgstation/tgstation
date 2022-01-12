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
	RegisterSignal(parent, COMSIG_LIVING_DEATH, .proc/respawn)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/multiple_lives/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_EXAMINE))

/datum/component/multiple_lives/proc/respawn(mob/living/source, gibbed)
	SIGNAL_HANDLER
	if(source.suiciding) //Freed from this mortail coil.
		qdel(src)
		return
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
		examine_list += "[source.p_theyve(TRUE)] [lives_left] extra lives left."

/datum/component/multiple_lives/InheritComponent(datum/component/multiple_lives/new_comp , lives_left)
	src.lives_left += new_comp ? new_comp.lives_left : lives_left

/datum/component/multiple_lives/PostTransfer()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
