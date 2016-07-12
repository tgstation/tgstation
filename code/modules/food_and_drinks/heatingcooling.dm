/obj/machinery/servingplate
	name = "Serving Plate"
	desc = "Keeps food at a desired temperature"
	icon = 'icons/obj/structures.dmi'
	icon_state = "cooler"
	density = 1
	anchored = 1
	use_power = 1
	layer = 2.8
	idle_power_usage = 15
	active_power_usage = 150
	var/maxTemp = 100
	var/targetTemp = 0
	var/cold = TRUE

/obj/machinery/servingplate/process()
	if(cold)
		icon_state = "cooler"
	else
		icon_state = "heater"

	for(var/O in src.loc)
		if(istype(O,/obj/item/weapon/reagent_containers/food))
			var/obj/item/weapon/reagent_containers/food/F = O
			if(cold)
				if(F.temperature > -targetTemp)
					F.temperature = max(-100,F.temperature - (targetTemp))
			else
				if(F.temperature < targetTemp)
					F.temperature = min(100,F.temperature + (targetTemp))
			use_power(active_power_usage * targetTemp)


/obj/machinery/servingplate/interact(mob/user as mob)
	if(stat)
		return 0

	var/dat = "<HEAD><TITLE>[src]</TITLE></HEAD><center><br>"
	dat += "Temperature: [fluffTemp(cold ? -targetTemp : targetTemp)] ([cold ? -targetTemp : targetTemp]c)<br>"
	var/counter
	for(counter = 1; counter <= targetTemp; counter++)
		if(counter > 50) //500 is the max number that fits comfortably.
			counter = targetTemp
			continue
		dat += "<font color=[tempColor(cold ? -counter : counter)]><b>|</b></font>"
	dat += "<br>"
	dat += "<a href='byond://?src=\ref[src];function=lowermore'>--</a><a href='byond://?src=\ref[src];function=lower'>-</a> <a href='byond://?src=\ref[src];function=raise'>+</a><a href='byond://?src=\ref[src];function=raisemore'>++</a><br>"
	dat += "Managed food:<br>"
	for(var/obj/O in src.loc)
		if(istype(O,/obj/item/weapon/reagent_containers/food))
			var/obj/item/weapon/reagent_containers/food/F = O
			dat += "<font color=[!F.shouldBeHot ? "#3399FF" : "#CC3300"]>[F.name]</font> - [fluffTemp(F.freshness)] (Needs: [F.targetTemperature]c, Current:[(F.temperature)]c)<br>"
	dat += "<a href='byond://?src=\ref[src];function=toggle'>Mode: [cold ? "Cool" : "Heat"]</a><br>"
	dat += "<a href='byond://?src=\ref[src];function=refresh'>Check Temperatures</a><br>"
	dat += "</center>"
	var/datum/browser/popup = new(user, "servingtable", name, 350, 300)
	popup.set_content(dat)
	popup.open()
	return dat

/obj/machinery/servingplate/Topic(var/href, var/list/href_list)
	if(..())
		return
	usr.set_machine(src)
	var/function = href_list["function"]
	if(function == "lower")
		targetTemp = max(0,targetTemp - 1)
	if(function == "lowermore")
		targetTemp = max(0,targetTemp - 5)
	if(function == "raise")
		targetTemp = min(maxTemp,targetTemp + 1)
	if(function == "raisemore")
		targetTemp = min(maxTemp,targetTemp + 5)
	if(function == "toggle")
		cold = !cold
	if(function == "refresh")
		src.updateUsrDialog()
	src.updateUsrDialog()
	return

/obj/machinery/servingplate/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/machinery/servingplate/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(default_unfasten_wrench(user, O))
		power_change()
		return
	if(stat)
		return 0
	if (istype(O, /obj/item/weapon/storage/bag/tray))
		var/obj/item/weapon/storage/bag/tray/T = O
		if(T.contents.len > 0)
			var/list/obj/item/oldContents = T.contents.Copy()
			T.quick_empty()
			for(var/obj/item/C in oldContents)
				C.loc = src.loc
			user.visible_message("<span class='notice'>[user] empties [O] on [src].</span>")
	if(!(O.flags & ABSTRACT))
		if(user.drop_item())
			O.loc = loc
	updateUsrDialog()
	return 1

/obj/machinery/conveyor/preserver
	name = "automated food belt"
	desc = "Promotes a healthy diet through gears, flaps and rotating doodads!"
	id = "kitchenconveyor"


/obj/machinery/conveyor/preserver/process()
	for(var/O in src.loc)
		if(istype(O,/obj/item/weapon/reagent_containers/food))
			var/obj/item/weapon/reagent_containers/food/F = O
			if(F)
				F.reachTemp = F.targetTemperature
	..()