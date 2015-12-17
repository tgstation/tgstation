//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/datum/game_mode
	var/list/datum/mind/cult = list()

/proc/iscultist(mob/living/M)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.cult)

/proc/cultist_commune(mob/living/user, say = 0, message)
	if(!message)
		return
	if(say)
		user.say("O bidai nabora se[pick("'","`")]sma!")
	else
		user.whisper("O bidai nabora se[pick("'","`")]sma!")
	sleep(10)
	if(!user)
		return
	if(say)
		user.say(message)
	else
		user.whisper(message)
	for(var/mob/M in mob_list)
		if(iscultist(M) || (M in dead_mob_list))
			M << "<span class='cultitalic'><b>[(ishuman(user) ? "Acolyte" : "Construct")] [user]:</b> [message]</span>"
	log_say("[user.real_name]/[user.key] : [message]")



/datum/game_mode/cult
	name = "cult"
	config_tag = "cult"
	antag_flag = ROLE_CULTIST
	restricted_jobs = list("Chaplain","AI", "Cyborg", "Security Officer", "Warden", "Detective", "Head of Security", "Captain", "Head of Personnel")
	protected_jobs = list()
	required_players = 10
	required_enemies = 2
	recommended_enemies = 2
	enemy_minimum_age = 14

	var/eldergod = 0
	var/orbs_needed = 3
	var/large_shell_summoned = 0
	var/attempts_left = 3

/datum/game_mode/cult/announce()
	world << "<B>The current game mode is - Cult!</B>"
	world << "<B>Some crewmembers are attempting to start a cult!<BR>\nCultists - summon the elder god. Sacrifice crewmembers and turn them into constructs. Remember - there is no you, there is only the cult.<BR>\nPersonnel - Do not let the cult succeed in its mission. Deal with the cultists and any constructs that they might summon.</B>"


/datum/game_mode/cult/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	if(config.protect_assistant_from_antagonist)
		restricted_jobs += "Assistant"

	//cult scaling goes here
	recommended_enemies = 1 + round(num_players()/8)
	orbs_needed = recommended_enemies

	for(var/cultists_number = 1 to recommended_enemies)
		if(!antag_candidates.len)
			break
		var/datum/mind/cultist = pick(antag_candidates)
		antag_candidates -= cultist
		cult += cultist
		cultist.special_role = "Cultist"
		cultist.restricted_roles = restricted_jobs
		log_game("[cultist.key] (ckey) has been selected as a cultist")

	return (cult.len>=required_enemies)


/datum/game_mode/cult/post_setup()
	modePlayer += cult
	for(var/datum/mind/cult_mind in cult)
		equip_cultist(cult_mind.current)
		update_cult_icons_added(cult_mind)
		cult_mind.current << "<span class='userdanger'>You are a member of the cult!</span>"
		memorize_cult_objectives(cult_mind)
	..()


/datum/game_mode/cult/proc/memorize_cult_objectives(datum/mind/cult_mind)
	cult_mind.current << "Your objective is to summon Nar-Sie by building and defending a suitable shell for the Geometer. Adequate supplies can be procured through human sacrifices."

/datum/game_mode/proc/equip_cultist(mob/living/carbon/human/mob)
	if(!istype(mob))
		return
	mob.cult_add_comm()
	if (mob.mind)
		if (mob.mind.assigned_role == "Clown")
			mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
			mob.dna.remove_mutation(CLOWNMUT)

	. += cult_give_item(/obj/item/weapon/tome, mob)
	. += cult_give_item(/obj/item/weapon/paper/talisman/supply, mob)
	. += cult_give_item(/obj/item/weapon/melee/cultblade/dagger, mob)
	mob << "These will help you start the cult on this station. Use them well, and remember - you are not the only one.</span>"

/datum/game_mode/proc/cult_give_item(obj/item/item_path, mob/living/carbon/human/mob)
	var/list/slots = list(
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	var/T = new item_path(mob)
	var/item_name = initial(item_path.name)
	var/where = mob.equip_in_one_of_slots(T, slots)
	if(!where)
		mob << "<span class='userdanger'>Unfortunately, you weren't able to get a [item_name]. This is very bad and you should adminhelp immediately (press F1).</span>"
		return 0
	else
		mob << "<span class='danger'>You have a [item_name] in your [where]."
		mob.update_icons()
		if(where == "backpack")
			var/obj/item/weapon/storage/B = mob.back
			B.orient2hud(mob)
			B.show_to(mob)
		return 1

/datum/game_mode/proc/add_cultist(datum/mind/cult_mind) //BASE
	if (!istype(cult_mind) || (cult_mind in cult))
		return 0
	cult_mind.current.Paralyse(5)
	cult += cult_mind
	cult_mind.current.faction |= "cult"
	cult_mind.current.cult_add_comm()
	update_cult_icons_added(cult_mind)
	cult_mind.current.attack_log += "\[[time_stamp()]\] <span class='danger'>Has been converted to the cult!</span>"
	if(jobban_isbanned(cult_mind.current, ROLE_CULTIST))
		replace_jobbaned_player(cult_mind.current, ROLE_CULTIST, ROLE_CULTIST)
	return 1


/datum/game_mode/cult/add_cultist(datum/mind/cult_mind) //INHERIT
	if (!..(cult_mind))
		return
	memorize_cult_objectives(cult_mind)


/datum/game_mode/proc/remove_cultist(datum/mind/cult_mind, show_message = 1)
	if(cult_mind in cult)
		cult -= cult_mind
		cult_mind.current.faction -= "cult"
		cult_mind.current.verbs -= /mob/living/proc/cult_innate_comm
		cult_mind.current.Paralyse(5)
		cult_mind.current << "<span class='userdanger'>An unfamiliar white light flashes through your mind, cleansing the taint of the Dark One and all your memories as its servant.</span>"
		cult_mind.memory = ""
		update_cult_icons_removed(cult_mind)
		cult_mind.current.attack_log += "\[[time_stamp()]\] <span class='danger'>Has renounced the cult!</span>"
		if(show_message)
			for(var/mob/M in viewers(cult_mind.current))
				M << "<span class='big'>[cult_mind.current] looks like they just reverted to their old faith!</span>"

/datum/game_mode/proc/update_cult_icons_added(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = huds[ANTAG_HUD_CULT]
	culthud.join_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, "cult")

/datum/game_mode/proc/update_cult_icons_removed(datum/mind/cult_mind)
	var/datum/atom_hud/antag/culthud = huds[ANTAG_HUD_CULT]
	culthud.leave_hud(cult_mind.current)
	set_antag_hud(cult_mind.current, null)

/datum/game_mode/cult/declare_completion()
	if(eldergod)
		feedback_set_details("round_end_result","win - cult win")
		world << "<span class='greentext'>The cult wins! It has succeeded in serving its dark master!</span>"
	else
		feedback_set_details("round_end_result","loss - staff stopped the cult")
		world << "<span class='redtext'>The staff managed to stop the cult!</span>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_cult()
	if( cult.len || (ticker && istype(ticker.mode,/datum/game_mode/cult)) )
		var/text = "<br><font size=3><b>The cultists were:</b></font>"
		for(var/datum/mind/cultist in cult)
			text += printplayer(cultist)

		text += "<br>"

		world << text
