
/obj/item/weapon/gun/energy/beam_rifle
	name = ""
	desc = ""
	icon = 'icons/obj/guns/'
	icon_state = ""
	item_state = ""
	fire_sound = 'sound/weapons/beam_sniper.ogg'
	slot_flags = SLOT_BACK
	force = 15
	materials = list()
	origin_tech = ""
	recoil = 5
	zoomable = TRUE
	zoom_amt = 20
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = list(/obj/item/ammo_casing/energy/beam_rifle)
	var/impact_delay = 10
	var/zoom_out_amt = 13
	var/power = 20
	var/maxpower = 20
	var/energy_coeff = 0.20
	var/hipfire_inaccuracy = 7
	var/hipfire_recoil = 20
	var/scoped_inaccuracy = 2
	var/scoped_recoil = 5
	var/scoped = FALSE
	var/noscope = FALSE	//Can you fire this without a scope?
	var/obj/item/weapon/stock_parts/capacitor/cap = new /obj/item/weapon/stock_parts/capacitor
	var/obj/item/weapon/stock_parts/scanning_module/scan = new /obj/item/weapon/stock_parts/scanning_module
	var/obj/item/weapon/stock_parts/manipulator/manip = new /obj/item/weapon/stock_parts/manipulator
	var/obj/item/weapon/stock_parts/micro_laser/laser = new /obj/item/weapon/stock_parts/micro_laser
	var/obj/item/weapon/stock_parts/matter_bin/bin = new /obj/item/weapon/stock_parts/matter_bin
	cell_type = /obj/item/weapon/stock_parts/cell/beam_rifle
	var/datum/action/item_action/beam_rifle_power/poweraction

/obj/item/weapon/gun/energy/beam_rifle/New()
	..()
	poweraction = new()
	poweraction.gun = src

/obj/item/weapon/gun/energy/beam_rifle/pickup(mob/user)
	if(poweraction)
		poweraction.Grant(user)
	. = ..(user)

/obj/item/weapon/gun/dropped(mob/user)
	if(poweraction)
		poweraction.Remove(user)
	. = ..(user)

/obj/item/weapon/gun/energy/proc/update_ammo_types()
	var/obj/item/ammo_casing/energy/shot
	for (var/i = 1, i <= ammo_type.len, i++)
		var/shottype = ammo_type[i]
		shot = new shottype(src)
		ammo_type[i] = shot
	shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay

/obj/item/weapon/gun/energy/beam_rifle/proc/update_stats()
	maxpower = laser.rating*20
	energy_coeff = (1 - (capacitor*0.1875))
	scoped_recoil = 5 - bin.rating
	hipfire_recoil = 20 - bin.rating*2
	scoped_inaccuracy = Clamp((3 - manip.rating), 0, 5)
	hipfire_inaccuacy = Clamp((30 - (manip.rating * 5)), 0, 30)
	for(var/obj/item/ammo_casing/energy/beam_rifle/BR in ammo_type)
		BR.base_energy_multiplier = (BR.initial(base_energy_multiplier) * (1 - (scan.rating * 0.075)))
		BR.e_cost = round((power * BR.base_energy_multiplier)*energy_coeff)
		BR.update_damage(power)

/obj/item/weapon/gun/energy/beam_rifle/zoom(user, forced_zoom)
	. = ..(user, forced_zoom)
	scope(user, zoomed)

/obj/item/weapon/gun/energy/beam_rifle/proc/scope(mob/user, forced)
	var/scoping
	switch(forced)
		if(TRUE)
			scoping = TRUE
		if(FALSE)
			scoping = FALSE
		else
			scoping = !scoped
	if(scoping)
		spread = scoped_inaccuracy
		recoil = scoped_recoil
		scoped = TRUE
		user << "<span class='boldnotice'>You bring your [src] up and use its scope...</span>"
	else
		spread = hipfire_inaccuracy
		recoil = hipfire_recoil
		scoped = FALSE
		user << "<span class='boldnotice'>You lower your [src].</span>"

/obj/item/weapon/gun/energy/beam_rifle/can_trigger_gun(var/mob/living/user)
	if(!scoped && !noscope)
		user << "<span class='userdanger'>This beam rifle can only be used while scoped!</span>"
		return FALSE
	. = ..(user)

/obj/item/weapon/gun/energy/beam_rifle/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/weapon/stock_parts))
		var/obj/item/weapon/stock_parts/S = I
		if(istype(S, /obj/item/weapon/stock_parts/manipulator))
			if((!manip) || (manip.rating < S.rating))
				user << "<span class='boldnotice'>[I] has been sucessfully installed into systems. Accuracy increased.</span>"
				if(user.unEquip(I))
					I.loc = src
					manip = I
		if(istype(S, /obj/item/weapon/stock_parts/scanning_module))
			if((!scan) || (scan.rating < S.rating))
				user << "<span class='boldnotice'>[I] has been sucessfully installed into systems. Power usage decreased.</span>"
				if(user.unEquip(I))
					I.loc = src
					scan = I
		if(istype(S, /obj/item/weapon/stock_parts/micro_laser))
			if((!laser) || (laser.rating < S.rating))
				user << "<span class='boldnotice'>[I] has been sucessfully installed into systems. Power output increased.</span>"
				if(user.unEquip(I))
					I.loc = src
					laser = I
		if(istype(S, /obj/item/weapon/stock_parts/matter_bin))
			if((!bin) || (bin.rating < S.rating))
				user << "<span class='boldnotice'>[I] has been sucessfully installed into systems. Recoil compensators upgraded.</span>"
				if(user.unEquip(I))
					I.loc = src
					bin = I
		if(istype(S, /obj/item/weapon/stock_parts/capacitor))
			if((!cap) || (cap.rating < S.rating))
				user << "<span class='boldnotice'>[I] has been sucessfully installed into systems. Power efficiency upgraded.</span>"
				if(user.unEquip(I))
					I.loc = src
					cap = I
	. = (I, user, params)

