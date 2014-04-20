
/obj/item/weapon/anobattery
	name = "Anomaly power battery"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "anobattery0"
	var/datum/artifact_effect/battery_effect
	var/capacity = 200
	var/stored_charge = 0
	var/effect_id = ""

/obj/item/weapon/anobattery/New()
	battery_effect = new()

/obj/item/weapon/anobattery/proc/UpdateSprite()
	var/p = (stored_charge/capacity)*100
	p = min(p, 100)
	icon_state = "anobattery[round(p,25)]"

/obj/item/weapon/anodevice
	name = "Anomaly power utilizer"
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "anodev"
	var/cooldown = 0
	var/activated = 0
	var/timing = 0
	var/time = 50
	var/archived_time = 50
	var/obj/item/weapon/anobattery/inserted_battery
	var/turf/archived_loc

/obj/item/weapon/anodevice/New()
	..()
	processing_objects.Add(src)

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

/obj/item/weapon/anodevice/attack_self(var/mob/user as mob)
	return src.interact(user)

/obj/item/weapon/anodevice/interact(var/mob/user)
	user.set_machine(src)
	var/dat = "<b>Anomalous Materials Energy Utiliser</b><br>"
	if(inserted_battery)
		if(cooldown)
			dat += "Cooldown in progress, please wait.<br>"
		else if(activated)
			if(timing)
				dat += "Device active.<br>"
			else
				dat += "Device active in timed mode.<br>"

		dat += "[inserted_battery] inserted, anomaly ID: [inserted_battery.battery_effect.artifact_id ? inserted_battery.battery_effect.artifact_id : "NA"]<BR>"
		dat += "<b>Total Power:</b> [inserted_battery.stored_charge]/[inserted_battery.capacity]<BR><BR>"
		dat += "<b>Timed activation:</b> <A href='?src=\ref[src];neg_changetime_max=-100'>--</a> <A href='?src=\ref[src];neg_changetime=-10'>-</a> [time >= 1000 ? "[time/10]" : time >= 100 ? " [time/10]" : "  [time/10]" ] <A href='?src=\ref[src];changetime=10'>+</a> <A href='?src=\ref[src];changetime_max=100'>++</a><BR>"
		if(cooldown)
			dat += "<font color=red>Cooldown in progress.</font><BR>"
			dat += "<br>"
		else if(!activated)
			dat += "<A href='?src=\ref[src];startup=1'>Start</a><BR>"
			dat += "<A href='?src=\ref[src];startup=1;starttimer=1'>Start in timed mode</a><BR>"
		else
			dat += "<a href='?src=\ref[src];shutdown=1'>Shutdown emission</a><br>"
			dat += "<br>"
		dat += "<A href='?src=\ref[src];ejectbattery=1'>Eject battery</a><BR>"
	else
		dat += "Please insert battery<br>"

		dat += "<br>"
		dat += "<br>"
		dat += "<br>"

		dat += "<br>"
		dat += "<br>"
		dat += "<br>"

	dat += "<hr>"
	dat += "<a href='?src=\ref[src]'>Refresh</a> <a href='?src=\ref[src];close=1'>Close</a>"

	user << browse(dat, "window=anodevice;size=400x500")
	onclose(user, "anodevice")

/obj/item/weapon/anodevice/process()
	if(cooldown > 0)
		cooldown -= 1
		if(cooldown <= 0)
			cooldown = 0
			src.visible_message("\blue \icon[src] [src] chimes.", "\blue \icon[src] You hear something chime.")
	else if(activated)
		if(inserted_battery && inserted_battery.battery_effect)
			//make sure the effect is active
			if(!inserted_battery.battery_effect.activated)
				inserted_battery.battery_effect.ToggleActivate(1)

			//update the effect loc
			var/turf/T = get_turf(src)
			if(T != archived_loc)
				archived_loc = T
				inserted_battery.battery_effect.UpdateMove()

			//process the effect
			inserted_battery.battery_effect.process()
			//if someone is holding the device, do the effect on them
			if(inserted_battery.battery_effect.effect == 0 && ismob(src.loc))
				inserted_battery.battery_effect.DoEffectTouch(src.loc)

			//handle charge
			inserted_battery.stored_charge -= 1
			if(inserted_battery.stored_charge <= 0)
				shutdown_emission()

			//handle timed mode
			if(timing)
				time -= 1
				if(time <= 0)
					shutdown_emission()
		else
			shutdown()

/obj/item/weapon/anodevice/proc/shutdown_emission()
	if(activated)
		activated = 0
		timing = 0
		src.visible_message("\blue \icon[src] [src] buzzes.", "\icon[src]\blue You hear something buzz.")

		cooldown = archived_time / 2

		if(inserted_battery.battery_effect.activated)
			inserted_battery.battery_effect.ToggleActivate(1)

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
	if(href_list["startup"])
		activated = 1
		if(!inserted_battery.battery_effect.activated)
			inserted_battery.battery_effect.ToggleActivate(1)
	if(href_list["shutdown"])
		activated = 0
	if(href_list["starttimer"])
		timing = 1
		archived_time = time
	if(href_list["ejectbattery"])
		shutdown_emission()
		inserted_battery.loc = get_turf(src)
		inserted_battery = null
		UpdateSprite()
	if(href_list["close"])
		usr << browse(null, "window=anodevice")
		usr.unset_machine(src)

	..()
	updateDialog()

/obj/item/weapon/anodevice/proc/UpdateSprite()
	if(!inserted_battery)
		icon_state = "anodev"
		return
	var/p = (inserted_battery.stored_charge/inserted_battery.capacity)*100
	p = min(p, 100)
	icon_state = "anodev[round(p,25)]"

/obj/item/weapon/anodevice/Destroy()
	processing_objects.Remove(src)
	..()
