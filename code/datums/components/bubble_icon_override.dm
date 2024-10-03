/datum/component/bubble_icon_override
	dupe_mode = COMPONENT_DUPE_ALLOWED
	can_transfer = TRUE //sure why not
	///The override to the default bubble icon for the atom
	var/bubble_icon
	///The priority of this bubble icon compared to others
	var/priority

/datum/component/bubble_icon_override/Initialize(bubble_icon, priority)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.bubble_icon = bubble_icon
	src.priority = priority

/datum/component/bubble_icon_override/RegisterWithParent()
	RegisterSignal(parent, COMSIG_GET_BUBBLE_ICON, PROC_REF(return_bubble_icon))
	get_bubble_icon()

/datum/component/bubble_icon_override/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_GET_BUBBLE_ICON)
	get_bubble_icon()

/datum/component/bubble_icon_override/proc/get_bubble_icon()
	if(QDELETED(parent))
		return
	var/list/holder = list(null)
	var/mob/living/living = parent
	SEND_SIGNAL(parent, COMSIG_GET_BUBBLE_ICON, holder)
	var/bubble_icon = holder[1]
	if(!bubble_icon)
		living.bubble_icon = bubble_icon || initial(living.bubble_icon)

/datum/component/bubble_icon_override/proc/return_bubble_icon(datum/source, list/holder)
	SIGNAL_HANDLER
	var/enemy_priority = holder[holder[1]]
	if(enemy_priority < priority)
		holder[1] = bubble_icon
		holder[bubble_icon] = priority
