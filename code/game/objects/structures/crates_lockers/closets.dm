/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "generic"
	density = 1
	var/icon_door = null
	var/icon_door_override = FALSE //override to have open overlay use icon different to its base's
	var/secure = FALSE //secure locker or not, also used if overriding a non-secure locker with a secure door overlay to add fancy lights
	var/opened = FALSE
	var/welded = FALSE
	var/locked = FALSE
	var/broken = FALSE
	var/large = TRUE
	var/wall_mounted = 0 //never solid (You can always pass over it)
	var/health = 100
	var/breakout_time = 2
	var/lastbang
	var/can_weld_shut = TRUE
	var/horizontal = FALSE
	var/allow_objects = FALSE
	var/allow_dense = FALSE
	var/max_mob_size = MOB_SIZE_HUMAN //Biggest mob_size accepted by the container
	var/mob_storage_capacity = 3 // how many human sized mob/living can fit together inside a closet.
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate then open it in a populated area to crash clients.
	var/cutting_tool = /obj/item/weapon/weldingtool
	var/open_sound = 'sound/machines/click.ogg'
	var/close_sound = 'sound/machines/click.ogg'
	var/cutting_sound = 'sound/items/Welder.ogg'
	var/material_drop = /obj/item/stack/sheet/metal

/obj/structure/closet/New()
	..()
	update_icon()

/obj/structure/closet/initialize()
	..()
	if(!opened)		// if closed, any item at the crate's loc is put in the contents
		take_contents()

/obj/structure/closet/Destroy()
	dump_contents()
	return ..()

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
	if(broken)
		user << "<span class='notice'>It appears to be broken.</span>"
	else if(secure && !opened)
		user << "<span class='notice'>Alt-click to [locked ? "unlock" : "lock"].</span>"

/obj/structure/closet/alter_health()
	return get_turf(src)

/obj/structure/closet/CanPass(atom/movable/mover, turf/target, height=0)
	if(height == 0 || wall_mounted)
		return 1
	return !density

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
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in src)
		AM.forceMove(T)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM, dir)
	if(throwing)
		throwing = 0

/obj/structure/closet/proc/take_contents()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in T)
		if(insert(AM) == -1) // limit reached
			break

/obj/structure/closet/proc/open()
	if(opened || !can_open())
		return
	playsound(loc, open_sound, 15, 1, -3)
	opened = 1
	density = 0
	dump_contents()
	update_icon()
	return 1

/obj/structure/closet/proc/insert(atom/movable/AM)
	if(contents.len >= storage_capacity)
		return -1


	if(ismob(AM))
		if(!isliving(AM)) //let's not put ghosts or camera mobs inside closets...
			return
		var/mob/living/L = AM
		if(L.buckled || L.incorporeal_move || L.buckled_mobs.len)
			return
		if(L.mob_size > MOB_SIZE_TINY) // Tiny mobs are treated as items.
			if(horizontal && !L.lying)
				return
			if(L.mob_size > max_mob_size)
				return
			var/mobs_stored = 0
			for(var/mob/living/M in contents)
				if(++mobs_stored >= mob_storage_capacity)
					return
		L.stop_pulling()
	else if(istype(AM, /obj/structure/closet))
		return
	else if(isobj(AM))
		if(!allow_objects && !istype(AM, /obj/item) && !istype(AM, /obj/effect/dummy/chameleon))
			return
		if(!allow_dense && AM.density)
			return
		if(AM.anchored || AM.buckled_mobs.len || (AM.flags & NODROP))
			return

	AM.forceMove(src)
	if(AM.pulledby)
		AM.pulledby.stop_pulling()

	return 1

/obj/structure/closet/proc/close()
	if(!opened || !can_close())
		return 0
	take_contents()
	playsound(loc, close_sound, 15, 1, -3)
	opened = 0
	density = 1
	update_icon()
	return 1

/obj/structure/closet/proc/toggle()
	if(opened)
		return close()
	else
		return open()

/obj/structure/closet/ex_act(severity, target)
	contents_explosion(severity, target)
	if(loc && ispath(material_drop) && !(flags & NODECONSTRUCT))
		new material_drop(loc)
	qdel(src)
	..()

/obj/structure/closet/bullet_act(obj/item/projectile/P)
	..()
	if(P.damage_type == BRUTE || P.damage_type == BURN)
		health -= P.damage
		if(health <= 0)
			qdel(src)

/obj/structure/closet/attack_animal(mob/living/simple_animal/user)
	if(user.environment_smash)
		user.do_attack_animation(src)
		visible_message("<span class='danger'>[user] destroys \the [src].</span>")
		qdel(src)

/obj/structure/closet/blob_act()
	if(prob(75))
		qdel(src)

