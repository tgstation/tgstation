/obj/item/device/vigilante_tool
	name = "Vigilant's Companion"
	desc = "A reverse-engineered gang tool designed by Nanotrasen to encourage crew to resist gang activity."
	icon_state = "gangtool-white"
	item_state = "walkietalkie"
	w_class = WEIGHT_CLASS_TINY
	origin_tech = "programming=5;bluespace=2"
	var/datum/action/innate/vigilante_tool/linked_action
	var/points = 0
	var/list/tags = list()
	var/vig_item_list
	var/vig_category_list
	var/static/gang = "Vigilante"
	var/static/list/vigilante_items = list(
		/datum/gang_item/function/implant,
		/datum/gang_item/weapon/hatchet,
		/datum/gang_item/weapon/pitchfork,
		/datum/gang_item/weapon/improvised,
		/datum/gang_item/weapon/ammo/buckshot_ammo,
		/datum/gang_item/weapon/surgood,
		/datum/gang_item/weapon/ammo/surplus_ammo,
		/datum/gang_item/weapon/auto,
		/datum/gang_item/weapon/ammo/auto_ammo,
		/datum/gang_item/weapon/ammo/auto_ammo_AP,
		/datum/gang_item/weapon/riot,
		/datum/gang_item/weapon/ammo/buckshot_ammo,
		/datum/gang_item/weapon/launcher,
		/datum/gang_item/equipment/sechuds,
		/datum/gang_item/equipment/sharpener,
		/datum/gang_item/equipment/brutepack,
		/datum/gang_item/equipment/shield,
		/datum/gang_item/equipment/bulletproof_armor,
		/datum/gang_item/equipment/bulletproof_helmet,
		/datum/gang_item/equipment/gangbreaker,
		/datum/gang_item/equipment/seraph
		)

/obj/item/device/vigilante_tool/Initialize()
	. = ..()
	if(ismob(loc))
		vig_item_list = list()
		vig_category_list = list()
		for(var/V in vigilante_items)
			var/datum/gang_item/G = new V()
			vig_item_list[G.id] = G
			var/list/Cat = vig_category_list[G.category]
			if(Cat)
				Cat += G
			else
				vig_category_list[G.category] = list(G)
		var/mob/living/M = loc
		linked_action = new(src)
		linked_action.Grant(M, src)
		addtimer(CALLBACK(src, .proc/earnings), 1500, TIMER_UNIQUE)
	else
		return INITIALIZE_HINT_QDEL

/obj/item/device/vigilante_tool/Destroy()
	var/mob/living/M = loc
	linked_action.Remove(M)
	M.update_icons()
	return ..()

/obj/item/device/vigilante_tool/proc/earnings()
	var/all_territory = list()
	var/newpoints = 0
	var/mob/living/carbon/human/H = loc
	for(var/datum/gang/G in SSticker.mode.gangs)
		all_territory += G.territory
	for(var/area/A in tags)
		if(!(A in all_territory))
			newpoints += 0.5
	to_chat(H, "<span class='notice'>You have received 3 influence for your continued loyalty, [newpoints] for keeping the station tag-free.")
	points += newpoints + 3
	for(var/obj/item/weapon/implant/mindshield/I in H.implants)
		points += 3
		to_chat(H, "<span class='notice'>You have also received 3 influence for possessing a mindshield implant.</span>")
	addtimer(CALLBACK(src, .proc/earnings), 1500, TIMER_UNIQUE)

/obj/item/device/vigilante_tool/attack_self(mob/user)
	if(user.mind in SSticker.mode.get_all_gangsters())
		return
	var/list/dat = list()
	dat += "Your Influence: <B>[points]</B><br>"
	dat += "<center><a href='?src=\ref[src];destroy=TRUE'><B>DESTROY HELD CONTRABAND</a></center></B><br>"
	dat += "<hr>"
	for(var/cat in vig_category_list)
		dat += "<b>[cat]</b><br>"
		for(var/V in vig_category_list[cat])
			var/datum/gang_item/G = V
			var/cost = G.get_cost_display(user, gang, src)
			if(cost)
				dat += cost + " "
			var/toAdd = G.get_name_display(user, gang, src)
			if(G.can_buy(user, gang, src))
				toAdd = "<a href='?src=\ref[src];purchase=[G.id]'>[toAdd]</a>"
			dat += toAdd
			var/extra = G.get_extra_info(user, gang, src)
			if(extra)
				dat += "<br><i>[extra]</i>"
			dat += "<br>"
		dat += "<br>"

	dat += "<a href='?src=\ref[src];choice=refresh'>Refresh</a><br>"

	var/datum/browser/popup = new(user, "gangtool", "Welcome to Vigilante's Companion v1.2", 400, 750)
	dat.Join()
	popup.open()