/obj/item/weapon/gun/energy/beam_rifle/emp_act(severity)
	chambered = null
	recharge_newshot()
	return	//Energy drain handled by its cell.

/obj/item/weapon/gun/energy/beam_rifle/proc/select_power(mob/user)
	var/powerpercent = 50
	powerpercent = round(input("Set [src] to percentage power","Adjust power output", null) as num|null)
	if(powerpercent)
		power = ((100/maxpower) * powerpercent)
		user << "<span class='boldnotice'>[src] set to [powerpercent]% power.</span>"
	update_stats()

/datum/action/item_action/beam_rifle_power
	name = "Adjust Power Output"
	var/obj/item/weapon/gun/energy/beam_rifle/gun
	button_icon_state = "
	background_icon_state = "

/datum/action/item_action/beam_rifle_power/Trigger()
	gun.select_power(owner)
	. = ..()

/obj/item/ammo_casing/energy/beam_rifle
	name = "particle acceleration lens"
	desc = "Don't look into barrel!"
	projectile_type = /obj/item/projectile/energy/beam_rifle
	select_name = "narrow-beam"
	e_cost = 2000
	var/base_energy_multiplier = 250
	var/hitscan_delay = 10
	fire_sound = 'sound/weapons/beam_sniper.ogg'
	firing_effect_type =
	var/projectile_damage = 20

/obj/item/ammo_casing/energy/beam_rifle/proc/update_damage(power)
	projectile_damage = power

/obj/item/ammo_casing/energy/beam_rifle/ready_proj(atom/target, mob/living/user, quiet, zone_override)
	BB.damage = projectile_damage
	. = ..(target, user, quiet, zone_override)

/obj/item/projectile/beam/beam_rifle
	name = "particle beam"
	icon = null
	icon_state = null
	hitsound = '
	hitsound_wall = "
	damage = 20
	damage_type = BURN
	flag = energy
	range = 150
	jitter = 10
	impact_effect_type =

/obj/item/projectile/beam/beam_rifle/fire(setAngle, atom/direct_target)
	if(!log_override && firer && original)
		add_logs(firer, original, "fired at", src, " [get_area(src)]")
	if(direct_target)
		prehit(direct_target)
		direct_target.bullet_act(src, def_zone)
		qdel(src)
		return
	if(setAngle)
		Angle = setAngle
	set waitfor = 0
	var/next_run = world.time
	while(loc)
		if((!( current ) || loc == current))
			current = locate(Clamp(x+xo,1,world.maxx),Clamp(y+yo,1,world.maxy),z)
		if(!Angle)
			Angle=round(Get_Angle(src,current))
		if(spread)
			Angle += (rand() - 0.5) * spread
		var/matrix/M = new
		M.Turn(Angle)
		transform = M
		var/obj/effect/overlay/temp/projectile_beam/tracer/T = new(loc, 5)
		T.set_transform(M)
		var/Pixel_x=round(sin(Angle)+16*sin(Angle)*2)
		var/Pixel_y=round(cos(Angle)+16*cos(Angle)*2)
		var/pixel_x_offset = pixel_x + Pixel_x
		var/pixel_y_offset = pixel_y + Pixel_y
		var/new_x = x
		var/new_y = y
		while(pixel_x_offset > 16)
			pixel_x_offset -= 32
			pixel_x -= 32
			new_x++// x++
		while(pixel_x_offset < -16)
			pixel_x_offset += 32
			pixel_x += 32
			new_x--
		while(pixel_y_offset > 16)
			pixel_y_offset -= 32
			pixel_y -= 32
			new_y++
		while(pixel_y_offset < -16)
			pixel_y_offset += 32
			pixel_y += 32
			new_y--
		step_towards(src, locate(new_x, new_y, z))
		pixel_x = pixel_x_offset
		pixel_y = pixel_y_offset
		animate(src, pixel_x = pixel_x_offset, pixel_y = pixel_y_offset, time = max(1, (delay <= 3 ? delay - 1 : delay)), flags = ANIMATION_END_NOW)
		if(original && (original.layer>=2.75) || ismob(original))
			if(loc == get_turf(original))
				if(!(original in permutated))
					Bump(original, 1)
		Range()

/obj/item/projectile/beam/beam_rifle/on_hit(atom/target, blocked = 0)
	. = ..(target, blocked)
	if(isturf(target) || istype(target,/obj/structure/))
		target.ex_act(2)

/obj/effect/overlay/temp/projectile_beam
	icon = 'icons/obj/projectiles.dmi'
	layer = ABOVE_MOB_LAYER
	anchored = 1
	duration = 5
	randomdir = FALSE

/obj/effect/overlay/temp/projectile_beam/New(var/turf/location, duration1 = 5)
	duration = duration1
	if(istype(location))
		loc = location
	..()

/obj/effect/overlay/temp/projectile_beam/proc/set_transform(var/matrix/M)
	if(istype(M))
		transform = M

/obj/effect/overlay/temp/projectile_beam/tracer
	icon_state = "tracer_beam"
