// AI (i.e. game AI, not the AI player) controlled bots

/obj/machinery/bot
	icon = 'icons/obj/aibots.dmi'
	layer = MOB_LAYER
	luminosity = 3
	use_power = 0
	var/obj/item/weapon/card/id/botcard			// the ID card that the bot "holds"
	var/on = 1
	var/health = 0 //do not forget to set health for your bot!
	var/maxhealth = 0
	var/fire_dam_coeff = 1.0
	var/brute_dam_coeff = 1.0
	var/open = 0//Maint panel
	var/locked = 1
	var/bot_type
	var/declare_message = "" //What the bot will display to the HUD user.
	#define SEC_BOT 1 // Secutritrons (Beepsky) and ED-209s
	#define MULE_BOT 2 // MULEbots
	#define FLOOR_BOT 3 // Floorbots
	#define CLEAN_BOT 4 // Cleanbots
	#define MED_BOT 5 // Medibots
	//var/emagged = 0 //Urist: Moving that var to the general /bot tree as it's used by most bots

/obj/machinery/bot/proc/turn_on()
	if(stat)	return 0
	on = 1
	SetLuminosity(initial(luminosity))
	return 1

/obj/machinery/bot/proc/turn_off()
	on = 0
	SetLuminosity(0)

/obj/machinery/bot/proc/explode()
	qdel(src)

/obj/machinery/bot/proc/healthcheck()
	if (src.health <= 0)
		src.explode()

/obj/machinery/bot/proc/Emag(mob/user as mob)
	if(locked)
		locked = 0
		emagged = 1
		user << "<span class='warning'>You bypass [src]'s controls.</span>"
	if(!locked && open)
		emagged = 2

/obj/machinery/bot/examine()
	set src in view()
	..()
	if (src.health < maxhealth)
		if (src.health > maxhealth/3)
			usr << "<span class='warning'>[src]'s parts look loose.</span>"
		else
			usr << "<span class='danger'>[src]'s parts look very loose!</span>"
	return

/obj/machinery/bot/attack_alien(var/mob/living/carbon/alien/user as mob)
	if(flags & INVULNERABLE)
		return
	src.health -= rand(15,30)*brute_dam_coeff
	src.visible_message("\red <B>[user] has slashed [src]!</B>")
	playsound(get_turf(src), 'sound/weapons/slice.ogg', 25, 1, -1)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()


/obj/machinery/bot/attack_animal(var/mob/living/simple_animal/M as mob)
	if(flags & INVULNERABLE)
		return
	if(M.melee_damage_upper == 0)	return
	src.health -= M.melee_damage_upper
	src.visible_message("\red <B>[M] has [M.attacktext] [src]!</B>")
	add_logs(M, src, "attacked", admin=0)
	if(prob(10))
		new /obj/effect/decal/cleanable/blood/oil(src.loc)
	healthcheck()

/obj/machinery/bot/proc/declare() //Signals a medical or security HUD user to a relevant bot's activity.
	var/hud_user_list = list() //Determines which userlist to use.
	switch(bot_type) //Made into a switch so more HUDs can be added easily.
		if(SEC_BOT) //Securitrons and ED-209
			hud_user_list = sec_hud_users
		if(MED_BOT) //Medibots
			hud_user_list = med_hud_users
	var/area/myturf = get_turf(src)
	for(var/mob/huduser in hud_user_list)
		var/turf/mobturf = get_turf(huduser)
		if(mobturf.z == myturf.z)
			huduser.show_message(declare_message,1)


/obj/machinery/bot/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(flags & INVULNERABLE)
		return
	if(istype(W, /obj/item/weapon/screwdriver))
		if(!locked)
			open = !open
			user << "<span class='notice'>Maintenance panel is now [src.open ? "opened" : "closed"].</span>"
	else if(istype(W, /obj/item/weapon/weldingtool))
		if(health < maxhealth)
			if(open)
				health = min(maxhealth, health+10)
				user.visible_message("\red [user] repairs [src]!","\blue You repair [src]!")
			else
				user << "<span class='notice'>Unable to repair with the maintenance panel closed.</span>"
		else
			user << "<span class='notice'>[src] does not need a repair.</span>"
	else if (istype(W, /obj/item/weapon/card/emag) && emagged < 2)
		Emag(user)
	else
		if(hasvar(W,"force") && hasvar(W,"damtype"))
			switch(W.damtype)
				if("fire")
					src.health -= W.force * fire_dam_coeff
				if("brute")
					src.health -= W.force * brute_dam_coeff
			..()
			healthcheck()
		else
			..()