/obj/item/device/vigilante_tool/Topic(href, href_list)
	if(usr.incapacitated())
		return 0
	if(href_list["purchase"])
		var/datum/gang_item/G = vig_item_list[href_list["purchase"]]
		if(G && G.can_buy(usr, gang, src))
			G.purchase(usr, gang, src, FALSE)
	if(href_list["destroy"])
		Destroy_Contraband(usr)
	attack_self(usr)

/obj/item/device/vigilante_tool/proc/Destroy_Contraband(mob/living/user)
	var/obj/item/I = user.get_active_held_item()
	var/value
	if(QDELETED(I))
		to_chat(user, "<span class='notice'>No item detected.</span>")
		return
	switch(I.type)
		if(/obj/item/weapon/gun/ballistic/automatic/pistol)
			value = 20
		if(/obj/item/weapon/implanter/gang)
			value = 12
		if(/obj/item/weapon/reagent_containers/syringe/stimulants)
			var/obj/item/weapon/reagent_containers/syringe/stimulants/S
			if(S.list_reagents.len)
				value = 10
			else
				value = 2
		if(/obj/item/weapon/grenade/plastic/c4)
			value = 5
		if(/obj/item/toy/crayon/spraycan/gang)
			var/obj/item/toy/crayon/spraycan/gang/SC = I
			value = 1 + round(SC.charges/9)
		if(/obj/item/weapon/grenade/syndieminibomb/concussion/frag)
			value = 13
		if(/obj/item/clothing/shoes/combat/gang)
			value = 9
		if(/obj/item/weapon/pen/gang)
			value = 17
		if(/obj/item/weapon/reviver)
			value = 10
		if(/obj/item/weapon/reagent_containers/pill/patch/gang)
			value = 4
		if(/obj/item/device/gangtool)
			value = 20
		if(/obj/item/clothing/glasses/hud/security/chameleon)
			value = 5
		if(/obj/item/weapon/gun/ballistic/automatic/mini_uzi)
			value = 30
		if(/obj/item/weapon/gun/ballistic/automatic/sniper_rifle)
			value = 20
		if(/obj/item/ammo_box/magazine/sniper_rounds)
			value = 5
		if(/obj/item/weapon/gun/ballistic/shotgun/lethal)
			value = 20
		if(/obj/item/weapon/gun/ballistic/automatic/surplus/gang)
			value = 8
		if(/obj/item/weapon/throwing_star)
			value = 3
		if(/obj/item/weapon/switchblade)
			value = 5
		if(/obj/item/weapon/storage/belt/military/gang)
			value = 8
		if(/obj/item/clothing/gloves/gang)
			value = 8
		if(/obj/item/clothing/neck/necklace/dope)
			value = 6
		if(/obj/item/clothing/shoes/gang)
			value = 14
		if(/obj/item/clothing/mask/gskull)
			value = 11
		if(/obj/item/clothing/head/collectable/petehat/gang)
			value = 10
	if(istype(I, /obj/item/clothing))
		for(var/datum/gang/G in SSticker.mode.gangs)
			if(I.type == G.outer_outfit && I.armor["bullet"]>=35)
				value = 5
	if(!value)
		to_chat(user, "<span class='notice'> No contraband detected!</span>")
		return
	playsound(src, 'sound/items/poster_being_created.ogg', 75, 1)
	if(do_after(user, 20, TRUE, I))
		points += value
		to_chat(user, "<span class='notice'>[I] has been processed for [value] influence.")
		qdel(I)



/datum/action/innate/vigilante_tool
	name = "Vigilante's Reverse-Engineered Gangtool"
	desc = "An implanted tool that lets you purchase gear"
	background_icon_state = "bg_default_on"
	button_icon_state = "bolt_action"
	var/obj/item/device/vigilante_tool/VT

/datum/action/innate/vigilante_tool/Grant(mob/user, obj/reg)
	. = ..()
	VT = reg
	user.update_icons()


/datum/action/innate/vigilante_tool/Activate()
	VT.attack_self(owner)

