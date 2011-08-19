#define BRUTE "brute"
#define BURN "burn"
#define TOX "tox"
#define OXY "oxy"
#define CLONE "clone"

#define ADD "add"
#define SET "set"



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
	mouse_opacity = 0
	var
		def_zone = ""
		//damage_type = PROJECTILE_BULLET
		mob/firer = null
		silenced = 0
		yo = null
		xo = null
		current = null
		turf/original = null

		damage = 51		// damage dealt by projectile. This is used for machinery, livestock, anything not under /mob heirarchy
		flag = "bullet" // identifier flag (bullet, laser, bio, rad, taser). This is to identify what kind of armor protects against the shot


		nodamage = 0 // determines if the projectile will skip any damage inflictions
		list/mobdamage = list(BRUTE = 50, BURN = 0, TOX = 0, OXY = 0, CLONE = 0) // determines what kind of damage it does to mobs
		list/effects = list("stun" = 0, "weak" = 0, "paralysis" = 0, "stutter" = 0, "drowsyness" = 0, "radiation" = 0, "eyeblur" = 0, "emp" = 0) // long list of effects a projectile can inflict on something. !!MUY FLEXIBLE!!~
		list/effectprob = list("stun" = 100, "weak" = 100, "paralysis" = 100, "stutter" = 100, "drowsyness" = 100, "radiation" = 100, "eyeblur" = 100, "emp" = 100) // Probability for an effect to execute
		list/effectmod = list("stun" = SET, "weak" = SET, "paralysis" = SET, "stutter" = SET, "drowsyness" = SET, "radiation" = SET, "eyeblur" = SET, "emp" = SET) // determines how the effect modifiers will effect a mob's variable


		bumped = 0

	weakbullet
		damage = 8
		mobdamage = list(BRUTE = 8, BURN = 0, TOX = 0, OXY = 0, CLONE = 0)
		New()
			..()
			effects["weak"] = 15
			effects["stun"] = 15
			effects["stutter"] = 5
			effects["eyeblur"] = 5


	suffocationbullet
		damage = 65
		mobdamage = list(BRUTE = 50, BURN = 0, TOX = 0, OXY = 15, CLONE = 0)

	cyanideround
		damage = 100
		mobdamage = list(BRUTE = 50, BURN = 0, TOX = 100, OXY = 15, CLONE = 0)

	burstbullet
		damage = 20
		mobdamage = list(BRUTE = 20, BURN = 0, TOX = 0, OXY = 0, CLONE = 0)

	beam
		name = "laser"
		icon_state = "laser"
		pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
		damage = 20
		mobdamage = list(BRUTE = 0, BURN = 20, TOX = 0, OXY = 0, CLONE = 0)
		flag = "laser"
		New()
			..()
			effects["eyeblur"] = 5
			effectprob["eyeblur"] = 50

		pulse
			name = "pulse"
			icon_state = "u_laser"
			damage = 50
			mobdamage = list(BRUTE = 10, BURN = 40, TOX = 0, OXY = 0, CLONE = 0)

	heavylaser
		name = "heavy laser"
		icon_state = "heavylaser"
		pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
		damage = 40
		mobdamage = list(BRUTE = 0, BURN = 40, TOX = 0, OXY = 0, CLONE = 0)
		flag = "laser"
		New()
			..()
			effects["eyeblur"] = 10
			effectprob["eyeblur"] = 100

	deathlaser
		name = "death laser"
		icon_state = "heavylaser"
		pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
		damage = 60
		mobdamage = list(BRUTE = 10, BURN = 60, TOX = 0, OXY = 0, CLONE = 0)
		flag = "laser"
		New()
			..()
			effects["eyeblur"] = 20
			effectprob["eyeblur"] = 100
			effects["weak"] = 5
			effectprob["weak"] = 15

	fireball
		name = "shock"
		icon_state = "fireball"
		pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
		damage = 25
		mobdamage = list(BRUTE = 0, BURN = 25, TOX = 0, OXY = 0, CLONE = 0)
		flag = "laser"
		New()
			..()
			effects["stun"] = 10
			effects["weak"] = 10
			effects["stutter"] = 10
			effectprob["weak"] = 25

	declone
		name = "declown"
		icon_state = "declone"
		pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE
		damage = 0
		mobdamage = list(BRUTE = 0, BURN = 0, TOX = 0, OXY = 0, CLONE = 40)
		flag = "bio"
		New()
			..()
			effects["radiation"] = 70
			effectmod["radiation"] = ADD

	dart
		name = "dart"
		icon_state = "toxin"
		flag = "bio"
		damage = 0
		mobdamage = list(BRUTE = 0, BURN = 0, TOX = 10, OXY = 0, CLONE = 0)
		New()
			..()
			effects["weak"] = 5
			effectmod["weak"] = ADD

	electrode
		name = "electrode"
		icon_state = "spark"
		flag = "taser"
		damage = 0
		nodamage = 1
		New()
			..()
			effects["stun"] = 10
			effects["weak"] = 10
			effects["stutter"] = 10
			effectprob["weak"] = 25

	stunshot
		name = "stunshot"
		icon_state = "bullet"
		flag = "stunshot"
		damage = 5
		mobdamage = list(BRUTE = 5, BURN = 0, TOX = 0, OXY = 0, CLONE = 0)
		New()
			..()
			effects["stun"] = 20
			effects["weak"] = 20
			effects["stutter"] = 20
			effectprob["weak"] = 45

	bolt
		name = "bolt"
		icon_state = "cbbolt"
		flag = "rad"
		damage = 0
		nodamage = 1
		New()
			..()
			effects["radiation"] = 20
			effectprob["radiation"] = 95
			effects["drowsyness"] = 5
			effectprob["drowsyness"] = 10
			effectmod["radiation"] = ADD
			effectmod["drowsyness"] = SET

	largebolt
		name = "largebolt"
		icon_state = "cbbolt"
		flag = "rad"
		damage = 20
		mobdamage = list(BRUTE = 10, BURN = 0, TOX = 10, OXY = 0, CLONE = 0)
		New()
			..()
			effects["radiation"] = 40
			effectprob["radiation"] = 95
			effects["drowsyness"] = 10
			effectprob["drowsyness"] = 25
			effectmod["radiation"] = ADD
			effectmod["drowsyness"] = SET

	freeze
		name = "freeze beam"
		icon_state = "ice_2"
		damage = 0
		var/temperature = 0

		proc/Freeze(atom/A as mob|obj|turf|area)
			if(istype(A, /mob))
				var/mob/M = A
				if(M.bodytemperature > temperature)
					M.bodytemperature = temperature

	plasma
		name = "plasma blast"
		icon_state = "plasma_2"
		damage = 0
		var/temperature = 800

		proc/Heat(atom/A as mob|obj|turf|area)
			if(istype(A, /mob/living/carbon))
				var/mob/M = A
				if(M.bodytemperature < temperature)
					M.bodytemperature = temperature




	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return // cannot shoot yourself

		if(bumped) return

		bumped = 1
		if(firer && istype(A, /mob))
			var/mob/M = A
			if(!istype(A, /mob/living))
				loc = A.loc
				return // nope.avi

			if(!silenced)
				/*
				for(var/mob/O in viewers(M))
					O.show_message("\red [A.name] has been shot by [firer.name]!", 1) */

				visible_message("\red [A.name] has been shot by [firer.name]!", "\blue You hear a [istype(src, /obj/item/projectile/beam) ? "gunshot" : "laser blast"]!")
			else
				M << "\red You've been shot!"
			if(istype(firer, /mob))
				M.attack_log += text("\[[]\] <b>[]/[]</b> shot <b>[]/[]</b> with a <b>[]</b>", time_stamp(), firer, firer.ckey, M, M.ckey, src)
				firer.attack_log += text("\[[]\] <b>[]/[]</b> shot <b>[]/[]</b> with a <b>[]</b>", time_stamp(), firer, firer.ckey, M, M.ckey, src)
			else
				M.attack_log += text("\[[]\] <b>UNKOWN SUBJECT (No longer exists)</b> shot <b>[]/[]</b> with a <b>[]</b>", time_stamp(), M, M.ckey, src)
		spawn(0)
			if(A)

				if(istype(src, /obj/item/projectile/freeze))
					var/obj/item/projectile/freeze/F = src
					F.Freeze(A)
				else if(istype(src, /obj/item/projectile/plasma))
					var/obj/item/projectile/plasma/P = src
					P.Heat(A)
				else

					A.bullet_act(src, def_zone)
					if(istype(A,/turf) && !istype(src, /obj/item/projectile/beam))
						for(var/obj/O in A)
							O.bullet_act(src, def_zone)

			// Okay this code, along with the sleep(10) {del(src)} up ahead is to make
			// sure the projectile doesn't cut off any procs it's executing. this may seem
			// incredibly stupid, I know, but it's to workaround pesky runtime error spam
			invisibility = 101
			loc = locate(1,1,1)

		sleep(10)
		del(src) // wait exactly 1 second, then delete itself. See above comments ^

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

			if(!bumped)
				if(loc == original)
					for(var/mob/living/M in original)
						Bump(M)
						sleep( 1 )

		return

