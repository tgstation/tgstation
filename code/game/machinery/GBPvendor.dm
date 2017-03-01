
/obj/machinery/GBP_vendor
	name = "engineering point redemption"
	desc = "Who's a good boy?"
	icon = 'icons/obj/vending.dmi'
	icon_state = "liberationstation"
	density = 1
	anchored = 1
	var/GBP = 0
	var/list/prize_list = list( //if you add something to this, please, for the love of god, use tabs and not spaces.
		new /datum/data/GBP_equipment("Whiskey",				/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey,		10),
		new /datum/data/GBP_equipment("Cigar",				/obj/item/clothing/mask/cigarette/cigar/havana,							20),
		new /datum/data/GBP_equipment("Soap",				/obj/item/weapon/soap/nanotrasen,										100),
		new /datum/data/GBP_equipment("Insulated Gloves",				/obj/item/clothing/gloves/color/yellow,						100),
		new /datum/data/GBP_equipment("Fulton Beacon",		/obj/item/fulton_core,													30),
		new /datum/data/GBP_equipment("Fulton Pack",			/obj/item/weapon/extraction_pack,									200),
		new /datum/data/GBP_equipment("Space Cash",			/obj/item/stack/spacecash/c1000,										200),
		new /datum/data/GBP_equipment("50 metal sheets",			/obj/item/stack/sheet/metal/fifty,								250),
		new /datum/data/GBP_equipment("50 glass sheets",			/obj/item/stack/sheet/glass/fifty,								250),
		new /datum/data/GBP_equipment("50 glass sheets",			/obj/item/stack/sheet/cardboard/fifty,							250),
		new /datum/data/GBP_equipment("Hardsuit Set",			/obj/item/clothing/suit/space/hardsuit,								500),
		new /datum/data/GBP_equipment("Jetpack Upgrade Set",		/obj/item/weapon/tank/jetpack/suit,								750),
		new /datum/data/GBP_equipment("Advanced Magboot Set",			/obj/item/clothing/shoes/magboots/advance,					1500),
		new /datum/data/GBP_equipment("ERT Hardsuit Set",		/obj/item/clothing/suit/space/hardsuit/ert,							4000),
		new /datum/data/GBP_equipment("Portal Gun Set",			/obj/item/weapon/gun/energy/wormhole_projector,						4000),
		new /datum/data/GBP_equipment("Reactive Decoy Armor Set",		/obj/item/clothing/suit/armor/reactive/stealth,				6000),
		new /datum/data/GBP_equipment("Cloaking Belt Set",		/obj/item/device/shadowcloak,										8000),
		new /datum/data/GBP_equipment("Chrono Suit Set",		/obj/item/clothing/suit/space/chronos,								10000),
		new /datum/data/GBP_equipment("WHAT HAVE YOU DONE... Set",		/obj/vehicle/space/speedbike/speedwagon,					30000),
		)

/datum/data/GBP_equipment
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/data/GBP_equipment/New(name, path, cost)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost

/obj/machinery/GBP_vendor/power_change()
	..()
	update_icon()

/obj/machinery/GBP_vendor/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"
	return

/obj/machinery/GBP_vendor/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/GBP_vendor/interact(mob/user)
	var/dat
	dat +="<div class='statusDisplay'>"
	dat += "You have <td>[GBP]</td> engineering voucher points<br>"
	switch(round(GBP*100/world.time))
		if(0 to 5)
			dat += "Rating: Terrible<br>"
		if(6 to 10)
			dat += "Rating: Bad<br>"
		if(11 to 15)
			dat += "Rating: Subpar<br>"
		if(16 to 20)
			dat += "Rating: Decent<br>"
		if(21 to 25)
			dat += "Rating: Robust<br>"
		if(26 to 50)
			dat += "Rating: Good boy<br>"
		if(51 to 999)
			dat += "Rating: Holy Shit<br>"
	dat += "</div>"
	dat += "<br><b>Equipment point cost list:</b><BR><table border='0' width='300'>"
	for(var/datum/data/GBP_equipment/prize in prize_list)
		dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=\ref[src];purchase=\ref[prize]'>Purchase</A></td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "vending", "Engineering Point Redemption", 400, 350)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/GBP_vendor/Topic(href, href_list)
	if(..())
		return
	if(href_list["purchase"])
		var/datum/data/mining_equipment/prize = locate(href_list["purchase"])
		if (!prize || !(prize in prize_list))
			return
		if(prize.cost > GBP)
		else if(prize.cost >= 300) // Placeholder spaghetti calm your shit
			GBP -= prize.cost
			new prize.equipment_path(src.loc)
			new prize.equipment_path(src.loc)
			new prize.equipment_path(src.loc)
			new prize.equipment_path(src.loc)
			new prize.equipment_path(src.loc)
			if(prize.cost== 10000)
				new /obj/item/clothing/head/helmet/space/chronos(src.loc)
				new /obj/item/clothing/head/helmet/space/chronos(src.loc)
				new /obj/item/clothing/head/helmet/space/chronos(src.loc)
				new /obj/item/clothing/head/helmet/space/chronos(src.loc)
				new /obj/item/clothing/head/helmet/space/chronos(src.loc)
			feedback_add_details("Engi_equipment_bought",
				"[src.type]|[prize.equipment_path]")
		else
			GBP -= prize.cost
			new prize.equipment_path(src.loc)
			feedback_add_details("Engi_equipment_bought",
				"[src.type]|[prize.equipment_path]")
	updateUsrDialog()
	return

/obj/machinery/GBP_vendor/attackby(obj/item/I, mob/user, params)
	return ..()


/obj/machinery/GBP_vendor/ex_act(severity, target)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(prob(50 / severity) && severity < 3)
		qdel(src)
