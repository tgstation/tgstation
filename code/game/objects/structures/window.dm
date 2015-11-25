//Windows, one of the oldest pieces of code
//Note : You might wonder where full windows are. Full windows are in fullwindow.dm. Now you know
//And knowing is half the battle

#define WINDOWLOOSE 0
#define WINDOWLOOSEFRAME 1
#define WINDOWUNSECUREFRAME 2
#define WINDOWSECURE 3

/obj/structure/window
	name = "window"
	desc = "A silicate barrier, used to keep things out and in sight. Fragile."
	icon = 'icons/obj/structures.dmi'
	icon_state = "window"
	density = 1
	layer = 3.2 //Just above airlocks //For some reason I guess
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1
	var/health = 10 //This window is so bad blowing on it would break it, sucks for it
	var/ini_dir = null //This really shouldn't exist, but it does and I don't want to risk deleting it because it's likely mapping-related
	var/d_state = WINDOWLOOSEFRAME //Normal windows have one step (unanchor), reinforced windows have three
	var/shardtype = /obj/item/weapon/shard
	var/sheettype = /obj/item/stack/sheet/glass/glass //Used for deconstruction
	var/sheetamount = 1 //Number of sheets needed to build this window (determines how much shit is spawned via Destroy())
	var/reinforced = 0 //Used for deconstruction steps
	penetration_dampening = 1

	var/obj/Overlays/damage_overlay
	var/cracked_base = "crack"

	var/fire_temp_threshold = 800
	var/fire_volume_mod = 100

/obj/structure/window/New(loc)

	..(loc)
	flags |= ON_BORDER
	ini_dir = dir

	update_nearby_tiles()
	update_nearby_icons()
	update_icon()

/obj/structure/window/projectile_check()
	return PROJREACT_WINDOWS

/obj/structure/window/examine(mob/user)

	..()
	if(!anchored)
		to_chat(user, "It appears to be completely loose and movable")
	//switch most likely can't take inequalities, so here's that if block
	if(health >= initial(health)) //Sanity
		to_chat(user, "It's in perfect shape, not even a scratch")
	else if(health >= 0.8*initial(health))
		to_chat(user, "It has a few scratches and a small impact")
	else if(health >= 0.5*initial(health))
		to_chat(user, "It has a few impacts and some cracks running from them")
	else if(health >= 0.2*initial(health))
		to_chat(user, "It's covered in impact marks and most of the outer sheet is crackled")
	else
		to_chat(user, "It's completely crackled over multiple layers, it's a miracle it's even standing")
	if(reinforced) //Normal windows can be loose or not, reinforced windows are more complex
		switch(d_state)
			if(WINDOWSECURE)
				to_chat(user, "It is firmly secured")
			if(WINDOWUNSECUREFRAME)
				to_chat(user, "It appears it was unfastened from its frame")
			if(WINDOWLOOSEFRAME)
				to_chat(user, "It appears to be loose from its frame")

//Allows us to quickly check if we should break the window, can handle not having an user
/obj/structure/window/proc/healthcheck(var/mob/M, var/sound = 1)


	if(health <= 0)
		if(M) //Did someone pass a mob ? If so, perform a pressure check
			var/pdiff = performWallPressureCheck(src.loc)
			if(pdiff > 0)
				message_admins("Window with pdiff [pdiff] at [formatJumpTo(loc)] destroyed by [M.real_name] ([formatPlayerPanel(M,M.ckey)])!")
				log_admin("Window with pdiff [pdiff] at [loc] destroyed by [M.real_name] ([M.ckey])!")
		Destroy(brokenup = 1)
	else
		if(sound)
			playsound(loc, 'sound/effects/Glasshit.ogg', 100, 1)
		if(!damage_overlay)
			damage_overlay = new(src)
			damage_overlay.icon = icon('icons/obj/structures.dmi')
			damage_overlay.dir = src.dir

		overlays.Cut()

		if(health < initial(health))
			var/damage_fraction = Clamp(round((initial(health) - health) / initial(health) * 5) + 1, 1, 5) //gives a number, 1-5, based on damagedness
			damage_overlay.icon_state = "[cracked_base][damage_fraction]"
			overlays += damage_overlay

