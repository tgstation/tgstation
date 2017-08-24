/obj/item/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/used = 0

/obj/item/antag_spawner/proc/spawn_antag(client/C, turf/T, type = "")
	return

/obj/item/antag_spawner/proc/equip_antag(mob/target)
	return


///////////WIZARD

/obj/item/antag_spawner/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"

/obj/item/antag_spawner/contract/attack_self(mob/user)
	user.set_machine(src)
	var/dat
	if(used)
		dat = "<B>You have already summoned your apprentice.</B><BR>"
	else
		dat = "<B>Contract of Apprenticeship:</B><BR>"
		dat += "<I>Using this contract, you may summon an apprentice to aid you on your mission.</I><BR>"
		dat += "<I>If you are unable to establish contact with your apprentice, you can feed the contract back to the spellbook to refund your points.</I><BR>"
		dat += "<B>Which school of magic is your apprentice studying?:</B><BR>"
		dat += "<A href='byond://?src=\ref[src];school=destruction'>Destruction</A><BR>"
		dat += "<I>Your apprentice is skilled in offensive magic. They know Magic Missile and Fireball.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=bluespace'>Bluespace Manipulation</A><BR>"
		dat += "<I>Your apprentice is able to defy physics, melting through solid objects and travelling great distances in the blink of an eye. They know Teleport and Ethereal Jaunt.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=healing'>Healing</A><BR>"
		dat += "<I>Your apprentice is training to cast spells that will aid your survival. They know Forcewall and Charge and come with a Staff of Healing.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=robeless'>Robeless</A><BR>"
		dat += "<I>Your apprentice is training to cast spells without their robes. They know Knock and Mindswap.</I><BR>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/antag_spawner/contract/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/H = usr

	if(H.stat || H.restrained())
		return
	if(!ishuman(H))
		return 1

	if(loc == H || (in_range(src, H) && isturf(loc)))
		H.set_machine(src)
		if(href_list["school"])
			if(used)
				to_chat(H, "You already used this contract!")
				return
			var/list/candidates = pollCandidatesForMob("Do you want to play as a wizard's [href_list["school"]] apprentice?", ROLE_WIZARD, null, ROLE_WIZARD, 150, src)
			if(candidates.len)
				if(used)
					to_chat(H, "You already used this contract!")
					return
				used = 1
				var/mob/dead/observer/theghost = pick(candidates)
				spawn_antag(theghost.client, get_turf(src), href_list["school"])
				if(H && H.mind)
					SSticker.mode.update_wiz_icons_added(H.mind)
			else
				to_chat(H, "Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later.")

/obj/item/antag_spawner/contract/spawn_antag(client/C, turf/T, type = "")
	new /obj/effect/particle_effect/smoke(T)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.copy_to(M)
	M.key = C.key
	var/wizard_name = "the wizard"
	if(usr)
		wizard_name = usr.real_name
	to_chat(M, "<B>You are [wizard_name]'s apprentice! You are bound by magic contract to follow their orders and help them in accomplishing their goals.")
	switch(type)
		if("destruction")
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(null))
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/aimed/fireball(null))
			to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [wizard_name], you have learned powerful, destructive spells. You are able to cast magic missile and fireball.")
		if("bluespace")
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null))
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))
			to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [wizard_name], you have learned reality bending mobility spells. You are able to cast teleport and ethereal jaunt.")
		if("healing")
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/charge(null))
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/forcewall(null))
			M.put_in_hands_or_del(new /obj/item/gun/magic/staff/healing(M))
			to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [wizard_name], you have learned livesaving survival spells. You are able to cast charge and forcewall.")
		if("robeless")
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(null))
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mind_transfer(null))
			to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [wizard_name], you have learned stealthy, robeless spells. You are able to cast knock and mindswap.")

	equip_antag(M)
	var/wizard_name_first = pick(GLOB.wizard_first)
	var/wizard_name_second = pick(GLOB.wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	if(usr)
		var/datum/objective/protect/new_objective = new /datum/objective/protect
		new_objective.owner = M.mind
		new_objective.target = usr.mind
		new_objective.explanation_text = "Protect [usr.real_name], the wizard."
		M.mind.objectives += new_objective
	SSticker.mode.apprentices += M.mind
	M.mind.special_role = "apprentice"
	SSticker.mode.update_wiz_icons_added(M.mind)
	SEND_SOUND(M, sound('sound/effects/magic.ogg'))
	var/newname = copytext(sanitize(input(M, "You are [wizard_name]'s apprentice. Would you like to change your name to something else?", "Name change", randomname) as null|text),1,MAX_NAME_LEN)
	if (!newname)
		newname = randomname
	M.mind.name = newname
	M.real_name = newname
	M.name = newname
	M.age = rand(AGE_MIN, WIZARD_AGE_MIN - 1)
	M.dna.update_dna_identity()

/obj/item/antag_spawner/contract/equip_antag(mob/target)
	target.equip_to_slot_or_del(new /obj/item/device/radio/headset(target), slot_ears)
	target.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(target), slot_w_uniform)
	target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal/magic(target), slot_shoes)
	target.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(target), slot_wear_suit)
	target.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(target), slot_head)
	target.equip_to_slot_or_del(new /obj/item/storage/backpack(target), slot_back)
	target.equip_to_slot_or_del(new /obj/item/storage/box(target), slot_in_backpack)
	target.equip_to_slot_or_del(new /obj/item/teleportation_scroll/apprentice(target), slot_r_store)
