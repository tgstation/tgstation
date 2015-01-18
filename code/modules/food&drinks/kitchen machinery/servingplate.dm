/obj/machinery/servingplate
	name = "Serving Plate"
	desc = "Keeps food at a desired temperature"
	icon = 'icons/obj/structures.dmi'
	icon_state = "cooler"
	density = 1
	anchored = 1
	use_power = 1
	layer = 2.8
	throwpass = 1
	idle_power_usage = 15
	active_power_usage = 150
	var/freshModifier = 10 //the number to * or / when converting values
	var/targetTemp = 0
	var/cold = TRUE

/obj/machinery/servingplate/process()
	for(var/O in src.loc)
		if(istype(O,/obj/item/weapon/reagent_containers/food))
			var/obj/item/weapon/reagent_containers/food/F = O
			if(cold)
				if(F.freshMod*freshModifier > -targetTemp)
					F.freshMod = max(-1,F.freshMod - (targetTemp/freshModifier))
			else
				if(F.freshMod*freshModifier < targetTemp)
					F.freshMod = min(1,F.freshMod + (targetTemp/freshModifier))
			if(emagged && !F.tainted)
				F.tainted = TRUE
			use_power(active_power_usage * targetTemp)

/obj/machinery/servingplate/proc/fluffTemp(var/what)
	if(what < 0)
		what = -what
	switch(what) //to is not inclusive, needs to be x-1 to y-1
		if(-110 to 3)
			return cold ? "Cool" : "Lukewarm"
		if(2 to 6)
			return cold ? "Chilled" : "Warm"
		if(5 to 9)
			return cold ? "Freezing" : "Hot"
		if(8 to 110)
			return cold ? "Frozen" : "Boiling"
	return "Off"

/obj/machinery/servingplate/proc/tempColor(var/what)
	if(what < 0)
		what = -what
	switch(what)
		if(-3 to 3)
			return cold ? "#80B2FF" : "#DB704D"
		if(2 to 6)
			return cold ? "#66A3FF" : "#D65C33"
		if(5 to 9)
			return cold ? "#4D94FF" : "#D14719"
		if(8 to 11)
			return cold ? "#3385FF" : "#CC3300"
	return "#000000"

/obj/machinery/servingplate/interact(mob/user as mob)
	if(stat)
		return 0

	var/dat = "<HEAD><TITLE>[src]</TITLE></HEAD><center><br>"
	dat += "Temperature: [fluffTemp(targetTemp)]<br>"
	var/counter
	for(counter = 1; counter <= targetTemp; counter++)
		if(counter > 48) //48 is the max number that fits comfortably.
			counter = targetTemp
			continue
		dat += "<font color=[tempColor(counter)]><b>|</b></font>"
	dat += "<br>"
	dat += "<a href='byond://?src=\ref[src];function=lowermore'>--</a><a href='byond://?src=\ref[src];function=lower'>-</a> <a href='byond://?src=\ref[src];function=raise'>+</a><a href='byond://?src=\ref[src];function=raisemore'>++</a><br>"
	dat += "[cold ? "Cooled" : "Heated"] food:<br>"
	for(var/obj/O in src.loc)
		if(istype(O,/obj/item/weapon/reagent_containers/food))
			var/obj/item/weapon/reagent_containers/food/F = O
			dat += "<font color=[F.coolFood ? "#3399FF" : "#CC3300"]>[F.name]</font> - [fluffTemp(F.freshMod*freshModifier)] ([(F.freshMod*freshModifier)*7]°C)<br>"
	dat += "<a href='byond://?src=\ref[src];function=toggle'>Mode: [cold ? "Cool" : "Heat"]</a><br>"
	dat += "<a href='byond://?src=\ref[src];function=refresh'>Check Temperatures</a><br>"
	dat += "</center>"
	var/datum/browser/popup = new(user, "servingtable", name, 300, 300)
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
		targetTemp = max(0,targetTemp - 2)
	if(function == "raise")
		targetTemp = min(emagged ? 100 : 10,targetTemp + 1)
	if(function == "raisemore")
		targetTemp = min(emagged ? 100 : 10,targetTemp + 2)
	if(function == "toggle")
		cold = !cold
	if(function == "refresh")
		src.updateUsrDialog()
	src.updateUsrDialog()
	return

/obj/machinery/servingplate/attack_hand(mob/user as mob)
	user.set_machine(src)
	interact(user)

/obj/machinery/servingplate/proc/tablepush(obj/item/I, mob/user)
	if(get_dist(src, user) < 2)
		var/obj/item/weapon/grab/G = I
		if(G.affecting.buckled)
			user << "<span class='warning'>[G.affecting] is buckled to [G.affecting.buckled]!</span>"
			return 0
		if(G.state == GRAB_AGGRESSIVE)
			G.affecting.visible_message("<span class='danger'>[G.assailant] slams [G.affecting] onto [src].</span>", \
									"<span class='userdanger'>[G.assailant] slams [G.affecting] onto [src].</span>")
			playsound(G.affecting, 'sound/items/trayhit2.ogg', 50, 1)
			var/damage = freshModifier < 0 ? (-freshModifier)*20 : freshModifier*20
			var/mob/living/L = G.affecting
			L.apply_damage(damage,BURN,"head")
			add_logs(G.assailant, G.affecting, "tableslammed")
			qdel(I)
			return 1
		if(!G.confirm())
			return 0
		G.affecting.loc = src.loc
		G.affecting.Weaken(5)
		G.affecting.visible_message("<span class='danger'>[G.assailant] pushes [G.affecting] onto [src].</span>", \
									"<span class='userdanger'>[G.assailant] pushes [G.affecting] onto [src].</span>")
		add_logs(G.assailant, G.affecting, "pushed")
		qdel(I)
		return 1
	qdel(I)

/obj/machinery/servingplate/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(default_unfasten_wrench(user, O))
		power_change()
		return
	if(stat)
		return 0
	if (istype(O, /obj/item/weapon/grab))
		tablepush(O, user)
		return
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

/obj/machinery/servingplate/emag_act()
	if(!emagged)
		emagged = 1
		var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
		spark_system.set_up(4, 0, src.loc)
		spark_system.start()
		playsound(src.loc, "sparks", 50, 1)