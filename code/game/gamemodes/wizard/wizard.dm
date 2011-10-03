
/datum/game_mode
	var/list/datum/mind/wizards = list()

/datum/game_mode/wizard
	name = "wizard"
	config_tag = "wizard"
	required_players = 0
	required_enemies = 1

	var/finished = 0

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)


/datum/game_mode/wizard/announce()
	world << "<B>The current game mode is - Wizard!</B>"
	world << "<B>There is a \red SPACE WIZARD\black on the station. You can't let him achieve his objective!</B>"


/datum/game_mode/wizard/can_start()//This could be better, will likely have to recode it later
	if(!..())
		return 0
	var/list/datum/mind/possible_wizards = get_players_for_role(BE_WIZARD)
	if(possible_wizards.len==0)
		return 0
	var/datum/mind/wizard = pick(possible_wizards)
	wizards += wizard
	modePlayer += wizard
	wizard.assigned_role = "MODE" //So they aren't chosen for other jobs.
	wizard.special_role = "Wizard"
	wizard.original = wizard.current
	if(wizardstart.len == 0)
		wizard.current << "<B>\red A starting location for you could not be found, please report this bug!</B>"
		return 0
	return 1


/datum/game_mode/wizard/pre_setup()
	for(var/datum/mind/wizard in wizards)
		wizard.current.loc = pick(wizardstart)

	return 1


