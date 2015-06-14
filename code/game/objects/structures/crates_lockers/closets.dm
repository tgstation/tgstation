/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "generic"
	density = 1
	var/icon_door = null
	var/icon_door_override = 0 //override to have open overlay use icon different to its base's
	var/secure = 0 //secure locker or not, also used if overriding a non-secure locker with a secure door overlay to add fancy lights
	var/opened = 0
	var/welded = 0
	var/locked = 0
	var/broken = 0
	var/large = 1
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/health = 100
	var/lastbang
	var/max_mob_size = MOB_SIZE_HUMAN //Biggest mob_size accepted by the container
	var/mob_storage_capacity = 3 // how many human sized mob/living can fit together inside a closet.
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate
							  //then open it in a populated area to crash clients.

/obj/structure/closet/New()
	..()
	update_icon()

/obj/structure/closet/initialize()
	..()
	if(!opened)		// if closed, any item at the crate's loc is put in the contents
		take_contents()

/obj/structure/closet/update_icon()
	overlays.Cut()
	if(!opened)
		if(icon_door)
			overlays += "[icon_door]_door"
		else
			overlays += "[icon_state]_door"
		if(welded)
			overlays += "welded"
		if(secure)
			if(!broken)
				if(locked)
					overlays += "locked"
				else
					overlays += "unlocked"
			else
				overlays += "off"
	else
		if(icon_door_override)
			overlays += "[icon_door]_open"
		else
			overlays += "[icon_state]_open"

/obj/structure/closet/examine(mob/user)
	..()
	if(secure)
		if(broken || opened || !ishuman(user))
			return //Monkeys don't get a message, nor does anyone if it's open or emagged
		else
			user << "<span class='notice'>Alt-click the locker to [locked ? "unlock" : "lock"] it.</span>"

/obj/structure/closet/alter_health()
	return get_turf(src)

/obj/structure/closet/CanPass(atom/movable/mover, turf/target, height=0)
	if(height==0 || wall_mounted) return 1
	return (!density)

/obj/structure/closet/proc/can_open()
	if(welded || locked)
		return 0
	return 1

/obj/structure/closet/proc/can_close()
	for(var/obj/structure/closet/closet in get_turf(src))
		if(closet != src && !closet.wall_mounted)
			return 0
	return 1

