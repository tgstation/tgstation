/obj/item/weapon/grenade/chem_grenade
	name = "Grenade Casing"
	icon_state = "chemg"
	item_state = "flashbang"
	w_class = 2.0
	force = 2.0
	var/stage = 0
	var/state = 0
	var/path = 0
	var/obj/item/weapon/circuitboard/circuit = null
	var/list/beakers = new/list()
	var/list/allowed_containers = list(/obj/item/weapon/reagent_containers/glass/beaker, /obj/item/weapon/reagent_containers/glass/bottle)
	var/affected_area = 3
	var/obj/item/device/assembly/trigger = null // Grenade assemblies by Sayu

	New()
		create_reagents(1000)
		verbs -= /obj/item/weapon/grenade/chem_grenade/verb/rotate // only used for infrared beam grenades

	// When constructing a grenade in code rather than by hand
	// Pass in the path to an assembly -Sayu
	proc/CreateDefaultTrigger(var/type)
		if(!ispath(type,/obj/item/device/assembly) || (type in list(/obj/item/device/assembly,/obj/item/device/assembly/igniter)))
			return
		if(trigger) del trigger
		if(type == /obj/item/device/assembly/signaler) type = /obj/item/device/assembly/signaler/reciever
		if(type == /obj/item/device/assembly/infra)
			verbs += /obj/item/weapon/grenade/chem_grenade/verb/rotate

		trigger = new type(src)
		if(!trigger.secured) 		// some assemblies require this
			trigger.toggle_secure()	// so they can add themselves to processing_objects()

	attack_self(mob/user as mob)
		if(stage > 1 &&  !active && trigger)
			if(clown_check(user))
				trigger.activate()
				user << "<span class='warning'>You prime the [name]!  [trigger.describe()]</span>"
				message_admins("[user] has primed a [name] for detonation")
				log_game("[user] primed a [name] for detonation")
				active = 1
				icon_state = initial(icon_state) + "_active"
				add_fingerprint(user)
				if(iscarbon(user))
					var/mob/living/carbon/C = user
					C.throw_mode_on()

	HasEntered(AM as mob|obj)
		if(trigger && trigger.secured)
			trigger.HasEntered(AM)

	HasProximity(atom/movable/AM as mob|obj)
		if(trigger && trigger.secured)
			trigger.HasProximity(AM)

	examine()
		set src in usr
		usr << desc
		if(trigger)
			if(trigger.secured)
				usr << trigger.describe()
			else
				usr << "The [trigger] is not properly secured."
		if(/obj/item/weapon/grenade/chem_grenade/verb/rotate in verbs)
			usr << "The sensor is rigged to face [dir2text(dir)]"

	attackby(obj/item/weapon/W as obj, mob/user as mob)

		if(istype(W,/obj/item/device/assembly_holder) && !stage && path != 2)

			var/obj/item/device/assembly/igniter/I = locate() in W

			if(!I)
				user << "You need an igniter if you're going to make any sort of bomb!"
				return

			I.loc = src				// make the igniter no longer [in W]
			trigger = locate() in W // should be one other assembly

			if(!trigger)
				warning("Could not find trigger assembly in assembly holder: [W]")
				user << "You attempt to fit the [W] to the [src], but fail.  It seems something is wrong with the [W]."
				I.loc = W
				trigger = null
				return

			//If you add a new assembly, create a new effective grenade type here
			//If you don't, grenade construction will fail.
			switch(trigger.type)
				if(/obj/item/device/assembly/infra)
					name = "unsecured tripwire mine"
					desc = "A grenade casing with an infrared tripwire assembly."
					verbs += /obj/item/weapon/grenade/chem_grenade/verb/rotate
				if(/obj/item/device/assembly/mousetrap,/obj/item/device/assembly/mousetrap/armed)
					name = "unsecured contact mine"
					desc = "A grenade casing with a pressure switch assembly."
					var/obj/item/device/assembly/mousetrap/M = trigger
					M.armed = 0 // Make it safe
				if(/obj/item/device/assembly/prox_sensor)
					name = "unsecured proximity mine"
					desc = "A grenade casing with a short-range sensor assembly."
				if(/obj/item/device/assembly/signaler)
					name = "unsecured remote mine"
					desc = "A grenade casing with a radio tranciever assembly."
					var/obj/item/device/assembly/signaler/reciever/R = new (src)
					var/obj/item/device/assembly/signaler/S = trigger
					R.frequency = S.frequency
					R.code = S.code
					trigger = R
					del S
				if(/obj/item/device/assembly/timer)
					name = "unsecured grenade"
					desc = "A grenade casing with a timer assembly."
				else
					user << "You need some sort of trigger mechanism!"
					I.loc = W
					trigger = null
					return //  Cancel construction

			trigger.loc = src	// Take the trigger mechanism for safe keeping

			del I // The igniter assembly doesn't *actually* do anything
			del W // The assembly holder is no longer needed

			icon_state = initial(icon_state) +"_ass"
			stage = 1
			path = 1
			user << "\blue You add [W] to the metal casing."
			playsound(src.loc, 'sound/items/Screwdriver2.ogg', 25, -3)

		else if(istype(W,/obj/item/device/multitool) && trigger && trigger.secured)
			trigger.interact(user) // Set trigger options

		else if(istype(W,/obj/item/weapon/screwdriver) && stage == 1 && path != 2)
			path = 1
			if(beakers.len)
				switch(trigger.type)
					if(/obj/item/device/assembly/infra)
						name = "tripwire mine"
					if(/obj/item/device/assembly/mousetrap,/obj/item/device/assembly/mousetrap/armed)
						name = "contact mine"
					if(/obj/item/device/assembly/prox_sensor)
						name = "proximity mine"
					if(/obj/item/device/assembly/signaler/reciever)
						name = "remote mine"
					if(/obj/item/device/assembly/timer)
						name = "grenade"
					else
						warning("Bad trigger in grenade during final construction: [trigger]")

				if(!trigger.secured)
					trigger.toggle_secure() // Necessary for some assemblies

				user << "\blue You lock the assembly."
				playsound(src.loc, 'sound/items/Screwdriver.ogg', 25, -3)
				icon_state = initial(icon_state) +"_locked"
				stage = 2
			else
				user << "\red You need to add at least one beaker before locking the assembly."

		else if(is_type_in_list(W, allowed_containers) && stage == 1 && path != 2)
			path = 1
			if(beakers.len == 2)
				user << "\red The grenade can not hold more containers."
				return
			else
				if(W.reagents.total_volume)
					user << "\blue You add \the [W] to the assembly."
					user.drop_item()
					W.loc = src
					beakers += W
				else
					user << "\red \the [W] is empty."

	prime()
		//if(prob(reliability))
		var/has_reagents = 0
		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			if(G.reagents.total_volume) has_reagents = 1

		if(!has_reagents)
			playsound(src.loc, 'sound/items/Screwdriver2.ogg', 50, 1)
			state = 0
			return

		playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)

		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			G.reagents.trans_to(src, G.reagents.total_volume)

		if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
			var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
			steam.set_up(10, 0, get_turf(src))
			steam.attach(src)
			steam.start()

			for(var/atom/A in view(affected_area, src.loc))
				if( A == src ) continue
				src.reagents.reaction(A, 1, 10)


		invisibility = INVISIBILITY_MAXIMUM //Why am i doing this?
		spawn(50)		   //To make sure all reagents can work
			del(src)	   //correctly before deleting the grenade.
		/*else
			icon_state = initial(icon_state) + "_locked"
			crit_fail = 1
			for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
				G.loc = get_turf(src.loc)*/

	//This hack is necessary for infrared beam grenades.
	//That said, you don't come across infrared sensors much...
	verb/rotate()
		set name = "Rotate Grenade"
		set category = "Object"
		set src in usr

		dir = turn(dir, 90)
		usr << "The grenade is now facing [dir2text(dir)]"
		trigger.dir = dir
		return

