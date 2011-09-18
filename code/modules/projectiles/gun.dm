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
	force = 5.0//They now do the ave damage
	origin_tech = "combat=1"

	var
		fire_sound = 'Gunshot.ogg'
		obj/item/projectile/in_chamber
		caliber = ""
		silenced = 0
		badmin = 0
		recoil = 0
	proc
		load_into_chamber()
		badmin_ammo()
		special_check(var/mob/M)


	load_into_chamber()
		in_chamber = new /obj/item/projectile/weakbullet(src)
		return 1


	badmin_ammo() //CREEEEEED!!!!!!!!!
		switch(badmin)
			if(1)
				in_chamber = new /obj/item/projectile/electrode(src)
			if(2)
				in_chamber = new /obj/item/projectile/weakbullet(src)
			if(3)
				in_chamber = new /obj/item/projectile(src)
			if(4)
				in_chamber = new /obj/item/projectile/beam(src)
			if(5)
				in_chamber = new /obj/item/projectile/beam/pulse(src)
			else
				return 0
		if(!istype(src, /obj/item/weapon/gun/energy))
			var/obj/item/ammo_casing/AC = new(get_turf(src))
			AC.name = "bullet casing"
			AC.desc = "This casing has the NT Insignia etched into the side."
		return 1


	special_check(var/mob/M) //Placeholder for any special checks, like detective's revolver.
		return 1


	emp_act(severity)
		for(var/obj/O in contents)
			O.emp_act(severity)


	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)//TODO: go over this
		if (flag)
			return //we're placing gun on a table or in backpack --rastaf0
		if(istype(target, /obj/machinery/recharger) && istype(src, /obj/item/weapon/gun/energy))
			return
		if(istype(user, /mob/living))
			var/mob/living/M = user
			if ((M.mutations & CLOWN) && prob(50))
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

		if(badmin)
			badmin_ammo()
		else if(!special_check(user))
			return
		else if(!load_into_chamber())
			user << "\red *click* *click*";
			return

		if(istype(src, /obj/item/weapon/gun/projectile/shotgun))//TODO: Get this out of here, parent objects should check child types as little as possible
			var/obj/item/weapon/gun/projectile/shotgun/S = src
			if(S.pumped >= S.maxpump)
				S.pump()
				return

		if(silenced)
			playsound(user, fire_sound, 10, 1)
		else
			playsound(user, fire_sound, 50, 1)

		if(!in_chamber)
			return

		in_chamber.firer = user
		in_chamber.def_zone = user.get_organ_target()

		if(targloc == curloc)
			user.bullet_act(in_chamber)
			del(in_chamber)
			update_icon()
			return

		if(istype(src, /obj/item/weapon/gun/energy/freeze))
			var/obj/item/projectile/freeze/F = in_chamber
			var/obj/item/weapon/gun/energy/freeze/Fgun = src
			F.temperature = Fgun.temperature

		if(recoil)
			spawn()
				shake_camera(user, recoil + 1, recoil)

		in_chamber.original = targloc
		in_chamber.loc = get_turf(user)
		user.next_move = world.time + 4
		in_chamber.silenced = silenced
		in_chamber.current = curloc
		in_chamber.yo = targloc.y - curloc.y
		in_chamber.xo = targloc.x - curloc.x
		spawn()
			in_chamber.process()
		sleep(1)
		in_chamber = null

		if(istype(src, /obj/item/weapon/gun/projectile/shotgun))
			var/obj/item/weapon/gun/projectile/shotgun/S = src
			S.pumped++
		update_icon()
		return


/obj/item/weapon/gun/projectile
	desc = "A classic revolver. Uses 357 ammo"
	name = "revolver"
	icon_state = "revolver"
	caliber = "357"
	origin_tech = "combat=2;materials=2;syndicate=6"
	w_class = 3.0
	m_amt = 1000

	var
		list/loaded = list()
		max_shells = 7
		load_method = 0 //0 = Single shells or quick loader, 1 = magazine

		// Shotgun variables
		pumped = 0
		maxpump = 1

		list/Storedshots = list()

	load_into_chamber()
		if(!loaded.len)
			if(Storedshots.len > 0)
				if(istype(src, /obj/item/weapon/gun/projectile/shotgun))
					var/obj/item/weapon/gun/projectile/shotgun/S = src
					S.pump(loc)
			return 0

		if(istype(src, /obj/item/weapon/gun/projectile/shotgun) && pumped >= maxpump)
			return 1

		var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
		loaded -= AC //Remove casing from loaded list.
		if(!istype(src, /obj/item/weapon/gun/projectile/shotgun))
			AC.loc = get_turf(src) //Eject casing onto ground.
		else
			Storedshots += AC

		if(AC.BB)
			in_chamber = AC.BB //Load projectile into chamber.
			AC.BB.loc = src //Set projectile loc to gun.
			return 1
		else
			return 0


	New()
		for(var/i = 1, i <= max_shells, i++)
			loaded += new /obj/item/ammo_casing(src)
		update_icon()

	attackby(var/obj/item/A as obj, mob/user as mob)
		var/num_loaded = 0
		if(istype(A, /obj/item/ammo_magazine))
			var/obj/item/ammo_magazine/AM = A
			for(var/obj/item/ammo_casing/AC in AM.stored_ammo)
				if(loaded.len >= max_shells)
					break
				if(AC.caliber == caliber && loaded.len < max_shells)
					AC.loc = src
					AM.stored_ammo -= AC
					loaded += AC
					num_loaded++
		else if(istype(A, /obj/item/ammo_casing) && !load_method)
			var/obj/item/ammo_casing/AC = A
			if(AC.caliber == caliber && loaded.len < max_shells)
				user.drop_item()
				AC.loc = src
				loaded += AC
				num_loaded++
		if(num_loaded)
			user << text("\blue You load [] shell\s into the gun!", num_loaded)
		A.update_icon()
		return

	update_icon()
		desc = initial(desc) + text(" Has [] rounds remaining.", loaded.len)


/obj/item/weapon/gun/energy
	icon_state = "energy"
	name = "energy gun"
	desc = "A basic energy-based gun with two settings: Stun and kill."
	fire_sound = 'Taser.ogg'
	var
		var/obj/item/weapon/cell/power_supply
		mode = 0 //0 = stun, 1 = kill
		charge_cost = 100 //How much energy is needed to fire.

	emp_act(severity)
		power_supply.use(round(power_supply.maxcharge / severity))
		update_icon()
		..()

	New()
		power_supply = new(src)
		power_supply.give(power_supply.maxcharge)

	load_into_chamber()
		if(in_chamber)
			return 1
		if(!power_supply)
			return 0
		if(power_supply.charge < charge_cost)
			return 0
		switch (mode)
			if(0)
				in_chamber = new /obj/item/projectile/electrode(src)
			if(1)
				in_chamber = new /obj/item/projectile/beam(src)
		power_supply.use(charge_cost)
		return 1

	attack_self(mob/living/user as mob)
		switch(mode)
			if(0)
				mode = 1
				charge_cost = 100
				fire_sound = 'Laser.ogg'
				user << "\red [src.name] is now set to kill."
			if(1)
				mode = 0
				charge_cost = 100
				fire_sound = 'Taser.ogg'
				user << "\red [src.name] is now set to stun."
		update_icon()
		return

	update_icon()
		var/ratio = power_supply.charge / power_supply.maxcharge
		ratio = round(ratio, 0.25) * 100
		icon_state = text("[][]", initial(icon_state), ratio)