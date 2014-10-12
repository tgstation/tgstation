/obj/item/weapon/gun/energy/temperature
	name = "temperature gun"
	icon = 'icons/obj/gun_temperature.dmi'
	icon_state = "tempgun"
	item_state = "tempgun_4"
	slot_flags = SLOT_BACK
	w_class = 4.0
	fire_sound = 'sound/weapons/pulse3.ogg'
	desc = "A gun that changes the body temperature of its targets."
	var/temperature = 300
	var/current_temperature = 300
	charge_cost = 90
	origin_tech = "combat=3;materials=4;powerstorage=3;magnets=2"

	projectile_type = "/obj/item/projectile/temp"
	cell_type = "/obj/item/weapon/cell/temperaturegun"

	var/powercost = ""
	var/powercostcolor = ""

	var/emagged = 0			//ups the temperature cap from 500 to 1000, targets hit by beams over 500 Kelvin will burst into flames

	var/overlay_layer = LIGHTING_LAYER+1

	New()
		..()
		update_icon()
		processing_objects.Add(src)


	Destroy()
		processing_objects.Remove(src)
		..()


	attack_self(mob/living/user as mob)
		user.set_machine(src)
		var/temp_text = ""
		if(temperature > 500)
			temp_text = "<FONT color=red><B>[temperature]</B> ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F) <B>SEARING!!</B></FONT>"
		else if(temperature > (T0C + 50))
			temp_text = "<FONT color=red><B>[temperature]</B> ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"
		else if(temperature > (T0C - 50))
			temp_text = "<FONT color=black><B>[temperature]</B> ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"
		else
			temp_text = "<FONT color=blue><B>[temperature]</B> ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"

		var/dat = {"<B>Temperature Gun Configuration: </B><BR>
		Current output temperature: [temp_text]<BR>
		Target output temperature: <A href='?src=\ref[src];temp=-100'>-</A> <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> <A href='?src=\ref[src];temp=100'>+</A><BR>
		Power cost: <FONT color=[powercostcolor]><B>[powercost]</B><BR></FONT>
		"}


		user << browse(dat, "window=freezegun;size=501x102;can_resize=1;can_close=1;can_minimize=1")
		onclose(user, "window=freezegun", src)

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W, /obj/item/weapon/card/emag) && !emagged)
			emagged = 1
			user << "<span class='caution'>You double the gun's temperature cap ! Targets hit by searing beams will burst into flames !</span>"
			desc = "A gun that changes the body temperature of its targets. Its temperature cap has been hacked"

	Topic(href, href_list)
		if (..())
			return
		usr.set_machine(src)
		src.add_fingerprint(usr)



		if(href_list["temp"])
			var/amount = text2num(href_list["temp"])
			if(amount > 0)
				src.current_temperature = min((500 + 500*emagged), src.current_temperature+amount)
			else
				src.current_temperature = max(0, src.current_temperature+amount)
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		src.add_fingerprint(usr)
		return


	process()
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
		if(current_temperature != temperature)
			var/difference = abs(current_temperature - temperature)
			if(difference >= (10 + 40*emagged)) //so emagged temp guns adjust their temperature much more quickly
				if(current_temperature < temperature)
					temperature -= (10 + 40*emagged)
				else
					temperature += (10 + 40*emagged)
			else
				temperature = current_temperature
			update_icon()

		if(power_supply)
			power_supply.give(50)
			update_icon()
		return

	proc
		update_temperature()
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

		update_charge()
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

		update_user()
			var/mob/living/carbon/M = new /mob/living/carbon
			if (istype(loc,/mob/living/carbon))
				M = loc
				M.update_inv_back()
				M.update_inv_l_hand()
				M.update_inv_r_hand()

	update_icon()
		overlays = 0
		update_temperature()
		update_user()
		update_charge()