/obj/structure/closet
	name = "closet"
	desc = "It's a basic storage unit."
	icon = 'icons/obj/closet.dmi'
	icon_state = "generic"
	density = TRUE
	var/icon_door = null
	var/icon_door_override = FALSE //override to have open overlay use icon different to its base's
	var/secure = FALSE //secure locker or not, also used if overriding a non-secure locker with a secure door overlay to add fancy lights
	var/opened = FALSE
	var/welded = FALSE
	var/locked = FALSE
	var/large = TRUE
	var/wall_mounted = 0 //never solid (You can always pass over it)
	max_integrity = 200
	integrity_failure = 50
	armor = list(melee = 20, bullet = 10, laser = 10, energy = 0, bomb = 10, bio = 0, rad = 0, fire = 70, acid = 60)
	var/breakout_time = 2
	var/lastbang
	var/can_weld_shut = TRUE
	var/horizontal = FALSE
	var/allow_objects = FALSE
	var/allow_dense = FALSE
	var/dense_when_open = FALSE //if it's dense when open or not
	var/max_mob_size = MOB_SIZE_HUMAN //Biggest mob_size accepted by the container
	var/mob_storage_capacity = 3 // how many human sized mob/living can fit together inside a closet.
	var/storage_capacity = 30 //This is so that someone can't pack hundreds of items in a locker/crate then open it in a populated area to crash clients.
	var/cutting_tool = /obj/item/weapon/weldingtool
	var/open_sound = 'sound/machines/click.ogg'
	var/close_sound = 'sound/machines/click.ogg'
	var/cutting_sound = 'sound/items/welder.ogg'
	var/material_drop = /obj/item/stack/sheet/metal
	var/material_drop_amount = 2
	var/delivery_icon = "deliverycloset" //which icon to use when packagewrapped. null to be unwrappable.
	var/anchorable = TRUE


/obj/structure/closet/Initialize(mapload)
	if(mapload && !opened)		// if closed, any item at the crate's loc is put in the contents
		addtimer(CALLBACK(src, .proc/take_contents), 0)
	. = ..()
	update_icon()
	PopulateContents()

//USE THIS TO FILL IT, NOT INITIALIZE OR NEW
/obj/structure/closet/proc/PopulateContents()
	return

/obj/structure/closet/Destroy()
	dump_contents()
	return ..()

/obj/structure/closet/update_icon()
	cut_overlays()
	if(!opened)
		if(icon_door)
			add_overlay("[icon_door]_door")
		else
			add_overlay("[icon_state]_door")
		if(welded)
			add_overlay("welded")
		if(secure)
			if(!broken)
				if(locked)
					add_overlay("locked")
				else
					add_overlay("unlocked")
			else
				add_overlay("off")

	else
		if(icon_door_override)
			add_overlay("[icon_door]_open")
		else
			add_overlay("[icon_state]_open")

/obj/structure/closet/examine(mob/user)
	..()
	if(anchored)
		to_chat(user, "It is anchored to the ground.")
	else if(secure && !opened)
		to_chat(user, "<span class='notice'>Alt-click to [locked ? "unlock" : "lock"].</span>")

/obj/structure/closet/CanPass(atom/movable/mover, turf/target)
	if(wall_mounted)
		return 1
	return !density

/obj/structure/closet/proc/can_open(mob/living/user)
	if(welded || locked)
		return 0
	var/turf/T = get_turf(src)
	for(var/mob/living/L in T)
		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
			if(user)
				to_chat(user, "<span class='danger'>There's something large on top of [src], preventing it from opening.</span>" )
			return 0
	return 1

/obj/structure/closet/proc/can_close(mob/living/user)
	var/turf/T = get_turf(src)
	for(var/obj/structure/closet/closet in T)
		if(closet != src && !closet.wall_mounted)
			return 0
	for(var/mob/living/L in T)
		if(L.anchored || horizontal && L.mob_size > MOB_SIZE_TINY && L.density)
			if(user)
				to_chat(user, "<span class='danger'>There's something too large in [src], preventing it from closing.</span>")
			return 0
	return 1

/obj/structure/closet/proc/dump_contents()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in src)
		AM.forceMove(T)
		if(throwing) // you keep some momentum when getting out of a thrown closet
			step(AM, dir)
	if(throwing)
		throwing.finalize(FALSE)

/obj/structure/closet/proc/take_contents()
	var/turf/T = get_turf(src)
	for(var/atom/movable/AM in T)
		if(AM != src && insert(AM) == -1) // limit reached
			break

