
/obj/machinery/engi_points_manager
	name = "Intergalatic Energy Point Exchange"
	desc = "A cutting edge market that trades energy and simple matter on a FTL basis."
	icon = 'icons/obj/machines/engi_points.dmi'
	icon_state = "store"
	verb_say = "states"
	density = TRUE
	anchored = TRUE
	req_access = list(access_engine)
	var/obj/item/device/radio/radio
	var/GBP = 0
	var/GBPearned = 0
	var/power_export_bonus = 0
	var/air_alarm_bonus = 0
	var/power_alarm_bonus = 0
	var/fire_alarm_bonus = 0
	var/alarm_rating = ""
	var/prior_bonus = 2500
	var/total_bonus = 0
	var/GBP_alarm_cooldown = 4500
	var/list/prize_list = list()

/datum/GBP_equipment
	var/equipment_name = "generic"
	var/equipment_path = null
	var/cost = 0
	var/amount = 0

/datum/GBP_equipment/New(name, path, cost, amount)
	equipment_name = name
	equipment_path = path
	cost = cost
	amount = amount

/obj/machinery/engi_points_manager/Initialize()
	engi_points_list += src
	radio = new(src)
	radio.listening = FALSE
	radio.frequency = 1357
	prize_list = list(
		new /datum/GBP_equipment("Tendie",				/obj/item/weapon/reagent_containers/food/snacks/nugget,				50,		1),
		new /datum/GBP_equipment("Cigar",				/obj/item/clothing/mask/cigarette/cigar/havana,						50,		1),
		new /datum/GBP_equipment("Fulton Beacon",		/obj/item/fulton_core,												50,		1),
		new /datum/GBP_equipment("Soap",				/obj/item/weapon/soap/nanotrasen,									250,	1),
		new /datum/GBP_equipment("Advanced Indoor Fulton Pack",			/obj/item/weapon/extraction_pack/advanced,			300,	1),
		new /datum/GBP_equipment("Insulated Gloves",				/obj/item/clothing/gloves/color/yellow,					400,	1),
		new /datum/GBP_equipment("50 metal sheets",			/obj/item/stack/sheet/metal/fifty,								500,	1),
		new /datum/GBP_equipment("50 glass sheets",			/obj/item/stack/sheet/glass/fifty,								500,	1),
		new /datum/GBP_equipment("50 cardboard sheets",			/obj/item/stack/sheet/cardboard/fifty,						500,	1),
		new /datum/GBP_equipment("Space Cash",			/obj/item/stack/spacecash/c1000,									600,	1),
		new /datum/GBP_equipment("Hardsuit x3",			/obj/item/clothing/suit/space/hardsuit,								750,	3),
		new /datum/GBP_equipment("Jetpack Upgrade x3",		/obj/item/weapon/tank/jetpack/suit,								1000,	3),
		new /datum/GBP_equipment("Powertools x4",			/obj/item/weapon/storage/belt/utility/chief/full,				2000,	4),
		new /datum/GBP_equipment("Freon Canister",			/obj/machinery/portable_atmospherics/canister/freon,			2500,	1),
		new /datum/GBP_equipment("Prototype Canister",			/obj/machinery/portable_atmospherics/canister/proto,		2500,	1),
		new /datum/GBP_equipment("Advanced Magboot x3",			/obj/item/clothing/shoes/magboots/advance,					3000,	3),
		new /datum/GBP_equipment("Reflector Box x3",			/obj/structure/reflector/box,								3500,	3),
		new /datum/GBP_equipment("Radiation Collector x3",			/obj/machinery/power/rad_collector,						4000,	3),
		new /datum/GBP_equipment("ERT Hardsuit x5",		/obj/item/clothing/suit/space/hardsuit/ert/engi,					7000,	5),
		new /datum/GBP_equipment("Portal Gun x5",			/obj/item/weapon/gun/energy/wormhole_projector,					8000,	5),
		new /datum/GBP_equipment("Ranged RCD x4",			/obj/item/weapon/rcd/arcd,										9000,	4),
		new /datum/GBP_equipment("Prototype Atmos Vehicle x2",			/obj/vehicle/space/speedbike/atmos,					10000,	2),
		new /datum/GBP_equipment("Reactive Decoy Armor x5",		/obj/item/clothing/suit/armor/reactive/stealth,				11000,	5),
		new /datum/GBP_equipment("Prototype Repair Vehicle x3",		/obj/vehicle/space/speedbike/repair,					15000,	3),
		new /datum/GBP_equipment("Chrono Suit x5",			/obj/item/clothing/suit/space/chronos,							20000,	5),
		new /datum/GBP_equipment("WHAT HAVE YOU DONE... x5",		/obj/vehicle/space/speedbike/memewagon,					30000,	5),
		)
	..()

/obj/machinery/engi_points_manager/Destroy()
	engi_points_list -= src
	if(radio)
		qdel(radio)
		radio = null
	return ..()


/obj/machinery/engi_points_manager/power_change()
	..()
	update_icon()

/obj/machinery/engi_points_manager/update_icon()
	if(powered())
		icon_state = initial(icon_state)
	else
		icon_state = "[initial(icon_state)]-off"

/obj/machinery/engi_points_manager/attack_hand(mob/user)
	if(..())
		return
	if(!allowed(user))
		user << "<span class='warning'>The shopping interface logs out with a message: Insufficient Access.</span>"
		return
	interact(user)

