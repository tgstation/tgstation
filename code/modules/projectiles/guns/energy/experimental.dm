/obj/item/weapon/gun/energy/ricochet
	name = "ricochet rifle"
	desc = "They say that ducks made this weapon. Yes, the quacking type."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "ricochet"
	item_state = null
	origin_tech = null
	projectile_type = "/obj/item/projectile/ricochet"
	charge_cost = 100
	cell_type = "/obj/item/weapon/cell"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')

/obj/item/weapon/gun/energy/bison
	name = "\improper Righteous Bison"
	desc = "A replica of Lord Cockswain's very own personnal ray gun."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "bison"
	item_state = null
	origin_tech = null
	projectile_type = "/obj/item/projectile/beam/bison"
	charge_cost = 100
	cell_type = "/obj/item/weapon/cell"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	fire_delay = 8
	fire_sound = 'sound/weapons/bison_fire.ogg'
	var/pumping = 0

/obj/item/weapon/gun/energy/bison/New()
	..()
	power_supply.charge = 0

/obj/item/weapon/gun/energy/bison/attack_self(mob/user as mob)
	if(pumping || !power_supply)	return
	pumping = 1
	power_supply.charge = min(power_supply.charge + 200,power_supply.maxcharge)
	if(power_supply.charge >= power_supply.maxcharge)
		playsound(get_turf(src), 'sound/machines/click.ogg', 25, 1)
		user << "<span class='rose'>You pull the pump at the back of the gun.Looks like the Inner battery is fully charged now.</span>"
	else
		playsound(get_turf(src), 'sound/weapons/bison_reload.ogg', 25, 1)
		user << "<span class='rose'>You pull the pump at the back of the gun.</span>"
	sleep(5)
	pumping = 0
	update_icon()

/obj/item/weapon/gun/energy/bison/update_icon()
	if(power_supply.charge >= power_supply.maxcharge)
		icon_state = "bison100"
	else if (power_supply.charge > 0)
		icon_state = "bison50"
	else
		icon_state = "bison0"
	return

#define SPUR_FULL_POWER 4
#define SPUR_HIGH_POWER 3
#define SPUR_MEDIUM_POWER 2
#define SPUR_LOW_POWER 1
#define SPUR_NO_POWER 0

/obj/item/weapon/gun/energy/polarstar
	name = "\improper Polar Star"
	desc = "Despite being incomplete, the severe wear on this gun shows to which extent it's been used already."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "polarstar"
	item_state = null
	fire_delay = 1
	origin_tech = null
	projectile_type = "/obj/item/projectile/spur"
	charge_cost = 100
	cell_type = "/obj/item/weapon/cell"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	var/firelevel = SPUR_FULL_POWER

/obj/item/weapon/gun/energy/polarstar/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	levelChange()
	..()

/obj/item/weapon/gun/energy/polarstar/proc/levelChange()
	var/maxlevel = power_supply.maxcharge
	var/level = power_supply.charge
	var/newlevel = 0
	if(level == maxlevel)
		newlevel = SPUR_FULL_POWER
	else if(level >= ((maxlevel/3)*2))
		newlevel = SPUR_HIGH_POWER
	else if(level >= (maxlevel/3))
		newlevel = SPUR_MEDIUM_POWER
	else if(level >= charge_cost)
		newlevel = SPUR_LOW_POWER
	else
		newlevel = SPUR_NO_POWER

	if(firelevel >= newlevel)
		firelevel = newlevel
		set_firesound()
		return

	firelevel = newlevel
	set_firesound()
	var/levelupsound = null
	switch(firelevel)
		if(SPUR_LOW_POWER)
			levelupsound = 'sound/weapons/spur_chargelow.ogg'
		if(SPUR_MEDIUM_POWER)
			levelupsound = 'sound/weapons/spur_chargemed.ogg'
		if(SPUR_HIGH_POWER)
			levelupsound = 'sound/weapons/spur_chargehigh.ogg'
		if(SPUR_FULL_POWER)
			levelupsound = 'sound/weapons/spur_chargefull.ogg'

	if(levelupsound)
		for(var/mob/M in get_turf(src))
			M.playsound_local(M, levelupsound, 100, 0, null, FALLOFF_SOUNDS, 0)
			spawn(1)
				M.playsound_local(M, levelupsound, 75, 0, null, FALLOFF_SOUNDS, 0)