// Large chem grenades accept slime cores and use the appropriately.
/obj/item/weapon/grenade/chem_grenade/large
	name = "Large Chem Grenade"
	desc = "An oversized grenade that affects a larger area."
	icon_state = "large_grenade"
	allowed_containers = list(/obj/item/weapon/reagent_containers/glass,/obj/item/weapon/reagent_containers/food/condiment,
								/obj/item/weapon/reagent_containers/food/drinks)
	origin_tech = "combat=3;materials=3"
	affected_area = 4
	prime()
		if(stage < 2)
			return // Signaller on an incomplete grenade, probably

		var/has_reagents = 0
		var/obj/item/slime_extract/valid_core = null

		for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
			if(!istype(G)) continue
			if(G.reagents.total_volume) has_reagents = 1
		for(var/obj/item/slime_extract/E in beakers)
			if(!istype(E)) continue
			if(E.Uses) valid_core = E
			if(E.reagents.total_volume) has_reagents = 1

		if(!has_reagents)
			playsound(src.loc, 'sound/items/Screwdriver2.ogg', 50, 1)
			state = 0
			if(trigger)
				trigger.toggle_secure()
			return

		playsound(src.loc, 'sound/effects/bamf.ogg', 50, 1)

		if(valid_core)
			for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
				G.reagents.trans_to(valid_core, G.reagents.total_volume)

			// If there is still a core (sometimes it's used up)
			// and there are reagents left, behave normally

			if(valid_core && valid_core.reagents && valid_core.reagents.total_volume)
				valid_core.reagents.trans_to(src,valid_core.reagents.total_volume)
		else
			for(var/obj/item/weapon/reagent_containers/glass/G in beakers)
				G.reagents.trans_to(src, G.reagents.total_volume)

		if(src.reagents.total_volume) //The possible reactions didnt use up all reagents.
			var/datum/effect/effect/system/steam_spread/steam = new /datum/effect/effect/system/steam_spread()
			steam.set_up(10, 0, get_turf(src))
			steam.attach(src)
			steam.start()

			for(var/atom/A in view(affected_area, src.loc))
				if( A == src ) continue
				src.reagents.reaction(A, 1, 10)

		invisibility = INVISIBILITY_MAXIMUM //Why am i doing this?
		spawn(50)		   //To make sure all reagents can work
			del(src)	   //correctly before deleting the grenade.

	//I tried to just put it in the allowed_containers list but
	//if you do that it must have reagents.  If you're going to
	//make a special case you might as well do it explicitly. -Sayu
	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W,/obj/item/slime_extract) && stage == 1 && path != 2)
			user << "\blue You add \the [W] to the assembly."
			user.drop_item()
			W.loc = src
			beakers += W
		else
			return ..(W,user)

