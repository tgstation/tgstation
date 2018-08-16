//This component applies a customizable drop_shadow filter to its wearer when they toggle combat mode on or off. This can stack.

/datum/component/phantomthief
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/filter_x
	var/filter_y
	var/filter_size
	var/filter_border
	var/filter_color

	var/datum/component/redirect/combattoggle_redir

/datum/component/phantomthief/Initialize(_x = -2, _y = 0, _size = 0, _border = 0, _color = "#E62111")
	filter_x = _x
	filter_y = _y
	filter_size = _size
	filter_border = _border
	filter_color = _color

	RegisterSignal(parent, COMSIG_COMBAT_TOGGLED, .proc/handlefilterstuff)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/OnEquipped)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/OnDropped)

/datum/component/phantomthief/proc/handlefilterstuff(mob/user, combatmodestate)
	if(istype(user))
		var/thefilter = filter(type = "drop_shadow", x = filter_x, y = filter_y, size = filter_size, border = filter_border, color = filter_color)
		if(!combatmodestate)
			user.filters -= thefilter
		else
			user.filters += thefilter

/datum/component/phantomthief/proc/stripdesiredfilter(mob/user)
	if(istype(user))
		var/thefilter = filter(type = "drop_shadow", x = filter_x, y = filter_y, size = filter_size, border = filter_border, color = filter_color)
		user.filters -= thefilter

/datum/component/phantomthief/proc/OnEquipped(mob/user, slot)
	if(!istype(user))
		return
	if(!combattoggle_redir)
		combattoggle_redir = user.AddComponent(/datum/component/redirect,list(COMSIG_COMBAT_TOGGLED),CALLBACK(src,.proc/handlefilterstuff))

/datum/component/phantomthief/proc/OnDropped(mob/user)
	if(!istype(user))
		return
	if(combattoggle_redir)
		QDEL_NULL(combattoggle_redir)
	stripdesiredfilter(user)