/obj/item/weapon/gun/energy/polarstar/proc/set_firesound()
	switch(firelevel)
		if(SPUR_HIGH_POWER,SPUR_FULL_POWER)
			fire_sound = 'sound/weapons/spur_high.ogg'
			recoil = 1
		if(SPUR_MEDIUM_POWER)
			fire_sound = 'sound/weapons/spur_medium.ogg'
			recoil = 0
		if(SPUR_LOW_POWER,SPUR_NO_POWER)
			fire_sound = 'sound/weapons/spur_low.ogg'
			recoil = 0
	return

/obj/item/weapon/gun/energy/polarstar/update_icon()
	return

/obj/item/weapon/gun/energy/polarstar/spur
	name = "\improper Spur"
	desc = "A masterpiece crafted by the legendary gunsmith of a far-away planet."
	icon_state = "spur"
	item_state = null
	fire_delay = 0
	var/charge_tick = 0

/obj/item/weapon/gun/energy/polarstar/spur/New()
	..()
	processing_objects.Add(src)


/obj/item/weapon/gun/energy/polarstar/spur/Destroy()
	processing_objects.Remove(src)
	..()

/obj/item/weapon/gun/energy/polarstar/spur/process()
	charge_tick++
	if(charge_tick < 2) return 0
	charge_tick = 0
	if(!power_supply) return 0
	power_supply.give(100)
	levelChange()
	return 1

#undef SPUR_FULL_POWER
#undef SPUR_HIGH_POWER
#undef SPUR_MEDIUM_POWER
#undef SPUR_LOW_POWER
#undef SPUR_NO_POWER

/obj/item/weapon/gun/gatling
	name = "gatling gun"
	desc = "Ya-ta-ta-ta-ta-ta-ta-ta ya-ta-ta-ta-ta-ta-ta-ta do-de-da-va-da-da-dada! Kaboom-Kaboom!"
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "minigun"
	item_state = "minigun0"
	origin_tech = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	slot_flags = null
	flags = FPRINT | TWOHANDABLE
	w_class = 5.0//we be fuckin huge maaan
	fire_delay = 0
	fire_sound = 'sound/weapons/gatling_fire.ogg'
	var/max_shells = 200
	var/current_shells = 200

/obj/item/weapon/gun/gatling/examine(mob/user)
	..()
	user << "<span class='info'>Has [current_shells] round\s remaining.</span>"

/obj/item/weapon/gun/gatling/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		user << "<span class='warning'>A label sticks the trigger to the trigger guard!</span>" //Such a new feature, the player might not know what's wrong if it doesn't tell them.
		return
	if(wielded)
		Fire(A,user,params, "struggle" = struggle)
	else
		user << "<span class='warning'>You must dual-wield \the [src] before you can fire it!</span>"

/obj/item/weapon/gun/gatling/Fire(atom/target as mob|obj|turf|area, mob/living/user as mob|obj, params, reflex = 0, struggle = 0)
	..()
	var/list/turf/possible_turfs = list()
	for(var/turf/T in orange(target,1))
		possible_turfs += T
	spawn()
		for(var/i = 1; i <= 3; i++)
			sleep(1)
			var/newturf = pick(possible_turfs)
			..(newturf,user,params,reflex,struggle)

/obj/item/weapon/gun/gatling/update_wield(mob/user)
	item_state = "minigun[wielded ? 1 : 0]"
	if(wielded)
		slowdown = 10
	else
		slowdown = 0

/obj/item/weapon/gun/gatling/process_chambered()
	if(in_chamber) return 1
	if(current_shells)
		current_shells--
		update_icon()
		in_chamber = new/obj/item/projectile/bullet/gatling()//We create bullets as we are about to fire them. No other way to remove them from the gatling.
		new/obj/item/ammo_casing_gatling(get_turf(src))
		return 1
	return 0

