/*
		Portable Turrets:

		Constructed from metal, a gun of choice, and a prox sensor.
		Gun can be a taser or laser or energy gun.

		This code is slightly more documented than normal, as requested by XSI on IRC.

*/


/obj/machinery/porta_turret
	name = "turret"
	icon = 'turrets.dmi'
	icon_state = "grey_target_prism"
	anchored = 1
	layer = 3
	invisibility = 2		// the turret is invisible if it's inside its cover
	density = 1
	use_power = 1			// this turret uses and requires power
	idle_power_usage = 50	// when inactive, this turret takes up constant 50 Equipment power
	active_power_usage = 300// when active, this turret takes up constant 300 Equipment power
	req_access = list(access_security)
	power_channel = EQUIP	// drains power from the EQUIPMENT channel

	var/raised = 0			// if the turret cover is "open" and the turret is raised
	var/raising= 0			// if the turret is currently opening or closing its cover
	var/health = 80			// the turret's health
	var/locked = 1			// if the turret's behaviour control access is locked

	var/installation		// the type of weapon installed
	var/gun_charge = 0		// the charge of the gun inserted

	var/obj/machinery/porta_turret_cover/cover = null	// the cover that is covering this turret
	var/last_fired = 0		// 1: if the turret is cooling down from a shot, 0: turret is ready to fire
	var/shot_delay = 15		// 1.5 seconds between each shot

	var/check_records = 1	// checks if it can use the security records
	var/criminals = 1		// checks if it can shoot people on arrest
	var/auth_weapons = 0	// checks if it can shoot people that have a weapon they aren't authorized to have
	var/stun_all = 0		// if this is active, the turret shoots everything that isn't security or head of staff
	var/check_anomalies = 1	// checks if it can shoot at unidentified lifeforms (ie xenos)
	var/ai		 = 0 		// if active, will shoot at anything not an AI or cyborg

	var/attacked = 0		// if set to 1, the turret gets pissed off and shoots at people nearby (unless they have sec access!)

	//var/emagged = 0			// 1: emagged, 0: not emagged
	var/on = 1				// determines if the turret is on

	var/datum/effect/effect/system/spark_spread/spark_system // the spark system, used for generating... sparks?

	New()
		..()
		// Sets up a spark system
		spark_system = new /datum/effect/effect/system/spark_spread
		spark_system.set_up(5, 0, src)
		spark_system.attach(src)
	Del()
		// deletes its own cover with it
		del(cover)
		..()


