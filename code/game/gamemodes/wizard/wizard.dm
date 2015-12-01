/*/proc/iswizard(mob/living/M as mob)
	return istype(M) && M.mind && ticker && ticker.mode && (M.mind in ticker.mode.wizards)*/ //See _macros.dm

/datum/game_mode
	var/list/datum/mind/wizards = list()

/datum/game_mode/wizard
	name = "wizard"
	config_tag = "wizard"
	required_players = 2
	required_players_secret = 10
	required_enemies = 1
	recommended_enemies = 1
	rage = 0

	uplink_welcome = "Wizardly Uplink Console:"
	uplink_uses = 10

	var/finished = 0

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)


/datum/game_mode/wizard/announce()
	to_chat(world, "<B>The current game mode is - Wizard!</B>")
	to_chat(world, "<B>There is a <span class='danger'>SPACE WIZARD on the station. You can't let him achieve his objective!</span>")

/datum/game_mode/wizard/pre_setup()
	var/list/datum/mind/possible_wizards = get_players_for_role(ROLE_WIZARD)
	if(possible_wizards.len==0)
		log_admin("Failed to set-up a round of wizard. Couldn't find any volunteers to be wizards.")
		message_admins("Failed to set-up a round of wizard. Couldn't find any volunteers to be wizards.")
		return 0
	var/datum/mind/wizard
	while(possible_wizards.len)
		wizard = pick(possible_wizards)
		if(wizard.special_role)
			possible_wizards -= wizard
			wizard = null
			continue
		else
			break
	if(isnull(wizard))
		log_admin("COULD NOT MAKE A WIZARD, Mixed mode is [mixed ? "enabled" : "disabled"]")
		message_admins("COULD NOT MAKE A WIZARD, Mixed mode is [mixed ? "enabled" : "disabled"]")
		return 0
	wizards += wizard
	modePlayer += wizard
	wizard.assigned_role = "MODE" //So they aren't chosen for other jobs.
	wizard.special_role = "Wizard"
	wizard.original = wizard.current
	if(wizardstart.len == 0)
		to_chat(wizard.current, "<span class='danger'>A starting location for you could not be found, please report this bug!</span>")
		log_admin("Failed to set-up a round of wizard. Couldn't find any wizard spawn points.")
		message_admins("Failed to set-up a round of wizard. Couldn't find any wizard spawn points.")
		return 0

	for(var/datum/mind/wwizard in wizards)
		wwizard.current.loc = pick(wizardstart)

	log_admin("Starting a round of wizard with [wizards.len] wizards.")
	message_admins("Starting a round of wizard with [wizards.len] wizards.")
	return 1


/datum/game_mode/wizard/post_setup()
	for(var/datum/mind/wizard in wizards)
		forge_wizard_objectives(wizard)
		//learn_basic_spells(wizard.current)
		equip_wizard(wizard.current)
		name_wizard(wizard.current)
		greet_wizard(wizard)
		update_wizard_icons_added(wizard)
	update_all_wizard_icons()
	if(!mixed)
		spawn (rand(waittime_l, waittime_h))
			send_intercept()
	..()
	return


/datum/game_mode/proc/forge_wizard_objectives(var/datum/mind/wizard)
	switch(rand(1,100))
		if(1 to 30)

			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = wizard
			kill_objective.find_target()
			wizard.objectives += kill_objective

			if (!(locate(/datum/objective/escape) in wizard.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = wizard
				wizard.objectives += escape_objective
		if(31 to 60)
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = wizard
			steal_objective.find_target()
			wizard.objectives += steal_objective

			if (!(locate(/datum/objective/escape) in wizard.objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = wizard
				wizard.objectives += escape_objective

		if(61 to 100)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = wizard
			kill_objective.find_target()
			wizard.objectives += kill_objective

			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = wizard
			steal_objective.find_target()
			wizard.objectives += steal_objective

			if (!(locate(/datum/objective/survive) in wizard.objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = wizard
				wizard.objectives += survive_objective

		else
			if (!(locate(/datum/objective/hijack) in wizard.objectives))
				var/datum/objective/hijack/hijack_objective = new
				hijack_objective.owner = wizard
				wizard.objectives += hijack_objective
	return


/datum/game_mode/proc/name_wizard(mob/living/carbon/human/wizard_mob)
	//Allows the wizard to choose a custom name or go with a random one. Spawn 0 so it does not lag the round starting.
	if(wizard_mob.species && wizard_mob.species.name != "Human")
		wizard_mob.set_species("Human", 1)
	var/wizard_name_first = pick(wizard_first)
	var/wizard_name_second = pick(wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	spawn(0)
		var/newname = copytext(sanitize(input(wizard_mob, "You are the Space Wizard. Would you like to change your name to something else?", "Name change", randomname) as null|text),1,MAX_NAME_LEN)

		if (!newname)
			newname = randomname

		wizard_mob.real_name = newname
		wizard_mob.name = newname
		if(wizard_mob.mind)
			wizard_mob.mind.name = newname
	return


/datum/game_mode/proc/greet_wizard(var/datum/mind/wizard, var/you_are=1)
	if (you_are)
		to_chat(wizard.current, "<span class='danger'>You are the Space Wizard!</span>")
	to_chat(wizard.current, "<B>The Space Wizards Federation has given you the following tasks:</B>")

	var/obj_count = 1
	for(var/datum/objective/objective in wizard.objectives)
		to_chat(wizard.current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++
	return


/*/datum/game_mode/proc/learn_basic_spells(mob/living/carbon/human/wizard_mob)
	if (!istype(wizard_mob))
		return
	if(!config.feature_object_spell_system)
		wizard_mob.verbs += /client/proc/jaunt
		wizard_mob.mind.special_verbs += /client/proc/jaunt
	else
		wizard_mob.spell_list += new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(usr)
*/

/datum/game_mode/proc/equip_wizard(mob/living/carbon/human/wizard_mob)
	if (!istype(wizard_mob))
		return

	//So zards properly get their items when they are admin-made.
	qdel(wizard_mob.wear_suit)
	qdel(wizard_mob.head)
	qdel(wizard_mob.shoes)
	qdel(wizard_mob.r_hand)
	qdel(wizard_mob.r_store)
	qdel(wizard_mob.l_store)

	wizard_mob.equip_to_slot_or_del(new /obj/item/device/radio/headset(wizard_mob), slot_ears)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(wizard_mob), slot_w_uniform)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(wizard_mob), slot_shoes)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(wizard_mob), slot_wear_suit)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(wizard_mob), slot_head)
	if(wizard_mob.backbag == 2) wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(wizard_mob), slot_back)
	if(wizard_mob.backbag == 3) wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel_norm(wizard_mob), slot_back)
	if(wizard_mob.backbag == 4) wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack/satchel(wizard_mob), slot_back)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/box(wizard_mob), slot_in_backpack)
