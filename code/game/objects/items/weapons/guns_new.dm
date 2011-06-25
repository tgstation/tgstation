var/const/PROJECTILE_TASER = 1
var/const/PROJECTILE_LASER = 2
var/const/PROJECTILE_BULLET = 3
var/const/PROJECTILE_PULSE = 4
var/const/PROJECTILE_BOLT = 5
var/const/PROJECTILE_WEAKBULLET = 6
var/const/PROJECTILE_TELEGUN = 7
var/const/PROJECTILE_DART = 8

///////////////////////////////////////////////
////////////////AMMO SECTION///////////////////
///////////////////////////////////////////////

/obj/item/projectile
	name = "projectile"
	icon = 'projectiles.dmi'
	icon_state = "bullet"
	density = 1
	throwforce = 0.1 //an attempt to make it possible to shoot your way through space
	unacidable = 1 //Just to be sure.
	anchored = 1 // I'm not sure if it is a good idea. Bullets sucked to space and curve trajectories near singularity could be awesome. --rastaf0
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT // ONBELT???
	var
		def_zone = ""
		damage_type = PROJECTILE_BULLET
		mob/firer = null
		silenced = 0
		yo = null
		xo = null
		current = null

	weakbullet
		damage_type = PROJECTILE_WEAKBULLET

	beam
		name = "laser"
		damage_type = PROJECTILE_LASER
		icon_state = "laser"
		pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE

		pulse
			name = "pulse"
			damage_type = PROJECTILE_PULSE
			icon_state = "u_laser"

	dart
		name = "dart"
		damage_type = PROJECTILE_DART
		icon_state = "toxin"

	electrode
		name = "electrode"
		damage_type = PROJECTILE_TASER
		icon_state = "spark"

	bolt
		name = "bolt"
		damage_type = PROJECTILE_BOLT
		icon_state = "cbbolt"

	Bump(atom/A as mob|obj|turf|area)
		if(firer && istype(A, /mob))
			var/mob/M = A
			if(!silenced)
				visible_message("\red [A.name] has been shot by [firer.name].", "\blue You hear a [istype(src, /obj/item/projectile/beam) ? "gunshot" : "laser blast"].")
			else
				M << "\red You've been shot!"
			if(istype(firer, /mob))
				M.attack_log += text("[] <b>[]/[]</b> shot <b>[]/[]</b> with a <b>[]</b>", world.time, firer, firer.ckey, M, M.ckey, src)
				firer.attack_log += text("[] <b>[]/[]</b> shot <b>[]/[]</b> with a <b>[]</b>", world.time, firer, firer.ckey, M, M.ckey, src)
			else
				M.attack_log += text("[] <b>UNKOWN SUBJECT (No longer exists)</b> shot <b>[]/[]</b> with a <b>[]</b>", world.time, M, M.ckey, src)
		spawn(0)
			if(A)
				A.bullet_act(damage_type, src, def_zone)
				if(istype(A,/turf) && !istype(src, /obj/item/projectile/beam))
					for(var/obj/O in A)
						O.bullet_act(damage_type, src, def_zone)
			del(src)
		return

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group || (height==0)) return 1

		if(istype(mover, /obj/item/projectile))
			return prob(95)
		else
			return 1

	process()
		spawn while(src)
			if ((!( current ) || loc == current))
				current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)
			if ((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
				del(src)
				return
			step_towards(src, current)
			sleep( 1 )
		return

/obj/item/ammo_casing
	name = "bullet casing (.375)"
	desc = "A .357 bullet casing."
	icon = 'ammo.dmi'
	icon_state = "s-casing"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	throwforce = 1
	var
		caliber = "357" //Which kind of guns it can be loaded into
		obj/item/projectile/BB //The loaded bullet
	New()
		BB = new /obj/item/projectile(src)
		pixel_x = rand(-10.0, 10)
		pixel_y = rand(-10.0, 10)
		dir = pick(cardinal)


	c38
		name = "bullet casing (.38)"
		desc = "A .38 bullet casing."
		caliber = "38"

		New()
			BB = new /obj/item/projectile/weakbullet(src)
			pixel_x = rand(-10.0, 10)
			pixel_y = rand(-10.0, 10)
			dir = pick(cardinal)

	shotgun
		desc = "A 12gauge shell."
		name = "12 gauge shell"
		icon_state = "gshell"
		caliber = "shotgun"
		m_amt = 25000

		New()
			BB = new /obj/item/projectile
			src.pixel_x = rand(-10.0, 10)
			src.pixel_y = rand(-10.0, 10)
		blank
			desc = "A blank shell."
			name = "blank shell"
			icon_state = "blshell"
			m_amt = 500

			New()
				src.pixel_x = rand(-10.0, 10)
				src.pixel_y = rand(-10.0, 10)

		beanbag
			desc = "A weak beanbag shell."
			name = "beanbag shell"
			icon_state = "bshell"
			m_amt = 10000

			New()
				BB = new /obj/item/projectile/weakbullet
				src.pixel_x = rand(-10.0, 10)
				src.pixel_y = rand(-10.0, 10)

		dart
			desc = "A dart for use in shotguns.."
			name = "shotgun dart"
			icon_state = "blshell" //someone, draw the icon, please.
			m_amt = 50000 //because it's like, instakill.

			New()
				BB = new /obj/item/projectile/dart
				src.pixel_x = rand(-10.0, 10)
				src.pixel_y = rand(-10.0, 10)

/obj/item/ammo_magazine
	name = "ammo box (.357)"
	desc = "A box of .357 ammo"
	icon_state = "357"
	icon = 'ammo.dmi'
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	item_state = "syringe_kit"
	m_amt = 50000
	throwforce = 2
	w_class = 1.0
	throw_speed = 4
	throw_range = 20
	var
		list/stored_ammo = list()

	New()
		for(var/i = 1, i <= 7, i++)
			stored_ammo += new /obj/item/ammo_casing(src)
		update_icon()

	update_icon()
		icon_state = text("[initial(icon_state)]-[]", stored_ammo.len)
		desc = text("There are [] shell\s left!", stored_ammo.len)

	c38
		name = "speed loader (.38)"
		icon_state = "38"
		New()
			for(var/i = 1, i <= 7, i++)
				stored_ammo += new /obj/item/ammo_casing/c38(src)
			update_icon()
/*
	shotgun
		name = "ammo box (12gauge)"
		desc = "A box of 12 gauge shell"
		icon_state = "" //no sprite :'(
		caliber = "shotgun"
		m_amt = 25000

		New()
			BB = new /obj/item/projectile/shotgun(src)
			src.pixel_x = rand(-10.0, 10)
			src.pixel_y = rand(-10.0, 10)
*/
///////////////////////////////////////////////
//////////////////////Guns/////////////////////
///////////////////////////////////////////////

/obj/item/weapon/gun
	name = "gun"
	desc = "Its a gun. It's pretty terrible, though."
	icon = 'gun.dmi'
	icon_state = "detective"
	item_state = "gun"
	flags =  FPRINT | TABLEPASS | CONDUCT | ONBELT | USEDELAY
	m_amt = 2000
	w_class = 2.0
	throw_speed = 4
	throwforce = 5
	throw_range = 10
	force = 10

	origin_tech = "combat=1"
	var
		fire_sound = 'Gunshot.ogg'
		obj/item/projectile/in_chamber
		caliber = ""
		silenced = 0
		badmin = 0

	projectile
		desc = "A classic revolver. Uses 357 ammo"
		name = "revolver"
		icon_state = "revolver"
		caliber = "357"
		origin_tech = "combat=2;materials=2"
		w_class = 3.0
		throw_speed = 2
		throw_range = 10
		m_amt = 1000
		force = 24
		var
			list/loaded = list()
			max_shells = 7
			load_method = 0 //0 = Single shells or quick loader, 1 = magazine

		load_into_chamber()
			if(!loaded.len)
				return 0
			var/obj/item/ammo_casing/AC = loaded[1] //load next casing.
			loaded -= AC //Remove casing from loaded list.
			AC.loc = get_turf(src) //Eject casing onto ground.
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

		detective
			desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
			name = ".38 revolver"
			icon_state = "detective"
			force = 14.0
			caliber = "38"

			New()
				for(var/i = 1, i <= max_shells, i++)
					loaded += new /obj/item/ammo_casing/c38(src)
				update_icon()

			special_check(var/mob/living/carbon/human/M)
				if(istype(M))
					if(istype(M.w_uniform, /obj/item/clothing/under/det) && istype(M.head, /obj/item/clothing/head/det_hat) && istype(M.wear_suit, /obj/item/clothing/suit/det_suit))
						return 1
					M << "\red You just don't feel cool enough to use this gun looking like that."
				return 0
		mateba
			name = "mateba"
			desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."
			icon_state = "mateba"

		shotgun
			name = "shotgun"
			desc = "Useful for sweeping alleys."
			icon_state = "shotgun"
			max_shells = 2
			w_class = 4.0
			force = 7.0
			caliber = "shotgun"

			New()
				for(var/i = 1, i <= max_shells, i++)
					loaded += new /obj/item/ammo_casing/shotgun/beanbag(src)
				update_icon()

			combat
				name = "combat shotgun"
				icon_state = "cshotgun"
				w_class = 4.0
				force = 12.0
				flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
				max_shells = 8
				origin_tech = "combat=3"
				New()
					for(var/i = 1, i <= max_shells, i++)
						loaded += new /obj/item/ammo_casing/shotgun(src)
					update_icon()

	energy
		icon_state = "energy"
		name = "energy"
		desc = "A basic energy-based gun with two settings: Stun and kill."
		fire_sound = 'Laser.ogg'
		var
			var/obj/item/weapon/cell/power_supply
			mode = 0 //0 = stun, 1 = kill
			charge_cost = 100 //How much energy is needed to fire.

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
					user << "\red [src.name] is now set to kill."
				if(1)
					mode = 0
					charge_cost = 100
					user << "\red [src.name] is now set to stun."
			update_icon()
			return

		update_icon()
			var/ratio = power_supply.charge / power_supply.maxcharge
			ratio = round(ratio, 0.25) * 100
			icon_state = text("[][]", initial(icon_state), ratio)

		laser
			name = "laser gun"
			icon_state = "laser"
			w_class = 3.0
			throw_speed = 2
			throw_range = 10
			force = 7.0
			m_amt = 2000
			origin_tech = "combat=3;magnets=2"

			captain
				icon_state = "caplaser"
				desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
				force = 10
				origin_tech = null //forgotten technology of ancients lol

			cyborg
				load_into_chamber()
					if(in_chamber)
						return 1
					if(isrobot(src.loc))
						var/mob/living/silicon/robot/R = src.loc
						R.cell.use(20)
						in_chamber = new /obj/item/projectile/beam(src)
						return 1
					return 0

		pulse_rifle
			name = "pulse rifle"
			desc = "A heavy-duty, pulse-based energy weapon with multiple fire settings, preferred by front-line combat personnel."
			icon_state = "pulse"
			force = 15
			mode = 2
			fire_sound = 'pulse.ogg'
			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge < charge_cost)
					return 0
				switch (mode)
					if(0)
						in_chamber = new /obj/item/projectile/electrode(src)
					if(1)
						in_chamber = new /obj/item/projectile/beam(src)
					if(2)
						in_chamber = new /obj/item/projectile/beam/pulse(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				mode++
				switch(mode)
					if(1)
						user << "\red [src.name] is now set to kill."
						charge_cost = 100
					if(2)
						user << "\red [src.name] is now set to destroy."
						charge_cost = 200
					else
						mode = 0
						user << "\red [src.name] is now set to stun."
						charge_cost = 50
			New()
				power_supply = new /obj/item/weapon/cell/super(src)
				power_supply.give(power_supply.maxcharge)
				update_icon()

			destroyer
				name = "pulse destroyer"
				desc = "A heavy-duty, pulse-based energy weapon. The mode is set to DESRTOY. Always destroy."
				mode = 2
				New()
					power_supply = new /obj/item/weapon/cell/infinite(src)
					power_supply.give(power_supply.maxcharge)
					update_icon()
				attack_self(mob/living/user as mob)
					return

		nuclear
			name = "Advanced Energy Gun"
			desc = "An energy gun with an experimental miniaturized reactor."
			origin_tech = "combat=3;materials=5;powerstorage=3"
			var/lightfail = 0
			icon_state = "nucgun"

			New()
				..()
				charge()

			proc
				charge()
					if(power_supply.charge < power_supply.maxcharge)
						if(failcheck())
							power_supply.give(100)
					update_icon()
					if(!crit_fail)
						spawn(50) charge()

				failcheck()
					lightfail = 0
					if (prob(src.reliability)) return 1 //No failure
					if (prob(src.reliability))
						for (var/mob/M in range(0,src)) //Only a minor failure, enjoy your radiation if you're in the same tile or carrying it
							if (src in M.contents)
								M << "\red Your gun feels pleasantly warm for a moment."
							else
								M << "\red You feel a warm sensation."
							M.radiation += rand(1,40)
						lightfail = 1
					else
						for (var/mob/M in range(rand(1,4),src)) //Big failure, TIME FOR RADIATION BITCHES
							if (src in M.contents)
								M << "\red Your gun's reactor overloads!"
							M << "\red You feel a wave of heat wash over you."
							M.radiation += 100
						crit_fail = 1 //break the gun so it stops recharging
						update_icon()

				update_charge()
					if (crit_fail)
						overlays += "nucgun-whee"
						return
					var/ratio = power_supply.charge / power_supply.maxcharge
					ratio = round(ratio, 0.25) * 100
					overlays += text("nucgun-[]", ratio)

				update_reactor()
					if(crit_fail)
						overlays += "nucgun-crit"
						return
					if(lightfail)
						overlays += "nucgun-medium"
					else if ((power_supply.charge/power_supply.maxcharge) <= 0.5)
						overlays += "nucgun-light"
					else
						overlays += "nucgun-clean"

				update_mode()
					if (mode == 2)
						overlays += "nucgun-stun"
					else if (mode == 1)
						overlays += "nucgun-kill"

			emp_act(severity)
				..()
				reliability -= round(15/severity)

			update_icon()
				overlays = null
				update_charge()
				update_reactor()
				update_mode()

		taser
			name = "taser gun"
			icon_state = "taser"
			fire_sound = 'Taser.ogg'
			charge_cost = 100

			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge <= charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/electrode(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				return

			New()
				power_supply = new /obj/item/weapon/cell/crap(src)
				power_supply.give(power_supply.maxcharge)

			cyborg
				load_into_chamber()
					if(in_chamber)
						return 1
					if(isrobot(src.loc))
						var/mob/living/silicon/robot/R = src.loc
						R.cell.use(20)
						in_chamber = new /obj/item/projectile/electrode(src)
						return 1
					return 0

		crossbow
			name = "mini energy-crossbow"
			desc = "A weapon favored by many of the syndicates stealth specialists."
			icon_state = "crossbow"
			w_class = 2.0
			item_state = "crossbow"
			force = 4.0
			throw_speed = 2
			throw_range = 10
			m_amt = 2000
			origin_tech = "combat=2;magnets=2;syndicate=2"
			silenced = 1
			fire_sound = 'Genhit.ogg'

			New()
				power_supply = new /obj/item/weapon/cell/crap(src)
				power_supply.give(power_supply.maxcharge)
				charge()

			proc/charge()
				if(power_supply)
					if(power_supply.charge < power_supply.maxcharge) power_supply.give(100)
				spawn(50) charge()

			update_icon()
				return

			attack_self(mob/living/user as mob)
				return

			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge <= charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/bolt(src)
				power_supply.use(charge_cost)
				return 1

			cyborg
				load_into_chamber()
					if(in_chamber)
						return 1
					if(isrobot(src.loc))
						var/mob/living/silicon/robot/R = src.loc
						R.cell.use(20)
						in_chamber = new /obj/item/projectile/electrode(src)
						return 1
					return 0
	proc
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
				AC.name = "unidentifiable bullet casing"
				AC.desc = "This casing has the Central Command Insignia etched into the side."
			return 1

		special_check(var/mob/M) //Placeholder for any special checks, like detective's revolver.
			return 1

	emp_act(severity)
		for(var/obj/O in contents)
			O.emp_act(severity)

	afterattack(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, flag)
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
		if ( ! (istype(usr, /mob/living/carbon/human) || \
			istype(usr, /mob/living/silicon/robot) || \
			istype(usr, /mob/living/carbon/monkey) && ticker && ticker.mode.name == "monkey") )
			usr << "\red You don't have the dexterity to do this!"
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

		update_icon()

		playsound(user, fire_sound, 50, 1)

		if(!in_chamber)
			return

		in_chamber.firer = user
		in_chamber.def_zone = user.get_organ_target()

		if(targloc == curloc)
			user.bullet_act(in_chamber.damage_type)
			del(in_chamber)
		else
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
