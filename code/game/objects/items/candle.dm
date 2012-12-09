/obj/item/candle
	name = "red candle"
	desc = "a candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle1"
	item_state = "candle1"
	w_class = 1
	light_on = 0
	brightness_on = 3 //luminosity when on

	var/wax = 200

	proc
		light(var/flavor_text = "\red [usr] lights the [name].")


	update_icon()
		var/i
		if(wax>150)
			i = 1
		else if(wax>80)
			i = 2
		else i = 3
		icon_state = "candle[i][light_on ? "_lit" : ""]"


	attackby(obj/item/weapon/W as obj, mob/user as mob)
		..()
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.isOn()) //Badasses dont get blinded by lighting their candle with a welding tool
				light("\red [user] casually lights the [name] with [W], what a badass.")
		else if(istype(W, /obj/item/weapon/lighter))
			var/obj/item/weapon/lighter/L = W
			if(L.light_on)
				light()
		else if(istype(W, /obj/item/weapon/match))
			var/obj/item/weapon/match/M = W
			if(M.light_on)
				light()
		else if(istype(W, /obj/item/candle))
			var/obj/item/candle/C = W
			if(C.light_on)
				light()


	light(var/flavor_text = "\red [usr] lights the [name].")
		if(!src.light_on)
			src.light_on = 1
			//src.damtype = "fire"
			for(var/mob/O in viewers(usr, null))
				O.show_message(flavor_text, 1)
			SetLuminosity(brightness_on)
			processing_objects.Add(src)


	process()
		if(!light_on)
			return
		wax--
		if(!wax)
			new/obj/item/trash/candle(src.loc)
			if(istype(src.loc, /mob))
				src.dropped()
			del(src)
		update_icon()
		if(istype(loc, /turf)) //start a fire if possible
			var/turf/T = loc
			T.hotspot_expose(700, 5)


	attack_self(mob/user as mob)
		if(light_on)
			light_on = 0
			update_icon()
			SetLuminosity(0)
			user.SetLuminosity(search_light(user, src))


	pickup(mob/user)
		if(light_on)
			if (user.luminosity < brightness_on)
				user.SetLuminosity(brightness_on)
			SetLuminosity(0)


	dropped(mob/user)
		if(light_on)
			if ((layer <= 3) || (loc != user.loc))
				user.SetLuminosity(search_light(user, src))
				SetLuminosity(brightness_on)


	equipped(mob/user, slot)
		if(light_on)
			if (user.luminosity < brightness_on)
				user.SetLuminosity(brightness_on)
			SetLuminosity(0)