/obj/item/weapon/gun/gatling/update_icon()
	switch(current_shells)
		if(150 to INFINITY)
			icon_state = "minigun100"
		if(100 to 149)
			icon_state = "minigun75"
		if(50 to 99)
			icon_state = "minigun50"
		if(1 to 49)
			icon_state = "minigun25"
		else
			icon_state = "minigun0"

/obj/item/weapon/gun/gatling/attack_self(mob/user)
	if(wielded)
		unwield(user)
	else
		wield(user)

/obj/item/ammo_casing_gatling
	name = "large bullet casing"
	desc = "An oversized bullet casing."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "gatling-casing"
	flags = FPRINT
	siemens_coefficient = 1
	throwforce = 1
	w_class = 1.0
	w_type = RECYK_METAL

/obj/item/ammo_casing_gatling/New()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
	dir = pick(cardinal)


#define MAX_STICKYBOMBS 4

/obj/item/weapon/gun/stickybomb
	name = "stickybomb launcher"
	desc = "Fired stickybombs take 5 seconds to become live. After which they'll progressively merge with their surroundings."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "stickybomb"
	item_state = null
	origin_tech = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	flags = FPRINT
	w_class = 3.0
	fire_delay = 2
	fire_sound = 'sound/weapons/grenadelauncher.ogg'
	var/list/loaded = list()
	var/list/fired = list()

	var/current_shells = 200

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
	user << "<span class='info'>Has [loaded.len] stickybomb\s loaded, and [fired.len] stickybomb\s placed.</span>"

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
			user << "<span class='warning'>You cannot load a live stickybomb!</span>"
		else
			if(loaded.len >= 6)
				user << "<span class='warning'>You cannot fit any more stickybombs in there!</span>"
			else
				user.drop_item(A, src)
				user << "<span class='notice'>You load \the [A] into \the [src].</span>"
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
				loc << "<span class='warning'>One of the stickybombs detonates to leave room for the next one.</span>"
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
	desc = "Ammo for a stickybomb launcher."
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
		user << "<span class='warning'>You reach for \the [src] stuck on \the [stuck_to] and start pulling.</span>"
		if(do_after(user, src, 30))
			user << "<span class='warning'>It came off!</span>"
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

/obj/item/weapon/gun/projectile/rocketlauncher/nikita
	name = "\improper Nikita"
	desc = "A miniature cruise missile launcher. Using a pulsed rocket engine and sophisticated TV guidance system."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "nikita"
	item_state = null
	origin_tech = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	flags = FPRINT
	slot_flags = null
	w_class = 4.0
	fire_delay = 2
	caliber = list("nikita" = 1)
	origin_tech = null
	fire_sound = 'sound/weapons/rocket.ogg'
	ammo_type = "/obj/item/ammo_casing/rocket_rpg/nikita"
	var/obj/item/projectile/nikita/fired = null
	var/emagged = 0

/obj/item/weapon/gun/projectile/rocketlauncher/nikita/update_icon()
	return

/obj/item/weapon/gun/projectile/rocketlauncher/nikita/attack_self(mob/user)
	if(fired)
		playsound(get_turf(src), 'sound/weapons/stickybomb_det.ogg', 30, 1)
		fired.detonate()

/obj/item/weapon/gun/projectile/rocketlauncher/nikita/suicide_act(var/mob/user)
	if(!loaded)
		user.visible_message("<span class='danger'>[user] jams down \the [src]'s trigger before noticing it isn't loaded and starts bashing \his head in with it! It looks like \he's trying to commit suicide.</span>")
		return(BRUTELOSS)
	else
		user.visible_message("<span class='danger'>[user] fiddles with \the [src]'s safeties and suddenly aims it at \his feet! It looks like \he's trying to commit suicide.</span>")
		spawn(10) //RUN YOU IDIOT, RUN
			explosion(src.loc, -1, 1, 4, 8)
			return(BRUTELOSS)
	return

/obj/item/weapon/gun/projectile/rocketlauncher/nikita/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/weapon/card/emag) && !emagged)
		emagged = 1
		user << "<span class='warning'>You disable \the [src]'s idiot security!</span>"
	else
		..()

