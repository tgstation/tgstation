/**
 * This organ has met with a terrible fate.
 * This is applied to a bunch of organs inside someone who gets sacrificed by a Heretic.
 * It provides minor annoyance and also acts as an incentive to leave them alone if they can't read the flavour text they get sent.
 * If they try and fight the same Heretic again it won't go great for them.
 */
/datum/component/cursed_organ
	dupe_mode = COMPONENT_DUPE_ALLOWED // Damn, you got sacrificed by two different guys...
	/// Was this organ removeable before we touched it?
	var/was_removeable = FALSE

/datum/component/cursed_organ/Initialize(...)
	if (!isinternalorgan(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/cursed_organ/RegisterWithParent()


/datum/component/cursed_organ/UnregisterFromParent()
