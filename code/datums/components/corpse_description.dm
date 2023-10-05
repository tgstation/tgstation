/**
 * Mapping component which adds examine text to a corpse that is removed on revival (in case for some reason someone revives your space ruin mob)
 * For immersive environmental story telling
 */
/datum/component/corpse_description
	/// What do we display on examine?
	var/description_text = ""
	/// What do we display if examined by a clown?
	var/naive_description = ""

/datum/component/corpse_description/Initialize(description_text = "", naive_description = "")
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.description_text = description_text
	src.naive_description = naive_description

/datum/component/corpse_description/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(on_revived))

/datum/component/corpse_description/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_LIVING_REVIVE))

/datum/component/corpse_description/proc/on_examined(mob/living/corpse, mob/corpse_inspector, list/examine_list)
	SIGNAL_HANDLER
	if (corpse.stat != DEAD || !description_text)
		return // Why the hell you put this on them then
	if (naive_description && HAS_TRAIT(corpse_inspector, TRAIT_NAIVE))
		examine_list += span_notice(naive_description)
		return
	examine_list += span_notice(description_text)

/datum/component/corpse_description/proc/on_revived(mob/living/formerly_dead)
	SIGNAL_HANDLER
	qdel(src) // It wouldn't be immersive if the circumstances of my grisly death remained after I was revived
