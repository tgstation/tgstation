/datum/component/ondemand_possessable
	var/amount = 0

/datum/component/ondemand_possessable/Initialize()
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/ondemand_possessable/proc/adjust(adjustment)
	amount = max(amount + adjustment, 0)
	var/atom/A = parent
	var/datum/atom_hud/ghost/interactable/possessable_hud = GLOB.huds[GHOST_HUD_INTERACTABLE]
	if(amount)
		possessable_hud.add_to_hud(A)
		var/image/holder = A.hud_list[GHOST_HUD]
		holder.icon_state = "possessable"
	else
		possessable_hud.remove_from_hud(A)
		qdel(src)