/obj/structure/closet/proc/open(mob/living/user)
	if(opened || !can_open(user))
		return
	playsound(loc, open_sound, 15, 1, -3)
	opened = 1
	if(!dense_when_open)
		density = FALSE
	climb_time *= 0.5 //it's faster to climb onto an open thing
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
		if(L.anchored || L.buckled || L.incorporeal_move || L.has_buckled_mobs())
			return
		if(L.mob_size > MOB_SIZE_TINY) // Tiny mobs are treated as items.
			if(horizontal && L.density)
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
		if(AM.anchored || AM.has_buckled_mobs() || (AM.flags & NODROP))
			return
	else
		return

	AM.forceMove(src)
	if(AM.pulledby)
		AM.pulledby.stop_pulling()

	return 1

/obj/structure/closet/proc/close(mob/living/user)
	if(!opened || !can_close(user))
		return 0
	take_contents()
	playsound(loc, close_sound, 15, 1, -3)
	climb_time = initial(climb_time)
	opened = 0
	density = TRUE
	update_icon()
	return 1

/obj/structure/closet/proc/toggle(mob/living/user)
	if(opened)
		return close(user)
	else
		return open(user)

/obj/structure/closet/deconstruct(disassembled = TRUE)
	if(ispath(material_drop) && material_drop_amount && !(flags & NODECONSTRUCT))
		new material_drop(loc, material_drop_amount)
	qdel(src)

/obj/structure/closet/obj_break(damage_flag)
	if(!broken && !(flags & NODECONSTRUCT))
		bust_open()

/obj/structure/closet/attackby(obj/item/weapon/W, mob/user, params)
	if(user in src)
		return
	if(opened)
		if(istype(W, cutting_tool))
			if(istype(W, /obj/item/weapon/weldingtool))
				var/obj/item/weapon/weldingtool/WT = W
				if(WT.remove_fuel(0, user))
					to_chat(user, "<span class='notice'>You begin cutting \the [src] apart...</span>")
					playsound(loc, cutting_sound, 40, 1)
					if(do_after(user, 40*WT.toolspeed, 1, target = src))
						if(!opened || !WT.isOn())
							return
						playsound(loc, cutting_sound, 50, 1)
						user.visible_message("<span class='notice'>[user] slices apart \the [src].</span>",
										"<span class='notice'>You cut \the [src] apart with \the [WT].</span>",
										"<span class='italics'>You hear welding.</span>")
						deconstruct(TRUE)
					return 0
			else // for example cardboard box is cut with wirecutters
				user.visible_message("<span class='notice'>[user] cut apart \the [src].</span>", \
									"<span class='notice'>You cut \the [src] apart with \the [W].</span>")
				deconstruct(TRUE)
				return 0
		if(user.drop_item()) // so we put in unlit welder too
			W.forceMove(loc)
			return 1
	else if(istype(W, /obj/item/weapon/weldingtool) && can_weld_shut)
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.remove_fuel(0, user))
			return
		to_chat(user, "<span class='notice'>You begin [welded ? "unwelding":"welding"] \the [src]...</span>")
		playsound(loc, 'sound/items/welder2.ogg', 40, 1)
		if(do_after(user, 40*WT.toolspeed, 1, target = src))
			if(opened || !WT.isOn())
				return
			playsound(loc, WT.usesound, 50, 1)
			welded = !welded
			user.visible_message("<span class='notice'>[user] [welded ? "welds shut" : "unweldeds"] \the [src].</span>",
							"<span class='notice'>You [welded ? "weld" : "unwelded"] \the [src] with \the [WT].</span>",
							"<span class='italics'>You hear welding.</span>")
			update_icon()
	else if(istype(W, /obj/item/weapon/wrench) && anchorable)
		if(isinspace() && !anchored)
			return
		anchored = !anchored
		playsound(src.loc, W.usesound, 75, 1)
		user.visible_message("<span class='notice'>[user] [anchored ? "anchored" : "unanchored"] \the [src] [anchored ? "to" : "from"] the ground.</span>", \
						"<span class='notice'>You [anchored ? "anchored" : "unanchored"] \the [src] [anchored ? "to" : "from"] the ground.</span>", \
						"<span class='italics'>You hear a ratchet.</span>")
	else if(user.a_intent != INTENT_HARM && !(W.flags & NOBLUDGEON))
		if(W.GetID() || !toggle(user))
			togglelock(user)
		return 1
	else
		return ..()