/obj/structure/window/bullet_act(var/obj/item/projectile/Proj)

	health -= Proj.damage
	..()
	healthcheck(Proj.firer)
	return

/obj/structure/window/proc/is_fulltile()


	return 0

//This ex_act just removes health to be fully modular with "bomb-proof" windows
/obj/structure/window/ex_act(severity)

	switch(severity)
		if(1.0)
			health -= rand(100, 150)
			healthcheck()
			return
		if(2.0)
			health -= rand(20, 50)
			healthcheck()
			return
		if(3.0)
			health -= rand(5, 15)
			healthcheck()
			return

/obj/structure/window/blob_act()

	health -= rand(30, 50)
	healthcheck()

/obj/structure/window/CheckExit(var/atom/movable/O, var/turf/target)

	if(istype(O) && O.checkpass(PASSGLASS))
		return 1
	if(get_dir(O.loc, target) == dir)
		return !density
	return 1

/obj/structure/window/CanPass(atom/movable/mover, turf/target, height = 0)

	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	return 1

//Someone threw something at us, please advise
/obj/structure/window/hitby(AM as mob|obj)

	..()
	if(ismob(AM))
		var/mob/M = AM //Duh
		health -= 10 //We estimate just above a slam but under a crush, since mobs can't carry a throwforce variable
		healthcheck(M)
		visible_message("<span class='danger'>\The [M] slams into \the [src].</span>", \
		"<span class='danger'>You slam into \the [src].</span>")
	else if(isobj(AM))
		var/obj/item/I = AM
		health -= I.throwforce
		healthcheck()
		visible_message("<span class='danger'>\The [I] slams into \the [src].</span>")

/obj/structure/window/attack_hand(mob/user as mob)

	if(M_HULK in user.mutations)
		user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!"))
		user.visible_message("<span class='danger'>[user] smashes \the [src]!</span>")
		health -= 25
		healthcheck()
		user.delayNextAttack(8)

	//Bang against the window
	else if(usr.a_intent == I_HURT)
		user.delayNextAttack(10)
		playsound(get_turf(src), 'sound/effects/glassknock.ogg', 100, 1)
		user.visible_message("<span class='warning'>[user] bangs against \the [src]!</span>", \
		"<span class='warning'>You bang against \the [src]!</span>", \
		"You hear banging.")

	//Knock against it
	else
		user.delayNextAttack(10)
		playsound(get_turf(src), 'sound/effects/glassknock.ogg', 50, 1)
		user.visible_message("<span class='notice'>[user] knocks on \the [src].</span>", \
		"<span class='notice'>You knock on \the [src].</span>", \
		"You hear knocking.")
	return

/obj/structure/window/attack_paw(mob/user as mob)

	return attack_hand(user)

/obj/structure/window/proc/attack_generic(mob/user as mob, damage = 0)	//used by attack_alien, attack_animal, and attack_slime


	user.delayNextAttack(10)
	health -= damage
	user.visible_message("<span class='danger'>\The [user] smashes into \the [src]!</span>", \
	"<span class='danger'>You smash into \the [src]!</span>")
	healthcheck(user)

/obj/structure/window/attack_alien(mob/user as mob)

	if(islarva(user))
		return
	attack_generic(user, 15)

/obj/structure/window/attack_animal(mob/user as mob)

	var/mob/living/simple_animal/M = user
	if(M.melee_damage_upper <= 0)
		return
	attack_generic(M, M.melee_damage_upper)

/obj/structure/window/attack_slime(mob/user as mob)

	if(!isslimeadult(user))
		return
	attack_generic(user, rand(10, 15))

