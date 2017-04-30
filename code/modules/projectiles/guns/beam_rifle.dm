
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
	ammo_type = list(/obj/item/ammo_casing/energy/beam_rifle/hitscan, /obj/item/ammo_casing/energy/beam_rifle/hitscan/explosive)
	var/power = 20
	var/maxpower = 20
	var/energy_coeff = 0.20
	var/hipfire_inaccuracy = 2
	var/hipfire_recoil = 10
	var/scoped_inaccuracy = 0
	var/scoped_recoil = 3
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
	var/aiming_time_increase_user_movement = 3
	var/aiming_time_increase_per_pixel = 1
	var/aiming_time_increase_range_falloff = 1
	var/aiming_x = 0
	var/aiming_y = 0
	var/mob/current_user = null
	var/list/obj/effect/overlay/temp/current_tracers = list()

/obj/item/weapon/gun/energy/beam_rifle/debug
	aiming_time = 0
	aiming_time_fire_threshold = 0
	noscope = TRUE
	scoped_recoil = 0
	hipfire_recoil = 0
	hipfire_inaccuracy = 0
	maxpower = 2000
	cell_type = /obj/item/weapon/stock_parts/cell/infinite

/obj/item/weapon/gun/energy/beam_rifle/debug/update_stats()
	return

/obj/item/weapon/gun/energy/beam_rifle/debug/Initialize()
	..()
	for(var/obj/item/ammo_casing/A in contents)
		A.delay = 0

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
	for(var/obj/item/ammo_casing/energy/beam_rifle/BR in contents)
		world << "DEBUG: Changing [BR]"
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
	powerpercent = Clamp(powerpercent, 0, 100)
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
	var/atom/A = current_user.client.mouseObject
	if(!istype(A) || !A.loc)
		return
	var/turf/T = get_turf(current_user.client.mouseObject)
	if(!istype(T))
		return
	var/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/P = new
	P.gun = src
	P.preparePixelProjectile(current_user.client.mouseObject, T, current_user, current_user.client.mouseParams, 0)
	if(aiming_time >= 1)
		var/percent = ((100/aiming_time)*aiming_time_left)
		P.color = rgb(255 * percent,255 * (100 - percent),0)
	else
		P.color = rgb(0, 255, 0)
	for(var/obj/effect/overlay/temp/O in current_tracers)
		O.alpha = 0
		current_tracers -= O
	P.fire()

/obj/item/weapon/gun/energy/beam_rifle/process()
	if(!aiming)
		return
	if(aiming_time_left > 0)
		aiming_time_left--
	aiming_beam()
	if(current_user.client.mouseParams)
		var/list/mouse_control = params2list(current_user.client.mouseParams)
		if(mouse_control["screen-loc"])
			var/list/screen_loc_params = splittext(mouse_control["screen-loc"], ",")
			var/list/screen_loc_X = splittext(screen_loc_params[1],":")
			var/list/screen_loc_Y = splittext(screen_loc_params[2],":")
			var/new_aiming_x = (text2num(screen_loc_X[1]) * 32 + text2num(screen_loc_X[2]) - 32)
			var/new_aiming_y = (text2num(screen_loc_Y[1]) * 32 + text2num(screen_loc_Y[2]) - 32)
			var/difference_raw = abs(new_aiming_x - aiming_x) + abs(new_aiming_y - aiming_y)
			aiming_x = new_aiming_x
			aiming_y = new_aiming_y
			var/range_from_user = get_dist(get_turf(current_user.client.mouseObject), get_turf(current_user))
			var/penalty = difference_raw - range_from_user
			world << "difference_raw [difference_raw] range [range_from_user]"
			delay_penalty(penalty)

/obj/item/weapon/gun/energy/beam_rifle/on_mob_move()
	delay_penalty(aiming_time_increase_user_movement)

/obj/item/weapon/gun/energy/beam_rifle/proc/start_aiming()
	aiming_time_left = aiming_time
	aiming = TRUE

/obj/item/weapon/gun/energy/beam_rifle/proc/stop_aiming()
	aiming_time_left = aiming_time
	aiming = FALSE

/obj/item/weapon/gun/energy/beam_rifle/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	current_user = mob

/obj/item/weapon/gun/energy/beam_rifle/onMouseDown(object, location, params, mob)
	start_aiming()
	current_user = mob

/obj/item/weapon/gun/energy/beam_rifle/onMouseUp(object, location, params, mob/M)
	if(aiming_time_left <= aiming_time_fire_threshold)
		afterattack(M.client.mouseObject, M, FALSE, M.client.mouseParams, passthrough = TRUE)
	stop_aiming()

/obj/item/weapon/gun/energy/beam_rifle/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	if(!passthrough && (aiming_time > aiming_time_fire_threshold))
		return
	. = ..()

/obj/item/weapon/gun/energy/beam_rifle/proc/delay_penalty(amount)
	aiming_time_left = Clamp(aiming_time_left + amount, 0, aiming_time)

/obj/item/ammo_casing/energy/beam_rifle
	name = "particle acceleration lens"
	desc = "Don't look into barrel!"
	var/base_energy_multiplier = 0
	var/projectile_damage = 20

/obj/item/ammo_casing/energy/beam_rifle/proc/update_damage(power)
	projectile_damage = power

/obj/item/ammo_casing/energy/beam_rifle/hitscan/ready_proj(atom/target, mob/living/user, quiet, zone_override)
	BB.damage = projectile_damage
	. = ..(target, user, quiet, zone_override)