/obj/item/ammo_casing
	name = "bullet casing (.375)"
	desc = "A .357 bullet casing."
	icon = 'ammo.dmi'
	icon_state = "s-casing"
	flags = FPRINT | TABLEPASS | CONDUCT | ONBELT
	throwforce = 1
	w_class = 1.0
	var
		caliber = "357" //Which kind of guns it can be loaded into
		obj/item/projectile/BB //The loaded bullet
	New()
		BB = new /obj/item/projectile(src)
		pixel_x = rand(-10.0, 10)
		pixel_y = rand(-10.0, 10)
		dir = pick(cardinal)


	a418
		name = "bullet casing (.418)"
		desc = "A .418 bullet casing."
		caliber = "357"

		New()
			BB = new /obj/item/projectile/suffocationbullet(src)
			pixel_x = rand(-10.0, 10)
			pixel_y = rand(-10.0, 10)
			dir = pick(cardinal)

	a666
		name = "bullet casing (.666)"
		desc = "A .666 bullet casing."
		caliber = "357"

		New()
			BB = new /obj/item/projectile/cyanideround(src)
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

	c9mm
		name = "bullet casing (9mm)"
		desc = "A 9mm bullet casing."
		caliber = "9mm"

		New()
			BB = new /obj/item/projectile/weakbullet(src)
			pixel_x = rand(-10.0, 10)
			pixel_y = rand(-10.0, 10)
			dir = pick(cardinal)

	c45
		name = "bullet casing (.45)"
		desc = "A .45 bullet casing."
		caliber = ".45"

		New()
			BB = new /obj/item/projectile(src)
			pixel_x = rand(-10.0, 10)
			pixel_y = rand(-10.0, 10)
			dir = pick(cardinal)


	shotgun
		desc = "A 12gauge shell."
		name = "12 gauge shell"
		icon_state = "gshell"
		caliber = "shotgun"
		m_amt = 12500

		New()
			BB = new /obj/item/projectile
			src.pixel_x = rand(-10.0, 10)
			src.pixel_y = rand(-10.0, 10)
		blank
			desc = "A blank shell."
			name = "blank shell"
			icon_state = "blshell"
			m_amt = 250

			New()
				src.pixel_x = rand(-10.0, 10)
				src.pixel_y = rand(-10.0, 10)

		beanbag
			desc = "A weak beanbag shell."
			name = "beanbag shell"
			icon_state = "bshell"
			m_amt = 500

			New()
				BB = new /obj/item/projectile/weakbullet
				src.pixel_x = rand(-10.0, 10)
				src.pixel_y = rand(-10.0, 10)

		stunshell
			desc = "A stunning shell."
			name = "stun shell"
			icon_state = "stunshell"
			m_amt = 2500

			New()
				BB = new /obj/item/projectile/stunshot
				src.pixel_x = rand(-10.0, 10)
				src.pixel_y = rand(-10.0, 10)

		dart
			desc = "A dart for use in shotguns.."
			name = "shotgun darts"
			icon_state = "blshell" //someone, draw the icon, please.
			m_amt = 50000 //because it's like, instakill.

			New()
				BB = new /obj/item/projectile/dart
				src.pixel_x = rand(-10.0, 10)
				src.pixel_y = rand(-10.0, 10)


