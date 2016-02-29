/obj/item/weapon/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = 1
	var/used = 0

/obj/item/weapon/antag_spawner/proc/spawn_antag(client/C, turf/T, type = "")
	return

/obj/item/weapon/antag_spawner/proc/equip_antag(mob/target)
	return


///////////WIZARD

/obj/item/weapon/antag_spawner/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"

/obj/item/weapon/antag_spawner/contract/attack_self(mob/user)
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

/obj/item/weapon/antag_spawner/contract/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/H = usr

	if(H.stat || H.restrained())
		return
	if(!istype(H, /mob/living/carbon/human))
		return 1

	if(loc == H || (in_range(src, H) && istype(loc, /turf)))
		H.set_machine(src)
		if(href_list["school"])
			if (used)
				H << "You already used this contract!"
				return
			var/list/candidates = get_candidates(ROLE_WIZARD)
			if(candidates.len)
				src.used = 1
				var/client/C = pick(candidates)
				spawn_antag(C, get_turf(H.loc), href_list["school"])
				if(H.mind)
					ticker.mode.update_wiz_icons_added(H.mind)
			else
				H << "Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later."

/obj/item/weapon/antag_spawner/contract/spawn_antag(client/C, turf/T, type = "")
	PoolOrNew(/obj/effect/particle_effect/smoke, T)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.copy_to(M)
	M.key = C.key
	M << "<B>You are the [usr.real_name]'s apprentice! You are bound by magic contract to follow their orders and help them in accomplishing their goals."
	switch(type)
		if("destruction")
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(null))
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/dumbfire/fireball(null))
			M << "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned powerful, destructive spells. You are able to cast magic missile and fireball."
		if("bluespace")
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null))
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null))
			M << "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned reality bending mobility spells. You are able to cast teleport and ethereal jaunt."
		if("healing")
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/charge(null))
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/forcewall(null))
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/magic/staff/healing(M), slot_r_hand)
			M << "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned livesaving survival spells. You are able to cast charge and forcewall."
		if("robeless")
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/knock(null))
			M.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/mind_transfer(null))
			M << "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned stealthy, robeless spells. You are able to cast knock and mindswap."

	equip_antag(M)
	var/wizard_name_first = pick(wizard_first)
	var/wizard_name_second = pick(wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	var/datum/objective/protect/new_objective = new /datum/objective/protect
	new_objective.owner = M:mind
	new_objective:target = usr:mind
	new_objective.explanation_text = "Protect [usr.real_name], the wizard."
	M.mind.objectives += new_objective
	ticker.mode.apprentices += M.mind
	M.mind.special_role = "apprentice"
	ticker.mode.update_wiz_icons_added(M.mind)
	M << sound('sound/effects/magic.ogg')
	var/newname = copytext(sanitize(input(M, "You are the wizard's apprentice. Would you like to change your name to something else?", "Name change", randomname) as null|text),1,MAX_NAME_LEN)
	if (!newname)
		newname = randomname
	M.mind.name = newname
	M.real_name = newname
	M.name = newname
	M.dna.update_dna_identity()

/obj/item/weapon/antag_spawner/contract/equip_antag(mob/target)
	target.equip_to_slot_or_del(new /obj/item/device/radio/headset(target), slot_ears)
	target.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(target), slot_w_uniform)
	target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(target), slot_shoes)
	target.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(target), slot_wear_suit)
	target.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(target), slot_head)
	target.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(target), slot_back)
	target.equip_to_slot_or_del(new /obj/item/weapon/storage/box(target), slot_in_backpack)
	target.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll/apprentice(target), slot_r_store)
///////////BORGS AND OPERATIVES


/obj/item/weapon/antag_spawner/nuke_ops
	name = "syndicate operative teleporter"
	desc = "A single-use teleporter designed to quickly reinforce operatives in the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/borg_to_spawn
	var/list/possible_types = list("Assault", "Medical")

/obj/item/weapon/antag_spawner/nuke_ops/proc/check_usability(mob/user)
	if(used)
		user << "<span class='warning'>[src] is out of power!</span>"
		return 0
	if(!(user.mind in ticker.mode.syndicates))
		user << "<span class='danger'>AUTHENTICATION FAILURE. ACCESS DENIED.</span>"
		return 0
	if(user.z != ZLEVEL_CENTCOM)
		user << "<span class='warning'>[src] is out of range! It can only be used at your base!</span>"
		return 0
	return 1


/obj/item/weapon/antag_spawner/nuke_ops/attack_self(mob/user)
	if(!(check_usability(user)))
		return

	var/list/nuke_candidates = get_candidates(ROLE_OPERATIVE, 3000, "operative")
	if(nuke_candidates.len > 0)
		used = 1
		var/client/C = pick(nuke_candidates)
		spawn_antag(C, get_turf(src.loc), "syndieborg")
		var/datum/effect_system/spark_spread/S = new /datum/effect_system/spark_spread
		S.set_up(4, 1, src)
		S.start()
		qdel(src)
	else
		user << "<span class='warning'>Unable to connect to Syndicate command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.</span>"

