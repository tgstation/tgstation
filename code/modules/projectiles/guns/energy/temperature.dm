/obj/item/weapon/gun/energy/temperature
	name = "temperature gun"
	icon_state = "freezegun"
	fire_sound = 'sound/weapons/pulse3.ogg'
	desc = "A gun that changes temperatures."
	var/temperature = T20C
	var/current_temperature = T20C
	charge_cost = 100
	origin_tech = "combat=3;materials=4;powerstorage=3;magnets=2"

	projectile_type = "/obj/item/projectile/temp"
	cell_type = "/obj/item/weapon/cell/crap"


	New()
		..()
		processing_objects.Add(src)


	Del()
		processing_objects.Remove(src)
		..()


	attack_self(mob/living/user as mob)
		user.set_machine(src)
		var/temp_text = ""
		if(temperature > (T0C - 50))
			temp_text = "<FONT color=black>[temperature] ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"
		else
			temp_text = "<FONT color=blue>[temperature] ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"

		var/dat = {"<B>Freeze Gun Configuration: </B><BR>
		Current output temperature: [temp_text]<BR>
		Target output temperature: <A href='?src=\ref[src];temp=-100'>-</A> <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> <A href='?src=\ref[src];temp=100'>+</A><BR>
		"}


		user << browse(dat, "window=freezegun;size=450x300;can_resize=1;can_close=1;can_minimize=1")
		onclose(user, "window=freezegun", src)


	Topic(href, href_list)
		if (..())
			return
		usr.set_machine(src)
		src.add_fingerprint(usr)



		if(href_list["temp"])
			var/amount = text2num(href_list["temp"])
			if(amount > 0)
				src.current_temperature = min(500, src.current_temperature+amount)
			else
				src.current_temperature = max(0, src.current_temperature+amount)
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		src.add_fingerprint(usr)
		return


	process()
		switch(temperature)
			if(0 to 100) charge_cost = 1000
			if(100 to 250) charge_cost = 500
			if(251 to 300) charge_cost = 100
			if(301 to 400) charge_cost = 500
			if(401 to 500) charge_cost = 1000

		if(current_temperature != temperature)
			var/difference = abs(current_temperature - temperature)
			if(difference >= 10)
				if(current_temperature < temperature)
					temperature -= 10
				else
					temperature += 10
			else
				temperature = current_temperature
		return