/obj/structure/closet/proc/dump_contents()

	for(var/obj/O in src)
		O.loc = loc

	for(var/mob/M in src)
		M.loc = loc
		if(M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE

/obj/structure/closet/proc/take_contents()

	for(var/atom/movable/AM in loc)
		if(insert(AM) == -1) // limit reached
			break

/obj/structure/closet/proc/open()
	if(opened)
		return 0
	if(!can_open())
		return 0
	dump_contents()

	opened = 1
	if(istype(src, /obj/structure/closet/body_bag))
		playsound(loc, 'sound/items/zip.ogg', 15, 1, -3)
	else
		playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
	density = 0
	update_icon()
	return 1

/obj/structure/closet/proc/insert(var/atom/movable/AM)

	if(contents.len >= storage_capacity)
		return -1

	if(istype(AM, /mob/living))
		var/mob/living/L = AM
		if(L.buckled || L.mob_size > max_mob_size) //buckled mobs and mobs too big for the container don't get inside closets.
			return 0
		if(L.mob_size > MOB_SIZE_TINY) //decently sized mobs take more space than objects.
			var/mobs_stored = 0
			for(var/mob/living/M in contents)
				mobs_stored++
				if(mobs_stored >= mob_storage_capacity)
					return 0
		if(L.client)
			L.client.perspective = EYE_PERSPECTIVE
			L.client.eye = src
	else if(!istype(AM, /obj/item) && !istype(AM, /obj/effect/dummy/chameleon))
		return 0
	else if(AM.density || AM.anchored)
		return 0
	else if(AM.flags & NODROP)
		return 0
	AM.loc = src
	return 1

/obj/structure/closet/proc/close()
	if(!opened)
		return 0
	if(!can_close())
		return 0
	take_contents()

	opened = 0
	if(istype(src, /obj/structure/closet/body_bag))
		playsound(loc, 'sound/items/zip.ogg', 15, 1, -3)
	else
		playsound(loc, 'sound/machines/click.ogg', 15, 1, -3)
	density = 1
	update_icon()
	return 1

/obj/structure/closet/proc/toggle()
	if(opened)
		return close()
	return open()

/obj/structure/closet/ex_act(severity, target)
	contents_explosion(severity, target)
	dump_contents()
	qdel(src)
	..()

/obj/structure/closet/bullet_act(var/obj/item/projectile/Proj)
	..()
	if((Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		health -= Proj.damage
		if(health <= 0)
			dump_contents()
			qdel(src)
	return

/obj/structure/closet/attack_animal(mob/living/simple_animal/user as mob)
	if(user.environment_smash)
		user.do_attack_animation(src)
		visible_message("<span class='danger'>[user] destroys \the [src].</span>")
		dump_contents()
		qdel(src)

/obj/structure/closet/blob_act()
	if(prob(75))
		dump_contents()
		qdel(src)


/obj/structure/closet/attackby(obj/item/weapon/W as obj, mob/user as mob, params)
	if(user.loc == src)
		return
	if(opened)
		if(istype(W, /obj/item/weapon/grab))
			if(large)
				var/obj/item/weapon/grab/G = W
				MouseDrop_T(G.affecting, user)	//act like they were dragged onto the closet
				user.drop_item()
			else
				user << "<span class='notice'>The locker is too small to stuff [W] into!</span>"
			return
		if(istype(W,/obj/item/tk_grab))
			return 0
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0,user))
				user << "<span class='notice'>You begin cutting \the [src] apart...</span>"
				playsound(loc, 'sound/items/Welder.ogg', 40, 1)
				if(do_after(user,40,5,1))
					if( !opened || !istype(src, /obj/structure/closet) || !user || !WT || !WT.isOn() || !user.loc )
						return
					playsound(loc, 'sound/items/Welder2.ogg', 50, 1)
					new /obj/item/stack/sheet/metal(loc)
					visible_message("[user] has cut \the [src] apart with \the [WT].", "<span class='italics'>You hear welding.</span>")
					qdel(src)
				return
		if(isrobot(user))
			return
		if(user.drop_item())
			W.Move(loc)
	else
		if(istype(W, /obj/item/stack/packageWrap))
			return
		if(istype(W, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0,user))
				user << "<span class='notice'>You begin [welded ? "unwelding":"welding"] \the [src]...</span>"
				playsound(loc, 'sound/items/Welder2.ogg', 40, 1)
				if(do_after(user,40,5,1))
					if(opened || !istype(src, /obj/structure/closet) || !user || !WT || !WT.isOn() || !user.loc )
						return
					playsound(loc, 'sound/items/welder.ogg', 50, 1)
					welded = !welded
					user << "<span class='notice'>You [welded ? "weld [src] shut":"unweld [src]"].</span>"
					update_icon()
					user.visible_message("[user.name] has [welded ? "welded [src] shut":"unwelded [src]"].", "<span class='warning'>You [welded ? "weld [src] shut":"unweld [src]"].</span>")
				return
		if(secure && broken)
			user << "<span class='notice'>The locker appears to be broken.</span>"
			return
		if(!place(user, W) && !isnull(W))
			attack_hand(user)

/obj/structure/closet/proc/place(var/mob/user, var/obj/item/I)
	if(!opened && secure)
		togglelock(user)
		return 1
	return 0

/obj/structure/closet/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob, var/needs_opened = 1, var/show_message = 1, var/move_them = 1)
	if(istype(O, /obj/screen))	//fix for HUD elements making their way into the world	-Pete
		return 0
	if(!isturf(O.loc))
		return 0
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.lying)
		return 0
	if((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1))
		return 0
	if(!istype(user.loc, /turf)) // are you in a container/closet/pod/etc? Will also check for null loc
		return 0
	if(needs_opened && !opened)
		return 0
	if(istype(O, /obj/structure/closet))
		return 0
	if(move_them)
		step_towards(O, loc)
	if(show_message && user != O)
		user.show_viewers("<span class='danger'>[user] stuffs [O] into [src]!</span>")
	add_fingerprint(user)
	return 1

