
/obj/item/weapon/anobattery
	name = "Anomaly power battery"
	icon = 'anomaly.dmi'
	icon_state = "anobattery0"
	var/datum/artifact_effect/battery_effect
	var/capacity = 200
	var/stored_charge = 0

/obj/item/weapon/anobattery/New()
	battery_effect = new()

/obj/item/weapon/anobattery/proc/UpdateSprite()
	var/p = (stored_charge/capacity)*100
	icon_state = "anobattery[round(p,25)]"

/obj/item/weapon/anodevice
	name = "Anomaly power utilizer"
	icon = 'anomaly.dmi'
	icon_state = "anodev"
	var/cooldown = 0
	var/activated = 0
	var/time = 50
	var/obj/item/weapon/anobattery/inserted_battery

/obj/item/weapon/anodevice/New()
	spawn(10)
		pulse()

/obj/item/weapon/anodevice/proc/UpdateSprite()
	if(!inserted_battery)
		icon_state = "anodev"
		return
	var/p = (inserted_battery.stored_charge/inserted_battery.capacity)*100
	var/s = round(p,25)
	icon_state = "anodev[s]"

/obj/item/weapon/anodevice/proc/interact(var/mob/user)
	user.machine = src
	var/dat = "<b>Anomalous Materials Energy Utiliser</b><br>"
	if(activated)
		dat += "Device active, stand by.<BR>"
	else if(cooldown)
		dat += "Cooldown in progress, please wait.<BR>"
	else
		if(!inserted_battery)
			dat += "Please insert battery<BR>"
		else
			dat += "[inserted_battery] inserted, anomaly ID: [inserted_battery.battery_effect.artifact_id == "" ? "???" : "[inserted_battery.battery_effect.artifact_id]"]<BR>"
			dat += "<b>Total Power:</b> [inserted_battery.stored_charge]/[inserted_battery.capacity]<BR><BR>"
			dat += "<b>Timed activation:</b> <A href='?src=\ref[src];neg_changetime_max=-100'>--</a> <A href='?src=\ref[src];neg_changetime=-10'>-</a> [time >= 1000 ? "[time/10]" : time >= 100 ? " [time/10]" : "  [time/10]" ] <A href='?src=\ref[src];changetime=10'>+</a> <A href='?src=\ref[src];changetime_max=100'>++</a><BR>"
			if(cooldown && !activated)
				dat += "<font color=red>Cooldown in progress.</font><BR>"
			else if(activated)
				dat += "<A href='?src=\ref[src];stoptimer=1'>Stop timer</a><BR>"
			else
				dat += "<A href='?src=\ref[src];starttimer=1'>Start timer</a><BR>"
			dat += "<A href='?src=\ref[src];ejectbattery=1'>Eject battery</a><BR>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh</a><BR>"
	dat += "<A href='?src=\ref[src];close=1'>Close</a><BR>"

	user << browse(dat, "window=anodevice;size=400x500")
	onclose(user, "anodevice")
	return

/obj/item/weapon/anodevice/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I, /obj/item/weapon/anobattery))
		if(!inserted_battery)
			user << "\blue You insert the battery."
			user.drop_item()
			I.loc = src
			inserted_battery = I
			UpdateSprite()
	else
		return ..()

/obj/item/weapon/anodevice/attack_ai(var/mob/user as mob)
	return src.interact(user)

/*/obj/item/weapon/anodevice/attack_paw(var/mob/user as mob)
	return src.interact(user)*/

/obj/item/weapon/anodevice/attack_self(var/mob/user as mob)
	return src.interact(user)

/*obj/item/weapon/anodevice/attack_hand(var/mob/user as mob)
	return src.interact(user)*/

/obj/item/weapon/anodevice/proc/pulse()
	if(activated)
		if(time <= 0 || !inserted_battery)
			time = 0
			activated = 0
			var/turf/T = get_turf(src)
			T.visible_message("\icon[src]\blue The utiliser device buzzes.", "\icon[src]\blue You hear something buzz.")
		else
			inserted_battery.battery_effect.DoEffect(src)
		time -= 10
		inserted_battery.stored_charge -= 10 + rand(-1,1)
		cooldown += 10
	else if(cooldown > 0)
		cooldown -= 10
		if(cooldown <= 0)
			cooldown = 0
			var/turf/T = get_turf(src)
			T.visible_message("\icon[src]\blue The utiliser device chimes.", "\icon[src]\blue You hear something chime.")

	spawn(10)
		pulse()

/obj/item/weapon/anodevice/Topic(href, href_list)

	if(href_list["neg_changetime_max"])
		time += -100
		if(time > inserted_battery.capacity)
			time = inserted_battery.capacity
		else if (time < 0)
			time = 0
	if(href_list["neg_changetime"])
		time += -10
		if(time > inserted_battery.capacity)
			time = inserted_battery.capacity
		else if (time < 0)
			time = 0
	if(href_list["changetime"])
		time += 10
		if(time > inserted_battery.capacity)
			time = inserted_battery.capacity
		else if (time < 0)
			time = 0
	if(href_list["changetime_max"])
		time += 100
		if(time > inserted_battery.capacity)
			time = inserted_battery.capacity
		else if (time < 0)
			time = 0

	if(href_list["stoptimer"])
		activated = 0

	if(href_list["starttimer"])
		activated = 1

	if(href_list["ejectbattery"])
		inserted_battery.loc = get_turf(src)
		inserted_battery = null
		UpdateSprite()

	if(href_list["close"])
		usr << browse(null, "window=anodevice")
		usr.machine = null

	if(usr)
		src.interact(usr)
