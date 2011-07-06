
/datum/game_mode
	var/list/datum/mind/wizards = list()

/datum/game_mode/wizard
	name = "wizard"
	config_tag = "wizard"

	var/finished = 0

	var/const/prob_int_murder_target = 50 // intercept names the assassination target half the time
	var/const/prob_right_murder_target_l = 25 // lower bound on probability of naming right assassination target
	var/const/prob_right_murder_target_h = 50 // upper bound on probability of naimg the right assassination target

	var/const/prob_int_item = 50 // intercept names the theft target half the time
	var/const/prob_right_item_l = 25 // lower bound on probability of naming right theft target
	var/const/prob_right_item_h = 50 // upper bound on probability of naming the right theft target

	var/const/prob_int_sab_target = 50 // intercept names the sabotage target half the time
	var/const/prob_right_sab_target_l = 25 // lower bound on probability of naming right sabotage target
	var/const/prob_right_sab_target_h = 50 // upper bound on probability of naming right sabotage target

	var/const/prob_right_killer_l = 25 //lower bound on probability of naming the right operative
	var/const/prob_right_killer_h = 50 //upper bound on probability of naming the right operative
	var/const/prob_right_objective_l = 25 //lower bound on probability of determining the objective correctly
	var/const/prob_right_objective_h = 50 //upper bound on probability of determining the objective correctly

	//apparently BYOND doesn't have enums, so this seems to be the best approximation
	var/const/obj_murder = 1
	var/const/obj_hijack = 2
	var/const/obj_steal = 3
	var/const/obj_sabotage = 4


	var/const/laser = 1
	var/const/hand_tele = 2
	var/const/plasma_bomb = 3
	var/const/jetpack = 4
	var/const/captain_card = 5
	var/const/captain_suit = 6

	var/const/destroy_plasma = 1
	var/const/destroy_ai = 2
	var/const/kill_monkeys = 3
	var/const/cut_power = 4

	var/const/percentage_plasma_destroy = 70 // what percentage of the plasma tanks you gotta destroy
	var/const/percentage_station_cut_power = 80 // what percentage of the tiles have to have power cut
	var/const/percentage_station_evacuate = 80 // what percentage of people gotta leave

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

/datum/game_mode/wizard/announce()
	world << "<B>The current game mode is - Wizard!</B>"
	world << "<B>There is a \red SPACE WIZARD\black on the station. You can't let him achieve his objective!</B>"

/datum/game_mode/wizard/can_start()
	for(var/mob/new_player/P in world)
		if(P.client && P.ready && !jobban_isbanned(P, "Syndicate"))
			return 1
	return 0

/datum/game_mode/wizard/pre_setup()
	var/list/datum/mind/possible_wizards = get_players_for_role(BE_WIZARD)
	if(possible_wizards.len==0)
		return 0
	var/datum/mind/wizard = pick(possible_wizards)
	//possible_wizards-=wizard
	wizards += wizard
	modePlayer += wizard
	wizard.assigned_role = "MODE" //So they aren't chosen for other jobs.
	wizard.special_role = "Wizard"
	wizard.original = wizard.current
	if(wizardstart.len == 0)
		wizard.current << "<B>\red A starting location for you could not be found, please report this bug!</B>"
	else
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
		wizard_mob.spell_list += new /obj/proc_holder/spell/targeted/ethereal_jaunt(usr)

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
	wizard_mob.equip_if_possible(new /obj/item/weapon/storage/survival_kit(wizard_mob), wizard_mob.slot_in_backpack)
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

//SPELL BOOK PROCS