//	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/scrying_gem(wizard_mob), slot_l_store) For scrying gem.
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(wizard_mob), slot_r_store)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/spellbook(wizard_mob), slot_r_hand)

	// For Vox and plasmadudes.
	//wizard_mob.species.handle_post_spawn(wizard_mob)

	to_chat(wizard_mob, "You will find a list of available spells in your spell book. Choose your magic arsenal carefully.")
	to_chat(wizard_mob, "In your pockets you will find a teleport scroll. Use it as needed.")
	wizard_mob.mind.store_memory("<B>Remember:</B> do not forget to prepare your spells.")
	wizard_mob.update_icons()
	return 1


/datum/game_mode/wizard/check_finished()
	if(istype(ticker.mode, /datum/game_mode/mixed))
		mixed = 1
	if(config.continous_rounds || mixed)
		return ..()

	var/wizards_alive = 0
	var/traitors_alive = 0
	for(var/datum/mind/wizard in wizards)
		if(!istype(wizard.current,/mob/living/carbon))
			continue
		if(wizard.current.stat==2)
			continue
		wizards_alive++

	if(!wizards_alive)
		for(var/datum/mind/traitor in traitors)
			if(!istype(traitor.current,/mob/living/carbon))
				continue
			if(traitor.current.stat==2)
				continue
			traitors_alive++

	if (wizards_alive || traitors_alive || (rage && src:making_mage))
		return ..()
	else
		finished = 1
		return 1