/obj/machinery/bot/bullet_act(var/obj/item/projectile/Proj)
	if(flags & INVULNERABLE)
		return
	health -= Proj.damage
	..()
	healthcheck()

/obj/machinery/bot/meteorhit()
	if(flags & INVULNERABLE)
		return
	src.explode()
	return

/obj/machinery/bot/blob_act()
	if(flags & INVULNERABLE)
		return
	src.health -= rand(20,40)*fire_dam_coeff
	healthcheck()
	return

/obj/machinery/bot/ex_act(severity)
	if(flags & INVULNERABLE)
		return
	switch(severity)
		if(1.0)
			src.explode()
			return
		if(2.0)
			src.health -= rand(5,10)*fire_dam_coeff
			src.health -= rand(10,20)*brute_dam_coeff
			healthcheck()
			return
		if(3.0)
			if (prob(50))
				src.health -= rand(1,5)*fire_dam_coeff
				src.health -= rand(1,5)*brute_dam_coeff
				healthcheck()
				return
	return

/obj/machinery/bot/emp_act(severity)
	if(flags & INVULNERABLE)
		return
	var/was_on = on
	stat |= EMPED
	var/obj/effect/overlay/pulse2 = new/obj/effect/overlay ( src.loc )
	pulse2.icon = 'icons/effects/effects.dmi'
	pulse2.icon_state = "empdisable"
	pulse2.name = "emp sparks"
	pulse2.anchored = 1
	pulse2.dir = pick(cardinal)

	spawn(10)
		qdel(pulse2)
	if (on)
		turn_off()
	spawn(severity*300)
		stat &= ~EMPED
		if (was_on)
			turn_on()


/obj/machinery/bot/attack_ai(mob/user as mob)
	src.add_hiddenprint(user)
	src.attack_hand(user)

/******************************************************************/
// Navigation procs
// Used for A-star pathfinding


// Returns the surrounding cardinal turfs with open links
// Including through doors openable with the ID
/turf/proc/CardinalTurfsWithAccess(var/obj/item/weapon/card/id/ID)
	var/L[] = new()

	//	for(var/turf/simulated/t in oview(src,1))

	for(var/d in cardinal)
		var/turf/simulated/T = get_step(src, d)
		if(istype(T) && !T.density)
			if(!LinkBlockedWithAccess(src, T, ID))
				L.Add(T)
	return L


// Returns true if a link between A and B is blocked
// Movement through doors allowed if ID has access
/proc/LinkBlockedWithAccess(turf/A, turf/B, obj/item/weapon/card/id/ID)

	if(A == null || B == null) return 1
	var/adir = get_dir(A,B)
	var/rdir = get_dir(B,A)
	if((adir & (NORTH|SOUTH)) && (adir & (EAST|WEST)))	//	diagonal
		var/iStep = get_step(A,adir&(NORTH|SOUTH))
		if(!LinkBlockedWithAccess(A,iStep, ID) && !LinkBlockedWithAccess(iStep,B,ID))
			return 0

		var/pStep = get_step(A,adir&(EAST|WEST))
		if(!LinkBlockedWithAccess(A,pStep,ID) && !LinkBlockedWithAccess(pStep,B,ID))
			return 0
		return 1

	if(DirBlockedWithAccess(A,adir, ID))
		return 1

	if(DirBlockedWithAccess(B,rdir, ID))
		return 1

	for(var/obj/O in B)
		if(O.density && !istype(O, /obj/machinery/door) && !(O.flags & ON_BORDER))
			return 1

	return 0

// Returns true if direction is blocked from loc
// Checks doors against access with given ID
/proc/DirBlockedWithAccess(turf/loc,var/dir,var/obj/item/weapon/card/id/ID)
	for(var/obj/structure/window/D in loc)
		if(!D.density)			continue
		if(D.is_fulltile())	return 1
		if(D.dir == dir)		return 1

	for(var/obj/machinery/door/D in loc)
		if(!D.density)			continue
		if(istype(D, /obj/machinery/door/window))
			if( dir & D.dir )	return !D.check_access(ID)

			//if((dir & SOUTH) && (D.dir & (EAST|WEST)))		return !D.check_access(ID)
			//if((dir & EAST ) && (D.dir & (NORTH|SOUTH)))	return !D.check_access(ID)
		else return !D.check_access(ID)	// it's a real, air blocking door
	return 0


/obj/machinery/bot/cultify()
	if(src.flags & INVULNERABLE)
		return
	else
		qdel(src)
