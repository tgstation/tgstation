/datum/game_mode
	var/list/datum/mind/deathsquads = list()
	var/list/datum/mind/infected_monkeys = list()

client/proc/antag_madness(var/mob/M in mob_list)
	set name = "Antag Madness"
	set desc = "Turns the target player into a random fully geared antag."
	set category = "Fun"

	if(!holder)
		return

	if(!M.mind)
		usr << "<span class='warning'>That mob has no mind.</span>"
		return

	if(!ishuman(M) && !ismonkey(M))
		usr << "<span class='warning'>Only humans and monkeys can become overpowered antags.</span>"
		return

	var/list/role_list = list("traitor", "changeling", "vampire", "cult", "rev", "nuke", "deathsquad", "wizard", "monkey")
	var/got_a_job = 0

	if(ismonkey(M))
		role_list = list("cult", "monkey")

	var/list/input_list = list("RANDOM")
	input_list += role_list
	input_list += "CANCEL"
	var/procedure = input("Choose antag type.", "Antag Madness") in input_list

	if(procedure == "CANCEL")
		return

	else if(procedure == "RANDOM")
		while(role_list.len > 0)
			var/choice = pick(role_list)
			if(create_madness(M,choice))
				log_admin("[key_name(usr)] turned [key_name(M)] into an overpowered [choice]")
				message_admins("[key_name_admin(usr)] turned [key_name_admin(M)]into an overpowered [choice]", 1)
				got_a_job = 1
				break
			else
				role_list -= choice

		if(!got_a_job)//aka: the mob failed all the antag creation checks
			usr << "<span class='danger'>The mob is already every type of antag at once holy shit stop that.</span>"
			return

	else
		if(create_madness(M,procedure))
			log_admin("[key_name(usr)] turned [key_name(M)] into an overpowered [procedure]")
			message_admins("[key_name_admin(usr)] turned [key_name_admin(M)]into an overpowered [procedure]", 1)
		else
			usr << "<span class='danger'>The mob is already a [procedure].</span>"
			return

	var/turf/T = get_turf(M)
	T.beamin("")

	feedback_add_details("admin_verb","AM") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/obj/structure/stool/bed/chair/vehicle/adminbus/proc/antag_madness_adminbus(var/mob/M)
	if(!M.mind)
		return

	if(!ishuman(M) && !ismonkey(M))
		return

	var/list/role_list = list("traitor", "changeling", "vampire", "cult", "rev", "nuke", "deathsquad", "wizard", "monkey")
	var/got_a_job = 0
	if(ismonkey(M))//OOK
		role_list = list("cult", "monkey")//monkeys in cult robes ftw

	while(role_list.len > 0)
		var/choice = pick(role_list)
		if(create_madness(M,choice))
			got_a_job = 1
			break
		else
			role_list -= choice

	if(!got_a_job)//aka: if the mob already is every single type of antag.
		M << "<span class='notice'>\"Hm, I guess it was nothing. I did remember everything after all.\"</span>"
		return

	var/turf/T = get_turf(M)
	T.beamin("")

	M << "<span class='danger'>You get the feeling that you're not the only one who remembered his true origin. Will they be your allies or your foes? That is for you to decide.</span>"