/obj/item/weapon/gun/projectile/rocketlauncher/nikita/process_chambered()
	if(..())
		if(!emagged)
			fired = in_chamber
		return 1
	return 0

/obj/item/ammo_casing/rocket_rpg/nikita
	name = "\improper Nikita missile"
	desc = "A miniature cruise missile"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "nikita"
	caliber = "nikita"
	projectile_type = "/obj/item/projectile/nikita"

/obj/item/ammo_casing/rocket_rpg/nikita/New()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)


#define OSIPR_MAX_CORES 3
#define OSIPR_PRIMARY_FIRE 1
#define OSIPR_SECONDARY_FIRE 2

/obj/item/weapon/gun/osipr
	name = "\improper Overwatch Standard Issue Pulse Rifle"
	desc = "Centuries ago those weapons striked fear in all of humanity when the Combine attacked the Earth. Nowadays these are just the best guns that the Syndicate can provide to its Elite Troops with its tight budget."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "osipr"
	item_state = "osipr"
	origin_tech = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 1
	fire_delay = 0
	w_class = 3.0
	fire_sound = 'sound/weapons/osipr_fire.ogg'
	var/obj/item/energy_magazine/osipr/magazine = null
	var/energy_balls = 2
	var/mode = OSIPR_PRIMARY_FIRE

/obj/item/weapon/gun/osipr/New()
	..()
	magazine = new(src)

/obj/item/weapon/gun/osipr/Destroy()
	if(magazine)
		qdel(magazine)
	..()

/obj/item/weapon/gun/osipr/examine(mob/user)
	..()
	if(magazine)
		user << "<span class='info'>Has [magazine.bullets] pulse bullet\s remaining.</span>"
	else
		user << "<span class='info'>It has no pulse magazine inserted!</span>"
	user << "<span class='info'>Has [energy_balls] dark energy core\s remaining.</span>"

/obj/item/weapon/gun/osipr/process_chambered()
	if(in_chamber) return 1
	switch(mode)
		if(OSIPR_PRIMARY_FIRE)
			if(!magazine || !magazine.bullets) return 0
			magazine.bullets--
			update_icon()
			in_chamber = new magazine.bullet_type()
			return 1
		if(OSIPR_SECONDARY_FIRE)
			if(!energy_balls) return 0
			energy_balls--
			in_chamber = new/obj/item/projectile/energy/osipr()
			return 1
	return 0

/obj/item/weapon/gun/osipr/attackby(var/obj/item/A as obj, mob/user as mob)
	if(istype(A, /obj/item/energy_magazine/osipr))
		if(magazine)
			user << "There is another magazine already inserted. Remove it first."
		else
			user.u_equip(A,1)
			A.loc = src
			magazine = A
			update_icon()
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 25, 1)
			user << "<span class='info'>You insert a new magazine.</span>"
			user.regenerate_icons()

	else if(istype(A, /obj/item/osipr_core))
		if(energy_balls >= OSIPR_MAX_CORES)
			user << "The OSIPR cannot receive any additional dark energy core."
		else
			user.u_equip(A,1)
			qdel(A)
			energy_balls++
			playsound(get_turf(src), 'sound/items/Deconstruct.ogg', 25, 1)
			user << "<span class='info'>You insert \the [A].</span>"
	else
		..()

/obj/item/weapon/gun/osipr/attack_hand(mob/user)
	if(((src == user.r_hand) || (src == user.l_hand)) && magazine)
		magazine.update_icon()
		user.put_in_hands(magazine)
		magazine = null
		update_icon()
		playsound(get_turf(src), 'sound/machines/click.ogg', 25, 1)
		user << "<span class='info'>You remove the magazine.</span>"
		user.regenerate_icons()
	else
		..()

/obj/item/weapon/gun/osipr/attack_self(mob/user)
	switch(mode)
		if(OSIPR_PRIMARY_FIRE)
			mode = OSIPR_SECONDARY_FIRE
			fire_sound = 'sound/weapons/osipr_altfire.ogg'
			fire_delay = 20
			user << "<span class='warning'>Now set to fire dark energy orbs.</span>"
		if(OSIPR_SECONDARY_FIRE)
			mode = OSIPR_PRIMARY_FIRE
			fire_sound = 'sound/weapons/osipr_fire.ogg'
			fire_delay = 0
			user << "<span class='warning'>Now set to fire pulse bullets.</span>"

