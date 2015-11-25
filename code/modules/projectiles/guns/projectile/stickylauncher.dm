#define MAX_STICKYBOMBS 4

/obj/item/weapon/gun/stickybomb
	name = "stickybomb launcher"
	desc = "Fired stickybombs take 5 seconds to become live. After which they'll progressively merge with their surroundings."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "stickybomb"
	item_state = null
	slot_flags = SLOT_BELT
	origin_tech = "materials=3;combat=4;programming=3"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	flags = FPRINT
	w_class = 3.0
	fire_delay = 2
	fire_sound = 'sound/weapons/grenadelauncher.ogg'
	var/list/loaded = list()
	var/list/fired = list()

	var/current_shells = 200

/obj/item/weapon/gun/stickybomb/isHandgun()
	return 0

/obj/item/weapon/gun/stickybomb/New()
	..()
	loaded = list(
		new /obj/item/stickybomb(src),
		new /obj/item/stickybomb(src),
		new /obj/item/stickybomb(src),
		new /obj/item/stickybomb(src),
		new /obj/item/stickybomb(src),
		new /obj/item/stickybomb(src),
		)

/obj/item/weapon/gun/stickybomb/Destroy()
	for(var/obj/item/stickybomb/S in loaded)
		qdel(S)
	loaded = null
	for(var/obj/item/stickybomb/B in fired)
		B.deactivate()
		B.unstick()
	..()

/obj/item/weapon/gun/stickybomb/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>Has [loaded.len] stickybomb\s loaded, and [fired.len] stickybomb\s placed.</span>")

/obj/item/weapon/gun/stickybomb/update_icon()
	return

/obj/item/weapon/gun/stickybomb/attack_self(mob/user)
	if(fired.len)
		playsound(get_turf(src), 'sound/weapons/stickybomb_det.ogg', 30, 1)
		for(var/obj/item/stickybomb/B in fired)
			spawn()
				if(B.live)
					B.detonate()

/obj/item/weapon/gun/stickybomb/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/stickybomb))
		var/obj/item/stickybomb/B = A
		if(B.live)
			to_chat(user, "<span class='warning'>You cannot load a live stickybomb!</span>")
		else
			if(loaded.len >= 6)
				to_chat(user, "<span class='warning'>You cannot fit any more stickybombs in there!</span>")
			else
				user.drop_item(A, src)
				to_chat(user, "<span class='notice'>You load \the [A] into \the [src].</span>")
				loaded += A
	else
		..()

/obj/item/weapon/gun/stickybomb/process_chambered()
	if(in_chamber) return 1
	if(loaded.len)
		var/obj/item/stickybomb/B = pick(loaded)
		loaded -= B
		if(fired.len >= MAX_STICKYBOMBS)
			var/obj/item/stickybomb/SB = pick(fired)
			spawn()
				SB.detonate()
			if(ismob(loc))
				to_chat(loc, "<span class='warning'>One of the stickybombs detonates to leave room for the next one.</span>")
		fired += B
		var/obj/item/projectile/stickybomb/SB = new()
		SB.sticky = B
		B.fired_from = src
		B.loc = SB
		in_chamber = SB
		return 1
	return 0


/obj/item/stickybomb
	name = "anti-personnel stickybomb"
	desc = "Ammo for a stickybomb launcher. Only affects living beings, produces a decent amount of knockback."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "stickybomb"
	flags = FPRINT
	force = 1
	throwforce = 1
	w_class = 1.0
	var/obj/item/weapon/gun/stickybomb/fired_from = null
	var/live = 0
	var/atom/stuck_to = null
	var/image/self_overlay = null
	var/signal = 0

/obj/item/stickybomb/New()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)

/obj/item/stickybomb/Destroy()
	if(fired_from)
		fired_from.fired -= src
		fired_from = null
	stuck_to = null
	self_overlay = null
	..()

/obj/item/stickybomb/update_icon()
	icon_state = "[initial(icon_state)][live ? "-live" : ""]"
	if(live)
		desc = "It appears to be live."
	else
		desc = "Ammo for a stickybomb launcher."

