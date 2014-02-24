/obj/item/weapon/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/used = 0

/obj/item/weapon/antag_spawner/proc/spawn_antag(var/client/C, var/turf/T, var/type = "")
	return

/obj/item/weapon/antag_spawner/proc/equip_antag(mob/target as mob)
	return

/obj/item/weapon/antag_spawner/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"

/obj/item/weapon/antag_spawner/contract/attack_self(mob/user as mob)
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
			var/list/candidates = get_candidates(BE_WIZARD)
			if(candidates.len)
				src.used = 1
				var/client/C = pick(candidates)
				spawn_antag(C, get_turf(H.loc), href_list["school"])
			else
				H << "Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later."

/obj/item/weapon/antag_spawner/contract/spawn_antag(var/client/C, var/turf/T, var/type = "")
	new /obj/effect/effect/harmless_smoke(T)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	M.key = C.key
	M << "<B>You are the [usr.real_name]'s apprentice! You are bound by magic contract to follow their orders and help them in accomplishing their goals."
	switch(type)
		if("destruction")
			M.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(null)
			M.mind.spell_list += new /obj/effect/proc_holder/spell/dumbfire/fireball(null)
			M << "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned powerful, destructive spells. You are able to cast magic missile and fireball."
		if("bluespace")
			M.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(null)
			M.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(null)
			M << "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned reality bending mobility spells. You are able to cast teleport and ethereal jaunt."
		if("healing")
			M.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/charge(null)
			M.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/conjure/forcewall(null)
			M.equip_to_slot_or_del(new /obj/item/weapon/gun/magic/staff/healing(M), slot_r_hand)
			M << "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned livesaving survival spells. You are able to cast charge and forcewall."
		if("robeless")
			M.mind.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/knock(null)
			M.mind.spell_list += new /obj/effect/proc_holder/spell/targeted/mind_transfer(null)
			M << "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned stealthy, robeless spells. You are able to cast knock and mindswap."

	equip_antag(M)
	var/wizard_name_first = pick(wizard_first)
	var/wizard_name_second = pick(wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	var/newname = copytext(sanitize(input(M, "You are the wizard's apprentice. Would you like to change your name to something else?", "Name change", randomname) as null|text),1,MAX_NAME_LEN)
	if (!newname)
		newname = randomname
	M.mind.name = newname
	M.real_name = newname
	M.name = newname
	var/datum/objective/protect/new_objective = new /datum/objective/protect
	new_objective.owner = M:mind
	new_objective:target = usr:mind
	new_objective.explanation_text = "Protect [usr.real_name], the wizard."
	M.mind.objectives += new_objective
	ticker.mode.traitors += M.mind
	M.mind.special_role = "apprentice"

/obj/item/weapon/antag_spawner/contract/equip_antag(mob/target as mob)
	target.equip_to_slot_or_del(new /obj/item/device/radio/headset(target), slot_ears)
	target.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(target), slot_w_uniform)
	target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(target), slot_shoes)
	target.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(target), slot_wear_suit)
	target.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(target), slot_head)
	target.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(target), slot_back)
	target.equip_to_slot_or_del(new /obj/item/weapon/storage/box(target), slot_in_backpack)
	target.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll/apprentice(target), slot_r_store)

/obj/item/weapon/antag_spawner/borg_tele
	name = "Syndicate Cyborg Teleporter"
	desc = "A single-use teleporter used to deploy a Syndicate Cyborg on the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/TC_cost = 0

/obj/item/weapon/antag_spawner/borg_tele/attack_self(mob/user as mob)
	if(used)
		user << "The teleporter is out of power."
		return
	var/list/borg_candicates = get_candidates(BE_OPERATIVE)
	if(borg_candicates.len > 0)
		used = 1
		var/client/C = pick(borg_candicates)
		spawn_antag(C, get_turf(src.loc), "syndieborg")
	else
		user << "<span class='notice'>Unable to connect to Syndicate Command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.</span>"

/obj/item/weapon/antag_spawner/borg_tele/spawn_antag(var/client/C, var/turf/T, var/type = "")
	var/datum/effect/effect/system/spark_spread/S = new /datum/effect/effect/system/spark_spread
	S.set_up(4, 1, src)
	S.start()
	var/mob/living/silicon/robot/R = new /mob/living/silicon/robot/syndicate(T)
	R.key = C.key
	ticker.mode.syndicates += R.mind
	ticker.mode.update_synd_icons_added(R.mind)
	R.mind.special_role = "syndicate"
	R.faction = "syndicate"