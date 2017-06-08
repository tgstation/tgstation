/obj/machinery/medical_equipment_vendor
	name = "mining equipment vendor"
	desc = "An equipment vendor for miners, points collected at an ore redemption machine can be spent here."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "mining"
	density = 1
	anchored = 1
	var/gbp = 0
	var/list/prize_list = list( //if you add something to this, please, for the love of god, use tabs and not spaces.
		new /datum/data/mining_equipment("Medical Hardsuit",	/obj/item/clothing/suit/space/hardsuit/ert/med ,			1000),
		new /datum/data/mining_equipment("Syndicate Medical Cyborg",			/obj/item/weapon/antag_spawner/nuke_ops/borg_tele/medical ,100),
		new /datum/data/mining_equipment("Medical Beamgun",				/obj/item/weapon/gun/medbeam ,							1500),
		new /datum/data/mining_equipment("Healing Staff",				/obj/item/weapon/gun/magic/staff/healing ,						2000),
		new /datum/data/mining_equipment("Nanite Injector",		/obj/item/weapon/reagent_containers/hypospray/combat/nanites ,			3000),
		new /datum/data/mining_equipment("Chemical Clusterbomb",/obj/item/weapon/grenade/clusterbuster/facid ,							3000),
		new /datum/data/mining_equipment("Odysseus Mech",		/obj/mecha/medical/odysseus ,											8000),
		)

/obj/machinery/medical_equipment_vendor/power_change()
	..()
	update_icon()

/obj/machinery/medical_equipment_vendor/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"
	return

/obj/machinery/medical_equipment_vendor/attack_hand(mob/user)
	if(..())
		return
	interact(user)

/obj/machinery/medical_equipment_vendor/interact(mob/user)
	var/dat
	dat +="<div class='statusDisplay'>"
	dat += "You have [gbp] GBP collected."
	dat += "</div>"
	dat += "<br><b>Rewards point cost list:</b><BR><table border='0' width='300'>"
	for(var/datum/data/mining_equipment/prize in prize_list)
		dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=\ref[src];purchase=\ref[prize]'>Purchase</A></td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "miningvendor", "Mining Equipment Vendor", 400, 350)
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/medical_equipment_vendor/Topic(href, href_list)
	if(..())
		return
	if(href_list["purchase"])
		var/datum/data/mining_equipment/prize = locate(href_list["purchase"])
		if (!prize || !(prize in prize_list))
			return
		if(prize.cost > gbp)
			return
		else
			gbp -= prize.cost
			new prize.equipment_path(src.loc)
	updateUsrDialog()
	return