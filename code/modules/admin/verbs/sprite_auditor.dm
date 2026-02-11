GLOBAL_DATUM_INIT(sprite_auditor, /datum/sprite_auditor, new)

/datum/sprite_auditor
	var/list/entries

/datum/sprite_auditor/proc/add_entry(icon/created_icon, mob/author)
	var/mutable_appearance/icon_appearance = mutable_appearance(created_icon)
	LAZYADD(entries, list(list(
		"ref" = REF(icon_appearance),
		"name" = author.real_name,
		"ckey" = author.ckey,
		"appearance" = icon_appearance,
		"timestamp" = gameTimestamp(),
	)))
	SStgui.update_uis(src)

/datum/sprite_auditor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpriteAuditor")
		ui.open()

/datum/sprite_auditor/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/sprite_auditor/ui_data(mob/user)
	return list("entries" = entries)

/datum/sprite_auditor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("playerPanel")
			SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/show_player_panel, get_mob_by_ckey(params["ckey"]))

ADMIN_VERB(sprite_auditor, R_ADMIN, "Audit Player-made Sprites", "View sprites created by players this round.", ADMIN_CATEGORY_MAIN)
	GLOB.sprite_auditor.ui_interact(user.mob)
