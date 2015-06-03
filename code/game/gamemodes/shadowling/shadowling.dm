#define LIGHT_DAM_THRESHOLD 4
#define LIGHT_HEAL_THRESHOLD 2
#define LIGHT_DAMAGE_TAKEN 10
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
	- Hard vacuum (They are not affected by it)
	- Their thralls who are not harmed by the light
	- Stealth

Shadowling weaknesses:
	- The light
	- Fire
	- Enemy numbers
	- Lasers (Lasers are concentrated light and do more damage)
	- Flashbangs (High stun and high burn damage; if the light stuns humans, you bet your ass it'll hurt the shadowling very much!)

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
	var/required_thralls = 15 //How many thralls are needed (hardcoded for now)
	var/shadowling_ascended = 0 //If at least one shadowling has ascended
	var/shadowling_dead = 0 //is shadowling kill
	var/objective_explanation


/proc/is_thrall(var/mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.thralls)


/proc/is_shadow_or_thrall(var/mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && ((M.mind in ticker.mode.thralls) || (M.mind in ticker.mode.shadows))


/proc/is_shadow(var/mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.shadows)


/datum/game_mode/shadowling
	name = "shadowling"
	config_tag = "shadowling"
	antag_flag = BE_SHADOWLING
	required_players = 30
	required_enemies = 2
	recommended_enemies = 2
	restricted_jobs = list("AI", "Cyborg")
	protected_jobs = list("Security Officer", "Warden", "Detective", "Head of Security", "Captain")

/datum/game_mode/shadowling/announce()
	world << "<b>The current game mode is - Shadowling!</b>"
	world << "<b>There are alien <span class='deadsay'>shadowlings</span> on the station. Crew: Kill the shadowlings before they can eat or enthrall the crew. Shadowlings: Enthrall the crew while remaining in hiding.</b>"

/datum/game_mode/shadowling/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	var/shadowlings = 2 //How many shadowlings there are; hardcoded to 2

	while(shadowlings)
		var/datum/mind/shadow = pick(antag_candidates)
		shadows += shadow
		antag_candidates -= shadow
		modePlayer += shadow
		shadow.special_role = "Shadowling"
		shadow.restricted_roles = restricted_jobs
		shadowlings--
	return 1


/datum/game_mode/shadowling/post_setup()
	for(var/datum/mind/shadow in shadows)
		log_game("[shadow.key] (ckey) has been selected as a Shadowling.")
		sleep(10)
		shadow.current << "<br>"
		shadow.current << "<span class='deadsay'><b><font size=3>You are a shadowling!</font></b></span>"
		greet_shadow(shadow)
		finalize_shadowling(shadow)
		process_shadow_objectives(shadow)
		//give_shadowling_abilities(shadow)
	..()
	return

/datum/game_mode/proc/greet_shadow(var/datum/mind/shadow)
	shadow.current << "<b>Currently, you are disguised as an employee aboard [world.name].</b>"
	shadow.current << "<b>In your limited state, you have three abilities: Enthrall, Hatch, and Hivemind Commune.</b>"
	shadow.current << "<b>Any other shadowlings are you allies. You must assist them as they shall assist you.</b>"
	shadow.current << "<b>If you are new to shadowling, or want to read about abilities, check the wiki page at https://tgstation13.org/wiki/Shadowling</b><br>"


/datum/game_mode/proc/process_shadow_objectives(var/datum/mind/shadow_mind)
	var/objective = "enthrall" //may be devour later, but for now it seems murderbone-y

	if(objective == "enthrall")
		objective_explanation = "Ascend to your true form by use of the Ascendance ability. This may only be used with [required_thralls] collective thralls, while hatched, and is unlocked with the Collective Mind ability."
		shadow_objectives += "enthrall"
		shadow_mind.memory += "<b>Objective #1</b>: [objective_explanation]"
		shadow_mind.current << "<b>Objective #1</b>: [objective_explanation]<br>"


/datum/game_mode/proc/finalize_shadowling(var/datum/mind/shadow_mind)
	var/mob/living/carbon/human/S = shadow_mind.current
	shadow_mind.current.verbs += /mob/living/carbon/human/proc/shadowling_hatch
	shadow_mind.spell_list += new /obj/effect/proc_holder/spell/targeted/enthrall
	spawn(0)
		shadow_mind.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind
		update_shadow_icons_added(shadow_mind)
		if(shadow_mind.assigned_role == "Clown")
			S << "<span class='notice'>Your alien nature has allowed you to overcome your clownishness.</span>"
			S.dna.remove_mutation(CLOWNMUT)

/datum/game_mode/proc/add_thrall(datum/mind/new_thrall_mind)
	if (!istype(new_thrall_mind))
		return 0
	if(!(new_thrall_mind in thralls))
		update_shadow_icons_added(new_thrall_mind)
		thralls += new_thrall_mind
		new_thrall_mind.current.attack_log += "\[[time_stamp()]\] <span class='danger'>Became a thrall</span>"
		new_thrall_mind.memory += "<b>The Shadowlings' Objectives:</b> [objective_explanation]"
		new_thrall_mind.current << "<b>The objectives of the shadowlings:</b> [objective_explanation]"
		new_thrall_mind.spell_list += new /obj/effect/proc_holder/spell/targeted/shadowling_hivemind
		return 1

/datum/game_mode/shadowling/proc/check_shadow_victory()
	var/success = 0 //Did they win?
	if(shadow_objectives.Find("enthrall"))
		success = shadowling_ascended
	return success


/datum/game_mode/shadowling/declare_completion()
	if(check_shadow_victory() && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE) //Doesn't end instantly - this is hacky and I don't know of a better way ~X
		world << "<span class='greentext'><b>The shadowlings have ascended and taken over the station!</b></span>"
	else if(shadowling_dead && !check_shadow_victory()) //If the shadowlings have ascended, they can not lose the round
		world << "<span class='redtext'><b>The shadowlings have been killed by the crew!</b></span>"
	else if(!check_shadow_victory() && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		world << "<span class='redtext'><b>The crew has escaped the station before the shadowlings could ascend!</b></span>"
	else
		world << "<span class='redtext'><b>The shadowlings have failed!</b></span>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_shadowling()
	var/text = ""
	if(shadows.len)
		text += "<br><span class='big'><b>The shadowlings were:</b></span>"
		for(var/datum/mind/shadow in shadows)
			text += printplayer(shadow)
		text += "<br>"
		if(thralls.len)
			text += "<br><span class='big'><b>The thralls were:</b></span>"
			for(var/datum/mind/thrall in thralls)
				text += printplayer(thrall)
	text += "<br>"
	world << text


/*
	MISCELLANEOUS
*/


/datum/species/shadow/ling
	//Normal shadowpeople but with enhanced effects
	name = "Shadowling"
	id = "shadowling"
	say_mod = "chitters"
	specflags = list(NOBREATH,NOBLOOD,RADIMMUNE,NOGUNS) //Can't use guns due to muzzle flash
	burnmod = 2 //2x burn damage lel
	heatmod = 2

/datum/species/shadow/ling/spec_life(mob/living/carbon/human/H)
	//H.shadowling_status = 1 //If they are affected more strongly by flashes and stuff
	var/light_amount = 0
	H.nutrition = NUTRITION_LEVEL_WELL_FED //i aint never get hongry
	if(isturf(H.loc)) //Copypasta
		var/turf/T = H.loc
		var/area/A = T.loc
		if(A)
			if(A.lighting_use_dynamic)	light_amount = T.lighting_lumcount
			else						light_amount =  10
		if(light_amount > LIGHT_DAM_THRESHOLD) //Not complete blackness - they can live in very small light levels plus starlight
			H.take_overall_damage(0, LIGHT_DAMAGE_TAKEN)
			H << "<span class='userdanger'>The light burns you!</span>"
			H << 'sound/weapons/sear.ogg'
		else if (light_amount < LIGHT_HEAL_THRESHOLD)
			H.heal_overall_damage(5,5)
			H.adjustToxLoss(-5)
			H.adjustBrainLoss(-25) //gibbering shadowlings are hilarious but also bad to have
			H.adjustCloneLoss(-1)
			H.SetWeakened(0)
			H.SetStunned(0)

/datum/game_mode/proc/update_shadow_icons_added(datum/mind/shadow_mind)
	var/datum/atom_hud/antag/shadow_hud = huds[ANTAG_HUD_SHADOW]
	shadow_hud.join_hud(shadow_mind.current)
	set_antag_hud(shadow_mind.current, ((shadow_mind in shadows) ? "shadowling" : "thrall"))

/datum/game_mode/proc/update_shadow_icons_removed(datum/mind/shadow_mind) //This should never actually occur, but it's here anyway.
	var/datum/atom_hud/antag/shadow_hud = huds[ANTAG_HUD_SHADOW]
	shadow_hud.leave_hud(shadow_mind.current)
	set_antag_hud(shadow_mind.current, null)
