
/*

SHADOWLING: A gamemode based on previously-run events

Aliens called shadowlings are on the station.
These shadowlings can 'enthrall' crew members and enslave them.
They also burn in the light but heal rapidly whilst in the dark.
The game will end under two conditions:
	1. The shadowlings die
	2. The emergency shuttle docks at CentCom

Shadowling strengths:
	- The dark
	- Hard vacuum (They are not affected by it, but are affected by starlight!)
	- Their thralls who are not harmed by the light
	- Stealth

Shadowling weaknesses:
	- The light
	- Fire
	- Enemy numbers
	- Burn-based weapons and items (flashbangs, lasers, etc.)

Shadowlings start off disguised as normal crew members, and they only have two abilities: Hatch and Enthrall.
They can still enthrall and perhaps complete their objectives in this form.
Hatch will, after a short time, cast off the human disguise and assume the shadowling's true identity.
They will then assume the normal shadowling form and gain their abilities.

The shadowling will seem OP, and that's because it kinda is. Being restricted to the dark while being alone most of the time is extremely difficult and as such the shadowling needs powerful abilities.
Made by Xhuis

*/



/*
	GAMEMODE
*/



/datum/game_mode
	var/list/datum/mind/shadows = list()
	var/list/datum/mind/thralls = list()
	var/list/shadow_objectives = list()
	var/required_thralls = 15 //How many thralls are needed (this is changed in pre_setup, so it scales based on pop)
	var/shadowling_ascended = 0 //If at least one shadowling has ascended
	var/shadowling_dead = 0 //is shadowling kill
	var/objective_explanation
	var/thrall_ratio = 1


/datum/game_mode/shadowling
	name = "shadowling"
	config_tag = "shadowling"
	antag_flag = ROLE_SHADOWLING
	required_players = 26
	required_enemies = 3
	recommended_enemies = 2
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")

/datum/game_mode/shadowling/announce()
	to_chat(world, "<b>The current game mode is - Shadowling!</b>")
	to_chat(world, "<b>There are alien <span class='shadowling'>shadowlings</span> on the station. Crew: Kill the shadowlings before they can enthrall the crew. Shadowlings: Enthrall the crew while remaining in hiding.</b>")

/datum/game_mode/shadowling/pre_setup()
	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += "Assistant"

	var/shadowlings = max(3, round(num_players()/14))


	while(shadowlings)
		var/datum/mind/shadow = pick(antag_candidates)
		shadows += shadow
		antag_candidates -= shadow
		shadow.special_role = "Shadowling"
		shadow.restricted_roles = restricted_jobs
		shadowlings--

	var/thrall_scaling = round(num_players() / 3)
	required_thralls = CLAMP(thrall_scaling, 15, 30)

	thrall_ratio = required_thralls / 15

	return TRUE

/datum/game_mode/shadowling/generate_report()
	return "Sightings of strange alien creatures have been observed in your area. These aliens supposedly possess the ability to enslave unwitting personnel and leech from their power. \
	Be wary of dark areas and ensure all lights are kept well-maintained. Closely monitor all crew for suspicious behavior and perform dethralling surgery if they have obvious tells. Investigate all \
	reports of odd or suspicious sightings in maintenance."

/datum/game_mode/shadowling/post_setup()
	for(var/datum/mind/shadow in shadows)
		log_game("[shadow.key] (ckey) has been selected as a Shadowling.")
		add_sling(shadow)
	. = ..()
	return

/datum/game_mode/shadowling/proc/check_shadow_victory()
	return shadowling_ascended

/datum/game_mode/shadowling/proc/check_shadow_death()
	for(var/datum/mind/shadow_mind in get_antagonists(/datum/antagonist/shadowling))
		var/turf/T = get_turf(shadow_mind.current)
		if((shadow_mind) && (shadow_mind.current) && (shadow_mind.current.stat != DEAD) && T && (T.z in GLOB.station_z_levels) && ishuman(shadow_mind.current))
			return FALSE
	return TRUE

/datum/game_mode/shadowling/check_finished()
	. = ..()
	if(check_shadow_death())
		return TRUE





// Thrall/Sling management procs

/proc/add_thrall(datum/mind/new_thrall_mind)
	if(!istype(new_thrall_mind))
		return FALSE
	return new_thrall_mind.add_antag_datum(ANTAG_DATUM_THRALL)

/proc/add_sling(datum/mind/new_sling_mind)
	if(!istype(new_sling_mind))
		return FALSE
	return new_sling_mind.add_antag_datum(ANTAG_DATUM_SLING)

/proc/remove_thrall(datum/mind/thrall_mind)
	if(!istype(thrall_mind))
		return FALSE
	return thrall_mind.remove_antag_datum(ANTAG_DATUM_THRALL)

/proc/remove_sling(datum/mind/ling_mind)
	if(!istype(ling_mind))
		return FALSE
	return ling_mind.remove_antag_datum(ANTAG_DATUM_SLING)

/proc/is_thrall(var/mob/living/M)
	return istype(M) && M.mind && M.mind.has_antag_datum(ANTAG_DATUM_THRALL)

/proc/is_shadow_or_thrall(var/mob/living/M)
	return M && (is_thrall(M) || is_shadow(M))

/proc/is_shadow(var/mob/living/M)
	return istype(M) && M.mind && M.mind.has_antag_datum(ANTAG_DATUM_SLING)


/datum/game_mode/proc/update_shadow_icons_added(datum/mind/shadow_mind)
	var/datum/atom_hud/antag/shadow_hud = GLOB.huds[ANTAG_HUD_SHADOW]
	shadow_hud.join_hud(shadow_mind.current)
	set_antag_hud(shadow_mind.current, ((is_shadow(shadow_mind.current)) ? "shadowling" : "thrall"))

/datum/game_mode/proc/update_shadow_icons_removed(datum/mind/shadow_mind)
	var/datum/atom_hud/antag/shadow_hud = GLOB.huds[ANTAG_HUD_SHADOW]
	shadow_hud.leave_hud(shadow_mind.current)
	set_antag_hud(shadow_mind.current, null)