/obj/structure/window/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if(istype(W, /obj/item/weapon/grab) && Adjacent(user))
		var/obj/item/weapon/grab/G = W
		if(istype(G.affecting, /mob/living))
			var/mob/living/M = G.affecting
			var/gstate = G.state
			returnToPool(W)	//Gotta delete it here because if window breaks, it won't get deleted
			switch(gstate)
				if(GRAB_PASSIVE)
					M.apply_damage(5) //Meh, bit of pain, window is fine, just a shove
					visible_message("<span class='warning'>\The [user] shoves \the [M] into \the [src]!</span>", \
					"<span class='warning'>You shove \the [M] into \the [src]!</span>")
				if(GRAB_AGGRESSIVE)
					M.apply_damage(10) //Nasty, but dazed and concussed at worst
					health -= 5
					visible_message("<span class='danger'>\The [user] slams \the [M] into \the [src]!</span>", \
					"<span class='danger'>You slam \the [M] into \the [src]!</span>")
				if(GRAB_NECK to GRAB_KILL)
					M.Weaken(3) //Almost certainly shoved head or face-first, you're going to need a bit for the lights to come back on
					M.apply_damage(20) //That got to fucking hurt, you were basically flung into a window, most likely a shattered one at that
					health -= 20 //Window won't like that
					visible_message("<span class='danger'>\The [user] crushes \the [M] into \the [src]!</span>", \
					"<span class='danger'>You crush \the [M] into \the [src]!</span>")
			healthcheck(user)
			M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been window slammed by [user.name] ([user.ckey]) ([gstate]).</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Window slammed [M.name] ([gstate]).</font>")
			msg_admin_attack("[user.name] ([user.ckey]) window slammed [M.name] ([M.ckey]) ([gstate]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			log_attack("[user.name] ([user.ckey]) window slammed [M.name] ([M.ckey]) ([gstate]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			return

	//Start construction and deconstruction, absolute priority over the other object interactions to avoid hitting the window

	if(reinforced) //Steps for all reinforced window types

		switch(d_state)

			if(WINDOWSECURE) //Reinforced, fully secured

				if(istype(W, /obj/item/weapon/screwdriver))
					playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
					user.visible_message("<span class='warning'>[user] unfastens \the [src] from its frame.</span>", \
					"<span class='notice'>You unfasten \the [src] from its frame.</span>")
					d_state = WINDOWUNSECUREFRAME
					return

			if(WINDOWUNSECUREFRAME)

				if(istype(W, /obj/item/weapon/screwdriver))
					playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
					user.visible_message("<span class='notice'>[user] fastens \the [src] to its frame.</span>", \
					"<span class='notice'>You fasten \the [src] to its frame.</span>")
					d_state = WINDOWSECURE
					return

				if(istype(W, /obj/item/weapon/crowbar))
					playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
					user.visible_message("<span class='warning'>[user] pries \the [src] from its frame.</span>", \
					"<span class='notice'>You pry \the [src] from its frame.</span>")
					d_state = WINDOWLOOSEFRAME
					return

			if(WINDOWLOOSEFRAME)

				if(istype(W, /obj/item/weapon/crowbar))
					playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
					user.visible_message("<span class='notice'>[user] pries \the [src] into its frame.</span>", \
					"<span class='notice'>You pry \the [src] into its frame.</span>")
					d_state = WINDOWUNSECUREFRAME
					return

				if(istype(W, /obj/item/weapon/screwdriver))
					playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
					user.visible_message("<span class='warning'>[user] unfastens \the [src]'s frame from the floor.</span>", \
					"<span class='notice'>You unfasten \the [src]'s frame from the floor.</span>")
					d_state = WINDOWLOOSE
					anchored = 0
					update_nearby_tiles() //Needed if it's a full window, since unanchored windows don't link
					update_nearby_icons()
					update_icon()
					//Përform pressure check since window no longer blocks air
					var/pdiff = performWallPressureCheck(src.loc)
					if(pdiff > 0)
						message_admins("Window with pdiff [pdiff] deanchored by [user.real_name] ([formatPlayerPanel(user,user.ckey)]) at [formatJumpTo(loc)]!")
						log_admin("Window with pdiff [pdiff] deanchored by [user.real_name] ([user.ckey]) at [loc]!")
					return

			if(WINDOWLOOSE)

				if(istype(W, /obj/item/weapon/screwdriver))
					playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
					user.visible_message("<span class='notice'>[user] fastens \the [src]'s frame to the floor.</span>", \
					"<span class='notice'>You fasten \the [src]'s frame to the floor.</span>")
					d_state = WINDOWLOOSEFRAME
					anchored = 1
					update_nearby_tiles() //Ditto above, but in reverse
					update_nearby_icons()
					update_icon()
					return

				if(istype(W, /obj/item/weapon/weldingtool))
					var/obj/item/weapon/weldingtool/WT = W
					if(WT.remove_fuel(0))
						playsound(src, 'sound/items/Welder.ogg', 100, 1)
						user.visible_message("<span class='warning'>[user] starts disassembling \the [src].</span>", \
						"<span class='notice'>You start disassembling \the [src].</span>")
						if(do_after(user, src, 40) && d_state == WINDOWLOOSE) //Extra condition needed to avoid cheesing
							playsound(src, 'sound/items/Welder.ogg', 100, 1)
							user.visible_message("<span class='warning'>[user] disassembles \the [src].</span>", \
							"<span class='notice'>You disassemble \the [src].</span>")
							getFromPool(sheettype, get_turf(src), sheetamount)
							qdel(src)
							return
					else
						to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
						return

	else if(!reinforced) //Normal window steps

		if(istype(W, /obj/item/weapon/screwdriver))
			playsound(loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user.visible_message("<span class='[d_state ? "warning":"notice"]'>[user] [d_state ? "un":""]fastens \the [src].</span>", \
			"<span class='notice'>You [d_state ? "un":""]fasten \the [src].</span>")
			d_state = !d_state
			anchored = !anchored
			update_nearby_tiles() //Ditto above
			update_nearby_icons()
			update_icon()
			return

		if(istype(W, /obj/item/weapon/weldingtool) && !d_state)
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0))
				playsound(src, 'sound/items/Welder.ogg', 100, 1)
				user.visible_message("<span class='warning'>[user] starts disassembling \the [src].</span>", \
				"<span class='notice'>You start disassembling \the [src].</span>")
				if(do_after(user, src, 40) && d_state == WINDOWLOOSE) //Ditto above
					playsound(src, 'sound/items/Welder.ogg', 100, 1)
					user.visible_message("<span class='warning'>[user] disassembles \the [src].</span>", \
					"<span class='notice'>You disassemble \the [src].</span>")
					getFromPool(sheettype, get_turf(src), sheetamount)
					Destroy()
					return
			else
				to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
				return

	if(W.damtype == BRUTE || W.damtype == BURN)
		user.delayNextAttack(10)
		health -= W.force
		user.visible_message("<span class='warning'>\The [user] hits \the [src] with \the [W].</span>", \
		"<span class='warning'>You hit \the [src] with \the [W].</span>")
		healthcheck(user)
		return
	else
		playsound(loc, 'sound/effects/Glasshit.ogg', 75, 1)
		..()

	return

/obj/structure/window/proc/can_be_reached(mob/user)


	if(!is_fulltile())
		if(get_dir(user, src) & dir)
			for(var/obj/O in loc)
				if(!O.CanPass(user, user.loc, 1, 0))
					return 0
	return 1

/obj/structure/window/verb/rotate()
	set name = "Rotate Window Counter-Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		to_chat(usr, "<span class='warning'>\The [src] is fastened to the floor, therefore you can't rotate it!</span>")
		return 0

	update_nearby_tiles() //Compel updates before
	dir = turn(dir, 90)
	update_nearby_tiles()
	ini_dir = dir
	return

/obj/structure/window/verb/revrotate()
	set name = "Rotate Window Clockwise"
	set category = "Object"
	set src in oview(1)

	if(anchored)
		to_chat(usr, "<span class='warning'>\The [src] is fastened to the floor, therefore you can't rotate it!</span>")
		return 0

	update_nearby_tiles() //Compel updates before
	dir = turn(dir, 270)
	update_nearby_tiles()
	ini_dir = dir
	return

/obj/structure/window/Destroy(var/brokenup = 0)

	density = 0 //Sanity while we do the rest
	update_nearby_tiles()
	update_nearby_icons()
	if(brokenup) //If the instruction we were sent clearly states we're breaking the window, not deleting it !
		if(loc)
			playsound(get_turf(src), "shatter", 70, 1)
		getFromPool(shardtype, loc, sheetamount)
		if(reinforced)
			getFromPool(/obj/item/stack/rods, loc, sheetamount)
	..()

/obj/structure/window/Move()

	update_nearby_tiles()
	..()
	dir = ini_dir
	update_nearby_tiles()

//This proc has to do with airgroups and atmos, it has nothing to do with smoothwindows, that's update_nearby_tiles().
/obj/structure/window/proc/update_nearby_tiles(var/turf/T)


	if(isnull(air_master))
		return 0

	if(!T)
		T = get_turf(src)

	if(isturf(T))
		air_master.mark_for_update(T)

	return 1

//This proc is used to update the icons of nearby windows. It should not be confused with update_nearby_tiles(), which is an atmos proc!
/obj/structure/window/proc/update_nearby_icons(var/turf/T)


	if(!loc)
		return 0
	if(!T)
		T = get_turf(src)

	update_icon()

	for(var/direction in cardinal)
		for(var/obj/structure/window/W in get_step(T,direction))
			W.update_icon()

/obj/structure/window/forceMove(var/atom/A)
	var/turf/T = loc
	..()
	update_nearby_icons(T)
	update_nearby_icons()
	update_nearby_tiles(T)
	update_nearby_tiles()

/obj/structure/window/update_icon()

	return

/obj/structure/window/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)

	if(exposed_temperature > T0C + fire_temp_threshold)
		health -= round(exposed_volume/fire_volume_mod)
		healthcheck(sound = 0)
	..()

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "A window with a rod matrice. It looks more solid than the average window."
	icon_state = "rwindow"
	sheettype = /obj/item/stack/sheet/glass/rglass
	health = 40
	d_state = WINDOWSECURE
	reinforced = 1
	penetration_dampening = 3