///////////BORGS AND OPERATIVES


/obj/item/antag_spawner/nuke_ops
	name = "syndicate operative teleporter"
	desc = "A single-use teleporter designed to quickly reinforce operatives in the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/borg_to_spawn

/obj/item/antag_spawner/nuke_ops/proc/check_usability(mob/user)
	if(used)
		to_chat(user, "<span class='warning'>[src] is out of power!</span>")
		return FALSE
	if(!(user.mind in SSticker.mode.syndicates))
		to_chat(user, "<span class='danger'>AUTHENTICATION FAILURE. ACCESS DENIED.</span>")
		return FALSE
	if(user.z != ZLEVEL_CENTCOM)
		to_chat(user, "<span class='warning'>[src] is out of range! It can only be used at your base!</span>")
		return FALSE
	return TRUE


/obj/item/antag_spawner/nuke_ops/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	to_chat(user, "<span class='notice'>You activate [src] and wait for confirmation.</span>")
	var/list/nuke_candidates = pollGhostCandidates("Do you want to play as a syndicate [borg_to_spawn ? "[lowertext(borg_to_spawn)] cyborg":"operative"]?", ROLE_OPERATIVE, null, ROLE_OPERATIVE, 150, POLL_IGNORE_SYNDICATE)
	if(nuke_candidates.len)
		if(!(check_usability(user)))
			return
		used = TRUE
		var/mob/dead/observer/theghost = pick(nuke_candidates)
		spawn_antag(theghost.client, get_turf(src), "syndieborg")
		do_sparks(4, TRUE, src)
		qdel(src)
	else
		to_chat(user, "<span class='warning'>Unable to connect to Syndicate command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.</span>")

/obj/item/antag_spawner/nuke_ops/spawn_antag(client/C, turf/T)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.copy_to(M)
	M.key = C.key
	var/code = "BOMB-NOT-FOUND"
	var/obj/machinery/nuclearbomb/nuke = locate("syndienuke") in GLOB.nuke_list
	if(nuke)
		code = nuke.r_code
	M.mind.make_Nuke(null, code, 0, FALSE)
	var/newname = M.dna.species.random_name(M.gender,0,SSticker.mode.nukeops_lastname)
	M.mind.name = newname
	M.real_name = newname
	M.name = newname

//////SYNDICATE BORG
/obj/item/antag_spawner/nuke_ops/borg_tele
	name = "syndicate cyborg teleporter"
	desc = "A single-use teleporter designed to quickly reinforce operatives in the field.."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"

/obj/item/antag_spawner/nuke_ops/borg_tele/assault
	name = "syndicate assault cyborg teleporter"
	borg_to_spawn = "Assault"

/obj/item/antag_spawner/nuke_ops/borg_tele/medical
	name = "syndicate medical teleporter"
	borg_to_spawn = "Medical"

