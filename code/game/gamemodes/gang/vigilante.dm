/obj/item/device/vigilante_tool
	name = "Vigilant's Companion"
	desc = "A reverse-engineered gang tool designed by Nanotrasen to encourage crew to resist gang activity."
	icon_state = "gangtool-white"
	item_state = "walkietalkie"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	origin_tech = "programming=5;bluespace=2"
//	var/datum/gang/gang
	var/points = 0
	var/list/tags = list()
	var/vig_item_list
	var/vig_category_list
	var/static/gang = "Vigilante"
	var/static/list/vigilante_items = list(
		/datum/gang_item/function/implant,
		/datum/gang_item/weapon/hatchet,
		/datum/gang_item/weapon/pitchfork,
		/datum/gang_item/weapon/surgood,
		/datum/gang_item/weapon/ammo/surplus_ammo,
		/datum/gang_item/weapon/riot,
		/datum/gang_item/weapon/ammo/buckshot_ammo,
		/datum/gang_item/weapon/auto,
		/datum/gang_item/weapon/ammo/auto_ammo,
		/datum/gang_item/weapon/ammo/auto_ammo_AP,
		/datum/gang_item/equipment/sharpener,
		/datum/gang_item/equipment/brutepatch,
		/datum/gang_item/equipment/shield,
		/datum/gang_item/equipment/bulletproof_armor,
		/datum/gang_item/equipment/bulletproof_helmet,
		/datum/gang_item/equipment/gangbreaker
		)

/obj/item/device/vigilante_tool/New(mob/user)
	var/datum/action/innate/vigilante_tool/VT = new
	VT.Grant(user, src)
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


/obj/item/device/vigilante_tool/attack_self(mob/user)
	if(user.mind in SSticker.mode.get_all_gangsters())
		return
	var/dat
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

	var/datum/browser/popup = new(user, "gangtool", "Welcome to Vigilante's Companion v1.1", 340, 625)
	popup.set_content(dat)
	popup.open()



/obj/item/device/vigilante_tool/Topic(href, href_list)
	if(href_list["purchase"])
		var/datum/gang_item/G = vig_item_list[href_list["purchase"]]
		if(G && G.can_buy(usr, gang, src))
			G.purchase(usr, gang, src, FALSE)
	if(href_list["destroy"])
		if(do_after(usr, 50, target = get_turf(usr)))
			world << "Good job"
	attack_self(usr)





/datum/action/innate/vigilante_tool
	name = "Vigilante's Reverse-Engineered Gangtool"
	desc = "An implanted tool that lets you purchase gear"
	background_icon_state = "bg_default_on"
	button_icon_state = "bolt_action"
	var/obj/item/device/vigilante_tool/VT

/datum/action/innate/vigilante_tool/Grant(mob/user, obj/reg)
	. = ..()
	VT = reg


/datum/action/innate/vigilante_tool/Activate()
	VT.attack_self(owner)

