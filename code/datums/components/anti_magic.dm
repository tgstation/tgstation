/datum/component/anti_magic
	var/active = TRUE
	var/magic = FALSE
	var/holy = FALSE

/datum/component/anti_magic/Initialize(_magic = FALSE, _holy = FALSE)
	magic = _magic
	holy = _holy

/datum/component/anti_magic/proc/can_protect(_magic = TRUE, _holy = FALSE)
	if(!active)
		return FALSE
	if((_magic && magic) || (_holy && holy))
		return TRUE
	return FALSE

/mob/proc/anti_magic_check(magic = TRUE, holy = FALSE)
	if(!magic && !holy)
		return
	var/list/obj/item/item_list = list()
	item_list |= held_items
	for(var/obj/O in item_list)
		GET_COMPONENT_FROM(anti_magic, /datum/component/anti_magic, O)
		if(!anti_magic)
			continue
		if(anti_magic.can_protect(magic, holy))
			return O

/mob/living/anti_magic_check(magic = TRUE, holy = FALSE)
	if(!magic && !holy)
		return

	if((magic && has_trait(TRAIT_ANTIMAGIC)) || (holy && has_trait(TRAIT_HOLY)))
		return src

	var/list/obj/item/item_list = list()
	item_list |= get_equipped_items(TRUE)
	item_list |= held_items
	for(var/obj/O in item_list)
		GET_COMPONENT_FROM(anti_magic, /datum/component/anti_magic, O)
		if(!anti_magic)
			continue
		if(anti_magic.can_protect(magic, holy))
			return O