/datum/game_mode/wizard/post_setup()
	for(var/datum/mind/wizard in wizards)
		forge_wizard_objectives(wizard)
		learn_basic_spells(wizard.current)
		equip_wizard(wizard.current)
		name_wizard(wizard.current)
		greet_wizard(wizard)

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

		if(61 to 85)
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
	var/wizard_name_first = pick(wizard_first)
	var/wizard_name_second = pick(wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	spawn(0)
		var/newname = input(wizard_mob, "You are the Space Wizard. Would you like to change your name to something else?", "Name change", randomname) as null|text

		if (length(newname) == 0)
			newname = randomname

		if (newname)
			if (length(newname) >= 26)
				newname = copytext(newname, 1, 26)
				newname = dd_replacetext(newname, ">", "'")
		wizard_mob.real_name = newname
		wizard_mob.name = newname
	return


/datum/game_mode/proc/greet_wizard(var/datum/mind/wizard, var/you_are=1)
	if (you_are)
		wizard.current << "<B>\red You are the Space Wizard!</B>"
	wizard.current << "<B>The Space Wizards Federation has given you the following tasks:</B>"

	var/obj_count = 1
	for(var/datum/objective/objective in wizard.objectives)
		wizard.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
		obj_count++
	return


/datum/game_mode/proc/learn_basic_spells(mob/living/carbon/human/wizard_mob)
	if (!istype(wizard_mob))
		return
	if(!config.feature_object_spell_system)
		wizard_mob.verbs += /client/proc/jaunt
		wizard_mob.mind.special_verbs += /client/proc/jaunt
	else
		wizard_mob.spell_list += new /obj/effects/proc_holder/spell/targeted/ethereal_jaunt(usr)


/datum/game_mode/proc/equip_wizard(mob/living/carbon/human/wizard_mob)
	if (!istype(wizard_mob))
		return

	//So zards properly get their items when they are admin-made.
	del(wizard_mob.wear_suit)
	del(wizard_mob.head)
	del(wizard_mob.shoes)
	del(wizard_mob.r_hand)
	del(wizard_mob.r_store)
	del(wizard_mob.l_store)

	wizard_mob.equip_if_possible(new /obj/item/device/radio/headset(wizard_mob), wizard_mob.slot_ears)
	wizard_mob.equip_if_possible(new /obj/item/clothing/under/lightpurple(wizard_mob), wizard_mob.slot_w_uniform)
	wizard_mob.equip_if_possible(new /obj/item/clothing/shoes/sandal(wizard_mob), wizard_mob.slot_shoes)
	wizard_mob.equip_if_possible(new /obj/item/clothing/suit/wizrobe(wizard_mob), wizard_mob.slot_wear_suit)
	wizard_mob.equip_if_possible(new /obj/item/clothing/head/wizard(wizard_mob), wizard_mob.slot_head)
	wizard_mob.equip_if_possible(new /obj/item/weapon/storage/backpack(wizard_mob), wizard_mob.slot_back)
	wizard_mob.equip_if_possible(new /obj/item/weapon/storage/box(wizard_mob), wizard_mob.slot_in_backpack)
//	wizard_mob.equip_if_possible(new /obj/item/weapon/scrying_gem(wizard_mob), wizard_mob.slot_l_store) For scrying gem.
	wizard_mob.equip_if_possible(new /obj/item/weapon/teleportation_scroll(wizard_mob), wizard_mob.slot_r_store)
	if(config.feature_object_spell_system) //if it's turned on (in config.txt), spawns an object spell spellbook
		wizard_mob.equip_if_possible(new /obj/item/weapon/spellbook/object_type_spells(wizard_mob), wizard_mob.slot_r_hand)
	else
		wizard_mob.equip_if_possible(new /obj/item/weapon/spellbook(wizard_mob), wizard_mob.slot_r_hand)

	wizard_mob << "You will find a list of available spells in your spell book. Choose your magic arsenal carefully."
	wizard_mob << "In your pockets you will find two more important, magical artifacts. Use them as needed."
	wizard_mob.mind.store_memory("<B>Remember:</B> do not forget to prepare your spells.")
	return 1


/datum/game_mode/wizard/check_finished()
	var/wizards_alive = 0
	for(var/datum/mind/wizard in wizards)
		if(!istype(wizard.current,/mob/living/carbon))
			continue
		if(wizard.current.stat==2)
			continue
		wizards_alive++

	if (wizards_alive)
		return ..()
	else
		finished = 1
		return 1


/datum/game_mode/wizard/declare_completion()
	if(finished)
		world << "\red <FONT size = 3><B> The wizard[(wizards.len>1)?"s":""] has been killed by the crew! The Space Wizards Federation has been taught a lesson they will not soon forget!</B></FONT>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_wizard()
	for(var/datum/mind/wizard in wizards)
		var/wizard_name
		if(wizard.current)
			if(wizard.current == wizard.original)
				wizard_name = "[wizard.current.real_name] (played by [wizard.key])"
			else if (wizard.original)
				wizard_name = "[wizard.current.real_name] (originally [wizard.original.real_name]) (played by [wizard.key])"
			else
				wizard_name = "[wizard.current.real_name] (original character destroyed) (played by [wizard.key])"
		else
			wizard_name = "[wizard.key] (character destroyed)"
		world << "<B>The wizard was [wizard_name]</B>"
		var/count = 1
		var/wizardwin = 1
		for(var/datum/objective/objective in wizard.objectives)
			if(objective.check_completion())
				world << "<B>Objective #[count]</B>: [objective.explanation_text] \green <B>Success</B>"
			else
				world << "<B>Objective #[count]</B>: [objective.explanation_text] \red Failed"
				wizardwin = 0
			count++

		if(wizard.current && wizard.current.stat!=2 && wizardwin)
			world << "<B>The wizard was successful!<B>"
		else
			world << "<B>The wizard has failed!<B>"
	return 1

//OTHER PROCS

//To batch-remove wizard spells. Linked to mind.dm.
/mob/proc/spellremove(var/mob/M as mob, var/spell_type = "verb")
//	..()
	if(spell_type == "verb")
		if(M.verbs.len)
			M.verbs -= /client/proc/jaunt
			M.verbs -= /client/proc/magicmissile
			M.verbs -= /client/proc/fireball
			M.verbs -= /mob/proc/kill
			M.verbs -= /mob/proc/tech
			M.verbs -= /client/proc/smokecloud
			M.verbs -= /client/proc/blind
			M.verbs -= /client/proc/forcewall
			M.verbs -= /mob/proc/teleport
			M.verbs -= /client/proc/mutate
			M.verbs -= /client/proc/knock
			M.verbs -= /mob/proc/swap
			M.verbs -= /client/proc/blink
		if(M.mind && M.mind.special_verbs.len)
			M.mind.special_verbs -= /client/proc/jaunt
			M.mind.special_verbs -= /client/proc/magicmissile
			M.mind.special_verbs -= /client/proc/fireball
			M.mind.special_verbs -= /mob/proc/kill
			M.mind.special_verbs -= /mob/proc/tech
			M.mind.special_verbs -= /client/proc/smokecloud
			M.mind.special_verbs -= /client/proc/blind
			M.mind.special_verbs -= /client/proc/forcewall
			M.mind.special_verbs -= /mob/proc/teleport
			M.mind.special_verbs -= /client/proc/mutate
			M.mind.special_verbs -= /client/proc/knock
			M.mind.special_verbs -= /mob/proc/swap
			M.mind.special_verbs -= /client/proc/blink
	else if(spell_type == "object")
		for(var/obj/effects/proc_holder/spell/spell_to_remove in src.spell_list)
			del(spell_to_remove)

/*Checks if the wizard can cast spells.
Made a proc so this is not repeated 14 (or more) times.*/
/mob/proc/casting()
//Removed the stat check because not all spells require clothing now.
	if(!istype(usr:wear_suit, /obj/item/clothing/suit/wizrobe))
		usr << "I don't feel strong enough without my robe."
		return 0
	if(!istype(usr:shoes, /obj/item/clothing/shoes/sandal))
		usr << "I don't feel strong enough without my sandals."
		return 0
	if(!istype(usr:head, /obj/item/clothing/head/wizard))
		usr << "I don't feel strong enough without my hat."
		return 0
	else
		return 1

/*Checks if the wizard is a mime and male/female.
Outputs the appropriate voice if the user is not a mime.
Made a proc here so it's not repeated several times.*/
/mob/proc/spellvoice()
//	if(!usr.miming)No longer necessary.
//	if(usr.gender=="male")
//		playsound(usr.loc, pick('null.ogg','null.ogg'), 100, 1)
//	else
//		playsound(usr.loc, pick('null.ogg','null.ogg'), 100, 1)


















//UNUSED/OLD CODE

//	for (var/obj/effects/landmark/A in world)
//		if (A.name == "Teleport-Scroll")
//			new /obj/item/weapon/teleportation_scroll(A.loc)
//			del(A)
//			continue
//Scroll now starts in the wizard's inventory.

//	if (wizard_mob.mind.assigned_role == "Clown")
//		wizard_mob << "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
//		wizard_mob.mutations &= ~CLOWN No more clowns as wizarrrddsss

/*Creates random numbers/codes for the uplink.
	var/freq = 1441
	var/list/freqlist = list()
	while (freq <= 1489)
		if (freq < 1451 || freq > 1459)
			freqlist += freq
		freq += 2
		if ((freq % 2) == 0)
			freq += 1
	freq = freqlist[rand(1, freqlist.len)]
	// generate a passcode if the uplink is hidden in a PDA
	var/pda_pass = "[rand(100,999)] [pick("Morgan","Circe","Prospero","Elminister","Raistlin","Tzeentch","Saruman","Khelben","Dumbledor","Gandalf","Houdini","Teferi","Urza","Tenser","Zagyg","Mystryl","Boccob","Merlin")]"
No longer used because wizards begin with a spell book.*/

/*Checks where to spawn the swf uplink.
	var/loc = ""
	var/obj/item/device/R = null //Hide the uplink in a PDA if available, otherwise radio
	if (!R && istype(wizard_mob.belt, /obj/item/device/pda))
		R = wizard_mob.belt
		loc = "on your belt"
	if (!R && istype(wizard_mob.l_hand, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = wizard_mob.l_hand
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your left hand"
			break
	if (!R && istype(wizard_mob.r_hand, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = wizard_mob.r_hand
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your right hand"
			break
	if (!R && istype(wizard_mob.back, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = wizard_mob.back
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] on your back"
			break
	if (!R && wizard_mob.w_uniform && istype(wizard_mob.belt, /obj/item/device/radio))
		R = wizard_mob.belt
		loc = "on your belt"
	if (!R && istype(wizard_mob.ears, /obj/item/device/radio))
		R = wizard_mob.ears
		loc = "on your head"
	if (!R)
		wizard_mob << "Unfortunately, the Space Wizards Federation wasn't able to get you a radio."
	else
		if (istype(R, /obj/item/device/radio))
			var/obj/item/weapon/SWF_uplink/T = new /obj/item/weapon/SWF_uplink(R)
			R:traitorradio = T
			R:traitor_frequency = freq
			T.name = R.name
			T.icon_state = R.icon_state
			T.origradio = R
			wizard_mob << "The Space Wizards Federation have cunningly disguised a spell book as your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock it's hidden features."
			wizard_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).")
		else if (istype(R, /obj/item/device/pda))
			var/obj/item/weapon/integrated_uplink/SWF/T = new /obj/item/weapon/integrated_uplink/SWF(R)
			R:uplink = T
			T.lock_code = pda_pass
			T.hostpda = R
			wizard_mob << "The Space Wizards Federation have cunningly enchanted a spellbook into your PDA [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features."
			wizard_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc]).")
No longer used because wizards begin with a spell book.*/

/*Code which works for intergrated uplinks, like those in PDAs.
/obj/item/weapon/integrated_uplink/SWF
	name = "enchanted uplink"
	uses = 4
	var/temp = null

/obj/item/weapon/integrated_uplink/SWF/generate_menu()
	src.menu_message = "<b>Wizarding Uplink Console:</b><br>"
	src.menu_message += "Tele-Crystals left: [src.uses]<BR>"
	src.menu_message += "<HR>"

	if(src.temp)
		src.menu_message += "[src.temp]<br>"
	else //Nice empty space for it to appear in.
		src.menu_message += "<br>"
	src.menu_message += "<B>Request item:</B><BR>"
	src.menu_message += "<I>Each item costs 1 telecrystal. The number afterwards is the cooldown time.</I><BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_spell=magicmissile'>Magic Missile</A> (10)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_spell=fireball'>Fireball</A> (10)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_spell=disintegrate'>Disintegrate</A> (60)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_spell=emp'>Disable Technology</A> (60)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_spell=smoke'>Smoke</A> (10)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_spell=blind'>Blind</A> (30)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_spell=forcewall'>Forcewall</A> (10)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_spell=blink'>Blink</A> (2)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_spell=teleport'>Teleport</A> (30)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_spell=mutate'>Mutate</A> (60)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_spell=jaunt'>Ethereal Jaunt</A> (60)<BR>"
	src.menu_message += "<A href='byond://?src=\ref[src];buy_spell=knock'>Knock</A> (10)<BR>"
	src.menu_message += "<HR>"
	return

/obj/item/weapon/integrated_uplink/SWF/Topic(href, href_list)
	if ((isnull(src.hostpda)) || (!src.active))
		return

	if (usr.stat || usr.restrained() || !in_range(src.hostpda, usr))
		return

	if (href_list["buy_spell"])
		switch(href_list["buy_spell"])
			if("magicmissile")
				if (src.uses >= 1)
					src.uses -= 1
					usr.verbs += /client/proc/magicmissile
					src.temp = "This spell fires several, slow moving, magic projectiles at nearby targets. If they hit a target, it is paralyzed and takes minor damage."
			if("fireball")
				if (src.uses >= 1)
					src.uses -= 1
					usr.verbs += /client/proc/fireball
					src.temp = "This spell fires a fireball at a target and does not require wizard garb. Be careful not to fire it at people that are standing next to you."
			if("disintegrate")
				if (src.uses >= 1)
					src.uses -= 1
					usr.verbs += /mob/proc/kill
					src.temp = "This spell instantly kills somebody adjacent to you with the vilest of magick. It has a long cooldown."
			if("emp")
				if (src.uses >= 1)
					src.uses -= 1
					usr.verbs += /mob/proc/tech
					src.temp = "This spell disables all weapons, cameras and most other technology in range."
			if("smoke")
				if (src.uses >= 1)
					src.uses -= 1
					usr.verbs += /client/proc/smokecloud
					src.temp = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."
			if("blind")
				if (src.uses >= 1)
					src.uses -= 1
					usr.verbs += /client/proc/blind
					src.temp = "This spell temporarly blinds a single person and does not require wizard garb."
			if("forcewall")
				if (src.uses >= 1)
					src.uses -= 1
					usr.verbs += /client/proc/forcewall
					src.temp = "This spell creates an unbreakable wall that lasts for 30 seconds and does not require wizard garb."
			if("blink")
				if (src.uses >= 1)
					src.uses -= 1
					usr.verbs += /client/proc/blink
					src.temp = "This spell randomly teleports you a short distance. Useful for evasion or getting into areas if you have patience."
			if("teleport")
				if (src.uses >= 1)
					src.uses -= 1
					usr.verbs += /mob/proc/teleport
					src.temp = "This spell teleports you to a type of area of your selection. Very useful if you are in danger, but has a decent cooldown, and is unpredictable."
			if("mutate")
				if (src.uses >= 1)
					src.uses -= 1
					usr.verbs += /client/proc/mutate
					src.temp = "This spell causes you to turn into a hulk, and gain telekinesis for a short while."
			if("jaunt")
				if (src.uses >= 1)
					src.uses -= 1
					usr.verbs += /client/proc/jaunt
					src.temp = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
			if("knock")
				if (src.uses >= 1)
					src.uses -= 1
					usr.verbs += /client/proc/knock
					src.temp = "This spell opens nearby doors and does not require wizard garb."
		src.generate_menu()
		src.print_to_host(src.menu_message)
		return

	return
No longer used because wizards begin with a spell book.*/