/obj/item/ammo_casing/attackby(obj/item/weapon/W as obj, mob/user as mob) //Adding this to the trash list. Nyoro~n --Agouri
	..()
	if (istype(W, /obj/item/weapon/trashbag))
		var/obj/item/weapon/trashbag/S = W
		if (S.mode == 1)
			for (var/obj/item/ammo_casing/AC in locate(src.x,src.y,src.z))
				if (S.contents.len < S.capacity)
					S.contents += AC;
				else
					user << "\blue The bag is full."
					break
			user << "\blue You pick up all trash."
		else
			if (S.contents.len < S.capacity)
				S.contents += src;
			else
				user << "\blue The bag is full."
		S.update_icon()
	return

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

	a418
		name = "ammo box (.418)"
		icon_state = "418"
		New()
			for(var/i = 1, i <= 7, i++)
				stored_ammo += new /obj/item/ammo_casing/a418(src)
			update_icon()

	a666
		name = "ammo box (.666)"
		icon_state = "666"
		New()
			for(var/i = 1, i <= 2, i++)
				stored_ammo += new /obj/item/ammo_casing/a666(src)
			update_icon()

	c9mm
		name = "Ammunition Box (9mm)"
		icon_state = "9mm"
		origin_tech = "combat=3;materials=2"
		New()
			for(var/i = 1, i <= 30, i++)
				stored_ammo += new /obj/item/ammo_casing/c9mm(src)
			update_icon()

		update_icon()
			desc = text("There are [] round\s left!", stored_ammo.len)

	c45
		name = "Ammunition Box (.45)"
		icon_state = "9mm"
		origin_tech = "combat=3;materials=2"
		New()
			for(var/i = 1, i <= 30, i++)
				stored_ammo += new /obj/item/ammo_casing/c45(src)
			update_icon()

		update_icon()
			desc = text("There are [] round\s left!", stored_ammo.len)

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
	w_class = 3.0
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
		origin_tech = "combat=2;materials=2;syndicate=6"
		w_class = 3.0
		throw_speed = 2
		throw_range = 10
		m_amt = 1000
		force = 24

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

		detective
			desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38-Special rounds."
			name = ".38 revolver"
			icon_state = "detective"
			force = 14.0
			caliber = "38"
			origin_tech = "combat=2;materials=2"

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

			verb
				rename_gun()
					set name = "Name Gun"
					set desc = "Click to rename your gun. If you're the detective."

					var/mob/U = usr
					if(ishuman(U)&&U.mind&&U.mind.assigned_role=="Detective")
						var/input = input("What do you want to name the gun?",,"")
						input = sanitize(input)
						if(input)
							if(in_range(U,src)&&(!isnull(src))&&!U.stat)
								name = input
								U << "You name the gun [input]. Say hello to your new friend."
							else
								U << "\red Can't let you do that, detective!"
					else
						U << "\red You don't feel cool enough to name this gun, chump."

		mateba
			name = "mateba"
			desc = "When you absolutely, positively need a 10mm hole in the other guy. Uses .357 ammo."
			icon_state = "mateba"
			origin_tech = "combat=2;materials=2"

		shotgun
			name = "shotgun"
			desc = "Useful for sweeping alleys."
			icon_state = "shotgun"
			max_shells = 2
			w_class = 4.0
			force = 7.0
			flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
			caliber = "shotgun"
			origin_tech = "combat=2;materials=2"
			var/recentpump = 0 // to prevent spammage

			New()
				for(var/i = 1, i <= max_shells, i++)
					loaded += new /obj/item/ammo_casing/shotgun/beanbag(src)
				update_icon()

			attack_self(mob/living/user as mob)
				if(recentpump) return
				pump()
				recentpump = 1
				sleep(10)
				recentpump = 0
				return

			combat
				name = "combat shotgun"
				icon_state = "cshotgun"
				w_class = 4.0
				force = 12.0
				flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
				max_shells = 8
				origin_tech = "combat=3"
				maxpump = 1
				New()
					for(var/i = 1, i <= max_shells, i++)
						loaded += new /obj/item/ammo_casing/shotgun(src)
					update_icon()

			combat2
				name = "security combat shotgun"
				icon_state = "cshotgun"
				w_class = 4.0
				force = 10.0
				flags =  FPRINT | TABLEPASS | CONDUCT | USEDELAY | ONBACK
				max_shells = 4
				origin_tech = "combat=3"
				maxpump = 1
				New()
					for(var/i = 1, i <= max_shells, i++)
						loaded += new /obj/item/ammo_casing/shotgun/beanbag(src)
					update_icon()

			proc/pump(mob/M)
				playsound(M, 'shotgunpump.ogg', 60, 1)
				pumped = 0
				for(var/obj/item/ammo_casing/AC in Storedshots)
					Storedshots -= AC //Remove casing from loaded list.
					AC.loc = get_turf(src) //Eject casing onto ground.

		automatic //Hopefully someone will find a way to make these fire in bursts or something. --Superxpdude
			name = "Submachine Gun"
			desc = "A lightweight, fast firing gun. Uses 9mm rounds."
			icon_state = "saber"
			w_class = 3.0
			force = 7
			max_shells = 18
			caliber = "9mm"
			origin_tech = "combat=4;materials=2"

			New()
				for(var/i = 1, i <= max_shells, i++)
					loaded += new /obj/item/ammo_casing/c9mm(src)
				update_icon()

			mini_uzi
				name = "Mini-Uzi"
				desc = "A lightweight, fast firing gun, for when you REALLY need someone dead. Uses .45 rounds."
				icon_state = "mini-uzi"
				w_class = 3.0
				force = 16
				max_shells = 20
				caliber = ".45"
				origin_tech = "combat=5;materials=2;syndicate=8"

				New()
					for(var/i = 1, i <= max_shells, i++)
						loaded += new /obj/item/ammo_casing/c45(src)
					update_icon()

		silenced
			name = "Silenced Pistol"
			desc = "A small, quiet,  easily concealable gun. Uses .45 rounds."
			icon_state = "silenced_pistol"
			w_class = 3.0
			force = 14.0
			max_shells = 12
			caliber = ".45"
			silenced = 1
			origin_tech = "combat=2;materials=2;syndicate=8"

			New()
				for(var/i = 1, i <= max_shells, i++)
					loaded += new /obj/item/ammo_casing/c45(src)
				update_icon()

	energy
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

		laser
			name = "laser gun"
			icon_state = "laser"
			fire_sound = 'Laser.ogg'
			w_class = 3.0
			throw_speed = 2
			throw_range = 10
			force = 7.0
			m_amt = 2000
			origin_tech = "combat=3;magnets=2"
			mode = 1 //We don't want laser guns to be on a stun setting. --Superxpdude

			attack_self(mob/living/user as mob)
				return // We don't want laser guns to be able to change to a stun setting. --Superxpdude

			captain
				icon_state = "caplaser"
				desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
				force = 10
				origin_tech = null //forgotten technology of ancients lol

				New()
					..()
					charge()

				proc
					charge()
						if(power_supply.charge < power_supply.maxcharge)
							power_supply.give(100)
						update_icon()
						spawn(50) charge()
						//Added this to the cap's laser back before the gun overhaul to make it halfways worth stealing. It's back now. --NEO

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
						fire_sound = 'Laser.ogg'
						charge_cost = 100
					if(2)
						user << "\red [src.name] is now set to destroy."
						fire_sound = 'pulse.ogg'
						charge_cost = 200
					else
						mode = 0
						user << "\red [src.name] is now set to stun."
						fire_sound = 'Taser.ogg'
						charge_cost = 50
			New()
				power_supply = new /obj/item/weapon/cell/super(src)
				power_supply.give(power_supply.maxcharge)
				update_icon()

			destroyer
				name = "pulse destroyer"
				desc = "A heavy-duty, pulse-based energy weapon. The mode is set to DESTROY. Always destroy."
				mode = 2
				New()
					power_supply = new /obj/item/weapon/cell/infinite(src)
					power_supply.give(power_supply.maxcharge)
					update_icon()
				attack_self(mob/living/user as mob)
					return
			M1911
				name = "m1911-P"
				desc = "It's not the size of the gun, it's the size of the hole it puts through people."
				icon_state = "m1911-p"
				New()
					power_supply = new /obj/item/weapon/cell/infinite(src)
					power_supply.give(power_supply.maxcharge)
					update_icon()

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
			desc = "A small, low capacity gun used for non-lethal takedowns."
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

		lasercannon
			name = "laser cannon"
			desc = "A heavy-duty laser cannon."
			icon_state = "lasercannon"
			force = 15
			fire_sound = 'lasercannonfire.wav'
			origin_tech = "combat=4;materials=3;powerstorage=3"
			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge < charge_cost)
					return 0
				switch(mode)
					if(0)
						in_chamber = new /obj/item/projectile/heavylaser(src)
					if(1)
						in_chamber = new /obj/item/projectile/beam(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				mode = !mode
				switch(mode)
					if(0)
						user << "\red [src.name] is now set to laser cannon."
						fire_sound = 'lasercannonfire.wav'
						charge_cost = 100
					if(1)
						user << "\red [src.name] is now set to laser."
						fire_sound = 'Laser.ogg'
						charge_cost = 50
			New()
				power_supply = new /obj/item/weapon/cell(src)
				power_supply.give(power_supply.maxcharge)
				update_icon()

		shockgun
			name = "shock gun"
			desc = "A high tech energy weapon that stuns and burns a target."
			icon_state = "shockgun"
			fire_sound = 'Laser.ogg'
			origin_tech = "combat=5;materials=4;powerstorage=3"
			charge_cost = 250

			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge <= charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/fireball(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				return

			New()
				power_supply = new /obj/item/weapon/cell(src)
				power_supply.give(power_supply.maxcharge)

		decloner
			name = "biological demolecularisor"
			desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
			icon_state = "decloner"
			fire_sound = 'pulse3.ogg'
			origin_tech = "combat=5;materials=4;powerstorage=3"
			charge_cost = 100

			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge <= charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/declone(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				return

			New()
				power_supply = new /obj/item/weapon/cell(src)
				power_supply.give(power_supply.maxcharge)

		stunrevolver
			name = "stun revolver"
			desc = "A high-tech revolver that fires stun cartridges. The stun cartridges can be recharged using a conventional energy weapon recharger."
			icon_state = "stunrevolver"
			fire_sound = 'Gunshot.ogg'
			origin_tech = "combat=3;materials=3;powerstorage=2"
			charge_cost = 125

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
				power_supply = new /obj/item/weapon/cell(src)
				power_supply.give(power_supply.maxcharge)

		freeze
			name = "freeze gun"
			icon_state = "freezegun"
			fire_sound = 'pulse3.ogg'
			desc = "A gun that shoots supercooled hydrogen particles to drastically chill a target's body temperature."
			var/temperature = T20C
			var/current_temperature = T20C
			charge_cost = 100
			origin_tech = "combat=3;materials=4;powerstorage=3;magnets=2"


			New()
				power_supply = new /obj/item/weapon/cell/crap(src)
				power_supply.give(power_supply.maxcharge)
				spawn()
					Life()


			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge < charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/freeze(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				user.machine = src
				var/temp_text = ""
				if(temperature > (T0C - 50))
					temp_text = "<FONT color=black>[temperature] ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"
				else
					temp_text = "<FONT color=blue>[temperature] ([round(temperature-T0C)]&deg;C) ([round(temperature*1.8-459.67)]&deg;F)</FONT>"

				var/dat = {"<B>Freeze Gun Configuration: </B><BR>
				Current output temperature: [temp_text]<BR>
				Target output temperature: <A href='?src=\ref[src];temp=-100'>-</A> <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> <A href='?src=\ref[src];temp=100'>+</A><BR>
				"}

				user << browse(dat, "window=freezegun;size=450x300")
				onclose(user, "freezegun")

			Topic(href, href_list)
				if (..())
					return
				usr.machine = src
				src.add_fingerprint(usr)
				if(href_list["temp"])
					var/amount = text2num(href_list["temp"])
					if(amount > 0)
						src.current_temperature = min(T20C, src.current_temperature+amount)
					else
						src.current_temperature = max(0, src.current_temperature+amount)
				if (istype(src.loc, /mob))
					attack_self(src.loc)
				src.add_fingerprint(usr)
				return

			proc/Life()
				while(src)
					sleep(10)

					switch(temperature)
						if(0 to 10) charge_cost = 500
						if(11 to 50) charge_cost = 150
						if(51 to 100) charge_cost = 100
						if(101 to 150) charge_cost = 75
						if(151 to 200) charge_cost = 50
						if(201 to 300) charge_cost = 25

					if(current_temperature != temperature)
						var/difference = abs(current_temperature - temperature)
						if(difference >= 10)
							if(current_temperature < temperature)
								temperature -= 10
							else
								temperature += 10

						else
							temperature = current_temperature

						if (istype(src.loc, /mob))
							attack_self(src.loc)

		plasma
			name = "plasma gun"
			icon_state = "plasmagun"
			fire_sound = 'pulse3.ogg'
			desc = "A gun that fires super heated plasma at targets, thus increasing their overall body temparature and also harming them."
			var/temperature = T20C
			var/current_temperature = T20C
			charge_cost = 100
			origin_tech = "combat=3;materials=4;powerstorage=3;magnets=2"


			New()
				power_supply = new /obj/item/weapon/cell/crap(src)
				power_supply.give(power_supply.maxcharge)
				spawn()
					Life()


			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge < charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/plasma(src)
				power_supply.use(charge_cost)
				return 1

			attack_self(mob/living/user as mob)
				user.machine = src
				var/temp_text = ""
				if(temperature < (T0C + 50))
					temp_text = "<FONT color=black>[temperature] ([round(temperature+T0C)]&deg;C) ([round(temperature*1.8+459.67)]&deg;F)</FONT>"
				else
					temp_text = "<FONT color=red>[temperature] ([round(temperature+T0C)]&deg;C) ([round(temperature*1.8+459.67)]&deg;F)</FONT>"

				var/dat = {"<B>Plasma Gun Configuration: </B><BR>
				Current output temperature: [temp_text]<BR>
				Target output temperature: <A href='?src=\ref[src];temp=-100'>-</A> <A href='?src=\ref[src];temp=-10'>-</A> <A href='?src=\ref[src];temp=-1'>-</A> [current_temperature] <A href='?src=\ref[src];temp=1'>+</A> <A href='?src=\ref[src];temp=10'>+</A> <A href='?src=\ref[src];temp=100'>+</A><BR>
				"}

				user << browse(dat, "window=plasmagun;size=450x300")
				onclose(user, "plasmagun")

			Topic(href, href_list)
				if (..())
					return
				usr.machine = src
				src.add_fingerprint(usr)
				if(href_list["temp"])
					var/amount = text2num(href_list["temp"])
					if(amount < 0)
						src.current_temperature = max(T20C, src.current_temperature+amount)
					else
						src.current_temperature = min(800, src.current_temperature+amount)
				if (istype(src.loc, /mob))
					attack_self(src.loc)
				src.add_fingerprint(usr)
				return

			proc/Life()
				while(src)
					sleep(10)

					switch(temperature)
						if(601 to 800) charge_cost = 500
						if(401 to 600) charge_cost = 150
						if(201 to 400) charge_cost = 100
						if(101 to 200) charge_cost = 75
						if(51 to 100) charge_cost = 50
						if(0 to 50) charge_cost = 25

					if(current_temperature != temperature)
						var/difference = abs(current_temperature + temperature)
						if(difference >= 10)
							if(current_temperature < temperature)
								temperature -= 10
							else
								temperature += 10

						else
							temperature = current_temperature

						if (istype(src.loc, /mob))
							attack_self(src.loc)




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
			origin_tech = "combat=2;magnets=2;syndicate=5"
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
						in_chamber = new /obj/item/projectile/bolt(src)
						return 1
					return 0

		largecrossbow
			name = "Energy Crossbow"
			desc = "A weapon favored by syndicate infiltration teams."
			icon_state = "crossbow"
			w_class = 4.0
			item_state = "crossbow"
			force = 9.0
			throw_speed = 4
			throw_range = 12
			m_amt = 2000
			origin_tech = "combat=2;magnets=2;syndicate=5"
			silenced = 1
			fire_sound = 'Genhit.ogg'

			New()
				power_supply = new /obj/item/weapon/cell/crap(src)
				power_supply.give(power_supply.maxcharge)
				charge()

			proc/charge()
				if(power_supply)
					if(power_supply.charge < power_supply.maxcharge) power_supply.give(200)
				spawn(20) charge()

			update_icon()
				return

			attack_self(mob/living/user as mob)
				return

			load_into_chamber()
				if(in_chamber)
					return 1
				if(power_supply.charge <= charge_cost)
					return 0
				in_chamber = new /obj/item/projectile/largebolt(src)
				power_supply.use(charge_cost)
				return 1

			cyborg
				load_into_chamber()
					if(in_chamber)
						return 1
					if(isrobot(src.loc))
						var/mob/living/silicon/robot/R = src.loc
						R.cell.use(20)
						in_chamber = new /obj/item/projectile/largebolt(src)
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

		if(istype(src, /obj/item/weapon/gun/projectile/shotgun))
			var/obj/item/weapon/gun/projectile/shotgun/S = src
			if(S.pumped >= S.maxpump)
				S.pump()
				return

		update_icon()

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
		else
			if(istype(src, /obj/item/weapon/gun/energy/freeze))
				var/obj/item/projectile/freeze/F = in_chamber
				var/obj/item/weapon/gun/energy/freeze/Fgun = src

				F.temperature = Fgun.temperature

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