/obj/item/stickybomb/pickup(mob/user)
	if(stuck_to)
		to_chat(user, "<span class='warning'>You reach for \the [src] stuck on \the [stuck_to] and start pulling.</span>")
		if(do_after(user, src, 30))
			to_chat(user, "<span class='warning'>It came off!</span>")
			unstick()
			..()
	else
		..()

/obj/item/stickybomb/proc/stick_to(var/atom/A as mob|obj|turf, var/side = null)
	stuck_to = A
	loc = A
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	playsound(A, 'sound/items/metal_impact.ogg', 30, 1)

	if(isturf(A))
		anchored = 1
		switch(side)
			if(NORTH)
				pixel_y = 16
			if(SOUTH)
				pixel_y = -16
			if(EAST)
				pixel_x = 16
			if(WEST)
				pixel_x = -16
		sleep(50)
		if(stuck_to == A)
			flick("stickybomb_flick",src)
			live = 1
			update_icon()
			animate(src, alpha=50, time=300)

	else if(isliving(A))
		visible_message("<span class='warning'>\the [src] sticks itself on \the [A].</span>")
		src.loc = A
		self_overlay = new(icon,src,icon_state,10,dir)
		self_overlay.pixel_x = pixel_x
		self_overlay.pixel_y = pixel_y
		A.overlays += self_overlay
		sleep(50)
		if(stuck_to == A)
			live = 1
			A.overlays -= self_overlay
			self_overlay.icon_state = "stickybomb-live"
			A.overlays += self_overlay

/obj/item/stickybomb/proc/unstick(var/fall_to_floor = 1)
	if(ismob(stuck_to))
		stuck_to.overlays -= self_overlay
		icon_state = self_overlay.icon_state
		if(fall_to_floor)
			src.loc = get_turf(src)
	stuck_to = null
	anchored = 0
	alpha = 255
	pixel_x = 0
	pixel_y = 0

/obj/item/stickybomb/proc/detonate()
	icon_state = "stickybomb_flick"
	if(!self_overlay)
		self_overlay = new(icon,src,icon_state,13,dir)
		overlays += self_overlay//a bit awkward but the sprite wouldn't properly animate otherwise
	if(signal)
		return
	signal = 1
	mouse_opacity = 0
	var/turf/T = get_turf(src)
	playsound(T, 'sound/machines/twobeep.ogg', 30, 1)
	if(ismob(stuck_to))
		stuck_to.overlays -= self_overlay
		self_overlay.icon_state = "stickybomb_flick"
		self_overlay.layer = 13
		stuck_to.overlays += self_overlay
	alpha = 255
	spawn(3)
		if(ismob(stuck_to))
			stuck_to.overlays -= self_overlay

		T.turf_animation('icons/effects/96x96.dmi',"explosion_sticky",pixel_x-32, pixel_y-32, 13)
		playsound(T, "explosion_small", 75, 1)

		for(var/mob/living/L in range(T,3))
			var/turf/TL = get_turf(L)
			var/dist = get_dist(T,L)
			var/atom/throw_target = T
			if(T!=TL)
				throw_target = get_edge_target_turf(T, get_dir(T,TL))
			switch(dist)
				if(0 to 1)
					L.ex_act(3)//ex_act(2) would deal too much damage
					L.ex_act(3)
					spawn(1)//to give time for the other bombs to calculate their damage.
						L.throw_at(throw_target, 2, 3)
				if(1 to 2)
					L.ex_act(3,TRUE)
					spawn(1)
						L.throw_at(throw_target, 1, 1)
				if(2 to 3)
					L.ex_act(3,TRUE)
		qdel(src)

/obj/item/stickybomb/proc/deactivate()
	live = 0
	if(fired_from)
		fired_from.fired -= src
		fired_from = null
	update_icon()
	alpha = 255
	unstick()

/obj/item/stickybomb/emp_act(severity)
	deactivate()
	unstick()

/obj/item/stickybomb/bullet_act(var/obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam)||istype(Proj,/obj/item/projectile/bullet)||istype(Proj,/obj/item/projectile/ricochet))
		if(!istype(Proj ,/obj/item/projectile/beam/lastertag) && !istype(Proj ,/obj/item/projectile/beam/practice) )
			detonate()

#undef MAX_STICKYBOMBS
