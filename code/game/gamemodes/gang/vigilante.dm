/obj/item/device/vigilante_tool
	name = "reverse-engineered device"
	desc = "A strange device of sorts. Hard to really make out what it actually does if you don't know how to operate it."
	icon_state = "gangtool-white"
	item_state = "walkietalkie"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	origin_tech = "programming=5;bluespace=2"
	var/datum/gang/gang //Which gang uses this?
	var/points = 0
	var/list/tags = list()
	var/vig_item_list
	var/vig_category_list
	var/static/gang = "Vigilante"
	var/static/list/vigilante_items = list(
	  	/datum/gang_item/weapon/shuriken,
		/datum/gang_item/weapon/switchblade,
		/datum/gang_item/weapon/improvised,
		/datum/gang_item/weapon/ammo/improvised_ammo,
		/datum/gang_item/weapon/surplus,
		/datum/gang_item/weapon/ammo/surplus_ammo,
		/datum/gang_item/weapon/sniper,
		/datum/gang_item/weapon/ammo/sniper_ammo,
		/datum/gang_item/equipment/sharpener,
		/datum/gang_item/equipment/spraycan,
		/datum/gang_item/equipment/sharpener,
		/datum/gang_item/equipment/frag,
		/datum/gang_item/equipment/stimpack,
		/datum/gang_item/equipment/implant_breaker
		)

/obj/item/device/vigilante_tool/New()
	vig_item_list = list()
	vig_category_list = list()
	for(var/V in vigilante_items)
		var/datum/gang_item/G = new V()
		vig_item_list[G.id] = G
		var/list/Cat = vig_category_list[G.category]
		if(Cat)
			Cat += G
		else
			reg_category_list[G.category] = list(G)


/obj/item/device/vigilante_tool/attack_self(mob/user)
	if(user.mind in SSticker.mode.get_all_gangsters())
		return
	var/dat
	dat += "Your Influence: <B>[points]</B><br>"
	dat += "<hr>"
	for(var/cat in vig_category_lis)
		dat += "<b>[cat]</b><br>"
		for(var/V in gang.boss_category_list[cat])
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
	if(!can_use(usr))
		return
	if(href_list["purchase"])
		var/datum/gang_item/G = gang.reg_item_list[href_list["purchase"]]
		if(G && G.can_buy(usr, gang, src))
			G.purchase(usr, gang, src, FALSE)
	attack_self(usr)







/datum/action/innate/vigilante/tool
	name = "Vigilante's Reverse-Engineered Gangtool"
	desc = "An implanted tool that lets you purchase gear"
	background_icon_state = "bg_default_on"
	button_icon_state = "bolt_action"
	var/obj/item/device/vigilante_tool = VT

/datum/action/innate/gang/tool/Grant(mob/user, obj/reg)
	. = ..()
	VT = reg


/datum/action/innate/vigilante/tool/Activate()
	VT.attack_self(owner)

