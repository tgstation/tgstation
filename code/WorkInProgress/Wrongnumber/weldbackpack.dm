/obj/item/weapon/weldpack
	name = "Portable welding tank."
	desc = "For welding on the go!"
	icon_state = "backpack"
	w_class = 4.0
	flags = 259.0
	var/max_fuel = 100

/obj/item/weapon/weldpack/New()
	var/datum/reagents/R = new/datum/reagents(100) //5 refills
	reagents = R
	R.my_atom = src
	R.add_reagent("fuel", 100)

/obj/item/weapon/weldpack/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/weldingtool)
		if(W.welding & prob(15))
			message_admins("[key_name_admin(user)] triggered a fueltank explosion.")
			log_game("[key_name(user)] triggered a fueltank explosion.")
			user << "\red That was stupid of you."
			explosion(src.loc,-1,0,2)
			if(src)
				del(src)
			return
		else
			if(W.welding)
				user << "\red That was close!"
			src.reagents.trans_to(W, W.max_fuel)
			user << "\blue Welder refilled!"
			playsound(src.loc, 'refill.ogg', 50, 1, -6)
			return
	user << "\blue The tank scoffs at your insolence.  It only provides services to welders."
	return

/obj/item/weapon/weldpack/afterattack(obj/O as obj, mob/user as mob)
		if (istype(O, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,O) <= 1 && src.reagents.total_volume < max_fuel)
			O.reagents.trans_to(src, max_fuel)
			user << "\blue Tank refilled!"
			playsound(src.loc, 'refill.ogg', 50, 1, -6)
			return
		else if (istype(O, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,O) <= 1 && src.reagents.total_volume == max_fuel)
			user << "\blue Tank is already full!"
			return

/obj/item/weapon/weldpack/examine()
	set src in usr
	usr << text("\icon[] [] units of fuel left!", src, src.reagents.total_volume)
	..()
	return