/obj/item/weapon/spellbook/attack_self(mob/user as mob)
	user.machine = src
	var/dat
	if (src.temp)
		dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
	else
		dat = "<B>The Book of Spells:</B><BR>"
		dat += "Spells left to memorize: [src.uses]<BR>"
		dat += "<HR>"
		dat += "<B>Memorize which spell:</B><BR>"
		dat += "<I>The number after the spell name is the cooldown time.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=1'>Magic Missile</A> (10)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=2'>Fireball</A> (10)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=3'>Disintegrate</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=4'>Disable Technology</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=5'>Smoke</A> (10)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=6'>Blind</A> (30)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=7'>Mind Transfer</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=8'>Forcewall</A> (10)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=9'>Blink</A> (2)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=10'>Teleport</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=11'>Mutate</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=12'>Ethereal Jaunt</A> (60)<BR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=13'>Knock</A> (10)<BR>"
		dat += "<HR>"
		dat += "<A href='byond://?src=\ref[src];spell_choice=14'>Re-memorize Spells</A><BR>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/weapon/spellbook/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	var/mob/living/carbon/human/H = usr
	if (!( istype(H, /mob/living/carbon/human)))
		return 1
	if ((usr.contents.Find(src) || (in_range(src,usr) && istype(src.loc, /turf))))
		usr.machine = src
		if(href_list["spell_choice"])
			if(src.uses >= 1 && href_list["spell_choice"] != 14)
				src.uses--
				if(spell_type == "verb")
					switch(href_list["spell_choice"])
						if ("1")
							usr.verbs += /client/proc/magicmissile
							usr.mind.special_verbs += /client/proc/magicmissile
							src.temp = "This spell fires several, slow moving, magic projectiles at nearby targets. If they hit a target, it is paralyzed and takes minor damage."
						if ("2")
							usr.verbs += /client/proc/fireball
							usr.mind.special_verbs += /client/proc/fireball
							src.temp = "This spell fires a fireball at a target and does not require wizard garb. Be careful not to fire it at people that are standing next to you."
						if ("3")
							usr.verbs += /mob/proc/kill
							usr.mind.special_verbs += /mob/proc/kill
							src.temp = "This spell instantly kills somebody adjacent to you with the vilest of magick. It has a long cooldown."
						if ("4")
							usr.verbs += /mob/proc/tech
							usr.mind.special_verbs += /mob/proc/tech
							src.temp = "This spell disables all weapons, cameras and most other technology in range."
						if ("5")
							usr.verbs += /client/proc/smokecloud
							usr.mind.special_verbs += /client/proc/smokecloud
							src.temp = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."
						if ("6")
							usr.verbs += /client/proc/blind
							usr.mind.special_verbs += /client/proc/blind
							src.temp = "This spell temporarly blinds a single person and does not require wizard garb."
						if ("7")
							usr.verbs += /mob/proc/swap
							src.temp = "This spell allows the user to switch bodies with a target. Careful to not lose your memory in the process."
						if ("8")
							usr.verbs += /client/proc/forcewall
							usr.mind.special_verbs += /client/proc/forcewall
							src.temp = "This spell creates an unbreakable wall that lasts for 30 seconds and does not need wizard garb."
						if ("9")
							usr.verbs += /client/proc/blink
							usr.mind.special_verbs += /client/proc/blink
							src.temp = "This spell randomly teleports you a short distance. Useful for evasion or getting into areas if you have patience."
						if ("10")
							usr.verbs += /mob/proc/teleport
							usr.mind.special_verbs += /mob/proc/teleport
							src.temp = "This spell teleports you to a type of area of your selection. Very useful if you are in danger, but has a decent cooldown, and is unpredictable."
						if ("11")
							usr.verbs += /client/proc/mutate
							usr.mind.special_verbs += /client/proc/mutate
							src.temp = "This spell causes you to turn into a hulk and gain telekinesis for a short while."
						if ("12")
							usr.verbs += /client/proc/jaunt
							usr.mind.special_verbs += /client/proc/jaunt
							src.temp = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
						if ("13")
							usr.verbs += /client/proc/knock
							usr.mind.special_verbs += /client/proc/knock
							src.temp = "This spell opens nearby doors and does not require wizard garb."
				else if(spell_type == "object")
					var/list/available_spells = list("Magic Missile","Fireball","Disintegrate","Disable Tech","Smoke","Blind","Mind Transfer","Forcewall","Blink","Teleport","Mutate","Ethereal Jaunt","Knock")
					var/already_knows = 0
					for(var/obj/proc_holder/spell/aspell in usr.spell_list)
						if(available_spells[text2num(href_list["spell_choice"])] == aspell.name)
							already_knows = 1
							src.temp = "You already know that spell."
							src.uses++
							break
					if(!already_knows)
						switch(href_list["spell_choice"])
							if ("1")
								usr.spell_list += new /obj/proc_holder/spell/targeted/projectile/magic_missile(usr)
								src.temp = "This spell fires several, slow moving, magic projectiles at nearby targets. If they hit a target, it is paralyzed and takes minor damage."
							if ("2")
								usr.spell_list += new /obj/proc_holder/spell/targeted/projectile/fireball(usr)
								src.temp = "This spell fires a fireball at a target and does not require wizard garb. Be careful not to fire it at people that are standing next to you."
							if ("3")
								usr.spell_list += new /obj/proc_holder/spell/targeted/inflict_handler/disintegrate(usr)
								src.temp = "This spell instantly kills somebody adjacent to you with the vilest of magick. It has a long cooldown."
							if ("4")
								usr.spell_list += new /obj/proc_holder/spell/targeted/emplosion/disable_tech(usr)
								src.temp = "This spell disables all weapons, cameras and most other technology in range."
							if ("5")
								usr.spell_list += new /obj/proc_holder/spell/targeted/smoke(usr)
								src.temp = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."
							if ("6")
								usr.spell_list += new /obj/proc_holder/spell/targeted/trigger/blind(usr)
								src.temp = "This spell temporarly blinds a single person and does not require wizard garb."
							if ("7")
								usr.spell_list += new /obj/proc_holder/spell/targeted/mind_transfer(usr)
								src.temp = "This spell allows the user to switch bodies with a target. Careful to not lose your memory in the process."
							if ("8")
								usr.spell_list += new /obj/proc_holder/spell/aoe_turf/conjure/forcewall(usr)
								src.temp = "This spell creates an unbreakable wall that lasts for 30 seconds and does not need wizard garb."
							if ("9")
								usr.spell_list += new /obj/proc_holder/spell/targeted/turf_teleport/blink(usr)
								src.temp = "This spell randomly teleports you a short distance. Useful for evasion or getting into areas if you have patience."
							if ("10")
								usr.spell_list += new /obj/proc_holder/spell/targeted/area_teleport/teleport(usr)
								src.temp = "This spell teleports you to a type of area of your selection. Very useful if you are in danger, but has a decent cooldown, and is unpredictable."
							if ("11")
								usr.spell_list += new /obj/proc_holder/spell/targeted/genetic/mutate(usr)
								src.temp = "This spell causes you to turn into a hulk and gain telekinesis for a short while."
							if ("12")
								usr.spell_list += new /obj/proc_holder/spell/targeted/ethereal_jaunt(usr)
								src.temp = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
							if ("13")
								usr.spell_list += new /obj/proc_holder/spell/aoe_turf/knock(usr)
								src.temp = "This spell opens nearby doors and does not require wizard garb."
			if (href_list["spell_choice"] == "14")
				var/area/wizard_station/A = locate()
				if(usr in A.contents)
					src.uses = src.max_uses
					usr.spellremove(usr,spell_type)
					src.temp = "All spells have been removed. You may now memorize a new set of spells."
				else
					src.temp = "You may only re-memorize spells whilst located inside the wizard sanctuary."
		else
			if (href_list["temp"])
				src.temp = null
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return