/obj/item/antag_spawner/nuke_ops/borg_tele/spawn_antag(client/C, turf/T)
	var/mob/living/silicon/robot/R
	switch(borg_to_spawn)
		if("Medical")
			R = new /mob/living/silicon/robot/syndicate/medical(T)
		else
			R = new /mob/living/silicon/robot/syndicate(T) //Assault borg by default

	var/brainfirstname = pick(GLOB.first_names_male)
	if(prob(50))
		brainfirstname = pick(GLOB.first_names_female)
	var/brainopslastname = pick(GLOB.last_names)
	if(SSticker.mode.nukeops_lastname)  //the brain inside the syndiborg has the same last name as the other ops.
		brainopslastname = SSticker.mode.nukeops_lastname
	var/brainopsname = "[brainfirstname] [brainopslastname]"

	R.mmi.name = "Man-Machine Interface: [brainopsname]"
	R.mmi.brain.name = "[brainopsname]'s brain"
	R.mmi.brainmob.real_name = brainopsname
	R.mmi.brainmob.name = brainopsname

	R.key = C.key
	R.mind.make_Nuke(null, nuke_code = null,leader=0, telecrystals = TRUE)

///////////SLAUGHTER DEMON

/obj/item/antag_spawner/slaughter_demon //Warning edgiest item in the game
	name = "vial of blood"
	desc = "A magically infused bottle of blood, distilled from countless murder victims. Used in unholy rituals to attract horrifying creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

	var/shatter_msg = "<span class='notice'>You shatter the bottle, no turning back now!</span>"
	var/veil_msg = "<span class='warning'>You sense a dark presence lurking just beyond the veil...</span>"
	var/objective_verb = "Kill"
	var/mob/living/demon_type = /mob/living/simple_animal/slaughter


/obj/item/antag_spawner/slaughter_demon/attack_self(mob/user)
	if(user.z != ZLEVEL_STATION)
		to_chat(user, "<span class='notice'>You should probably wait until you reach the station.</span>")
		return
	if(used)
		return
	var/list/demon_candidates = pollCandidatesForMob("Do you want to play as a [initial(demon_type.name)]?", null, null, ROLE_ALIEN, 50, src)
	if(demon_candidates.len)
		if(used)
			return
		used = 1
		var/mob/dead/observer/theghost = pick(demon_candidates)
		spawn_antag(theghost.client, get_turf(src), initial(demon_type.name))
		to_chat(user, shatter_msg)
		to_chat(user, veil_msg)
		playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
		qdel(src)
	else
		to_chat(user, "<span class='notice'>You can't seem to work up the nerve to shatter the bottle. Perhaps you should try again later.</span>")


/obj/item/antag_spawner/slaughter_demon/spawn_antag(client/C, turf/T, type = "")

	var /obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(T)
	var/mob/living/simple_animal/slaughter/S = new demon_type(holder)
	S.holder = holder
	S.key = C.key
	S.mind.assigned_role = S.name
	S.mind.special_role = S.name
	SSticker.mode.traitors += S.mind
	var/datum/objective/assassinate/new_objective
	if(usr)
		new_objective = new /datum/objective/assassinate
		new_objective.owner = S.mind
		new_objective.target = usr.mind
		new_objective.explanation_text = "[objective_verb] [usr.real_name], the one who summoned you."
		S.mind.objectives += new_objective
	var/datum/objective/new_objective2 = new /datum/objective
	new_objective2.owner = S.mind
	new_objective2.explanation_text = "[objective_verb] everyone[usr ? " else while you're at it":""]."
	S.mind.objectives += new_objective2
	to_chat(S, S.playstyle_string)
	to_chat(S, "<B>You are currently not currently in the same plane of existence as the station. \
	Ctrl+Click a blood pool to manifest.</B>")
	if(new_objective)
		to_chat(S, "<B>Objective #[1]</B>: [new_objective.explanation_text]")
	to_chat(S, "<B>Objective #[new_objective ? "[2]":"[1]"]</B>: [new_objective2.explanation_text]")

/obj/item/antag_spawner/slaughter_demon/laughter
	name = "vial of tickles"
	desc = "A magically infused bottle of clown love, distilled from countless hugging attacks. Used in funny rituals to attract adorable creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"
	color = "#FF69B4" // HOT PINK

	veil_msg = "<span class='warning'>You sense an adorable presence lurking just beyond the veil...</span>"
	objective_verb = "Hug and Tickle"
	demon_type = /mob/living/simple_animal/slaughter/laughter