/obj/structure/closet/attackby(obj/item/weapon/W, mob/user, params)
	if(user in src)
		return
	if(opened)
		if(istype(W, cutting_tool))
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(!WT.remove_fuel(0, user))
					return
				user << "<span class='notice'>You begin cutting \the [src] apart...</span>"
				playsound(loc, cutting_sound, 40, 1)
				if(do_after(user, 40/WT.toolspeed, 1, target = src))
					if(!opened || !WT.isOn())
						return
					playsound(loc, cutting_sound, 50, 1)
					visible_message("<span class='notice'>[user] slices apart \the [src].</span>",
									"<span class='notice'>You cut \the [src] apart with \the [WT].</span>",
									"<span class='italics'>You hear welding.</span>")
					var/turf/T = get_turf(src)
					new material_drop(T)
					qdel(src)
		else if(user.drop_item())
			W.Move(loc)
	else
		if(istype(W, /obj/item/stack/packageWrap))
			return
		else if(istype(W, /obj/item/weapon/weldingtool) && can_weld_shut)
			var/obj/item/weapon/weldingtool/WT = W
			if(!WT.remove_fuel(0, user))
				return
			user << "<span class='notice'>You begin [welded ? "unwelding":"welding"] \the [src]...</span>"
			playsound(loc, 'sound/items/Welder2.ogg', 40, 1)
			if(do_after(user, 40/WT.toolspeed, 1, target = src))
				if(opened || !WT.isOn())
					return
				playsound(loc, 'sound/items/welder.ogg', 50, 1)
				welded = !welded
				visible_message("<span class='notice'>[user] [welded ? "welds shut" : "unweldeds"] \the [src].</span>",
								"<span class='notice'>You [welded ? "weld" : "unwelded"] \the [src] with \the [WT].</span>",
								"<span class='italics'>You hear welding.</span>")
				update_icon()
		else
			togglelock(user)

/obj/structure/closet/MouseDrop_T(atom/movable/O, mob/living/user)
	if(!istype(O) || O.anchored || istype(O, /obj/screen))
		return
	if(!istype(user) || user.incapacitated() || user.lying)
		return
	if(!Adjacent(user) || !user.Adjacent(O))
		return
	if(!opened || istype(O, /obj/structure/closet))
		return
	if(user == O)
		return

	add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] tries to stuff [O] into [src].</span>", \
				 	 	"<span class='warning'>You try to stuff [O] into [src].</span>", \
				 	 	"<span class='italics'>You hear clanging.</span>")
	if(do_after(user, 40, target = src))
		user.visible_message("<span class='notice'>[user] stuffs [O] into [src].</span>", \
						 	 "<span class='notice'>You stuff [O] into [src].</span>", \
						 	 "<span class='italics'>You hear a loud metal bang.</span>")
		var/mob/living/L = O
		if(istype(L) && !issilicon(L))
			L.Weaken(2)
		step_towards(O, loc)
		close()
	return 1

/obj/structure/closet/relaymove(mob/user)
	if(user.stat || !isturf(loc) || !isliving(user))
		return
	var/mob/living/L = user
	if(!open())
		if(L.last_special <= world.time)
			container_resist(L)
		if(world.time > lastbang+5)
			lastbang = world.time
			for(var/mob/M in get_hearers_in_view(src, null))
				M.show_message("<FONT size=[max(0, 5 - get_dist(src, M))]>BANG, bang!</FONT>", 2)

/obj/structure/closet/attack_hand(mob/user)
	add_fingerprint(user)
	if(user.lying && get_dist(src, user) > 0)
		return

	if(!toggle())
		togglelock(user)
		return

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user)
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

/obj/structure/closet/container_resist(mob/living/user)
	if(opened)
		return
	if(istype(loc, /atom/movable))
		user.changeNext_move(CLICK_CD_BREAKOUT)
		user.last_special = world.time + CLICK_CD_BREAKOUT
		var/atom/movable/AM = loc
		AM.relay_container_resist(user, src)
		return
	if(!welded && !locked)
		open()
		return

	//okay, so the closet is either welded or locked... resist!!!
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user << "<span class='notice'>You lean on the back of [src] and start pushing the door open.</span>"
	visible_message("<span class='warning'>[src] begins to shake violently!</span>")
	if(do_after(user,(breakout_time * 60 * 10), target = src)) //minutes * 60seconds * 10deciseconds
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened || (!locked && !welded) )
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting
		welded = 0 //applies to all lockers lockers
		locked = 0 //applies to critter crates and secure lockers only
		broken = 1 //applies to secure lockers only
		user.visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>",
							"<span class='notice'>You successfully break out of [src]!</span>")
		open()
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			user << "<span class='warning'>You fail to break out of [src]!</span>"

/obj/structure/closet/AltClick(mob/user)
	..()
	if(!user.canUseTopic(user))
		user << "<span class='warning'>You can't do that right now!</span>"
		return
	if(opened || !secure || !in_range(src, user))
		return
	else
		togglelock(user)

/obj/structure/closet/proc/togglelock(mob/living/user)
	if(secure && !broken)
		if(allowed(user))
			add_fingerprint(user)
			locked = !locked
			user.visible_message("<span class='notice'>[user] [locked ? null : "un"]locks [src].</span>",
							"<span class='notice'>You [locked ? null : "un"]locks [src].</span>")
			update_icon()
		else
			user << "<span class='notice'>Access Denied</span>"
	else if(secure && broken)
		user << "<span class='warning'>\The [src] is broken!</span>"

/obj/structure/closet/emag_act(mob/user)
	if(secure && !broken)
		user.visible_message("<span class='warning'>Sparks fly from [src]!</span>",
						"<span class='warning'>You scramble [src]'s lock, breaking it open!</span>",
						"<span class='italics'>You hear a faint electrical spark.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 50, 1)
		broken = 1
		locked = 0
		update_icon()

/obj/structure/closet/get_remote_view_fullscreens(mob/user)
	if(user.stat == DEAD || !(user.sight & (SEEOBJS|SEEMOBS)))
		user.overlay_fullscreen("remote_view", /obj/screen/fullscreen/impaired, 1)

/obj/structure/closet/emp_act(severity)
	for(var/obj/O in src)
		O.emp_act(severity)
	if(secure && !broken)
		if(prob(50 / severity))
			locked = !locked
			update_icon()
		if(prob(20 / severity) && !opened)
			if(!locked)
				open()
			else
				req_access = list()
				req_access += pick(get_all_accesses())
	..()