/obj/structure/window/plasma

	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "plasmawindow"
	shardtype = /obj/item/weapon/shard/plasma
	sheettype = /obj/item/stack/sheet/glass/plasmaglass
	health = 120
	penetration_dampening = 5

	fire_temp_threshold = 32000
	fire_volume_mod = 1000

/obj/structure/window/reinforced/plasma

	name = "reinforced plasma window"
	desc = "A window made out of a plasma-silicate alloy and a rod matrice. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon_state = "plasmarwindow"
	shardtype = /obj/item/weapon/shard/plasma
	sheettype = /obj/item/stack/sheet/glass/plasmarglass
	health = 160
	penetration_dampening = 7

/obj/structure/window/reinforced/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	return

/obj/structure/window/reinforced/tinted

	name = "tinted window"
	desc = "A window with a rod matrice. Its surface is completely tinted, making it opaque. Why not a wall ?"
	icon_state = "twindow"
	opacity = 1
	sheettype = /obj/item/stack/sheet/glass/rglass //A glass type for this window doesn't seem to exist, so here's to you

/obj/structure/window/reinforced/tinted/frosted

	name = "frosted window"
	desc = "A window with a rod matrice. Its surface is completely tinted, making it opaque, and it's frosty. Why not an ice wall ?"
	icon_state = "fwindow"
	health = 30
	sheettype = /obj/item/stack/sheet/glass/rglass //Ditto above

#undef WINDOWLOOSE
#undef WINDOWLOOSEFRAME
#undef WINDOWUNSECUREFRAME
#undef WINDOWSECURE
