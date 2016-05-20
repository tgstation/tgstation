var/datum/subsystem/altsprites/SSaltsprites

/datum/subsystem/altsprites
	name = "Alternate Sprites"
	priority = -420
	wait = 69

	var/list/sprite_overrides = list()

/datum/subsystem/altsprites/New()
	NEW_SS_GLOBAL(SSaltsprites)
	var/list/sec_themes = list(/datum/sprite_theme/oldsec, /datum/sprite_theme/greysec, /datum/sprite_theme/copsec, /datum/sprite_theme/corpsec, /datum/sprite_theme/redsec)
	var/help_me = pick(sec_themes)
	var/datum/sprite_theme/S = new help_me
	for(var/O in S.overrides)
		sprite_overrides += new O
	for(var/datum/sprite_override/OR in sprite_overrides)
		OR.adjust_all_sprites()

/datum/sprite_theme
	var/name = "redtube"
	var/list/overrides = list()

/datum/sprite_override
	var/item_type = null
	var/list/list_to_search = list()
	var/list/alts = list()
	var/datum/sprite_alt/chosen = null

/datum/sprite_override/New()
	..()
	if(alts.len)
		chosen = pick(alts)
		return
	else
		return

/datum/sprite_override/proc/adjust_all_sprites()
	for(var/obj/item/A in list_to_search)
		if(A.type != item_type)
			continue
		A.icon_state = initial(chosen.icon_state)
		A.item_state = initial(chosen.item_state)
		A.item_color = initial(chosen.item_color)
		A.update_icon()

/datum/sprite_override/proc/adjust_a_sprite(var/obj/item/A)
	A.icon_state = initial(chosen.icon_state)
	A.item_state = initial(chosen.item_state)
	A.item_color = initial(chosen.item_color)
	A.update_icon()

/datum/sprite_alt
	var/name = "http://www."
	var/icon_state = "porn"
	var/item_state = "hub"
	var/item_color = ".com"