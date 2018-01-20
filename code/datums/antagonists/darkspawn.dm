#define MUNDANE 0
#define DIVULGED 1
#define PROGENITOR 2

//aka Shadowlings/umbrages/whatever
/datum/antagonist/darkspawn
	name = "Darkspawn"
	roundend_category = "darkspawn"
	antagpanel_category = "Darkspawn"
	job_rank = ROLE_DARKSPAWN
	var/darkspawn_state = MUNDANE //0 for normal crew, 1 for divulged, and 2 for progenitor

	//Psi variables
	var/psi = 100 //Psi is the resource used for darkspawn powers
	var/psi_cap = 100 //Max Psi by default
	var/psi_regen = 20 //How much Psi will regenerate after using an ability
	var/psi_regen_delay = 5 //How many ticks need to pass before Psi regenerates
	var/psi_regen_ticks = 0 //When this hits 0, regenerate Psi and return to psi_regen_delay
	var/psi_used_since_regen = 0 //How much Psi has been used since we last regenerated

	//Lucidity variables
	var/lucidity = 3 //Lucidity is used to buy abilities and is gained by using Devour Will
	var/lucidity_drained = 0 //How much lucidity has been drained from other players

	//Ability variables
	var/list/abilities = list() //An associative list ("id" = ability datum) containing the abilities the darkspawn has

// Antagonist datum things like assignment //

/datum/antagonist/darkspawn/on_gain()
	SSticker.mode.darkspawn += owner
	owner.special_role = "darkspawn"
	forge_objectives()
	owner.current.hud_used.psi_counter.invisibility = 0
	update_psi_hud()
	add_ability("divulge")
	START_PROCESSING(SSprocessing, src)
	return ..()

/datum/antagonist/darkspawn/on_removal()
	SSticker.mode.darkspawn -= owner
	owner.special_role = null
	adjust_darkspawn_hud(FALSE)
	for(var/datum/objective/darkspawn/D in owner.objectives)
		objectives -= D
		owner.objectives -= D
		qdel(D)
	owner.current.hud_used.psi_counter.invisibility = initial(owner.current.hud_used.psi_counter.invisibility)
	owner.current.hud_used.psi_counter.maptext = ""
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/antagonist/darkspawn/apply_innate_effects()
	adjust_darkspawn_hud(TRUE)
	owner.current.grant_language(/datum/language/darkspawn)

/datum/antagonist/darkspawn/remove_innate_effects()
	adjust_darkspawn_hud(FALSE)
	owner.current.remove_language(/datum/language/darkspawn)

/datum/antagonist/darkspawn/antag_panel_data()
	. = "<b>Abilities:</b><br>"
	for(var/V in abilities)
		var/datum/action/innate/darkspawn/D = abilities[V]
		. += "[D.name] ([D.id])<br>"

/datum/antagonist/darkspawn/get_admin_commands()
	. = ..()
	.["Give Ability"] = CALLBACK(src,.proc/admin_give_ability)
	.["Take Ability"] = CALLBACK(src,.proc/admin_take_ability)
	if(darkspawn_state == MUNDANE)
		.["Divulge"] = CALLBACK(src, .proc/divulge)
	else if(darkspawn_state == DIVULGED)
		.["[psi]/[psi_cap] Psi"] = CALLBACK(src, .proc/admin_edit_psi)
		.["[lucidity] Lucidity"] = CALLBACK(src, .proc/admin_edit_lucidity)

/datum/antagonist/darkspawn/proc/admin_give_ability(mob/admin)
	var/id = stripped_input(admin, "Enter an ability ID.", "Give Ability")
	if(!id)
		return
	if(has_ability(id))
		to_chat(admin, "<span class='warning'>[owner.current] already has this ability!</span>")
		return
	add_ability(id)

/datum/antagonist/darkspawn/proc/admin_take_ability(mob/admin)
	var/id = stripped_input(admin, "Enter an ability ID.", "Take Ability")
	if(!id)
		return
	if(!has_ability(id))
		to_chat(admin, "<span class='warning'>[owner.current] does not have this ability!</span>")
		return
	remove_ability(id)

/datum/antagonist/darkspawn/proc/admin_edit_psi(mob/admin)
	var/new_psi = input(admin, "Enter a new psi amount. (Current: [psi]/[psi_cap])", "Change Psi", psi) as null|num
	if(!new_psi)
		return
	new_psi = CLAMP(new_psi, 0, psi_cap)
	psi = new_psi

/datum/antagonist/darkspawn/proc/admin_edit_lucidity(mob/admin)
	var/newcidity = input(admin, "Enter a new lucidity amount. (Current: [lucidity])", "Change Lucidity", lucidity) as null|num
	if(!newcidity)
		return
	newcidity = max(0, newcidity)
	lucidity = newcidity

/datum/antagonist/darkspawn/greet()
	to_chat(owner.current, "<span class='velvet bold big'>You are a darkspawn!</span>")
	to_chat(owner.current, "<i>Append :a or .a before your message to silently speak with any other darkspawn.</i>")
	to_chat(owner.current, "<i>When you're ready, retreat to a hidden location and Divulge to shed your human skin.</i>")
	to_chat(owner.current, "<i>If you do not do this within ten minutes, this will happen involuntarily. Prepare quickly.</i>")
	to_chat(owner.current, "<i>Remember that this will make you die in the light and heal in the dark - keep to the shadows.</i>")
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/darkspawn.ogg', 50, FALSE)
	owner.announce_objectives()