/datum/game_mode/wizard/declare_completion(var/ragin = 0)
	if(finished && !ragin)
		feedback_set_details("round_end_result","loss - wizard killed")
		completion_text += "<br><span class='warning'><FONT size = 3><B> The wizard[(wizards.len>1)?"s":""] has been killed by the crew! The Space Wizards Federation has been taught a lesson they will not soon forget!</B></FONT></span>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_wizard()
	var/text = ""
	if(wizards.len)
		var/icon/logo = icon('icons/mob/mob.dmi', "wizard-logo")
		end_icons += logo
		var/tempstate = end_icons.len
		text += {"<br><img src="logo_[tempstate].png"> <font size=2><b>the wizards/witches were:</b></font> <img src="logo_[tempstate].png">"}

		for(var/datum/mind/wizard in wizards)

			if(wizard.current)
				var/icon/flat = getFlatIcon(wizard.current, SOUTH, 1, 1)
				end_icons += flat
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[wizard.key]</b> was <b>[wizard.name]</b> ("}
				if(wizard.current.stat == DEAD)
					text += "died"
					flat.Turn(90)
					end_icons[tempstate] = flat
				else
					text += "survived"
				if(wizard.current.real_name != wizard.name)
					text += " as <b>[wizard.current.real_name]</b>"
			else
				var/icon/sprotch = icon('icons/effects/blood.dmi', "floor1-old")
				end_icons += sprotch
				tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[wizard.key]</b> was <b>[wizard.name]</b> ("}
				text += "body destroyed"
			text += ")"

			var/count = 1
			var/wizardwin = 1
			for(var/datum/objective/objective in wizard.objectives)
				if(objective.check_completion())
					text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='green'><B>Success!</B></font>"
					feedback_add_details("wizard_objective","[objective.type]|SUCCESS")
				else
					text += "<br><B>Objective #[count]</B>: [objective.explanation_text] <font color='red'>Fail.</font>"
					feedback_add_details("wizard_objective","[objective.type]|FAIL")
					wizardwin = 0
				count++

			if(wizard.current && wizard.current.stat!=2 && wizardwin)
				text += "<br><font color='green'><B>The wizard was successful!</B></font>"
				feedback_add_details("wizard_success","SUCCESS")
			else
				text += "<br><font color='red'><B>The wizard has failed!</B></font>"
				feedback_add_details("wizard_success","FAIL")
			if(wizard.current && wizard.current.spell_list)
				text += "<br><B>[wizard.name] used the following spells: </B>"
				var/i = 1
				for(var/spell/S in wizard.current.spell_list)
					var/icon/spellicon = icon('icons/mob/screen_spells.dmi', S.hud_state)
					end_icons += spellicon
					tempstate = end_icons.len
					text += {"<br><img src="logo_[tempstate].png"> [S.name]"}
					if(wizard.current.spell_list.len > i)
						text += ", "
					i++
			text += "<br>"
		text += "<HR>"
	return text

//OTHER PROCS

//To batch-remove wizard spells. Linked to mind.dm.
/mob/proc/spellremove(var/mob/M as mob)
	for(var/spell/spell_to_remove in src.spell_list)
		remove_spell(spell_to_remove)

// Does this clothing slot count as wizard garb? (Combines a few checks)
/proc/is_wiz_garb(var/obj/item/clothing/C)
	return C && C.wizard_garb

/*Checks if the wizard is wearing the proper attire.
Made a proc so this is not repeated 14 (or more) times.*/
/mob/proc/wearing_wiz_garb()
	to_chat(src, "Silly creature, you're not a human. Only humans can cast this spell.")
	return 0

// Humans can wear clothes.
/mob/living/carbon/human/wearing_wiz_garb()
	if(!is_wiz_garb(src.wear_suit))
		to_chat(src, "<span class='warning'>I don't feel strong enough without my robe.</span>")
		return 0
	if(!is_wiz_garb(src.shoes))
		to_chat(src, "<span class='warning'>I don't feel strong enough without my sandals.</span>")
		return 0
	if(!is_wiz_garb(src.head))
		to_chat(src, "<span class='warning'>I don't feel strong enough without my hat.</span>")
		return 0
	return 1

// So can monkeys (FIXME)
/*
/mob/living/carbon/monkey/wearing_wiz_garb()
	if(!is_wiz_garb(src.wear_suit))
		to_chat(src, "<span class='warning'>I don't feel strong enough without my robe.</span>")
		return 0
	if(!is_wiz_garb(src.shoes))
		to_chat(src, "<span class='warning'>I don't feel strong enough without my sandals.</span>")
		return 0
	if(!is_wiz_garb(src.head))
		to_chat(src, "<span class='warning'>I don't feel strong enough without my hat.</span>")
		return 0
	return 1
*/

/datum/game_mode/proc/update_all_wizard_icons()
	spawn(0)
		for(var/datum/mind/wizard_mind in wizards)
			if(wizard_mind.current)
				if(wizard_mind.current.client)
					for(var/image/I in wizard_mind.current.client.images)
						if(I.icon_state == "wizard")
							wizard_mind.current.client.images -= I

		for(var/datum/mind/wizard_mind in wizards)
			if(wizard_mind.current)
				if(wizard_mind.current.client)
					for(var/datum/mind/wizard_mind_1 in wizards)
						if(wizard_mind_1.current)
							var/imageloc = wizard_mind_1.current
							if(istype(wizard_mind_1.current.loc,/obj/mecha))
								imageloc = wizard_mind_1.current.loc
							var/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "wizard", layer = 13)
							wizard_mind.current.client.images += I

/datum/game_mode/proc/update_wizard_icons_added(datum/mind/wizard_mind)
	spawn(0)
		if(wizard_mind.current)
			if(wizard_mind.current.client)
				var/imageloc = wizard_mind.current
				if(istype(wizard_mind.current.loc,/obj/mecha))
					imageloc = wizard_mind.current.loc
				var/I = image('icons/mob/mob.dmi', loc = imageloc, icon_state = "wizard", layer = 13)
				wizard_mind.current.client.images += I

/datum/game_mode/proc/update_wizard_icons_removed(datum/mind/wizard_mind)
	spawn(0)
		for(var/datum/mind/wizard in wizards)
			if(wizard.current)
				if(wizard.current.client)
					for(var/image/I in wizard.current.client.images)
						if(I.icon_state == "wizard" && ((I.loc == wizard_mind.current) || (I.loc == wizard_mind.current.loc)))
							//del(I)
							wizard.current.client.images -= I

		if(wizard_mind.current)
			if(wizard_mind.current.client)
				for(var/image/I in wizard_mind.current.client.images)
					if(I.icon_state == "wizard")
						//del(I)
						wizard_mind.current.client.images -= I
