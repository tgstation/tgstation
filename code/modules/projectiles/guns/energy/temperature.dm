/obj/item/weapon/gun/energy/temperature
	name = "temperature gun"
	icon = 'icons/obj/gun_temperature.dmi'
	icon_state = "tempgun_4"
	item_state = "tempgun_4"
	slot_flags = SLOT_BACK
	w_class = 4.0
	fire_sound = 'sound/weapons/pulse3.ogg'
	desc = "A gun that changes the body temperature of its targets."
	var/temperature = 300
	var/target_temperature = 300
	charge_cost = 90
	origin_tech = "combat=3;materials=4;powerstorage=3;magnets=2"

	projectile_type = "/obj/item/projectile/temp"
	cell_type = "/obj/item/weapon/cell/temperaturegun"

	var/powercost = ""
	var/powercostcolor = ""

	var/emagged = 0			//ups the temperature cap from 500 to 1000, targets hit by beams over 500 Kelvin will burst into flames
	var/dat = ""

/obj/item/weapon/gun/energy/temperature/New()
	..()
	update_icon()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/temperature/Destroy()
	processing_objects.Remove(src)
	..()


/obj/item/weapon/gun/energy/temperature/attack_self(mob/living/user as mob)
	user.set_machine(src)
	update_dat()

	user << browse("<TITLE>Temperature Gun Configuration</TITLE><HR>[dat]", "window=tempgun;size=510x102")
	onclose(user, "tempgun")

/obj/item/weapon/gun/energy/temperature/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/card/emag) && !emagged)
		emagged = 1
		user << "<span class='caution'>You double the gun's temperature cap ! Targets hit by searing beams will burst into flames !</span>"
		desc = "A gun that changes the body temperature of its targets. Its temperature cap has been hacked"

/obj/item/weapon/gun/energy/temperature/Topic(href, href_list)
	if (..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)

	if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		if(amount > 0)
			src.target_temperature = min((500 + 500*emagged), src.target_temperature+amount)
		else
			src.target_temperature = max(0, src.target_temperature+amount)
	if (istype(src.loc, /mob))
		attack_self(src.loc)
	src.add_fingerprint(usr)
	return


/obj/item/weapon/gun/energy/temperature/process()
	switch(temperature)
		if(0 to 100)
			charge_cost = 300
			powercost = "High"
		if(100 to 250)
			charge_cost = 180
			powercost = "Medium"
		if(251 to 300)
			charge_cost = 90
			powercost = "Low"
		if(301 to 400)
			charge_cost = 180
			powercost = "Medium"
		if(401 to 1000)
			charge_cost = 300
			powercost = "High"
	switch(powercost)
		if("High")		powercostcolor = "orange"
		if("Medium")	powercostcolor = "green"
		else			powercostcolor = "blue"
	if(target_temperature != temperature)
		var/difference = abs(target_temperature - temperature)
		if(difference >= (10 + 40*emagged)) //so emagged temp guns adjust their temperature much more quickly
			if(target_temperature < temperature)
				temperature -= (10 + 40*emagged)
			else
				temperature += (10 + 40*emagged)
		else
			temperature = target_temperature
		update_icon()

		if (istype(loc, /mob/living/carbon))
			var /mob/living/carbon/M = loc
			if (src == M.machine)
				update_dat()
				M << browse("<TITLE>Temperature Gun Configuration</TITLE><HR>[dat]", "window=tempgun;size=510x102")


	if(power_supply)
		power_supply.give(50)
		update_icon()
	return

/obj/item/weapon/gun/energy/temperature/proc/update_dat()
	dat = ""
	dat += "Current output temperature: "
	if(temperature > 500)
		dat += "<FONT color=red><B>[temperature]</B> ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F) </FONT>"
		dat += "<FONT color=red><B>SEARING!!</B></FONT>"
	else if(temperature > (T0C + 50))
		dat += "<FONT color=red><B>[temperature]</B> ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"
	else if(temperature > (T0C - 50))
		dat += "<FONT color=black><B>[temperature]</B> ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"
	else
		dat += "<FONT color=blue><B>[temperature]</B> ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"
	dat += "<BR>"
	dat += "Target output temperature: "	//might be string idiocy, but at least it's easy to read
	dat += "<A href='?src=\ref[src];temp=-100'>-</A> "
	dat += "<A href='?src=\ref[src];temp=-10'>-</A> "
	dat += "<A href='?src=\ref[src];temp=-1'>-</A> "
	dat += "[target_temperature] "
	dat += "<A href='?src=\ref[src];temp=1'>+</A> "
	dat += "<A href='?src=\ref[src];temp=10'>+</A> "
	dat += "<A href='?src=\ref[src];temp=100'>+</A>"
	dat += "<BR>"
	dat += "Power cost: "
	dat += "<FONT color=[powercostcolor]><B>[powercost]</B></FONT>"

/obj/item/weapon/gun/energy/temperature/proc/update_temperature()
	switch(temperature)
		if(501 to INFINITY)
			item_state = "tempgun_8"
		if(400 to 500)
			item_state = "tempgun_7"
		if(360 to 400)
			item_state = "tempgun_6"
		if(335 to 360)
			item_state = "tempgun_5"
		if(295 to 335)
			item_state = "tempgun_4"
		if(260 to 295)
			item_state = "tempgun_3"
		if(200 to 260)
			item_state = "tempgun_2"
		if(120 to 260)
			item_state = "tempgun_1"
		if(-INFINITY to 120)
			item_state = "tempgun_0"
	icon_state = item_state

/obj/item/weapon/gun/energy/temperature/proc/update_charge()
	var/charge = power_supply.charge
	switch(charge)
		if(900 to INFINITY)		overlays += "900"
		if(800 to 900)			overlays += "800"
		if(700 to 800)			overlays += "700"
		if(600 to 700)			overlays += "600"
		if(500 to 600)			overlays += "500"
		if(400 to 500)			overlays += "400"
		if(300 to 400)			overlays += "300"
		if(200 to 300)			overlays += "200"
		if(100 to 200)			overlays += "100"
		if(-INFINITY to 100)	overlays += "0"

/obj/item/weapon/gun/energy/temperature/proc/update_user()
	var/mob/living/carbon/M = new /mob/living/carbon
	if (istype(loc,/mob/living/carbon))
		M = loc
		M.update_inv_back()
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/weapon/gun/energy/temperature/update_icon()
	overlays = 0
	update_temperature()
	update_user()
	update_charge()