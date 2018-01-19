//aka Shadowlings/umbrages/whatever
/datum/antagonist/darkspawn
	name = "Darkspawn"
	roundend_category = "darkspawn"
	job_rank = ROLE_DARKSPAWN
	var/in_hud = FALSE

	// Variables below here are for actual darkspawn things //

	//Psi variables
	var/psi = 100 //Psi is the resource used for darkspawn powers
	var/psi_cap = 100 //Max Psi by default
	var/psi_regen = 20 //How much Psi will regenerate after using an ability
	var/psi_regen_delay = 5 //How many ticks need to pass before Psi regenerates
	var/psi_regen_ticks = 0 //When this hits 0, regenerate Psi and return to psi_regen_delay
	var/psi_used_since_regen = 0 //How much Psi has been used since we last regenerated



// Antagonist datum things like assignment //

/datum/antagonist/darkspawn/on_gain()
	SSticker.mode.darkspawn += owner
	owner.special_role = "Darkspawn"
	forge_objectives()
	adjust_darkspawn_hud()
	START_PROCESSING(SSprocessing, src)
	return ..()

/datum/antagonist/darkspawn/on_removal()
	SSticker.mode.darkspawn -= owner
	owner.special_role = null
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/antagonist/darkspawn/greet()
	to_chat(owner.current, "<span class='velvet bold big'>You are a darkspawn!</span>")
	owner.announce_objectives()

/datum/antagonist/darkspawn/proc/forge_objectives()
	var/datum/objective/darkspawn/sacrament = new
	sacrament.owner = owner
	objectives += sacrament

/datum/antagonist/darkspawn/proc/adjust_darkspawn_hud()
	if(in_hud)
		SSticker.mode.update_darkspawn_icons_added(owner)
	else
		SSticker.mode.update_darkspawn_icons_removed(owner)
	in_hud = !in_hud



// Gamemode variables as needed //

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

/datum/antagonist/darkspawn/proc/has_psi(amt)
	return psi >= amt

/datum/antagonist/darkspawn/proc/use_psi(amt)
	if(!has_psi(amt))
		return
	psi_regen_ticks = psi_regen_delay
	psi_used_since_regen += amt
	psi -= amt
	return TRUE

/datum/antagonist/darkspawn/proc/regenerate_psi()
	set waitfor = FALSE
	var/total_regen = min(psi_used_since_regen, psi_regen)
	while(total_regen) //tick it up very quickly instead of just increasing it by the regen
		psi++
		total_regen--
		sleep(1)
	psi_used_since_regen = 0
	psi_regen_ticks = psi_regen_delay
	return TRUE
