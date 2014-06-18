//improvised explosives//

//iedcasing assembly crafting//
/obj/item/weapon/reagent_containers/food/drinks/soda_cans/attackby(var/obj/item/I, mob/user as mob)
        if(istype(I, /obj/item/device/assembly/igniter))
                var/obj/item/device/assembly/igniter/G = I
                var/obj/item/weapon/grenade/iedcasing/W = new /obj/item/weapon/grenade/iedcasing
                user.unEquip(G)
                user.unEquip(src)
                user.put_in_hands(W)
                user << "<span  class='notice'>You stuff the [I] in the [src], emptying the contents beforehand.</span>"
                W.underlays += image(src.icon, icon_state = src.icon_state)
                qdel(I)
                qdel(src)


/obj/item/weapon/grenade/iedcasing
	name = "improvised firebomb assembly"
	desc = "An igniter stuffed into an aluminium shell."
	w_class = 2.0
	icon = 'icons/obj/grenade.dmi'
	icon_state = "improvised_grenade"
	item_state = "flashbang"
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	slot_flags = SLOT_BELT
	var/assembled = 0
	active = 1
	det_time = 50
	display_timer = 0
	var/range = 3
	var/times = list()



/obj/item/weapon/grenade/iedcasing/afterattack(atom/target, mob/user , flag) //Filling up the can
	if(assembled == 0)
		if(istype(target, /obj/structure/reagent_dispensers/fueltank) && in_range(src, target))
			if(target.reagents.total_volume < 50)
				user << "<span  class='notice'>There's not enough fuel left to work with.</span>"
				return
			var/obj/structure/reagent_dispensers/fueltank/F = target
			F.reagents.remove_reagent("fuel", 50, 1)//Deleting 50 fuel from the welding fuel tank,
			assembled = 1
			user << "<span  class='notice'>You've filled the makeshift explosive with welding fuel.</span>"
			playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
			desc = "An improvised firebomb assembly. Filled to the brim with 'Firery flavor'"
			overlays += image('icons/obj/grenade.dmi', icon_state = "improvised_grenade_filled")
			return


/obj/item/weapon/grenade/iedcasing/attackby(var/obj/item/I, mob/user as mob) //Wiring the can for ignition
	if(istype(I, /obj/item/stack/cable_coil))
		if(assembled == 1)
			var/obj/item/stack/cable_coil/C = I
			if (C.use(1))
				times = list("5" = 10, "-1" = 20, "[rand(30,80)]" = 50, "[rand(65,180)]" = 20)	// "Premature, Dud, Short Fuse, Long Fuse"=[weighting value]
				assembled = 2
				user << "<span  class='notice'>You wire the igniter to detonate the fuel.</span>"
				desc = "A weak, improvised incendiary device."
				overlays += image('icons/obj/grenade.dmi', icon_state = "improvised_grenade_wired")
				name = "improvised firebomb"
				active = 0
				det_time = text2num(pickweight(times))
				if(det_time < 0) //checking for 'duds'
					range = 1
					det_time = rand(30,80)
				else
					range = pick(2,2,2,3,3,3,4)
			else
				user <<"span class='warning'>You need one length of cable to add an igniter.</span>"
				return

/obj/item/weapon/grenade/iedcasing/attack_self(mob/user as mob) //
	if(!active)
		if(clown_check(user))
			user << "<span class='warning'>You light the [name]!</span>"
			active = 1
			overlays -= image('icons/obj/grenade.dmi', icon_state = "improvised_grenade_filled")
			icon_state = initial(icon_state) + "_active"
			assembled = 3
			add_fingerprint(user)
			var/turf/bombturf = get_turf(src)
			var/area/A = get_area(bombturf)

			message_admins("[key_name(usr)]<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A> has primed a [name] for detonation at <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[bombturf.x];Y=[bombturf.y];Z=[bombturf.z]'>[A.name] (JMP)</a>.")
			log_game("[key_name(usr)] has primed a [name] for detonation at [A.name] ([bombturf.x],[bombturf.y],[bombturf.z]).")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
			spawn(det_time)
				prime()

/obj/item/weapon/grenade/iedcasing/prime() //Blowing that can up
	update_mob()
	explosion(src.loc,-1,-1,-1, flame_range = range)	// no explosive damage, only a large fireball.
	qdel(src)

/obj/item/weapon/grenade/iedcasing/examine()
	set src in usr
	..()
	if(assembled == 3)
		usr << "You can't tell when it will explode!"