/obj/item/weapon/grenade/chem_grenade/metalfoam
	name = "Metal-Foam Grenade"
	desc = "Used for emergency sealing of air breaches."
	path = 1
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("aluminum", 30)
		B2.reagents.add_reagent("foaming_agent", 10)
		B2.reagents.add_reagent("pacid", 10)

		beakers += B1
		beakers += B2
		icon_state = "grenade"

		CreateDefaultTrigger(/obj/item/device/assembly/timer)

/obj/item/weapon/grenade/chem_grenade/incendiary
	name = "Incendiary Grenade"
	desc = "Used for clearing rooms of living things."
	path = 1
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("aluminum", 25)
		B2.reagents.add_reagent("plasma", 25)
		B2.reagents.add_reagent("sacid", 25)

		beakers += B1
		beakers += B2
		icon_state = "grenade"

		CreateDefaultTrigger(/obj/item/device/assembly/timer)

/obj/item/weapon/grenade/chem_grenade/antiweed
	name = "weedkiller grenade"
	desc = "Used for purging large areas of invasive plant species. Contents under pressure. Do not directly inhale contents."
	path = 1
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("plantbgone", 25)
		B1.reagents.add_reagent("potassium", 25)
		B2.reagents.add_reagent("phosphorus", 25)
		B2.reagents.add_reagent("sugar", 25)

		beakers += B1
		beakers += B2
		icon_state = "grenade"

		CreateDefaultTrigger(/obj/item/device/assembly/timer)

/obj/item/weapon/grenade/chem_grenade/cleaner
	name = "cleaner grenade"
	desc = "BLAM!-brand foaming space cleaner. In a special applicator for rapid cleaning of wide areas."
	stage = 2
	path = 1

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("fluorosurfactant", 40)
		B2.reagents.add_reagent("water", 40)
		B2.reagents.add_reagent("cleaner", 10)

		beakers += B1
		beakers += B2
		icon_state = "grenade"

		CreateDefaultTrigger(/obj/item/device/assembly/timer)

/obj/item/weapon/grenade/chem_grenade/teargas
	name = "teargas grenade"
	desc = "Used for nonlethal riot control. Contents under pressure. Do not directly inhale contents."
	path = 1
	stage = 2

	New()
		..()
		var/obj/item/weapon/reagent_containers/glass/beaker/B1 = new(src)
		var/obj/item/weapon/reagent_containers/glass/beaker/B2 = new(src)

		B1.reagents.add_reagent("condensedcapsaicin", 25)
		B1.reagents.add_reagent("potassium", 25)
		B2.reagents.add_reagent("phosphorus", 25)
		B2.reagents.add_reagent("sugar", 25)

		beakers += B1
		beakers += B2
		icon_state = "grenade"

		CreateDefaultTrigger(/obj/item/device/assembly/timer)