/proc/create_madness(var/mob/living/carbon/human/M, var/choice)
	if (M.mind.assigned_role == "Clown")
		M << "The adminbus has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself."
		M.mutations.Remove(M_CLUMSY)

	switch(choice)
		if("traitor")
			if(M.mind in ticker.mode.traitors)	return 0
			ticker.mode.traitors += M.mind
			M.mind.special_role = "traitor"
			ticker.mode.forge_traitor_objectives(M.mind)
			ticker.mode.greet_traitor(M.mind)

			var/obj/item/packobelongings/pack = new /obj/item/packobelongings(M)
			pack.name = "[M.real_name]'s belongings"

			for(var/obj/item/I in M)
				M.u_equip(I)
				if(I)
					I.loc = M.loc
					I.layer = initial(I.layer)
					I.dropped(M)
					I.loc = pack

			M.equip_to_slot_or_del(new/obj/item/device/radio/headset, slot_ears)
			M.equip_to_slot_or_del(new/obj/item/clothing/under/chameleon, slot_w_uniform)
			M.equip_to_slot_or_del(new/obj/item/clothing/shoes/syndigaloshes, slot_shoes)
			M.equip_to_slot_or_del(new/obj/item/clothing/mask/gas/voice, slot_wear_mask)
			M.equip_to_slot_or_del(new/obj/item/weapon/storage/backpack, slot_back)
			M.equip_to_slot_or_del(new/obj/item/weapon/card/id/syndicate, slot_wear_id)
			M.equip_to_slot_or_del(new/obj/item/clothing/head/helmet/space/syndicate, slot_head)
			M.equip_to_slot_or_del(new/obj/item/clothing/suit/space/syndicate, slot_wear_suit)
			M.equip_to_slot_or_del(new/obj/item/clothing/gloves/yellow, slot_gloves)
			M.equip_to_slot_or_del(new/obj/item/weapon/storage/belt/utility/complete, slot_belt)
			M.equip_to_slot_or_del(new/obj/item/weapon/tank/oxygen, slot_s_store)
			var/obj/item/device/radio/uplink/U = new/obj/item/device/radio/uplink(M)
			U.hidden_uplink.uses = 40
			M.equip_to_slot_or_del(U, slot_l_store)

			M.regenerate_icons()

			M.equip_to_slot_or_del(pack, slot_in_backpack)
			M << "Your previous belongings have been stored in your backpack."
			return 1



		if("changeling")
			if(M.mind in ticker.mode.changelings)	return 0
			ticker.mode.changelings += M.mind
			ticker.mode.grant_changeling_powers(M)
			M.mind.special_role = "Changeling"
			ticker.mode.forge_changeling_objectives(M.mind)
			ticker.mode.greet_changeling(M.mind)
			M.mind.changeling.geneticpoints = 100
			M << "<span class='danger'>You have been gifted a total of 100 evolution points to spend!</span>"
			return 1



		if("vampire")
			if(M.mind in ticker.mode.vampires)	return 0
			ticker.mode.vampires += M.mind
			ticker.mode.grant_vampire_powers(M)
			M.mind.special_role = "Vampire"
			ticker.mode.forge_vampire_objectives(M.mind)
			ticker.mode.greet_vampire(M.mind)
			M.mind.vampire.bloodtotal = 500
			M.mind.vampire.bloodusable = 500
			M.check_vampire_upgrade(M.mind)

			var/obj/item/packobelongings/pack = new /obj/item/packobelongings(M)
			pack.name = "[M.real_name]'s belongings"

			for(var/obj/item/I in M)
				M.u_equip(I)
				if(I)
					I.loc = M.loc
					I.layer = initial(I.layer)
					I.dropped(M)
					I.loc = pack

			M.equip_to_slot_or_del(new/obj/item/device/radio/headset, slot_ears)
			M.equip_to_slot_or_del(new/obj/item/clothing/under/batmansuit, slot_w_uniform)
			M.equip_to_slot_or_del(new/obj/item/weapon/storage/backpack/satchel, slot_back)
			M.equip_to_slot_or_del(new/obj/item/clothing/shoes/jackboots, slot_shoes)
			M.equip_to_slot_or_del(new/obj/item/clothing/gloves/batmangloves, slot_gloves)
			M.equip_to_slot_or_del(new/obj/item/clothing/mask/gas/death_commando, slot_wear_mask)
			M.equip_to_slot_or_del(new/obj/item/clothing/suit/hgpirate, slot_wear_suit)
			M.equip_to_slot_or_del(new/obj/item/clothing/head/chaplain_hood, slot_head)
			M.equip_to_slot_or_del(new/obj/item/weapon/tank/emergency_oxygen/double, slot_s_store)

			M.equip_to_slot_or_del(pack, slot_in_backpack)
			M << "Your previous belongings have been stored in your backpack."
			M.regenerate_icons()

			M << "<span class='danger'>You have been gifted a total of 500 usable units of blood!</span>"
			return 1



		if("cult")
			if(M.mind in ticker.mode.cult)	return 0
			ticker.mode.cult += M.mind
			ticker.mode.update_cult_icons_added(M.mind)
			M.mind.special_role = "Cultist"
			M << "<span class='sinister'>You remember the Realm of Nar-Sie, The Geometer of Blood. You now see how flimsy the world is, you see that it should be open to the knowledge of Nar-Sie.</span>"
			M << "<span class='sinister'>Assist your new compatriots in their dark dealings. Their goal is yours, and yours is theirs. You serve the Dark One above all else. Bring It back.</span>"
			var/datum/game_mode/cult/cult = ticker.mode
			if (istype(cult))
				cult.memoize_cult_objectives(M.mind)
			else
				var/explanation1 = "Check for any fellow cultist, coordinate with them."
				var/explanation2 = "Convert, soulstone, or sacrifice your foes."
				var/explanation3 = "Summon Nar-Sie."

				M << "<B>Objective #1</B>: [explanation1]"
				M.memory += "<B>Objective #1</B>: [explanation1]<BR>"

				M << "<B>Objective #2</B>: [explanation2]"
				M.memory += "<B>Objective #2</B>: [explanation2]<BR>"

				M << "<B>Objective #3</B>: [explanation3]"
				M.memory += "<B>Objective #3</B>: [explanation3]<BR>"

				M << "The convert rune is join blood self"

			var/obj/item/packobelongings/pack = new /obj/item/packobelongings(M)
			pack.name = "[M.real_name]'s belongings"

			for(var/obj/item/I in M)
				M.u_equip(I)
				if(I)
					I.loc = M.loc
					I.layer = initial(I.layer)
					I.dropped(M)
					I.loc = pack

			var/obj/item/weapon/tome/T = new/obj/item/weapon/tome(M)
			var/obj/item/weapon/paper/talisman/supply/A = new/obj/item/weapon/paper/talisman/supply(M)

			if (istype(M, /mob/living/carbon/human))
				M.equip_to_slot_or_del(new/obj/item/device/radio/headset, slot_ears)
				M.equip_to_slot_or_del(new/obj/item/clothing/under/color/black, slot_w_uniform)
				M.equip_to_slot_or_del(new/obj/item/clothing/shoes/cult, slot_shoes)
				M.equip_to_slot_or_del(new/obj/item/clothing/mask/gas/death_commando, slot_wear_mask)
				M.equip_to_slot_or_del(new/obj/item/weapon/storage/backpack/cultpack, slot_back)
				M.equip_to_slot_or_del(new/obj/item/clothing/head/helmet/space/cult, slot_head)
				M.equip_to_slot_or_del(new/obj/item/clothing/suit/space/cult, slot_wear_suit)
				M.equip_to_slot_or_del(new/obj/item/weapon/tank/emergency_oxygen/double, slot_s_store)
				M.equip_to_slot_or_del(pack, slot_in_backpack)
				M.equip_to_slot_or_del(T, slot_in_backpack)
				M.equip_to_slot_or_del(A, slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/melee/cultblade, slot_r_hand)
			else if(istype(M, /mob/living/carbon/monkey))
				var/mob/living/carbon/monkey/K = M
				var/obj/item/weapon/storage/backpack/cultpack/P = new/obj/item/weapon/storage/backpack/cultpack(K)
				K.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/death_commando(K), slot_wear_mask)
				K.equip_to_slot_or_del(P, slot_back)
				pack.loc = P
				T.loc = P
				A.loc = P
				K.equip_to_slot_or_del(new /obj/item/weapon/melee/cultblade(K), slot_r_hand)
				var/obj/item/clothing/monkeyclothes/cultrobes/JS = new /obj/item/clothing/monkeyclothes/cultrobes(K)
				var/obj/item/clothing/head/culthood/alt/CH = new /obj/item/clothing/head/culthood/alt(K)
				var/obj/item/clothing/monkeyclothes/olduniform = null
				var/obj/item/clothing/monkeyclothes/oldhat = null
				if(K.uniform)
					olduniform = K.uniform
					K.uniform = null
					olduniform.loc = pack
				K.uniform = JS
				K.uniform.loc = K
				if(K.hat)
					oldhat = K.hat
					K.hat = null
					oldhat.loc = pack
				K.hat = CH
				K.hat.loc = K

			M.regenerate_icons()

			M << "Your previous belongings have been stored in your backpack."

			if(!cultwords["travel"])
				runerandom()
			for (var/word in engwords)
				M.mind.store_memory("[cultwords[word]] is [word]<BR>")

			M << "<span class='danger'>You suddenly realize that you clearly remember every single rune word! Check your notes.</span>"

			M << "A tome, a message from your new master, appears in your backpack."

			M << "You have a talisman in your backpack, one that will help you start the cult on this station. Use it well and remember - there are others...or maybe not..."//duh
			return 1



		if("rev")
			if(M.mind in ticker.mode.head_revolutionaries)	return 0
			ticker.mode.head_revolutionaries += M.mind
			ticker.mode.update_rev_icons_added(M.mind)
			M.mind.special_role = "Head Revolutionary"
			ticker.mode.forge_revolutionary_objectives(M.mind)
			ticker.mode.greet_revolutionary(M.mind,0)

			var/obj/item/packobelongings/pack = new /obj/item/packobelongings(M)
			pack.name = "[M.real_name]'s belongings"

			for(var/obj/item/I in M)
				M.u_equip(I)
				if(I)
					I.loc = M.loc
					I.layer = initial(I.layer)
					I.dropped(M)
					I.loc = pack

			M.equip_to_slot_or_del(new/obj/item/device/radio/headset/syndicate, slot_ears)
			M.equip_to_slot_or_del(new/obj/item/clothing/under/soviet, slot_w_uniform)
			M.equip_to_slot_or_del(new/obj/item/clothing/shoes/jackboots, slot_shoes)
			M.equip_to_slot_or_del(new/obj/item/clothing/mask/cigarette/cigar/havana, slot_wear_mask)
			M.equip_to_slot_or_del(new/obj/item/weapon/storage/backpack/satchel, slot_back)
			M.equip_to_slot_or_del(new/obj/item/weapon/card/id/syndicate, slot_wear_id)
			M.equip_to_slot_or_del(new/obj/item/clothing/head/russofurhat, slot_head)
			M.equip_to_slot_or_del(new/obj/item/clothing/suit/russofurcoat, slot_wear_suit)
			M.equip_to_slot_or_del(new/obj/item/clothing/gloves/grey, slot_gloves)
			M.equip_to_slot_or_del(new/obj/item/weapon/katana, slot_belt)
			M.equip_to_slot_or_del(new/obj/item/device/flash, slot_l_store)
			M.equip_to_slot_or_del(new/obj/item/weapon/storage/box/matches, slot_r_store)
			M.regenerate_icons()
			M.equip_to_slot_or_del(new/obj/item/weapon/gun/energy/laser/LaserAK, slot_in_backpack)
			M.equip_to_slot_or_del(new/obj/item/weapon/gun/energy/laser/LaserAK, slot_in_backpack)
			M.equip_to_slot_or_del(new/obj/item/device/flash, slot_in_backpack)

			M.equip_to_slot_or_del(pack, slot_in_backpack)
			M << "Your previous belongings have been stored in your backpack."

			M << "The flash in your pocket will help you to persuade the crew to join your cause."
			return 1



		if("nuke")
			if(M.mind in ticker.mode.syndicates)	return 0
			ticker.mode.syndicates += M.mind
			ticker.mode.update_synd_icons_added(M.mind)
			M.real_name = "[syndicate_name()] Operative"
			M.mind.special_role = "Syndicate"
			M.mind.assigned_role = "MODE"
			M << "<span class='notice'>You are a [syndicate_name()] agent!</span>"
			ticker.mode.forge_syndicate_objectives(M.mind)
			ticker.mode.greet_syndicate(M.mind)

			var/obj/item/packobelongings/pack = new /obj/item/packobelongings(M)
			pack.name = "[M.real_name]'s belongings"

			for(var/obj/item/I in M)
				M.u_equip(I)
				if(I)
					I.loc = M.loc
					I.layer = initial(I.layer)
					I.dropped(M)
					I.loc = pack

			ticker.mode.equip_syndicate(M)

			M.equip_to_slot_or_del(pack, slot_in_backpack)
			M << "Your previous belongings have been stored in your backpack."

			del(M.wear_suit)
			del(M.head)
			M.equip_to_slot_or_del(new /obj/item/clothing/mask/gas/syndicate(M), slot_wear_mask)
			M.equip_to_slot_or_del(new /obj/item/clothing/suit/space/rig/syndi(M), slot_wear_suit)
			M.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/space/rig/syndi(M), slot_head)
			M.equip_to_slot_or_del(new /obj/item/weapon/pinpointer/nukeop(M), slot_r_store)
			M.equip_to_slot_or_del(new /obj/item/weapon/tank/oxygen, slot_s_store)
			var/obj/item/device/radio/uplink/U = new/obj/item/device/radio/uplink(M)
			U.hidden_uplink.uses = 40
			M.equip_to_slot_or_del(U, slot_l_store)
			M.regenerate_icons()

			M.equip_to_slot_or_del(new /obj/item/device/codebreaker, slot_in_backpack)
			M << "You have been provided with a code breaker to decipher the nuke's code, it has been placed in your backpack."
			return 1



		if("deathsquad")
			if(M.mind in ticker.mode.deathsquads)	return 0
			M.mind.assigned_role = "MODE"
			M.mind.special_role = "Death Commando"
			ticker.mode.deathsquads += M.mind

			M << "<span class='rose'>You are a rogue Death Squad agent. Your envy for powerful and exotic weapons got you caught by Centcomm when you stole their prototype Colt M1911-Pulse, and you ended up on the station by hiding on the cargo shuttle.</span>"
			M << "<span class='rose'>Now that you're trapped here, free of any supervision, you might as well put the station's chaos to your advantage, and steal as many different types of weapons as you can.</span>"

			var/explanation1 = "Disregard centcomm, aquire guns."
			var/explanation2 = "Only kill if it helps you get rare guns, or if your life is in danger"
			var/explanation3 = "You're really not eager to go back to centcomm. Do not let the shuttle get called."

			M << "<B>Objective #1</B>: [explanation1]"
			M.memory += "<B>Objective #1</B>: [explanation1]<BR>"

			M << "<B>Objective #2</B>: [explanation2]"
			M.memory += "<B>Objective #2</B>: [explanation2]<BR>"

			M << "<B>Objective #3</B>: [explanation3]"
			M.memory += "<B>Objective #3</B>: [explanation3]<BR>"

			var/obj/item/packobelongings/pack = new /obj/item/packobelongings(M)
			pack.name = "[M.real_name]'s belongings"

			for(var/obj/item/I in M)
				M.u_equip(I)
				if(I)
					I.loc = M.loc
					I.layer = initial(I.layer)
					I.dropped(M)
					I.loc = pack

			M.equip_to_slot_or_del(new/obj/item/device/radio/headset/syndicate, slot_ears)
			M.equip_to_slot_or_del(new/obj/item/clothing/under/color/green, slot_w_uniform)
			M.equip_to_slot_or_del(new/obj/item/clothing/shoes/swat, slot_shoes)
			M.equip_to_slot_or_del(new/obj/item/clothing/mask/gas/swat, slot_wear_mask)
			M.equip_to_slot_or_del(new/obj/item/weapon/storage/backpack/security, slot_back)
			M.equip_to_slot_or_del(new/obj/item/weapon/card/id/centcom, slot_wear_id)
			M.equip_to_slot_or_del(new/obj/item/clothing/head/helmet/space/deathsquad, slot_head)
			M.equip_to_slot_or_del(new/obj/item/clothing/suit/armor/swat, slot_wear_suit)
			M.equip_to_slot_or_del(new/obj/item/clothing/gloves/swat, slot_gloves)
			M.equip_to_slot_or_del(new/obj/item/weapon/gun/energy/pulse_rifle/M1911, slot_belt)
			M.equip_to_slot_or_del(new/obj/item/weapon/tank/emergency_oxygen/double, slot_s_store)
			M.equip_to_slot_or_del(new/obj/item/weapon/shield/energy, slot_l_store)
			M.equip_to_slot_or_del(new/obj/item/weapon/melee/energy/sword, slot_r_store)
			M.equip_to_slot_or_del(new/obj/item/clothing/glasses/thermal, slot_glasses)
			M.equip_to_slot_or_del(new/obj/item/weapon/storage/firstaid/adv, slot_in_backpack)
			M.equip_to_slot_or_del(new/obj/item/weapon/storage/box/flashbangs, slot_in_backpack)
			M.equip_to_slot_or_del(new/obj/item/weapon/plastique, slot_in_backpack)
			M.equip_to_slot_or_del(new/obj/item/weapon/plastique, slot_in_backpack)
			M.equip_to_slot_or_del(new/obj/item/ammo_storage/speedloader/a357, slot_in_backpack)
			M.equip_to_slot_or_del(new/obj/item/weapon/gun/projectile/mateba, slot_in_backpack)
			M.regenerate_icons()

			M.equip_to_slot_or_del(pack, slot_in_backpack)
			M << "Your previous belongings have been stored in your backpack."
			return 1



		if("wizard")
			if(M.mind in ticker.mode.wizards)	return 0
			ticker.mode.wizards += M.mind
			M.mind.special_role = "Wizard"
			M.mind.assigned_role = "MODE"
			ticker.mode.update_wizard_icons_added(M.mind)
			ticker.mode.forge_wizard_objectives(M.mind)
			ticker.mode.greet_wizard(M.mind)

			var/obj/item/packobelongings/pack = new /obj/item/packobelongings(M)
			pack.name = "[M.real_name]'s belongings"

			for(var/obj/item/I in M)
				M.u_equip(I)
				if(I)
					I.loc = M.loc
					I.layer = initial(I.layer)
					I.dropped(M)
					I.loc = pack

			if(M.gender == "male")
				M.equip_to_slot_or_del(new/obj/item/clothing/shoes/sandal, slot_shoes)
				M.equip_to_slot_or_del(new/obj/item/clothing/head/wizard, slot_head)
				M.equip_to_slot_or_del(new/obj/item/clothing/suit/wizrobe, slot_wear_suit)

				M.r_eyes = 102
				M.g_eyes = 51
				M.b_eyes = 0

				M.r_hair = 178
				M.g_hair = 178
				M.b_hair = 178

				M.r_facial = 178
				M.g_facial = 178
				M.b_facial = 178

				M.f_style = "Dwarf Beard"
				M.h_style = "Shoulder-length Hair Alt"

			if(M.gender == "female")
				M.equip_to_slot_or_del(new/obj/item/clothing/shoes/sandal/marisa, slot_shoes)
				M.equip_to_slot_or_del(new/obj/item/clothing/head/wizard/marisa, slot_head)
				M.equip_to_slot_or_del(new/obj/item/clothing/suit/wizrobe/marisa, slot_wear_suit)

				M.r_eyes = 153
				M.g_eyes = 102
				M.b_eyes = 0

				M.r_hair = 255
				M.g_hair = 255
				M.b_hair = 153

				M.r_facial = 255
				M.g_facial = 255
				M.b_facial = 153

				M.f_style = "Shaved"
				M.h_style = "Marisa"

			M.update_body()
			M.update_hair()

			M.equip_to_slot_or_del(new/obj/item/device/radio/headset, slot_ears)
			M.equip_to_slot_or_del(new/obj/item/clothing/under/lightpurple, slot_w_uniform)
			M.equip_to_slot_or_del(new/obj/item/weapon/storage/backpack/satchel, slot_back)
			M.equip_to_slot_or_del(new/obj/item/weapon/staff, slot_l_hand)
			var/obj/item/weapon/spellbook/S = new/obj/item/weapon/spellbook(M)
			S.uses = 30
			S.op = 0
			M.equip_to_slot_or_del(S, slot_r_hand)

			var/obj/item/weapon/teleportation_scroll/T = new/obj/item/weapon/teleportation_scroll(M)
			S.uses = 10
			M.equip_to_slot_or_del(T, slot_l_store)

			M << "You will find a list of available spells in your spell book. It many more spells than normal spellbooks."
			M << "In your pockets you will find a teleport scroll.It has twice as many uses as normal teleport scrolls."

			M.regenerate_icons()

			ticker.mode.update_all_wizard_icons()

			M.equip_to_slot_or_del(pack, slot_in_backpack)
			M << "Your previous belongings have been stored in your backpack."
			return 1



		if("monkey")
			if(M.monkeyizing)	return 0
			if(M.mind in ticker.mode.infected_monkeys)	return 0
			ticker.mode.infected_monkeys += M.mind
			var/mob/living/carbon/human/H = M
			var/mob/living/carbon/monkey/K = M
			M << "<span class='danger'>YOU WERE A MONKEY ALL ALONG! JUNGLE NAITO FEEVAH!</span>"
			if (istype(H))
				K = H.monkeyize()
				K.contract_disease(new /datum/disease/jungle_fever,1,0)
			else if (istype(K))
				M.contract_disease(new /datum/disease/jungle_fever,1,0)

			return 1
	return 0