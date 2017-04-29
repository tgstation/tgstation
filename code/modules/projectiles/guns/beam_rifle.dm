
/obj/item/weapon/gun/energy/beam_rifle
	name = "particle acceleration rifle"
	desc = "A powerful marksman rifle that uses highly focused particle beams to obliterate targets."
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "esniper"
	item_state = "esniper"
	fire_sound = 'sound/weapons/beam_sniper.ogg'
	slot_flags = SLOT_BACK
	force = 15
	materials = list()
	origin_tech = ""
	recoil = 5
	ammo_x_offset = 3
	ammo_y_offset = 3
	modifystate = FALSE
	zoomable = TRUE
	zoom_amt = 20
	zoom_out_amt = 23
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = list(/obj/item/ammo_casing/energy/beam_rifle/hitscan)
	var/impact_delay = 10
	var/power = 20
	var/maxpower = 20
	var/energy_coeff = 0.20
	var/hipfire_inaccuracy = 4
	var/hipfire_recoil = 10
	var/scoped_inaccuracy = 0
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
	canMouseDown = TRUE
	var/aiming = FALSE
	var/aiming_time = 10
	var/aiming_time_fire_threshold = 2
	var/aiming_time_left = 10
	var/aiming_time_increase_per_pixel = 5
	var/aiming_time_increase_range_falloff = 1
	var/turf/aiming_target = null
	var/aiming_params = ""
	var/mob/current_user = null

/obj/item/weapon/gun/energy/beam_rifle/New()
	..()
	poweraction = new()
	poweraction.gun = src
	START_PROCESSING(SSfastprocess, src)

/obj/item/weapon/gun/energy/beam_rifle/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	..()

/obj/item/weapon/gun/energy/beam_rifle/pickup(mob/user)
	if(poweraction)
		poweraction.Grant(user)
	. = ..()

/obj/item/weapon/gun/energy/beam_rifle/dropped(mob/user)
	if(poweraction)
		poweraction.Remove(user)
	. = ..()

/obj/item/weapon/gun/energy/beam_rifle/proc/update_stats()
	maxpower = laser.rating*20
	if(maxpower > power)
		power = maxpower
	energy_coeff = (1 - (cap*0.1875))
	scoped_recoil = 5 - bin.rating
	hipfire_recoil = 10 - bin.rating*2
	hipfire_inaccuracy = Clamp((30 - (manip.rating * 5)), 0, 30)
	for(var/obj/item/ammo_casing/energy/beam_rifle/BR in ammo_type)
		BR.base_energy_multiplier = (initial(BR.base_energy_multiplier) * (1 - (scan.rating * 0.075)))
		BR.e_cost = round((power * BR.base_energy_multiplier)*energy_coeff)
		BR.update_damage(power)

/obj/item/weapon/gun/energy/beam_rifle/zoom(user, forced_zoom)
	. = ..()
	scope(user, .)

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
			to_chat(user, "[I] has been sucessfully installed into systems.")
			if(user.transferItemToLoc(I, src))
				if(manip)
					manip.forceMove(get_turf(src))
					manip = null
				manip = I
		if(istype(S, /obj/item/weapon/stock_parts/scanning_module))
			to_chat(user, "[I] has been sucessfully installed into systems.")
			if(user.transferItemToLoc(I, src))
				if(scan)
					scan.forceMove(get_turf(src))
					scan = null
				scan = I
		if(istype(S, /obj/item/weapon/stock_parts/micro_laser))
			to_chat(user, "[I] has been sucessfully installed into systems.")
			if(user.transferItemToLoc(I, src))
				if(laser)
					laser.forceMove(get_turf(src))
					laser = null
				laser = I
		if(istype(S, /obj/item/weapon/stock_parts/matter_bin))
			to_chat(user, "[I] has been sucessfully installed into systems.")
			if(user.transferItemToLoc(I, src))
				if(bin)
					bin.forceMove(get_turf(src))
					bin = null
				bin = I
		if(istype(S, /obj/item/weapon/stock_parts/capacitor))
			to_chat(user, "[I] has been sucessfully installed into systems.")
			if(user.transferItemToLoc(I, src))
				if(cap)
					cap.forceMove(get_turf(src))
					cap = null
				cap = I
	. = ..(I, user, params)

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
	button_icon_state = "esniper_power"
	background_icon_state = "bg_tech_red"

/datum/action/item_action/beam_rifle_power/Trigger()
	gun.select_power(owner)
	. = ..()

/obj/item/weapon/gun/energy/beam_rifle/proc/aiming_beam()
	aiming_target = get_turf(aiming_target)
	if(!isturf(aiming_target))
		return
	var/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/P = new
	P.preparePixelProjectile(aiming_target, aiming_target, current_user, aiming_params, 0)
	P.color = rgb(255,0,0)
	P.fire()

/obj/item/weapon/gun/energy/beam_rifle/process()
	if(!aiming)
		return
	if(aiming_time_left > 0)
		aiming_time_left--
	aiming_beam()

/obj/item/weapon/gun/energy/beam_rifle/proc/start_aiming()
	aiming_time_left = aiming_time
	aiming = TRUE

