
/////////Apprentice Contract//////////

/obj/item/weapon/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	throw_speed = 1
	throw_range = 5
	w_class = 1.0
	var/used = 0
	flags = FPRINT | TABLEPASS


/obj/item/weapon/contract/attack_self(mob/user as mob)
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
		dat += "<A href='byond://?src=\ref[src];school=robeless'>Robeless</A><BR>"
		dat += "<I>Your apprentice is training to cast spells without their robes. They know Knock and Mindswap.</I><BR>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return


/obj/item/weapon/contract/Topic(href, href_list)
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
				new /obj/effect/effect/harmless_smoke(H.loc)
				var/mob/living/carbon/human/M = new/mob/living/carbon/human(H.loc)
				M.key = C.key
				M << "<B>You are the [H.real_name]'s apprentice! You are bound by magic contract to follow their orders and help them in accomplishing their goals."
				switch(href_list["school"])
					if("destruction")
						M.spell_list += new /obj/effect/proc_holder/spell/targeted/projectile/magic_missile(M)
						M.spell_list += new /obj/effect/proc_holder/spell/dumbfire/fireball(M)
						M << "<B>Your service has not gone unrewarded, however. Studying under [H.real_name], you have learned powerful, destructive spells. You are able to cast magic missile and fireball."
					if("bluespace")
						M.spell_list += new /obj/effect/proc_holder/spell/targeted/area_teleport/teleport(M)
						M.spell_list += new /obj/effect/proc_holder/spell/targeted/ethereal_jaunt(M)
						M << "<B>Your service has not gone unrewarded, however. Studying under [H.real_name], you have learned reality bending mobility spells. You are able to cast teleport and ethereal jaunt."
					if("robeless")
						M.spell_list += new /obj/effect/proc_holder/spell/aoe_turf/knock(M)
						M.spell_list += new /obj/effect/proc_holder/spell/targeted/mind_transfer(M)
						M << "<B>Your service has not gone unrewarded, however. Studying under [H.real_name], you have learned stealthy, robeless spells. You are able to cast knock and mindswap."
				M.equip_to_slot_or_del(new /obj/item/device/radio/headset(M), slot_ears)
				M.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(M), slot_w_uniform)
				M.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(M), slot_shoes)
				M.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(M), slot_wear_suit)
				M.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(M), slot_head)
				M.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(M), slot_back)
				M.equip_to_slot_or_del(new /obj/item/weapon/storage/box(M), slot_in_backpack)
				M.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll/apprentice(M), slot_r_store)
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
				new_objective:target = H:mind
				new_objective.explanation_text = "Protect [H.real_name], the wizard."
				M.mind.objectives += new_objective
				ticker.mode.traitors += M.mind
				M.mind.special_role = "apprentice"

			else
				H << "Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later."
	return


///////////////////////////Veil Render//////////////////////

/obj/item/weapon/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	flags = FPRINT | TABLEPASS
	force = 15
	throwforce = 10
	w_class = 3
	var/charged = 1

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now"
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = 1
	unacidable = 1
	anchored = 1.0

/obj/effect/rend/New()
	spawn(50)
		new /obj/machinery/singularity/narsie/wizard(get_turf(src))
		del(src)
		return
	return

/obj/item/weapon/veilrender/attack_self(mob/user as mob)
	if(charged == 1)
		new /obj/effect/rend(get_turf(usr))
		charged = 0
		visible_message("\red <B>[src] hums with power as [usr] deals a blow to reality itself!</B>")
	else
		user << "\red The unearthly energies that powered the blade are now dormant."



/obj/item/weapon/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."

/obj/item/weapon/veilrender/vealrender/attack_self(mob/user as mob)
	if(charged)
		new /obj/effect/rend/cow(get_turf(usr))
		charged = 0
		visible_message("\red <B>[src] hums with power as [usr] deals a blow to hunger itself!</B>")
	else
		user << "\red The unearthly energies that powered the blade are now dormant."

/obj/effect/rend/cow
	desc = "Reverberates with the sound of ten thousand moos."
	var/cowsleft = 20

/obj/effect/rend/cow/New()
	processing_objects.Add(src)
	return

/obj/effect/rend/cow/process()
	if(locate(/mob) in loc) return
	new /mob/living/simple_animal/cow(loc)
	cowsleft--
	if(cowsleft <= 0)
		del src

/obj/effect/rend/cow/attackby(obj/item/I as obj, mob/user as mob)
	if(istype(I, /obj/item/weapon/nullrod))
		visible_message("\red <b>[I] strikes a blow against \the [src], banishing it!</b>")
		spawn(1)
			del src
		return
	..()


/////////////////////////////////////////Scrying///////////////////

/obj/item/weapon/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, staring into it gives you vision beyond mortal means."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 7
	throw_range = 15
	throwforce = 15
	damtype = BURN
	force = 15
	flags = FPRINT | TABLEPASS
	hitsound = 'sound/items/welder2.ogg'

/obj/item/weapon/scrying/attack_self(mob/user as mob)
	user << "\blue You can see...everything!"
	visible_message("\red <B>[usr] stares into [src], their eyes glazing over.</B>")
	user.ghostize(1)
	return