/obj/item/ammo_casing/energy/beam_rifle/hitscan
	projectile_type = /obj/item/projectile/beam/beam_rifle/hitscan
	select_name = "narrow-beam"
	e_cost = 500
	base_energy_multiplier = 62.5	//4x the damage of an egun on lethal at full charge.
	fire_sound = 'sound/weapons/beam_sniper.ogg'
	delay = 40

/obj/item/ammo_casing/energy/beam_rifle/hitscan/explosive
	projectile_type = /obj/item/projectile/beam/beam_rifle/hitscan/explosive
	select_name = "explosive-beam"
	e_cost = 1000
	base_energy_multiplier = 125	//2x the damage of an egun on lethal at full charge, but AOE damage.
	var/area_damage = 20
	var/burn_chance = 20

/obj/item/ammo_casing/energy/beam_rifle/hitscan/explosive/update_damage(damage)
	projectile_damage = 0
	area_damage = damage
	burn_chance = damage

/obj/item/ammo_casing/energy/beam_rifle/hitscan/explosive/ready_proj()
	..()
	var/obj/item/projectile/beam/beam_rifle/hitscan/explosive/E = BB
	E.area_damage = area_damage
	E.burn_chance = burn_chance

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
	var/obj/item/weapon/gun/energy/beam_rifle/gun
	//impact_effect_type = ""

/obj/item/projectile/beam/beam_rifle/hitscan
	icon_state = ""
	var/tracer_type = /obj/effect/overlay/temp/projectile_beam/tracer

/obj/item/projectile/beam/beam_rifle/hitscan/fire(setAngle, atom/direct_target)	//oranges didn't let me make this a var the first time around so copypasta time
	set waitfor = 0
	if(!log_override && firer && original)
		add_logs(firer, original, "fired at", src, " [get_area(src)]")
	if(setAngle)
		Angle = setAngle
	var/next_run = world.time
	var/old_pixel_x = pixel_x
	var/old_pixel_y = pixel_y
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
		var/Pixel_x=sin(Angle)+16*sin(Angle)*2
		var/Pixel_y=cos(Angle)+16*cos(Angle)*2
		var/pixel_x_offset = old_pixel_x + Pixel_x
		var/pixel_y_offset = old_pixel_y + Pixel_y
		var/new_x = x
		var/new_y = y
		while(pixel_x_offset > 16)
			pixel_x_offset -= 32
			old_pixel_x -= 32
			new_x++// x++
		while(pixel_x_offset < -16)
			pixel_x_offset += 32
			old_pixel_x += 32
			new_x--
		while(pixel_y_offset > 16)
			pixel_y_offset -= 32
			old_pixel_y -= 32
			new_y++
		while(pixel_y_offset < -16)
			pixel_y_offset += 32
			old_pixel_y += 32
			new_y--
		pixel_x = old_pixel_x
		pixel_y = old_pixel_y
		step_towards(src, locate(new_x, new_y, z))
		next_run += max(world.tick_lag, speed)
		var/delay = next_run - world.time
		if(delay <= world.tick_lag*2)
			pixel_x = pixel_x_offset
			pixel_y = pixel_y_offset
		else
			animate(src, pixel_x = pixel_x_offset, pixel_y = pixel_y_offset, time = max(1, (delay <= 3 ? delay - 1 : delay)), flags = ANIMATION_END_NOW)
		old_pixel_x = pixel_x_offset
		old_pixel_y = pixel_y_offset
		if(original && (original.layer>=2.75) || ismob(original))
			if(loc == get_turf(original))
				if(!(original in permutated))
					Bump(original, 1)
		Range()

/obj/item/projectile/beam/beam_rifle/hitscan/Range()
	spawn_tracer_effect()

/obj/item/projectile/beam/beam_rifle/hitscan/proc/spawn_tracer_effect()
	new tracer_type(loc, time = 5, angle_override = Angle, p_x = pixel_x, p_y = pixel_y, color_override = color)

/obj/item/projectile/beam/beam_rifle/hitscan/on_hit(atom/target, blocked = 0)
	. = ..(target, blocked)
	if(!ismob(target))
		target.ex_act(2)

/obj/item/projectile/beam/beam_rifle/hitscan/explosive
	damage = 0
	var/area_damage = 10
	var/burn_chance = 33

/obj/item/projectile/beam/beam_rifle/hitscan/explosive/on_hit(atom/target, blocked = 0)
	var/turf/T = get_turf(target)
	. = ..()
	new /obj/effect/overlay/temp/explosion/fast(T)
	for(var/atom/A in range(3, T))
		if(isobj(A))
			var/obj/O = A
			O.take_damage(area_damage, BURN, "energy", FALSE)
		if(isliving(A))
			var/mob/living/L = A
			to_chat(L, "<span class='userdanger'>You are seared by the [src]!</span>")
			L.adjustFireLoss(area_damage)
		if(isturf(A))
			var/turf/Z = A
			if(prob(burn_chance))
				new /obj/effect/hotspot(Z)
	playsound(get_turf(target), 'sound/effects/Explosion1.ogg', 100, 1)

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam
	tracer_type = /obj/effect/overlay/temp/projectile_beam/tracer/aiming
	name = "aiming beam"
	hitsound = null
	hitsound_wall = null

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/prehit()
	qdel(src)
	return FALSE

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/spawn_tracer_effect()
	var/obj/effect/overlay/temp/projectile_beam/T = new tracer_type(loc, time = 5, angle_override = Angle, p_x = pixel_x, p_y = pixel_y, color_override = color)
	if(istype(gun) && istype(T))
		gun.current_tracers += T

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