/obj/structure/closet/relaymove(mob/user as mob)
	if(user.stat || !isturf(loc))
		return
	if(!open())
		user << "<span class='notice'>It won't budge!</span>"
		if(world.time > lastbang+5)
			lastbang = world.time
			for(var/mob/M in get_hearers_in_view(src, null))
				M.show_message("<FONT size=[max(0, 5 - get_dist(src, M))]>BANG, bang!</FONT>", 2)


/obj/structure/closet/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/structure/closet/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(user.lying && get_dist(src, user) > 0)
		return

	if(!toggle())
		user << "<span class='notice'>You cannot close the locker!</span>"
		return

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user as mob)
	return attack_hand(user)

/obj/structure/closet/verb/verb_toggleopen()
	set src in oview(1)
	set category = "Object"
	set name = "Toggle Open"

	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if(iscarbon(usr) || issilicon(usr))
		attack_hand(usr)
	else
		usr << "<span class='warning'>This mob type can't use this verb.</span>"

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/AM)
	open()
	if(AM.loc == src) return 0
	return 1

/obj/structure/closet/container_resist()
	var/mob/living/user = usr
	var/breakout_time = 2 //2 minutes by default
	if(istype(user.loc, /obj/structure/closet/critter) && !welded)
		breakout_time = 0.75 //45 seconds if it's an unwelded critter crate

	if( opened || (!welded && !locked && !istype(loc, /obj/mecha)) )
		return  //Door's open, not locked or welded or inside a mech, no point in resisting.

	//okay, so the closet is either welded or locked... resist!!!
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user << "<span class='notice'>You lean on the back of [src] and start pushing the door open. (this will take about [breakout_time] minutes.)</span>"
	for(var/mob/O in viewers(src))
		O << "<span class='warning'>[src] begins to shake violently!</span>"
	if(do_after(user,(breakout_time*60*10))) //minutes * 60seconds * 10deciseconds
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened || (!locked && !welded && !istype(loc, /obj/mecha)) )
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting

		welded = 0 //applies to all lockers lockers
		locked = 0 //applies to critter crates and secure lockers only
		broken = 1 //applies to secure lockers only
		user.visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>", "<span class='notice'>You successfully break out of [src]!</span>")
		if(istype( loc, /obj/structure/bigDelivery))
			var/obj/structure/bigDelivery/D = loc
			qdel(D)
		else if(istype( loc, /obj/mecha))
			loc = get_turf(loc)
		open()
	else
		user << "<span class='warning'>You fail to break out of [src]!</span>"

/obj/structure/closet/AltClick(var/mob/user)
	..()
	if(!user.canUseTopic(user) || broken)
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	if(opened || !secure || !in_range(src, user))
		return
	else
		togglelock(user)

/obj/structure/closet/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(secure && !broken)
		if(prob(50/severity))
			locked = !locked
			update_icon()
		if(prob(20/severity) && !opened)
			if(!locked)
				open()
			else
				req_access = list()
				req_access += pick(get_all_accesses())
	..()

/obj/structure/closet/proc/togglelock(mob/user as mob)
	if(secure)
		if(allowed(user))
			locked = !locked
			add_fingerprint(user)
			for(var/mob/O in viewers(user, 3))
				if((O.client && !( O.eye_blind )))
					O << "<span class='notice'>[user] has [locked ? null : "un"]locked the locker.</span>"
			update_icon()
		else
			user << "<span class='notice'>Access Denied</span>"
	else
		return

/obj/structure/closet/emag_act(mob/user as mob)
	if(secure && !broken)
		broken = 1
		locked = 0
		desc += " It appears to be broken."
		update_icon()
		for(var/mob/O in viewers(user, 3))
			O.show_message("<span class='warning'>The locker has been broken by [user] with an electromagnetic card!</span>", 1, "You hear a faint electrical spark.", 2)
		overlays += "sparking"
		spawn(4) //overlays don't support flick so we have to cheat
		update_icon()