/obj/machinery/porta_turret/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/porta_turret/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	var/dat

	// The browse() text, similar to ED-209s and beepskies.
	dat += text({"
<TT><B>Automatic Portable Turret Installation</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [src.locked ? "locked" : "unlocked"]"},

"<A href='?src=\ref[src];power=1'>[src.on ? "On" : "Off"]</A>" )

	if(!src.locked)
		dat += text({"<BR>
Check for Weapon Authorization: []<BR>
Check Security Records: []<BR>
Neutralize Identified Criminals: []<BR>
Neutralize All Non-Security and Non-Command Personnel: []<BR>
Neutralize All Unidentified Life Signs: []<BR>"},

"<A href='?src=\ref[src];operation=authweapon'>[src.auth_weapons ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=checkrecords'>[src.check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=shootcrooks'>[src.criminals ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=shootall'>[stun_all ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=checkxenos'>[check_anomalies ? "Yes" : "No"]</A>" )


	user << browse("<HEAD><TITLE>Automatic Portable Turret Installation</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/obj/machinery/porta_turret/Topic(href, href_list)
	if (..())
		return
	usr.machine = src
	src.add_fingerprint(usr)
	if ((href_list["power"]) && (src.allowed(usr)))
		if(anchored) // you can't turn a turret on/off if it's not anchored/secured
			on = !on // toggle on/off
		else
			usr << "\red It has to be secured first!"

		updateUsrDialog()
		return

	switch(href_list["operation"])
		// toggles customizable behavioural protocols

		if ("authweapon")
			src.auth_weapons = !src.auth_weapons
		if ("checkrecords")
			src.check_records = !src.check_records
		if ("shootcrooks")
			src.criminals = !src.criminals
		if("shootall")
			stun_all = !stun_all
	updateUsrDialog()


/obj/machinery/porta_turret/power_change()

	if(!anchored)
		icon_state = "turretCover"
		return
	if(stat & BROKEN)
		icon_state = "destroyed_target_prism"
	else
		if( powered() )
			if (on)
				if (installation == /obj/item/weapon/gun/energy/laser || installation == /obj/item/weapon/gun/energy/pulse_rifle)
					// laser guns and pulse rifles have an orange icon
					icon_state = "orange_target_prism"
				else
					// anything else has a blue icon
					icon_state = "target_prism"
			else
				icon_state = "grey_target_prism"
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "grey_target_prism"
				stat |= NOPOWER



/obj/machinery/porta_turret/attackby(obj/item/W as obj, mob/user as mob)
	if(stat & BROKEN)
		if(istype(W, /obj/item/weapon/crowbar))

			// If the turret is destroyed, you can remove it with a crowbar to
			// try and salvage its components
			user << "You begin prying the metal coverings off."
			sleep(20)
			if(prob(70))
				user << "You remove the turret and salvage some components."
				if(installation)
					var/obj/item/weapon/gun/energy/Gun = new installation(src.loc)
					Gun.power_supply.charge=gun_charge
					Gun.update_icon()
				if(prob(50)) new /obj/item/stack/sheet/metal( loc, rand(1,4))
				if(prob(50)) new /obj/item/device/assembly/prox_sensor(locate(x,y,z))
			else
				user << "You remove the turret but did not manage to salvage anything."
			del(src)


	if ((istype(W, /obj/item/weapon/card/emag)) && (!src.emagged))
		var/obj/item/weapon/card/emag/E = W
		if(E.uses)
			E.uses--
		else
			return
		// Emagging the turret makes it go bonkers and stun everyone. It also makes
		// the turret shoot much, much faster.

		user << "\red You short out [src]'s threat assessment circuits."
		spawn(0)
			for(var/mob/O in hearers(src, null))
				O.show_message("\red [src] hums oddly...", 1)
		emagged = 1
		src.on = 0 // turns off the turret temporarily
		sleep(60) // 6 seconds for the traitor to gtfo of the area before the turret decides to ruin his shit
		on = 1 // turns it back on. The cover popUp() popDown() are automatically called in process(), no need to define it here

	else if((istype(W, /obj/item/weapon/wrench)) && (!on))
		if(raised) return
		// This code handles moving the turret around. After all, it's a portable turret!

		if(!anchored)
			anchored = 1
			invisibility = 2
			icon_state = "grey_target_prism"
			user << "You secure the exterior bolts on the turret."
			cover=new/obj/machinery/porta_turret_cover(src.loc) // create a new turret. While this is handled in process(), this is to workaround a bug where the turret becomes invisible for a split second
			cover.Parent_Turret = src // make the cover's parent src
		else
			anchored = 0
			user << "You unsecure the exterior bolts on the turret."
			icon_state = "turretCover"
			invisibility = 0
			del(cover) // deletes the cover, and the turret instance itself becomes its own cover.

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		// Behavior lock/unlock mangement
		if (allowed(user))
			locked = !src.locked
			user << "Controls are now [locked ? "locked." : "unlocked."]"
		else
			user << "\red Access denied."

	else
		// if the turret was attacked with the intention of harming it:
		src.health -= W.force * 0.5
		if (src.health <= 0)
			src.die()
		if ((W.force * 0.5) > 1) // if the force of impact dealt at least 1 damage, the turret gets pissed off
			if(!attacked && !emagged)
				attacked = 1
				spawn()
					sleep(60)
					attacked = 0
		..()



/obj/machinery/porta_turret/bullet_act(var/obj/item/projectile/Proj)
	if(on)
		if(!attacked && !emagged)
			attacked = 1
			spawn()
				sleep(60)
				attacked = 0

	src.health -= Proj.damage
	..()
	if(prob(45) && Proj.damage > 0) src.spark_system.start()
	if (src.health <= 0)
		src.die() // the death process :(
	return

/obj/machinery/porta_turret/emp_act(severity)
	if(on)
		// if the turret is on, the EMP no matter how severe disables the turret for a while
		// and scrambles its settings, with a slight chance of having an emag effect
		check_records=pick(0,1)
		criminals=pick(0,1)
		auth_weapons=pick(0,1)
		stun_all=pick(0,0,0,0,1) // stun_all is a pretty big deal, so it's least likely to get turned on
		if(prob(5)) emagged=1
		on=0
		sleep(rand(60,600))
		if(!on)
			on=1

	..()

/obj/machinery/porta_turret/ex_act(severity)
	if(severity >= 3) // turret dies if an explosion touches it!
		del(src)
	else
		src.die()

/obj/machinery/porta_turret/proc/die() // called when the turret dies, ie, health <= 0
	src.health = 0
	src.density = 0
	src.stat |= BROKEN // enables the BROKEN bit
	src.icon_state = "destroyed_target_prism"
	invisibility=0
	src.spark_system.start() // creates some sparks because they look cool
	src.density=1
	del(cover) // deletes the cover - no need on keeping it there!



/obj/machinery/porta_turret/process()
	// the main machinery process

	set background = 1

	if(src.cover==null && anchored) // if it has no cover and is anchored
		if (stat & BROKEN) // if the turret is borked
			del(cover) // delete its cover, assuming it has one. Workaround for a pesky little bug
		else

			src.cover = new /obj/machinery/porta_turret_cover(src.loc) // if the turret has no cover and is anchored, give it a cover
			src.cover.Parent_Turret = src // assign the cover its Parent_Turret, which would be this (src)
	if(stat & (NOPOWER|BROKEN))
		// if the turret has no power or is broken, make the turret pop down if it hasn't already
		popDown()
		return
	if(!on)
		// if the turret is off, make it pop down
		popDown()
		return

	var/list/targets = list()		   // list of primary targets
	var/list/secondarytargets = list() // targets that are least important

	if(src.check_anomalies) // if its set to check for xenos/carps, check for non-mob "crittersssss"
		for (var/obj/effect/critter/L in view(12,src))
			if(L.alive)
				targets += L

	for (var/mob/living/carbon/C in view(12,src)) // loops through all living carbon-based lifeforms in view(12)
		if(istype(C, /mob/living/carbon/alien) && src.check_anomalies) // git those fukken xenos
			if(!C.stat) // if it's dead/dying, there's no need to keep shooting at it.
				targets += C

		else
			if(emagged) // if emagged, HOLY SHIT EVERYONE IS DANGEROUS beep boop beep
				targets += C
			else
				if (C.stat || C.handcuffed) // if the perp is handcuffed or dead/dying, no need to bother really
					continue // move onto next potential victim!

				var/dst = get_dist(src, C) // if it's too far away, why bother?
				if (dst > 12)
					continue

				if(!istype(C, /mob/living/silicon) && ai) // If it's set to attack all nonsilicons, target them!
					if(C.lying)
						secondarytargets += C
					else
						targets += C
						continue

				if (istype(C, /mob/living/carbon/human)) // if the target is a human, analyze threat level
					if(src.assess_perp(C)<4)
						continue // if threat level < 4, keep going

				else if (istype(C, /mob/living/carbon/monkey) || istype(C, /mob/living/silicon))
					continue // Don't target monkeys or borgs/AIs you dumb shit

				if (C.lying) // if the perp is lying down, it's still a target but a less-important target
					secondarytargets += C
					continue

				targets += C // if the perp has passed all previous tests, congrats, it is now a "shoot-me!" nominee

	if (targets.len>0) // if there are targets to shoot

		var/atom/t = pick(targets) // pick a perp from the list of targets. Targets go first because they are the most important

		if (istype(t, /mob/living)) // if a mob
			var/mob/living/M = t // simple typecasting
			if (M.stat!=2) // if the target is not dead
				spawn() popUp() // pop the turret up if it's not already up.
				dir=get_dir(src,M) // even if you can't shoot, follow the target
				spawn() shootAt(M) // shoot the target, finally
		else

			if (istype(t, /obj/effect/critter)) // shoot other things, same process as above
				var/obj/effect/critter/L = t
				if (L.alive==1)
					spawn() popUp()
					dir=get_dir(src,L)
					spawn() shootAt(L)


	else
		if(secondarytargets.len>0) // if there are no primary targets, go for secondary targets
			var/mob/t = pick(secondarytargets)
			if (istype(t, /mob/living))
				if (t.stat!=2)
					spawn() popUp()
					dir=get_dir(src,t)
					shootAt(t)
		else
			spawn() popDown()

/obj/machinery/porta_turret/proc
	popUp() // pops the turret up
		if(raising || raised) return
		if(stat & BROKEN) return
		invisibility=0
		raising=1
		flick("popup",cover)
		sleep(5)
		sleep(5)
		raising=0
		cover.icon_state="openTurretCover"
		raised=1
		layer=4

	popDown() // pops the turret down
		if(raising || !raised) return
		if(stat & BROKEN) return
		layer=3
		raising=1
		flick("popdown",cover)
		sleep(10)
		raising=0
		cover.icon_state="turretCover"
		raised=0
		invisibility=2
		icon_state="grey_target_prism"


/obj/machinery/porta_turret/proc/assess_perp(mob/living/carbon/human/perp as mob)
	var/threatcount = 0 // the integer returned

	if(src.emagged) return 10 // if emagged, always return 10.

	if((stun_all && !src.allowed(perp)) || attacked && !src.allowed(perp))
		// if the turret has been attacked or is angry, target all non-sec people
		if(!src.allowed(perp))
			return 10

	if(auth_weapons) // check for weapon authorization
		if((isnull(perp:wear_id)) || (istype(perp:wear_id, /obj/item/weapon/card/id/syndicate)))

			if(src.allowed(perp)) // if the perp has security access, return 0
				return 0

			if((istype(perp.l_hand, /obj/item/weapon/gun) && !istype(perp.l_hand, /obj/item/weapon/gun/projectile/shotgun)) || istype(perp.l_hand, /obj/item/weapon/melee/baton))
				threatcount += 4

			if((istype(perp.r_hand, /obj/item/weapon/gun) && !istype(perp.r_hand, /obj/item/weapon/gun/projectile/shotgun)) || istype(perp.r_hand, /obj/item/weapon/melee/baton))
				threatcount += 4

			if(istype(perp:belt, /obj/item/weapon/gun) || istype(perp:belt, /obj/item/weapon/melee/baton))
				threatcount += 2

	if (src.check_records) // if the turret can check the records, check if they are set to *Arrest* on records
		for (var/datum/data/record/E in data_core.general)
			var/perpname = perp.name
			if (perp:wear_id)
				var/obj/item/weapon/card/id/id = perp:wear_id
				if(istype(perp:wear_id, /obj/item/device/pda))
					var/obj/item/device/pda/pda = perp:wear_id
					id = pda.id
				if (id)
					perpname = id.registered_name
				else
					var/obj/item/device/pda/pda = perp:wear_id
					perpname = pda.owner
			if (E.fields["name"] == perpname)
				for (var/datum/data/record/R in data_core.security)
					if ((R.fields["id"] == E.fields["id"]) && (R.fields["criminal"] == "*Arrest*"))
						threatcount = 4
						break


	return threatcount





/obj/machinery/porta_turret/proc/shootAt(var/atom/movable/target) // shoots at a target
	if(!emagged) // if it hasn't been emagged, it has to obey a cooldown rate
		if(last_fired || !raised) return // prevents rapid-fire shooting, unless it's been emagged
		last_fired = 1
		spawn()
			sleep(shot_delay)
			last_fired = 0

	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if (!istype(T) || !istype(U))
		return

	if (!raised) // the turret has to be raised in order to fire - makes sense, right?
		return


	// any emagged turrets will shoot extremely fast! This not only is deadly, but drains a lot power!


	var/obj/item/projectile/A
	if(!installation) // if for some reason the turret has no gun (ie, admin spawned) it resorts to basic taser shots
		A = new /obj/item/projectile/energy/electrode( loc )
		if(!emagged) use_power(200)
		else use_power(400)
		playsound(src.loc, 'Taser.ogg', 75, 1)
		icon_state = "target_prism"
	else
		// Shooting Code:
		var/obj/item/weapon/gun/energy/E=new installation

		if(!E.silenced)
			playsound(src.loc, E.fire_sound, 75, 1)
		else
			playsound(src.loc, E.fire_sound, 10, 1)

		// All energy-based weapons are applicable
		if(istype(E, /obj/item/weapon/gun/energy/laser))
			A = new /obj/item/projectile/beam( loc )
			A.original = target.loc
			icon_state = "orange_target_prism"
			if(!emagged) use_power(500)
			else use_power(1000)

		else if(istype(E, /obj/item/weapon/gun/energy/pulse_rifle))
			A = new /obj/item/projectile/beam/pulse( loc )
			A.original = target.loc
			icon_state = "orange_target_prism"
			if(!emagged) use_power(700)
			else use_power(1400)

		else if(istype(E, /obj/item/weapon/gun/energy/staff))
			A = new /obj/item/projectile/change( loc )
			A.original = target.loc
			icon_state = "target_prism"
			if(!emagged) use_power(700)
			else use_power(1400)

		else if(istype(E, /obj/item/weapon/gun/energy/ionrifle))
			A = new /obj/item/projectile/ion( loc )
			A.original = target.loc
			icon_state = "target_prism"
			if(!emagged) use_power(700)
			else use_power(1400)


		else if(istype(E, /obj/item/weapon/gun/energy/taser) || istype(E, /obj/item/weapon/gun/energy/stunrevolver))
			A = new /obj/item/projectile/energy/electrode( loc )
			icon_state = "target_prism"
			if(!emagged) use_power(200)
			else use_power(400)

		else if(istype(E, /obj/item/weapon/gun/energy/lasercannon))
			A = new /obj/item/projectile/beam/heavylaser( loc )
			A.original = target.loc
			icon_state = "orange_target_prism"
			if(!emagged) use_power(600)
			else use_power(1200)

		else if(istype(E, /obj/item/weapon/gun/energy/decloner))
			A = new /obj/item/projectile/energy/declone( loc )
			A.original = target.loc
			icon_state = "orange_target_prism"
			if(!emagged) use_power(600)
			else use_power(1200)

		else if(istype(E, /obj/item/weapon/gun/energy/crossbow))
			A = new /obj/item/projectile/energy/bolt( loc )
			A.original = target.loc
			icon_state = "orange_target_prism"
			if(!emagged) use_power(50)
			else use_power(100)

		else if(istype(E, /obj/item/weapon/gun/energy/crossbow/largecrossbow))
			A = new /obj/item/projectile/energy/bolt/large( loc )
			A.original = target.loc
			icon_state = "orange_target_prism"
			if(!emagged) use_power(125)
			else use_power(250)

		else // Energy gun shots

			if(!emagged) // if it hasn't been emagged, it uses normal taser shots
				A = new /obj/item/projectile/energy/electrode( loc )
				icon_state = "target_prism"
				use_power(200)

			else // if it has been emagged, use laser shots
				A = new /obj/item/projectile/beam( loc )
				A.original = target.loc
				icon_state = "orange_target_prism"
				use_power(1000)

		del(E)
	A.current = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	spawn( 1 )
		A.fired()
	return



/*

		Portable turret constructions

		Known as "turret frame"s

*/

/obj/machinery/porta_turret_construct
	name = "turret frame"
	icon = 'turrets.dmi'
	icon_state = "turret_frame"
	density=1
	var/build_step = 0 // the current step in the building process
	var/finish_name="turret" // the name applied to the product turret
	var/installation = null // the gun type installed
	var/gun_charge = 0 // the gun charge of the gun type installed



/obj/machinery/porta_turret_construct/attackby(obj/item/W as obj, mob/user as mob)

	// this is a bit unweildy but self-explanitory
	switch(build_step)
		if(0) // first step
			if(istype(W, /obj/item/weapon/wrench) && !anchored)
				playsound(src.loc, 'Ratchet.ogg', 100, 1)
				user << "\blue You secure the external bolts."
				anchored = 1
				build_step = 1
				return

			else if(istype(W, /obj/item/weapon/crowbar) && !anchored)
				playsound(src.loc, 'Crowbar.ogg', 75, 1)
				user << "You dismantle the turret construction."
				new /obj/item/stack/sheet/metal( loc, 5)
				del(src)
				return

		if(1)
			if(istype(W, /obj/item/stack/sheet/metal))
				if(W:amount>=2) // requires 2 metal sheets
					user << "\blue You add some metal armor to the interior frame."
					build_step = 2
					W:amount -= 2
					icon_state = "turret_frame2"
					if(W:amount <= 0)
						del(W)
					return

			else if(istype(W, /obj/item/weapon/wrench))
				playsound(src.loc, 'Ratchet.ogg', 75, 1)
				user << "You unfasten the external bolts."
				anchored = 0
				build_step = 0
				return


		if(2)
			if(istype(W, /obj/item/weapon/wrench))
				playsound(src.loc, 'Ratchet.ogg', 100, 1)
				user << "\blue You bolt the metal armor into place."
				build_step = 3
				return

			else if(istype(W, /obj/item/weapon/weldingtool))
				if (W:remove_fuel(5,user)) // uses up 5 fuel.
					playsound(src.loc, pick('Welder.ogg', 'Welder2.ogg'), 50, 1)
					if(do_after(user, 20))
						build_step = 1
						user << "You remove the turret's interior metal armor."
						new /obj/item/stack/sheet/metal( loc, 2)
						return


		if(3)
			if(istype(W, /obj/item/weapon/gun/energy)) // the gun installation part

				var/obj/item/weapon/gun/energy/E = W // typecasts the item to an energy gun
				installation = W.type // installation becomes W.type
				gun_charge = E.power_supply.charge // the gun's charge is stored in src.gun_charge
				user << "\blue You add \the [W] to the turret."
				build_step = 4
				del(W) // delete the gun :(
				return

			else if(istype(W, /obj/item/weapon/wrench))
				playsound(src.loc, 'Ratchet.ogg', 100, 1)
				user << "You remove the turret's metal armor bolts."
				build_step = 2
				return

		if(4)
			if(isprox(W))
				build_step = 5
				user << "\blue You add the prox sensor to the turret."
				del(W)
				return

			// attack_hand() removes the gun

		if(5)
			if(istype(W, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'Screwdriver.ogg', 100, 1)
				build_step = 6
				user << "\blue You close the internal access hatch."
				return

			// attack_hand() removes the prox sensor

		if(6)
			if(istype(W, /obj/item/stack/sheet/metal))
				if(W:amount>=2)
					user << "\blue You add some metal armor to the exterior frame."
					build_step = 7
					W:amount -= 2
					if(W:amount <= 0)
						del(W)
					return

			else if(istype(W, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'Screwdriver.ogg', 100, 1)
				build_step = 5
				user << "You open the internal access hatch."
				return

		if(7)
			if(istype(W, /obj/item/weapon/weldingtool))
				if (W:remove_fuel(5,user))
					playsound(src.loc, pick('Welder.ogg', 'Welder2.ogg'), 50, 1)
					if(do_after(user, 30))
						build_step = 8
						user << "\blue You weld the turret's armor down."

						// The final step: create a full turret
						var/obj/machinery/porta_turret/Turret = new/obj/machinery/porta_turret(locate(x,y,z))
						Turret.name = finish_name
						Turret.installation = src.installation
						Turret.gun_charge = src.gun_charge

						Turret.cover=new/obj/machinery/porta_turret_cover(src.loc)
						Turret.cover.Parent_Turret=Turret
						Turret.cover.name = finish_name
						del(src)

			else if(istype(W, /obj/item/weapon/crowbar))
				playsound(src.loc, 'Crowbar.ogg', 75, 1)
				user << "You pry off the turret's exterior armor."
				new /obj/item/stack/sheet/metal( loc, 2)
				build_step = 6
				return

	if (istype(W, /obj/item/weapon/pen)) // you can rename turrets like bots!
		var/t = input(user, "Enter new turret name", src.name, src.finish_name) as text
		t = copytext(sanitize(t), 1, MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && src.loc != usr)
			return

		src.finish_name = t
		return
	..()



/obj/machinery/porta_turret_construct/attack_hand(mob/user as mob)
	switch(build_step)
		if(4)
			if(!installation) return
			build_step = 3

			var/obj/item/weapon/gun/energy/Gun = new installation(src.loc)
			Gun.power_supply.charge=gun_charge
			Gun.update_icon()
			installation = null
			gun_charge = 0
			user << "You remove \the [Gun] from the turret frame."

		if(5)
			user << "You remove the prox sensor from the turret frame."
			new/obj/item/device/assembly/prox_sensor(locate(x,y,z))
			build_step = 4












/obj/machinery/porta_turret_cover
	name = "turret"
	icon = 'turrets.dmi'
	icon_state = "turretCover"
	anchored = 1
	layer = 3.5
	density = 0
	var/obj/machinery/porta_turret/Parent_Turret = null



// The below code is pretty much just recoded from the initial turret object. It's necessary but uncommented because it's exactly the same!

/obj/machinery/porta_turret_cover/attack_ai(mob/user as mob)
	. = ..()
	if (.)
		return
	var/dat

	dat += text({"
<TT><B>Automatic Portable Turret Installation</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [Parent_Turret.locked ? "locked" : "unlocked"]"},

"<A href='?src=\ref[src];power=1'>[Parent_Turret.on ? "On" : "Off"]</A>" )


	dat += text({"<BR>
Check for Weapon Authorization: []<BR>
Check Security Records: []<BR>
Neutralize Identified Criminals: []<BR>
Neutralize All Non-Security and Non-Command Personnel: []<BR>
Neutralize All Unidentified Life Signs: []<BR>"},

"<A href='?src=\ref[src];operation=authweapon'>[Parent_Turret.auth_weapons ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=checkrecords'>[Parent_Turret.check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=shootcrooks'>[Parent_Turret.criminals ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=shootall'>[Parent_Turret.stun_all ? "Yes" : "No"]</A>" ,
"<A href='?src=\ref[src];operation=checkxenos'>[Parent_Turret.check_anomalies ? "Yes" : "No"]</A>" )


	user << browse("<HEAD><TITLE>Automatic Portable Turret Installation</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/obj/machinery/porta_turret_cover/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	var/dat

	dat += text({"
<TT><B>Automatic Portable Turret Installation</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [Parent_Turret.locked ? "locked" : "unlocked"]"},

"<A href='?src=\ref[src];power=1'>[Parent_Turret.on ? "On" : "Off"]</A>" )

	if(!Parent_Turret.locked)
		dat += text({"<BR>
Check for Weapon Authorization: []<BR>
Check Security Records: []<BR>
Neutralize Identified Criminals: []<BR>
Neutralize All Non-Security and Non-Command Personnel: []<BR>
Neutralize All Unidentified Life Signs: []<BR>"},

"<A href='?src=\ref[src];operation=authweapon'>[Parent_Turret.auth_weapons ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=checkrecords'>[Parent_Turret.check_records ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=shootcrooks'>[Parent_Turret.criminals ? "Yes" : "No"]</A>",
"<A href='?src=\ref[src];operation=shootall'>[Parent_Turret.stun_all ? "Yes" : "No"]</A>" ,
"<A href='?src=\ref[src];operation=checkxenos'>[Parent_Turret.check_anomalies ? "Yes" : "No"]</A>" )


	user << browse("<HEAD><TITLE>Automatic Portable Turret Installation</TITLE></HEAD>[dat]", "window=autosec")
	onclose(user, "autosec")
	return

/obj/machinery/porta_turret_cover/Topic(href, href_list)
	if (..())
		return
	usr.machine = src
	Parent_Turret.add_fingerprint(usr)
	src.add_fingerprint(usr)
	if ((href_list["power"]) && (Parent_Turret.allowed(usr)))
		if(Parent_Turret.anchored)
			if (Parent_Turret.on)
				Parent_Turret.on=0
			else
				Parent_Turret.on=1
		else
			usr << "\red It has to be secured first!"

		updateUsrDialog()
		return

	switch(href_list["operation"])
		if ("authweapon")
			Parent_Turret.auth_weapons = !Parent_Turret.auth_weapons
		if ("checkrecords")
			Parent_Turret.check_records = !Parent_Turret.check_records
		if ("shootcrooks")
			Parent_Turret.criminals = !Parent_Turret.criminals
		if("shootall")
			Parent_Turret.stun_all = !Parent_Turret.stun_all
		if("checkxenos")
			Parent_Turret.check_anomalies = !Parent_Turret.check_anomalies

	updateUsrDialog()



/obj/machinery/porta_turret_cover/attackby(obj/item/W as obj, mob/user as mob)

	if ((istype(W, /obj/item/weapon/card/emag)) && (!Parent_Turret.emagged))
		var/obj/item/weapon/card/emag/E = W
		if(E.uses)
			E.uses--
		else
			return
		user << "\red You short out [Parent_Turret]'s threat assessment circuits."
		spawn(0)
			for(var/mob/O in hearers(Parent_Turret, null))
				O.show_message("\red [Parent_Turret] hums oddly...", 1)
		Parent_Turret.emagged = 1
		Parent_Turret.on = 0
		sleep(40)
		Parent_Turret.on = 1

	else if((istype(W, /obj/item/weapon/wrench)) && (!Parent_Turret.on))
		if(Parent_Turret.raised) return

		if(!Parent_Turret.anchored)
			Parent_Turret.anchored = 1
			Parent_Turret.invisibility = 2
			Parent_Turret.icon_state = "grey_target_prism"
			user << "You secure the exterior bolts on the turret."
		else
			Parent_Turret.anchored = 0
			user << "You unsecure the exterior bolts on the turret."
			Parent_Turret.icon_state = "turretCover"
			Parent_Turret.invisibility = 0
			del(src)

	else if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if (Parent_Turret.allowed(user))
			Parent_Turret.locked = !Parent_Turret.locked
			user << "Controls are now [Parent_Turret.locked ? "locked." : "unlocked."]"
			updateUsrDialog()
		else
			user << "\red Access denied."

	else
		Parent_Turret.health -= W.force * 0.5
		if (Parent_Turret.health <= 0)
			Parent_Turret.die()
		if ((W.force * 0.5) > 2)
			if(!Parent_Turret.attacked && !Parent_Turret.emagged)
				Parent_Turret.attacked = 1
				spawn()
					sleep(30)
					Parent_Turret.attacked = 0
		..()




/obj/machinery/porta_turret/stationary
	emagged = 1

	New()
		installation = new/obj/item/weapon/gun/energy/laser(src.loc)
		..()
