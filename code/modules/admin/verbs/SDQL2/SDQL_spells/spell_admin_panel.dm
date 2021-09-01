/// An admin verb to view all sdql spells, plus useful information
/datum/admins/proc/view_all_sdql_spells()
	set category = "Admin.Game"
	set name = "View All SDQL Spells"

	if(CONFIG_GET(flag/sdql_spells) || tgui_alert(usr, "SDQL spells are disabled. Open the admin panel anyways?", "SDQL Admin Panel", list("Yes", "No")) == "Yes")
		var/static/datum/SDQL_spell_panel/SDQL_spell_panel = new
		SDQL_spell_panel.ui_interact(usr)

/datum/SDQL_spell_panel

/datum/SDQL_spell_panel/ui_static_data(mob/user)
	var/list/data = list()
	data["spells"] = list()

	for (var/obj/effect/proc_holder/spell/spell as anything in GLOB.sdql_spells)
		var/mob/living/owner = spell.owner.resolve()
		var/datum/component/sdql_executor/executor = spell.GetComponent(/datum/component/sdql_executor)
		if(!executor)
			continue

		data["spells"] += list(list(
			"ref" = REF(spell),
			"name" = "[spell]",
			"owner" = owner,
			"ownerRef" = REF(owner),
			"creator" = executor.giver
		))

	return data

/datum/SDQL_spell_panel/ui_act(action, list/params)
	. = ..()
	if (.)
		return .

	switch(action)
		if("edit_spell")
			var/obj/effect/proc_holder/spell/spell = locate(params["spell"])
			if(!spell)
				to_chat(usr, span_warning("That spell no longer exists!"))
				return
			var/datum/component/sdql_executor/executor = spell.GetComponent(/datum/component/sdql_executor)
			if(!executor)
				to_chat(usr, span_warning("[spell][spell.p_s()] SDQL executor component is gone!"))
				return
			if(usr.ckey == executor.giver || tgui_alert(usr, "You didn't create this SDQL spell. Edit it anyways?", "SDQL Admin Panel", list("Yes", "No")) == "Yes")
				usr.client?.cmd_sdql_spell_menu(spell)
		if("follow_owner")
			var/mob/living/owner = locate(params["owner"])
			if(!owner)
				to_chat(usr, span_warning("That mob no longer exists!"))
				return
			usr.client?.admin_follow(owner)
		if("vv_spell")
			var/obj/effect/proc_holder/spell/spell = locate(params["spell"])
			if(!spell)
				to_chat(usr, span_warning("That spell no longer exists!"))
				return
			usr.client?.debug_variables(spell)
		if("open_player_panel")
			var/mob/living/owner = locate(params["owner"])
			if(!owner)
				to_chat(usr, span_warning("That mob no longer exists!"))
				return
			usr.client?.holder?.show_player_panel(owner)

	return TRUE

/datum/SDQL_spell_panel/ui_state(mob/user)
	return GLOB.admin_state

/datum/SDQL_spell_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SDQLSpellAdminPanel")
		ui.open()