/obj/item/weapon/antag_spawner/nuke_ops/spawn_antag(client/C, turf/T)
	var/new_op_code = "Ask your leader!"
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	C.prefs.copy_to(M)
	M.key = C.key
	var/obj/machinery/nuclearbomb/nuke = locate("syndienuke") in nuke_list
	if(nuke)
		new_op_code = nuke.r_code
	M.mind.make_Nuke(T, new_op_code, 0, FALSE)
	var/newname = M.dna.species.random_name(M.gender,0,ticker.mode.nukeops_lastname)
	M.mind.name = newname
	M.real_name = newname
	M.name = newname



//////SYNDICATE BORG
/obj/item/weapon/antag_spawner/nuke_ops/borg_tele
	name = "syndicate cyborg teleporter"
	desc = "A single-use teleporter designed to quickly reinforce operatives in the field.."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"


/obj/item/weapon/antag_spawner/nuke_ops/borg_tele/attack_self(mob/user)
	borg_to_spawn = input("What type?", "Cyborg Type", type) as null|anything in possible_types
	if(!borg_to_spawn)
		return
	..()

/obj/item/weapon/antag_spawner/nuke_ops/borg_tele/spawn_antag(client/C, turf/T)
	var/mob/living/silicon/robot/R
	switch(borg_to_spawn)
		if("Medical")
			R = new /mob/living/silicon/robot/syndicate/medical(T)
		else
			R = new /mob/living/silicon/robot/syndicate(T) //Assault borg by default

	var/brainfirstname = pick(first_names_male)
	if(prob(50))
		brainfirstname = pick(first_names_female)
	var/brainopslastname = pick(last_names)
	if(ticker.mode.nukeops_lastname)  //the brain inside the syndiborg has the same last name as the other ops.
		brainopslastname = ticker.mode.nukeops_lastname
	var/brainopsname = "[brainfirstname] [brainopslastname]"

	R.mmi.name = "Man-Machine Interface: [brainopsname]"
	R.mmi.brain.name = "[brainopsname]'s brain"
	R.mmi.brainmob.real_name = brainopsname
	R.mmi.brainmob.name = brainopsname

	R.key = C.key
	ticker.mode.syndicates += R.mind
	ticker.mode.update_synd_icons_added(R.mind)
	R.mind.special_role = "syndicate"
	R.faction = list("syndicate")



///////////SLAUGHTER DEMON

/obj/item/weapon/antag_spawner/slaughter_demon //Warning edgiest item in the game
	name = "vial of blood"
	desc = "A magically infused bottle of blood, distilled from countless murder victims. Used in unholy rituals to attract horrifying creatures."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"


/obj/item/weapon/antag_spawner/slaughter_demon/attack_self(mob/user)
	var/list/demon_candidates = get_candidates(ROLE_ALIEN)
	if(user.z != 1)
		user << "<span class='notice'>You should probably wait until you reach the station.</span>"
		return
	if(demon_candidates.len > 0)
		used = 1
		var/client/C = pick(demon_candidates)
		spawn_antag(C, get_turf(src.loc), "Slaughter Demon")
		user << "<span class='notice'>You shatter the bottle, no turning back now!</span>"
		user << "<span class='notice'>You sense a dark presence lurking just beyond the veil...</span>"
		playsound(user.loc, 'sound/effects/Glassbr1.ogg', 100, 1)
		qdel(src)
	else
		user << "<span class='notice'>You can't seem to work up the nerve to shatter the bottle. Perhaps you should try again later.</span>"


/obj/item/weapon/antag_spawner/slaughter_demon/spawn_antag(client/C, turf/T, type = "")

	var /obj/effect/dummy/slaughter/holder = PoolOrNew(/obj/effect/dummy/slaughter,T)
	var/mob/living/simple_animal/slaughter/S = new /mob/living/simple_animal/slaughter/(holder)
	S.holder = holder
	S.key = C.key
	S.mind.assigned_role = "Slaughter Demon"
	S.mind.special_role = "Slaughter Demon"
	ticker.mode.traitors += S.mind
	var/datum/objective/assassinate/new_objective = new /datum/objective/assassinate
	new_objective.owner = S.mind
	new_objective.target = usr.mind
	new_objective.explanation_text = "Kill [usr.real_name], the one who summoned you."
	S.mind.objectives += new_objective
	var/datum/objective/new_objective2 = new /datum/objective
	new_objective2.owner = S.mind
	new_objective2.explanation_text = "Kill everyone else while you're at it."
	S.mind.objectives += new_objective2
	S << S.playstyle_string
	S << "<B>You are currently not currently in the same plane of existence as the station. Ctrl+Click a blood pool to manifest.</B>"
	S << "<B>Objective #[1]</B>: [new_objective.explanation_text]"
	S << "<B>Objective #[2]</B>: [new_objective2.explanation_text]"