/datum/antagonist/darkspawn/proc/forge_objectives()
	var/datum/objective/darkspawn/sacrament = new
	sacrament.owner = owner
	objectives += sacrament
	owner.objectives += sacrament

/datum/antagonist/darkspawn/proc/adjust_darkspawn_hud(add_hud)
	if(add_hud)
		SSticker.mode.update_darkspawn_icons_added(owner)
	else
		SSticker.mode.update_darkspawn_icons_removed(owner)


// Gamemode variables as needed (but note that there is no darkspawn gamemode)//

/datum/game_mode
	var/list/darkspawn = list()

/datum/game_mode/proc/update_darkspawn_icons_added(datum/mind/darkspawn_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_DARKSPAWN]
	hud.join_hud(darkspawn_mind.current)
	set_antag_hud(darkspawn_mind.current, "darkspawn")

/datum/game_mode/proc/update_darkspawn_icons_removed(datum/mind/darkspawn_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_DARKSPAWN]
	hud.leave_hud(darkspawn_mind.current)
	set_antag_hud(darkspawn_mind.current, null)


// Darkspawn-related things like Psi //

/datum/antagonist/darkspawn/process() //This is here since it controls most of the Psi stuff
	psi = min(psi, psi_cap)
	if(psi != psi_cap)
		psi_regen_ticks = max(0, psi_regen_ticks - 1)
		if(!psi_regen_ticks)
			regenerate_psi()
	update_psi_hud()

/datum/antagonist/darkspawn/proc/has_psi(amt)
	return psi >= amt

/datum/antagonist/darkspawn/proc/use_psi(amt)
	if(!has_psi(amt))
		return
	psi_regen_ticks = psi_regen_delay
	psi_used_since_regen += amt
	psi -= amt
	update_psi_hud()
	return TRUE

/datum/antagonist/darkspawn/proc/regenerate_psi()
	set waitfor = FALSE
	var/total_regen = min(psi_used_since_regen, psi_regen)
	while(total_regen && psi < psi_cap) //tick it up very quickly instead of just increasing it by the regen
		psi++
		total_regen--
		update_psi_hud()
		sleep(0.5)
	psi_used_since_regen = 0
	psi_regen_ticks = psi_regen_delay
	return TRUE

/datum/antagonist/darkspawn/proc/update_psi_hud()
	if(!owner.current)
		return
	var/obj/screen/counter = owner.current.hud_used.psi_counter
	counter.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#7264FF'>[psi]</font></div>"

/datum/antagonist/darkspawn/proc/has_ability(id)
	return abilities[id]

/datum/antagonist/darkspawn/proc/add_ability(id, silent, no_cost)
	if(has_ability(id))
		return
	for(var/V in subtypesof(/datum/action/innate/darkspawn))
		var/datum/action/innate/darkspawn/D = V
		if(initial(D.id) == id)
			var/datum/action/innate/darkspawn/action = new D
			action.Grant(owner.current)
			action.darkspawn = src
			abilities[id] = action
			if(!silent)
				to_chat(owner.current, "<span class='velvet'>You have learned the <b>[action.name]</b> ability.</span>")
			if(!no_cost)
				lucidity = max(0, lucidity - action.lucidity_price)
			return TRUE

/datum/antagonist/darkspawn/proc/remove_ability(id, silent)
	if(!has_ability(id))
		return
	var/datum/action/innate/darkspawn/D = abilities[id]
	if(!silent)
		to_chat(owner.current, "<span class='velvet'>You have lost the <b>[D.name]</b> ability.</span>")
	qdel(D)
	abilities[id] = null
	return TRUE

/datum/antagonist/darkspawn/proc/divulge()
	var/mob/living/carbon/human/user = owner.current
	to_chat(user, "<span class='velvet bold'>Your mind has expanded. The Psi Web is now available. Avoid the light. Keep to the shadows. Your time will come.</span>")
	user.fully_heal()
	user.set_species(/datum/species/darkspawn)
	add_ability("psi_web", TRUE)
	add_ability("sacrament", TRUE)
	add_ability("devour_will", TRUE)
	add_ability("pass", TRUE)
	remove_ability("divulge", TRUE)
	darkspawn_state = DIVULGED


// Psi Web code //

/datum/antagonist/darkspawn/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.not_incapacitated_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "psi_web", "Psi Web", 900, 480, master_ui, state)
		ui.open()

/datum/antagonist/darkspawn/ui_data(mob/user)
	var/list/data = list()

	data["lucidity"] = "[lucidity] ([lucidity_drained] drained)"

	var/list/abilities = list()

	for(var/path in subtypesof(/datum/action/innate/darkspawn))
		var/datum/action/innate/darkspawn/ability = path

		if(initial(ability.blacklisted))
			continue

		var/list/AL = list() //This is mostly copy-pasted from the cellular emporium, but it should be fine regardless
		AL["name"] = initial(ability.name)
		AL["id"] = initial(ability.id)
		AL["desc"] = initial(ability.desc)
		AL["psi_cost"] = "[initial(ability.psi_cost)][initial(ability.psi_addendum)]"
		AL["lucidity_cost"] = initial(ability.lucidity_price)
		AL["owned"] = has_ability(initial(ability.id))
		AL["can_purchase"] = (!has_ability(initial(ability.id)) && lucidity >= initial(ability.lucidity_price))

		abilities += list(AL)

	data["abilities"] = abilities

	return data

/datum/antagonist/darkspawn/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("unlock")
			add_ability(params["id"])

#undef MUNDANE
#undef DIVULGED
#undef PROGENITOR