/obj/item/weapon/gun/osipr/update_icon()
	if(!magazine)
		icon_state = "osipr-empty"
		item_state = "osipr-empty"
	else
		item_state = "osipr"
		var/bullets = round(magazine.bullets/(magazine.max_bullets/10))
		icon_state = "osipr[bullets]0"

/obj/item/energy_magazine
	name = "energy magazine"
	desc = "Can be replenished by a recharger"
	icon = 'icons/obj/ammo.dmi'
	icon_state = "osipr-magfull"
	flags = FPRINT
	force = 1
	throwforce = 1
	w_class = 3.0
	var/bullets = 10
	var/max_bullets = 10
	var/caliber = "osipr"	//base icon name
	var/bullet_type = /obj/item/projectile/bullet/osipr

/obj/item/energy_magazine/New()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)
	update_icon()

/obj/item/energy_magazine/examine(mob/user)
	..()
	user << "<span class='info'>Has [bullets] bullet\s remaining.</span>"

/obj/item/energy_magazine/update_icon()
	if(bullets == max_bullets)
		icon_state = "[caliber]-magfull"
	else
		icon_state = "[caliber]-mag"

/obj/item/energy_magazine/osipr
	name = "pulse magazine"
	desc = "Primary ammo for OSIPR. Can be replenished by a recharger."
	icon_state = "osipr-magfull"
	w_class = 3.0
	bullets = 30
	max_bullets = 30
	caliber = "osipr"
	bullet_type = /obj/item/projectile/bullet/osipr

#undef OSIPR_PRIMARY_FIRE
#undef OSIPR_SECONDARY_FIRE

/obj/item/osipr_core
	name = "dark energy core"
	desc = "Secondary ammo for OSIPR."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "osipr-core"
	flags = FPRINT
	force = 1
	throwforce = 1
	w_class = 3.0

/obj/item/osipr_core/New()
	..()
	pixel_x = rand(-10.0, 10)
	pixel_y = rand(-10.0, 10)

/obj/item/weapon/gun/projectile/hecate
	name = "\improper PGM Hécate II"
	desc = "An Anti-Materiel Rifle. You can read \"Fabriqué en Haute-Savoie\" on the receiver. Whatever that means..."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "hecate"
	item_state = null
	origin_tech = null
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 2
	slot_flags = null
	fire_delay = 30
	w_class = 4.0
	fire_sound = 'sound/weapons/hecate_fire.ogg'
	caliber = list(".50BMG" = 1)
	ammo_type = "/obj/item/ammo_casing/BMG50"
	max_shells = 1
	load_method = 0
	var/backup_view = 7

/obj/item/weapon/gun/projectile/hecate/afterattack(atom/A as mob|obj|turf|area, mob/living/user as mob|obj, flag, params, struggle = 0)
	if(flag)	return //we're placing gun on a table or in backpack
	if(harm_labeled >= min_harm_label)
		user << "<span class='warning'>A label sticks the trigger to the trigger guard!</span>" //Such a new feature, the player might not know what's wrong if it doesn't tell them.
		return
	if(wielded)
		Fire(A,user,params, "struggle" = struggle)
	else
		user << "<span class='warning'>You must dual-wield \the [src] before you can fire it!</span>"

/obj/item/weapon/gun/projectile/hecate/update_wield(mob/user)
	if(wielded)
		slowdown = 10
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_64x64.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_64x64.dmi')
		if(user && user.client)
			user.regenerate_icons()
			var/client/C = user.client
			backup_view = C.view
			C.view = C.view * 2
	else
		slowdown = 0
		inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
		if(user && user.client)
			user.regenerate_icons()
			var/client/C = user.client
			C.view = backup_view

/obj/item/weapon/gun/projectile/hecate/attack_self(mob/user)
	if(wielded)
		unwield(user)
	else
		wield(user)
