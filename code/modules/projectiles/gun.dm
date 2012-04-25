/obj/item/weapon/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'gun.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags =  FPRINT | TABLEPASS | CONDUCT | ONBELT | USEDELAY
	m_amt = 2000
	w_class = 3.0
	throwforce = 5
	throw_speed = 4
	throw_range = 5
	force = 5.0
	origin_tech = "combat=1"

	var
		fire_sound = 'Gunshot.ogg'
		obj/item/projectile/in_chamber = null
		caliber = ""
		silenced = 0
		recoil = 0
		ejectshell = 1

	proc
		load_into_chamber()
		special_check(var/mob/M)


	load_into_chamber()
		return 0


	special_check(var/mob/M) //Placeholder for any special checks, like detective's revolver.
		return 1


	emp_act(severity)
		for(var/obj/O in contents)
			O.emp_act(severity)



	attack(mob/M as mob, mob/user as mob)
		if(!in_chamber)
			if(!load_into_chamber())
				..() // No ammo, we're going to get bashy now.


		return// fuck you, guns.  you stick to shooting when you have ammo

	New()
		spawn(15)				// Hack, but I need to wait for sub-calls to load the gun before loading the chamber.  1.5 seconds should be fine.
			load_into_chamber()


	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, inrange, params)//TODO: go over this
		if(inrange)
			if(!doafterattack(target , src))
				return //we're placing gun on a table or in backpack.  What the fuck was the previous check?
		if(istype(target, /obj/machinery/recharger) && istype(src, /obj/item/weapon/gun/energy))
			return//Shouldnt flag take care of this?

		if(istype(user, /mob/living))
			var/mob/living/M = user
			if ((M.mutations & CLUMSY) && prob(50))
				M << "\red The [src.name] blows up in your face."
				M.take_organ_damage(0,20)
				M.drop_item()
				del(src)
				return

		if (!user.IsAdvancedToolUser())
			user << "\red You don't have the dexterity to do this!"
			return

		add_fingerprint(user)

		var/turf/curloc = user.loc
		var/turf/targloc = get_turf(target)
		if (!istype(targloc) || !istype(curloc))
			return

		if(!special_check(user))
			return
		if(!load_into_chamber())
			if(!inrange)	// If we're in range, we're just going to hit them instead of pulling the trigger.
				user << "\red *click*";
			return

		if(!in_chamber)
			return

		in_chamber.firer = user
		in_chamber.def_zone = user.zone_sel.selecting

		if(targloc == curloc)
			if(silenced)
				playsound(user, fire_sound, 10, 1)
			else
				playsound(user, fire_sound, 50, 1)
				user.visible_message("\red [user.name] fires the [src.name] at themselves!", "\red You fire the [src.name] at yourself!", "\blue You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")

			user.bullet_act(in_chamber)
			del(in_chamber)
			update_icon()
			return

		if(recoil)
			spawn()
				shake_camera(user, recoil + 1, recoil)

		if(silenced)
			playsound(user, fire_sound, 10, 1)
		else
			playsound(user, fire_sound, 50, 1)
			user.visible_message("\red [user.name] fires the [src.name]!", "\red You fire the [src.name]!", "\blue You hear a [istype(in_chamber, /obj/item/projectile/beam) ? "laser blast" : "gunshot"]!")

		in_chamber.original = targloc
		in_chamber.loc = get_turf(user)
		in_chamber.starting = get_turf(user)
		user.next_move = world.time + 4
		in_chamber.silenced = silenced
		in_chamber.current = curloc
		in_chamber.yo = targloc.y - curloc.y
		in_chamber.xo = targloc.x - curloc.x

		if(params)
			var/list/mouse_control = params2list(params)
			if(mouse_control["icon-x"])
				in_chamber.p_x = text2num(mouse_control["icon-x"])
			if(mouse_control["icon-y"])
				in_chamber.p_y = text2num(mouse_control["icon-y"])

		spawn()
			if(in_chamber)
				in_chamber.process()
		sleep(1)
		in_chamber = null

		update_icon()
		return