//SWF UPLINK PROCS
/obj/item/weapon/SWF_uplink/attack_self(mob/user as mob)
	user.machine = src
	var/dat
	if (src.selfdestruct)
		dat = "Self Destructing..."
	else
		if (src.temp)
			dat = "[src.temp]<BR><BR><A href='byond://?src=\ref[src];temp=1'>Clear</A>"
		else
			dat = "<B>Syndicate Uplink Console:</B><BR>"
			dat += "Tele-Crystals left: [src.uses]<BR>"
			dat += "<HR>"
			dat += "<B>Request item:</B><BR>"
			dat += "<I>Each item costs 1 telecrystal. The number afterwards is the cooldown time.</I><BR>"
			dat += "<A href='byond://?src=\ref[src];spell_magicmissile=1'>Magic Missile</A> (10)<BR>"
			dat += "<A href='byond://?src=\ref[src];spell_fireball=1'>Fireball</A> (10)<BR>"
			dat += "<A href='byond://?src=\ref[src];spell_disintegrate=1'>Disintegrate</A> (60)<BR>"
			dat += "<A href='byond://?src=\ref[src];spell_emp=1'>Disable Technology</A> (60)<BR>"
			dat += "<A href='byond://?src=\ref[src];spell_smoke=1'>Smoke</A> (10)<BR>"
			dat += "<A href='byond://?src=\ref[src];spell_blind=1'>Blind</A> (30)<BR>"
			dat += "<A href='byond://?src=\ref[src];spell_swap=1'>Mind Transfer</A> (60)<BR>"
			dat += "<A href='byond://?src=\ref[src];spell_forcewall=1'>Forcewall</A> (10)<BR>"
			dat += "<A href='byond://?src=\ref[src];spell_blink=1'>Blink</A> (2)<BR>"
			dat += "<A href='byond://?src=\ref[src];spell_teleport=1'>Teleport</A> (60)<BR>"
			dat += "<A href='byond://?src=\ref[src];spell_mutate=1'>Mutate</A> (60)<BR>"
			dat += "<A href='byond://?src=\ref[src];spell_jaunt=1'>Ethereal Jaunt</A> (60)<BR>"
			dat += "<A href='byond://?src=\ref[src];spell_knock=1'>Knock</A> (10)<BR>"
			dat += "<HR>"
			if (src.origradio)
				dat += "<A href='byond://?src=\ref[src];lock=1'>Lock</A><BR>"
				dat += "<HR>"
			dat += "<A href='byond://?src=\ref[src];selfdestruct=1'>Self-Destruct</A>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/weapon/SWF_uplink/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	var/mob/living/carbon/human/H = usr
	if (!( istype(H, /mob/living/carbon/human)))
		return 1
	if ((usr.contents.Find(src) || (in_range(src,usr) && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["spell_magicmissile"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.verbs += /client/proc/magicmissile
				usr.mind.special_verbs += /client/proc/magicmissile
				src.temp = "This spell fires several, slow moving, magic projectiles at nearby targets. If they hit a target, it is paralyzed and takes minor damage."
		else if (href_list["spell_fireball"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.verbs += /client/proc/fireball
				usr.mind.special_verbs += /client/proc/fireball
				src.temp = "This spell fires a fireball at a target and does not require wizard garb. Be careful not to fire it at people that are standing next to you."
		else if (href_list["spell_disintegrate"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.verbs += /mob/proc/kill
				usr.mind.special_verbs += /mob/proc/kill
				src.temp = "This spell instantly kills somebody adjacent to you with the vilest of magick. It has a long cooldown."
		else if (href_list["spell_emp"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.verbs += /mob/proc/tech
				usr.mind.special_verbs += /mob/proc/tech
				src.temp = "This spell disables all weapons, cameras and most other technology in range."
		else if (href_list["spell_smoke"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.verbs += /client/proc/smokecloud
				usr.mind.special_verbs += /client/proc/smokecloud
				src.temp = "This spell spawns a cloud of choking smoke at your location and does not require wizard garb."
		else if (href_list["spell_blind"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.verbs += /client/proc/blind
				usr.mind.special_verbs += /client/proc/blind
				src.temp = "This spell temporarly blinds a single person and does not require wizard garb."
		else if (href_list["spell_swap"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.verbs += /mob/proc/swap
				src.temp = "This spell allows the user to switch bodies with a target. Careful to not lose your memory in the process."
		else if (href_list["spell_forcewall"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.verbs += /client/proc/forcewall
				usr.mind.special_verbs += /client/proc/forcewall
				src.temp = "This spell creates an unbreakable wall that lasts for 30 seconds and does not need wizard garb."
		else if (href_list["spell_blink"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.verbs += /client/proc/blink
				usr.mind.special_verbs += /client/proc/blink
				src.temp = "This spell randomly teleports you a short distance. Useful for evasion or getting into areas if you have patience."
		else if (href_list["spell_teleport"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.verbs += /mob/proc/teleport
				usr.mind.special_verbs += /mob/proc/teleport
				src.temp = "This spell teleports you to a type of area of your selection. Very useful if you are in danger, but has a decent cooldown, and is unpredictable."
		else if (href_list["spell_mutate"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.verbs += /client/proc/mutate
				usr.mind.special_verbs += /client/proc/mutate
				src.temp = "This spell causes you to turn into a hulk and gain telekinesis for a short while."
		else if (href_list["spell_jaunt"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.verbs += /client/proc/jaunt
				usr.mind.special_verbs += /client/proc/jaunt
				src.temp = "This spell creates your ethereal form, temporarily making you invisible and able to pass through walls."
		else if (href_list["spell_knock"])
			if (src.uses >= 1)
				src.uses -= 1
				usr.verbs += /client/proc/knock
				usr.mind.special_verbs += /client/proc/knock
				src.temp = "This spell opens nearby doors and does not require wizard garb."
		else if (href_list["lock"] && src.origradio)
			// presto chango, a regular radio again! (reset the freq too...)
			usr.machine = null
			usr << browse(null, "window=radio")
			var/obj/item/device/radio/T = src.origradio
			var/obj/item/weapon/SWF_uplink/R = src
			R.loc = T
			T.loc = usr
			// R.layer = initial(R.layer)
			R.layer = 0
			if (usr.client)
				usr.client.screen -= R
			if (usr.r_hand == R)
				usr.u_equip(R)
				usr.r_hand = T
			else
				usr.u_equip(R)
				usr.l_hand = T
			R.loc = T
			T.layer = 20
			T.set_frequency(initial(T.frequency))
			T.attack_self(usr)
			return
		else if (href_list["selfdestruct"])
			src.temp = "<A href='byond://?src=\ref[src];selfdestruct2=1'>Self-Destruct</A>"
		else if (href_list["selfdestruct2"])
			src.selfdestruct = 1
			spawn (100)
				explode()
				return
		else
			if (href_list["temp"])
				src.temp = null
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
	return

/obj/item/weapon/SWF_uplink/proc/explode()
	var/turf/location = get_turf(src.loc)
	location.hotspot_expose(700, 125)

	explosion(location, 0, 0, 2, 4)

	del(src.master)
	del(src)
	return

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
		for(var/obj/proc_holder/spell/spell_to_remove in src.spell_list)
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
	if(usr.gender=="male")
		playsound(usr.loc, pick('vs_chant_conj_hm.wav','vs_chant_conj_lm.wav','vs_chant_ench_hm.wav','vs_chant_ench_lm.wav','vs_chant_evoc_hm.wav','vs_chant_evoc_lm.wav','vs_chant_illu_hm.wav','vs_chant_illu_lm.wav','vs_chant_necr_hm.wav','vs_chant_necr_lm.wav'), 100, 1)
	else
		playsound(usr.loc, pick('vs_chant_conj_hf.wav','vs_chant_conj_lf.wav','vs_chant_ench_hf.wav','vs_chant_ench_lf.wav','vs_chant_evoc_hf.wav','vs_chant_evoc_lf.wav','vs_chant_illu_hf.wav','vs_chant_illu_lf.wav','vs_chant_necr_hf.wav','vs_chant_necr_lf.wav'), 100, 1)


















//UNUSED/OLD CODE

//	for (var/obj/landmark/A in world)
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