/obj/machinery/engi_points_manager/interact(mob/user)
	var/list/dat = list()
	dat +="<div class='statusDisplay'>"
	dat += "You currently have <td>[round(GBP)]</td> engineering voucher points<br>"
	dat += "You have earned a total of <td>[round(GBPearned)]</td> this shift<br>"
	dat += "</div>"
	dat += "<br><b>Equipment point cost list:</b><BR><table border='0' width='300'>"
	for(var/datum/GBP_equipment/prize in prize_list)
		dat += "<tr><td>[prize.equipment_name]</td><td>[prize.cost]</td><td><A href='?src=\ref[src];purchase=\ref[prize]'>Purchase</A></td></tr>"
	dat += "</table>"

	var/datum/browser/popup = new(user, "vending", "Engineering Point Redemption", 400, 350)
	popup.set_content(dat.Join())
	popup.open()

/obj/machinery/engi_points_manager/Topic(href, href_list)
	if(..())
		return
	if(href_list["purchase"])
		var/datum/GBP_equipment/prize = locate(href_list["purchase"])
		if (!prize || !(prize in prize_list))
			return
		if(prize.cost > GBP)
			return
		else if(prize.cost <= GBP) // Placeholder spaghetti calm your shit
			GBP -= prize.cost
			for(var/obj/machinery/engi_points_delivery/D in deliverer_list)
				D.icon_state = "geardist-load"
				playsound(D, 'sound/machines/Ding.ogg', 100, 1)
				sleep(20)
				if(!D || QDELETED(D))
					return
				spawn_atom_to_turf(new prize.equipment_path, D, prize.amount, admin_spawn=FALSE)
				D.icon_state = "geardist"
				if(prize.cost == 20000) // Still a placeholder
					spawn_atom_to_turf(/obj/item/clothing/head/helmet/space/chronos, D, prize.amount, admin_spawn=FALSE)
				if(prize.cost >= 1000)
					radio.talk_into(src, "[usr] has bought [prize.equipment_name] for [prize.cost] points")
				feedback_add_details("Engi_equipment_bought","[src.type]|[prize.equipment_path]")
	updateUsrDialog()

/obj/machinery/engi_points_manager/attackby(obj/item/I, mob/user, params)
	return ..()

/obj/machinery/engi_points_manager/process()
	power_export_bonus = 0
	for(var/obj/machinery/power/exporter/PE in power_exporter_list)
		power_export_bonus = PE.drain_rate/200 // basically controls the balance of the current point system
	if(GBP_alarm_cooldown <= world.time)
		for(var/obj/machinery/computer/station_alert/SA in machines)
			if(SA.z == src.z)
				air_alarm_bonus = max(0,(1000 - (SA.air_alarm_count * 200)))
				power_alarm_bonus = max(0,(1000 - (SA.power_alarm_count * 200)))
				fire_alarm_bonus = max(0,(500 - (SA.fire_alarm_count * 100)))
				total_bonus = air_alarm_bonus + power_alarm_bonus + fire_alarm_bonus
				break
		switch(total_bonus)
			if(0)
				alarm_rating = "GREYTIDE IN YELLOW JUMPSUITS"
				playsound(src, 'sound/misc/compiler-failure.ogg', 100, 1)
			if(100 to 900)
				alarm_rating = "COMPLICIT IN THE STATION'S DOWNFALL"
				playsound(src, 'sound/misc/compiler-failure.ogg', 100, 1)
			if(1000 to 1500)
				alarm_rating = "HALF-ASSED"
				playsound(src, 'sound/misc/compiler-stage1.ogg', 100, 1)
			if(1600 to 2000)
				alarm_rating = "ADEQUATE AND UNREMARKABLE"
				playsound(src, 'sound/misc/compiler-stage1.ogg', 100, 1)
			if(2100 to 2400)
				alarm_rating = "IMPRESSIVE"
				playsound(src, 'sound/misc/compiler-stage2.ogg', 100, 1)
			if(2500 to 9999999)
				alarm_rating = "ABSOLUTELY FLAWLESS"
				playsound(src, 'sound/misc/compiler-stage2.ogg', 100, 1)
		radio.talk_into(src,"UPDATE: The engineering department has been awarded [air_alarm_bonus] points for the state of the station's air, [power_alarm_bonus] points for the state of the station's power, and [fire_alarm_bonus] points for the state of the station's fire alarms.")
		radio.talk_into(src,"This bonus represents [((total_bonus)/2500)*100]% of the total possible bonus. Your rating is: [alarm_rating]. Consult the station alert console for details.")
		if((total_bonus - prior_bonus) >= 1600)
			radio.talk_into(src,"Congratulations! Due to the significant repairs made by the engineering team, your bonus has been doubled this cycle!")
			total_bonus = total_bonus*2
		prior_bonus = total_bonus
		GBP_alarm_cooldown = world.time + 3000
		power_export_bonus += (air_alarm_bonus + power_alarm_bonus + fire_alarm_bonus)
	GBP += power_export_bonus
	GBPearned += power_export_bonus

/obj/machinery/engi_points_delivery
	name = "Engineering Reward Fabricator"
	desc = "Tapping into an almost infinite network of energy that transcends space and time... for goodies"
	icon = 'icons/obj/machines/engi_points.dmi'
	icon_state = "geardist"
	density = TRUE
	anchored = TRUE
	
/obj/machinery/engi_points_delivery/Initialize()
	..()
	deliverer_list += src
	
/obj/machinery/engi_points_delivery/Destroy()
	..()
	deliverer_list -= src
