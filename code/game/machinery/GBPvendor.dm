
/obj/machinery/GBP_vendor
	name = "engineering point redemption"
	desc = "Who's a good boy?"
	icon = 'icons/obj/vending.dmi'
	icon_state = "liberationstation"
	density = 1
	anchored = 1
	var/GBP = 0
	var/GBP_spent = 0
	var/GBP_earned = GBP + GBP_spent
	var/list/prize_list = list( //if you add something to this, please, for the love of god, use tabs and not spaces.
		new /datum/GBP_equipment("Whiskey",				/obj/item/weapon/reagent_containers/food/drinks/bottle/whiskey,		10,	1),
		new /datum/GBP_equipment("Cigar",				/obj/item/clothing/mask/cigarette/cigar/havana,						20,	1),
		new /datum/GBP_equipment("Soap",				/obj/item/weapon/soap/nanotrasen,									100,	1),
		new /datum/GBP_equipment("Insulated Gloves",				/obj/item/clothing/gloves/color/yellow,					100,	1),
		new /datum/GBP_equipment("Fulton Beacon",		/obj/item/fulton_core,												30,	1),
		new /datum/GBP_equipment("Fulton Pack",			/obj/item/weapon/extraction_pack,									200,	1),
		new /datum/GBP_equipment("Space Cash",			/obj/item/stack/spacecash/c1000,									200,	1),
		new /datum/GBP_equipment("50 metal sheets",			/obj/item/stack/sheet/metal/fifty,								250,	1),
		new /datum/GBP_equipment("50 glass sheets",			/obj/item/stack/sheet/glass/fifty,								250,	1),
		new /datum/GBP_equipment("50 cardboard sheets",			/obj/item/stack/sheet/cardboard/fifty,						250,	1),
		new /datum/GBP_equipment("Hardsuit x3",			/obj/item/clothing/suit/space/hardsuit,								500,	3),
		new /datum/GBP_equipment("Jetpack Upgrade x5",		/obj/item/weapon/tank/jetpack/suit,								750,	5),
		new /datum/GBP_equipment("Advanced Magboot x5",			/obj/item/clothing/shoes/magboots/advance,					1500,	5),
		new /datum/GBP_equipment("ERT Hardsuit x5",		/obj/item/clothing/suit/space/hardsuit/ert,							4000,	5),
		new /datum/GBP_equipment("Portal Gun x5",			/obj/item/weapon/gun/energy/wormhole_projector,					4000,	5),
		new /datum/GBP_equipment("Reactive Decoy Armor x5",		/obj/item/clothing/suit/armor/reactive/stealth,				6000,	5),
		new /datum/GBP_equipment("Cloaking Belt x5",		/obj/item/device/shadowcloak,									8000,	5),
		new /datum/GBP_equipment("Chrono Suit x5",		/obj/item/clothing/suit/space/chronos,								10000,	5),
		new /datum/GBP_equipment("WHAT HAVE YOU DONE... x5",		/obj/vehicle/space/speedbike/speedwagon,				30000,	5),
		)

/datum/GBP_equipment
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0

/datum/GBP_equipment/New(name, path, cost, amount)
	src.equipment_name = name
	src.equipment_path = path
	src.cost = cost
	src.amount = amount

/obj/machinery/GBP_vendor/power_change()
	..()
	update_icon()

/obj/machinery/GBP_vendor/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/GBP_vendor/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/GBP_vendor/interact(mob/user)
	var/dat
	dat +="<div class='statusDisplay'>"
	dat += "You have <td>[GBP]</td> engineering voucher points<br>"
	switch(round(GBP_earned*100/world.time))
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
	for(var/datum/GBP_equipment/prize in prize_list)
		dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=\ref[src];purchase=\ref[prize]'>Purchase</A></td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "vending", "Engineering Point Redemption", 400, 350)
	popup.set_content(dat)
	popup.open()

/obj/machinery/GBP_vendor/Topic(href, href_list)
	if(..())
		return
	if(href_list["purchase"])
		var/datum/GBP_equipment/prize = locate(href_list["purchase"])
		if (!prize || !(prize in prize_list))
			return
		if(prize.cost > GBP)
		else if(prize.cost >= 300) // Placeholder spaghetti calm your shit
			GBP -= prize.cost
			GBP_spent += prize.cost
			for(var/i in 1 to prize.amount)
				new prize.equipment_path(get_turf(src))
			if(prize.cost== 10000) // Still a placeholder
				for(var/i in 1 to prize.amount)
					new /obj/item/clothing/head/helmet/space/chronos(get_turf(src))
			feedback_add_details("Engi_equipment_bought",
				"[src.type]|[prize.equipment_path]")
		else
			GBP -= prize.cost
			new prize.equipment_path(src.loc)
			feedback_add_details("Engi_equipment_bought",
				"[src.type]|[prize.equipment_path]")
	updateUsrDialog()

/obj/machinery/GBP_vendor/attackby(obj/item/I, mob/user, params)
	return ..()


/obj/machinery/GBP_vendor/ex_act(severity, target)
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(5, 1, src)
	s.start()
	if(prob(50 / severity) && severity < 3)
		qdel(src)