/obj/item/weapon/gun/energy/beam_rifle/proc/stop_aiming()
	aiming_time_left = aiming_time
	aiming = FALSE
	aiming_params = ""

/obj/item/weapon/gun/energy/beam_rifle/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	aiming_target = over_location
	aiming_params = params
	current_user = mob
	world << "Updating mousecontrol with params [params]"

/obj/item/weapon/gun/energy/beam_rifle/onMouseDown(object, location, params, mob)
	aiming_target = location
	aiming_params = params
	start_aiming()
	current_user = mob
	world << "Updating mousecontrol with params [params]"

/obj/item/weapon/gun/energy/beam_rifle/onMouseUp(object, location, params, mob)
	if(aiming_time_left <= aiming_time_fire_threshold)
		afterattack(aiming_target, mob, FALSE, aiming_params, passthrough = TRUE)
	stop_aiming()

/obj/item/weapon/gun/energy/beam_rifle/afterattack(atom/target, mob/living/user, flag, params, x_compensation = 0, y_compensation = 0, passthrough = FALSE)
	if(!passthrough && (aiming_time != 0))
		return
	. = ..()

/obj/item/ammo_casing/energy/beam_rifle
	name = "particle acceleration lens"
	desc = "Don't look into barrel!"
	var/base_energy_multiplier = 250
	var/projectile_damage = 20

/obj/item/ammo_casing/energy/beam_rifle/proc/update_damage(power)
	projectile_damage = power

/obj/item/ammo_casing/energy/beam_rifle/ready_proj(atom/target, mob/living/user, quiet, zone_override)
	BB.damage = projectile_damage
	. = ..(target, user, quiet, zone_override)

/obj/item/ammo_casing/energy/beam_rifle/hitscan
	projectile_type = /obj/item/projectile/beam/beam_rifle/hitscan
	select_name = "narrow-beam"
	e_cost = 2000
	fire_sound = 'sound/weapons/beam_sniper.ogg'
	firing_effect_type = ""
	delay = 40

/obj/item/projectile/beam/beam_rifle
	name = "particle beam"
	icon = ""
	//hitsound = ''
	//hitsound_wall = ''
	damage = 20
	damage_type = BURN
	flag = "energy"
	range = 150
	jitter = 10
	//impact_effect_type = ""

/obj/item/projectile/beam/beam_rifle/hitscan
	icon_state = ""
	var/tracer_type = /obj/effect/overlay/temp/projectile_beam/tracer

/obj/item/projectile/beam/beam_rifle/hitscan/fire(setAngle, atom/direct_target)	//oranges didn't let me make this a var the first time around so copypasta time
	set waitfor = 0
	if(setAngle)
		Angle = setAngle
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
		var/Pixel_x=round((sin(Angle)+16*sin(Angle)*2), 1)	//round() is a floor operation when only one argument is supplied, we don't want that here
		var/Pixel_y=round((cos(Angle)+16*cos(Angle)*2), 1)
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
		next_run += max(world.tick_lag, speed)
		var/delay = next_run - world.time
		if(delay <= world.tick_lag*2)
			pixel_x = pixel_x_offset
			pixel_y = pixel_y_offset
		else
			animate(src, pixel_x = pixel_x_offset, pixel_y = pixel_y_offset, time = max(1, (delay <= 3 ? delay - 1 : delay)), flags = ANIMATION_END_NOW)

		if(original && (original.layer>=2.75) || ismob(original))
			if(loc == get_turf(original))
				if(!(original in permutated))
					Bump(original, 1)
		Range()

/obj/item/projectile/beam/beam_rifle/hitscan/Range()
	spawn_tracer_effect()

/obj/item/projectile/beam/beam_rifle/hitscan/proc/spawn_tracer_effect()
	new tracer_type(loc, time = 5, angle_override = Angle, p_x = pixel_x, p_y = pixel_y, color_override = color)

/obj/item/projectile/beam/beam_rifle/on_hit(atom/target, blocked = 0)
	. = ..(target, blocked)
	if(!ismob(target))
		target.ex_act(2)

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam
	tracer_type = /obj/effect/overlay/temp/projectile_beam/tracer/aiming
	name = "aiming beam"
	hitsound = null
	hitsound_wall = null

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/prehit()
	qdel(src)
	return FALSE

/obj/effect/overlay/temp/projectile_beam
	icon = 'icons/obj/projectiles.dmi'
	layer = ABOVE_MOB_LAYER
	anchored = 1
	duration = 5
	randomdir = FALSE

/obj/effect/overlay/temp/projectile_beam/New(time = 5, angle_override, p_x, p_y, color_override)
	duration = time
	if(isnull(angle_override)||isnull(p_x)|isnull(p_y))
		qdel(src)
	pixel_x = p_x
	pixel_y = p_y
	var/matrix/M = new
	M.Turn(angle_override)
	transform = M
	if(color_override)
		color = color_override
	..()

/obj/effect/overlay/temp/projectile_beam/tracer
	icon_state = "tracer_beam"

/obj/effect/overlay/temp/projectile_beam/tracer/aiming
	icon_state = "gbeam"
	duration = 1