/obj/structure/closet/MouseDrop_T(atom/movable/O, mob/living/user)
	if(!istype(O) || O.anchored || istype(O, /obj/screen))
		return
	if(!istype(user) || user.incapacitated() || user.lying)
		return
	if(!Adjacent(user) || !user.Adjacent(O))
		return
	if(user == O) //try to climb onto it
		return ..()
	if(!opened)
		return
	if(!isturf(O.loc))
		return

	var/actuallyismob = 0
	if(isliving(O))
		actuallyismob = 1
	else if(!isitem(O))
		return
	var/turf/T = get_turf(src)
	var/list/targets = list(O, src)
	add_fingerprint(user)
	user.visible_message("<span class='warning'>[user] [actuallyismob ? "tries to ":""]stuff [O] into [src].</span>", \
				 	 	"<span class='warning'>You [actuallyismob ? "try to ":""]stuff [O] into [src].</span>", \
				 	 	"<span class='italics'>You hear clanging.</span>")
	if(actuallyismob)
		if(do_after_mob(user, targets, 40))
			user.visible_message("<span class='notice'>[user] stuffs [O] into [src].</span>", \
							 	 "<span class='notice'>You stuff [O] into [src].</span>", \
							 	 "<span class='italics'>You hear a loud metal bang.</span>")
			var/mob/living/L = O
			if(!issilicon(L))
				L.Knockdown(40)
			O.forceMove(T)
			close()
	else
		O.forceMove(T)
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
	..()
	if(user.lying && get_dist(src, user) > 0)
		return

	if(!toggle(user))
		togglelock(user)
		return

/obj/structure/closet/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/closet/attack_robot(mob/user)
	if(user.Adjacent(src))
		return attack_hand(user)

// tk grab then use on self
/obj/structure/closet/attack_self_tk(mob/user)
	return attack_hand(user)

/obj/structure/closet/verb/verb_toggleopen()
	set src in oview(1)
	set category = "Object"
	set name = "Toggle Open"

	if(!usr.canmove || usr.stat || usr.restrained())
		return

	if(iscarbon(usr) || issilicon(usr) || isdrone(usr))
		attack_hand(usr)
	else
		to_chat(usr, "<span class='warning'>This mob type can't use this verb.</span>")

// Objects that try to exit a locker by stepping were doing so successfully,
// and due to an oversight in turf/Enter() were going through walls.  That
// should be independently resolved, but this is also an interesting twist.
/obj/structure/closet/Exit(atom/movable/AM)
	open()
	if(AM.loc == src)
		return 0
	return 1

/obj/structure/closet/container_resist(mob/living/user)
	if(opened)
		return
	if(ismovableatom(loc))
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
	to_chat(user, "<span class='notice'>You lean on the back of [src] and start pushing the door open.</span>")
	visible_message("<span class='warning'>[src] begins to shake violently!</span>")
	if(do_after(user,(breakout_time * 60 * 10), target = src)) //minutes * 60seconds * 10deciseconds
		if(!user || user.stat != CONSCIOUS || user.loc != src || opened || (!locked && !welded) )
			return
		//we check after a while whether there is a point of resisting anymore and whether the user is capable of resisting
		user.visible_message("<span class='danger'>[user] successfully broke out of [src]!</span>",
							"<span class='notice'>You successfully break out of [src]!</span>")
		bust_open()
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, "<span class='warning'>You fail to break out of [src]!</span>")

/obj/structure/closet/proc/bust_open()
	welded = FALSE //applies to all lockers
	locked = FALSE //applies to critter crates and secure lockers only
	broken = 1 //applies to secure lockers only
	open()

/obj/structure/closet/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, be_close=TRUE))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	if(opened || !secure)
		return
	else
		togglelock(user)

/obj/structure/closet/proc/togglelock(mob/living/user)
	if(secure && !broken)
		if(allowed(user))
			if(iscarbon(user))
				add_fingerprint(user)
			locked = !locked
			user.visible_message("<span class='notice'>[user] [locked ? null : "un"]locks [src].</span>",
							"<span class='notice'>You [locked ? null : "un"]lock [src].</span>")
			update_icon()
		else
			to_chat(user, "<span class='notice'>Access Denied</span>")
	else if(secure && broken)
		to_chat(user, "<span class='warning'>\The [src] is broken!</span>")

/obj/structure/closet/emag_act(mob/user)
	if(secure && !broken)
		user.visible_message("<span class='warning'>Sparks fly from [src]!</span>",
						"<span class='warning'>You scramble [src]'s lock, breaking it open!</span>",
						"<span class='italics'>You hear a faint electrical spark.</span>")
		playsound(src, "sparks", 50, 1)
		broken = 1
		locked = FALSE
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


/obj/structure/closet/contents_explosion(severity, target)
	for(var/atom/A in contents)
		A.ex_act(severity, target)
		CHECK_TICK

/obj/structure/closet/singularity_act()
	dump_contents()
	..()
