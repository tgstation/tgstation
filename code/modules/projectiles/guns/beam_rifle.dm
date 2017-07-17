
#define ZOOM_LOCK_AUTOZOOM_FREEMOVE 0
#define ZOOM_LOCK_AUTOZOOM_ANGLELOCK 1
#define ZOOM_LOCK_CENTER_VIEW 2
#define ZOOM_LOCK_OFF 3

#define ZOOM_SPEED_STEP 0
#define ZOOM_SPEED_INSTANT 1

#define AUTOZOOM_PIXEL_STEP_FACTOR 48

#define AIMING_BEAM_ANGLE_CHANGE_THRESHOLD 0.1

/obj/item/weapon/gun/energy/beam_rifle
	name = "particle acceleration rifle"
	desc = "An energy-based anti material marksman rifle that uses highly charged particle beams moving at extreme velocities to decimate whatever is unfortunate enough to be targetted by one. \
		<span class='boldnotice'>Hold down left click while scoped to aim, when weapon is fully aimed (Tracer goes from red to green as it charges), release to fire. Moving while aiming or \
		changing where you're pointing at while aiming will delay the aiming process depending on how much you changed.</span>"
	icon = 'icons/obj/guns/energy.dmi'
	icon_state = "esniper"
	item_state = "esniper"
	fire_sound = 'sound/weapons/beam_sniper.ogg'
	slot_flags = SLOT_BACK
	force = 15
	materials = list()
	origin_tech = ""
	recoil = 4
	ammo_x_offset = 3
	ammo_y_offset = 3
	modifystate = FALSE
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/beam_rifle/hitscan)
	cell_type = /obj/item/weapon/stock_parts/cell/beam_rifle
	canMouseDown = TRUE
	pin = null
	var/aiming = FALSE
	var/aiming_time = 7
	var/aiming_time_fire_threshold = 2
	var/aiming_time_left = 7
	var/aiming_time_increase_user_movement = 3
	var/scoped_slow = 1
	var/aiming_time_increase_angle_multiplier = 0.3

	var/lastangle = 0
	var/aiming_lastangle = 0
	var/mob/current_user = null
	var/obj/effect/projectile_beam/current_tracer

	var/structure_piercing = 2				//Amount * 2. For some reason structures aren't respecting this unless you have it doubled. Probably with the objects in question's Bump() code instead of this but I'll deal with this later.
	var/structure_bleed_coeff = 0.7
	var/wall_pierce_amount = 0
	var/wall_devastate = 0
	var/aoe_structure_range = 1
	var/aoe_structure_damage = 50
	var/aoe_fire_range = 2
	var/aoe_fire_chance = 40
	var/aoe_mob_range = 1
	var/aoe_mob_damage = 30
	var/impact_structure_damage = 60
	var/projectile_damage = 30
	var/projectile_stun = 0
	var/projectile_setting_pierce = TRUE
	var/delay = 65
	var/lastfire = 0

	//ZOOMING
	var/zoom_current_view_increase = 0
	var/zoom_target_view_increase = 10
	var/zoom_speed = ZOOM_SPEED_STEP
	var/zooming = FALSE
	var/zoom_lock = ZOOM_LOCK_AUTOZOOM_FREEMOVE
	var/zooming_angle
	var/current_zoom_x = 0
	var/current_zoom_y = 0
	var/zoom_animating = 0

	var/static/image/charged_overlay = image(icon = 'icons/obj/guns/energy.dmi', icon_state = "esniper_charged")
	var/static/image/drained_overlay = image(icon = 'icons/obj/guns/energy.dmi', icon_state = "esniper_empty")

	var/datum/action/item_action/zoom_speed_action/zoom_speed_action
	var/datum/action/item_action/zoom_lock_action/zoom_lock_action

/obj/item/weapon/gun/energy/beam_rifle/debug
	delay = 0
	cell_type = /obj/item/weapon/stock_parts/cell/infinite
	aiming_time = 0
	recoil = 0
	pin = /obj/item/device/firing_pin

/obj/item/weapon/gun/energy/beam_rifle/equipped(mob/user)
	set_user(user)
	. = ..()

/obj/item/weapon/gun/energy/beam_rifle/pickup(mob/user)
	set_user(user)
	. = ..()

/obj/item/weapon/gun/energy/beam_rifle/dropped()
	set_user()
	. = ..()

/obj/item/weapon/gun/energy/beam_rifle/ui_action_click(owner, action)
	if(istype(action, /datum/action/item_action/zoom_speed_action))
		zoom_speed++
		if(zoom_speed > 1)
			zoom_speed = ZOOM_SPEED_STEP
		switch(zoom_speed)
			if(ZOOM_SPEED_STEP)
				to_chat(owner, "<span class='boldnotice'>You switch [src]'s digital zoom to stepper mode.</span>")
			if(ZOOM_SPEED_INSTANT)
				to_chat(owner, "<span class='boldnotice'>You switch [src]'s digital zoom to instant mode.</span>")
	if(istype(action, /datum/action/item_action/zoom_lock_action))
		zoom_lock++
		if(zoom_lock > 3)
			zoom_lock = 0
		switch(zoom_lock)
			if(ZOOM_LOCK_AUTOZOOM_FREEMOVE)
				to_chat(owner, "<span class='boldnotice'>You switch [src]'s zooming processor to free directional.</span>")
			if(ZOOM_LOCK_AUTOZOOM_ANGLELOCK)
				to_chat(owner, "<span class='boldnotice'>You switch [src]'s zooming processor to locked directional.</span>")
			if(ZOOM_LOCK_CENTER_VIEW)
				to_chat(owner, "<span class='boldnotice'>You switch [src]'s zooming processor to center mode.</span>")
			if(ZOOM_LOCK_OFF)
				to_chat(owner, "<span class='boldnotice'>You disable [src]'s zooming system.</span>")
	reset_zooming()

/obj/item/weapon/gun/energy/beam_rifle/proc/smooth_zooming(delay_override = null)
	if(!check_user() || !zooming || zoom_lock == ZOOM_LOCK_OFF || zoom_lock == ZOOM_LOCK_CENTER_VIEW)
		return
	if(zoom_animating && delay_override != 0)
		return smooth_zooming(zoom_animating + delay_override)	//Automatically compensate for ongoing zooming actions.
	var/total_time = SSfastprocess.wait
	if(delay_override)
		total_time = delay_override
	if(zoom_speed == ZOOM_SPEED_INSTANT)
		total_time = 0
	zoom_animating = total_time
	animate(current_user.client, pixel_x = current_zoom_x, pixel_y = current_zoom_y , total_time, SINE_EASING, ANIMATION_PARALLEL)
	zoom_animating = 0

/obj/item/weapon/gun/energy/beam_rifle/proc/set_autozoom_pixel_offsets_immediate(current_angle)
	if(zoom_lock == ZOOM_LOCK_CENTER_VIEW || zoom_lock == ZOOM_LOCK_OFF)
		return
	current_zoom_x = sin(current_angle) + sin(current_angle) * AUTOZOOM_PIXEL_STEP_FACTOR * zoom_current_view_increase
	current_zoom_y = cos(current_angle) + cos(current_angle) * AUTOZOOM_PIXEL_STEP_FACTOR * zoom_current_view_increase

/obj/item/weapon/gun/energy/beam_rifle/proc/handle_zooming()
	if(!zooming || !check_user())
		return
	if(zoom_speed == ZOOM_SPEED_INSTANT)
		current_user.client.change_view(world.view + zoom_target_view_increase)
		zoom_current_view_increase = zoom_target_view_increase
		set_autozoom_pixel_offsets_immediate(zooming_angle)
		smooth_zooming()
		return
	if(zoom_current_view_increase > zoom_target_view_increase)
		return
	zoom_current_view_increase++
	current_user.client.change_view(zoom_current_view_increase + world.view)
	set_autozoom_pixel_offsets_immediate(zooming_angle)
	smooth_zooming(SSfastprocess.wait * zoom_target_view_increase * zoom_speed)

/obj/item/weapon/gun/energy/beam_rifle/proc/start_zooming()
	if(zoom_lock == ZOOM_LOCK_OFF)
		return
	zooming = TRUE

/obj/item/weapon/gun/energy/beam_rifle/proc/stop_zooming()
	zooming = FALSE
	reset_zooming()

/obj/item/weapon/gun/energy/beam_rifle/proc/reset_zooming()
	if(!check_user(FALSE))
		return
	zoom_animating = 0
	animate(current_user.client, pixel_x = 0, pixel_y = 0, 0, FALSE, LINEAR_EASING, ANIMATION_END_NOW)
	zoom_current_view_increase = 0
	current_user.client.change_view(world.view)
	zooming_angle = 0
	current_zoom_x = 0
	current_zoom_y = 0

/obj/item/weapon/gun/energy/beam_rifle/update_icon()
	cut_overlays()
	var/obj/item/ammo_casing/energy/primary_ammo = ammo_type[1]
	if(cell.charge > primary_ammo.e_cost)
		add_overlay(charged_overlay)
	else
		add_overlay(drained_overlay)

/obj/item/weapon/gun/energy/beam_rifle/attack_self(mob/user)
	projectile_setting_pierce = !projectile_setting_pierce
	to_chat(user, "<span class='boldnotice'>You set \the [src] to [projectile_setting_pierce? "pierce":"impact"] mode.</span>")
	aiming_beam()

/obj/item/weapon/gun/energy/beam_rifle/proc/update_slowdown()
	if(aiming)
		slowdown = scoped_slow
	else
		slowdown = initial(slowdown)

/obj/item/weapon/gun/energy/beam_rifle/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	zoom_speed_action = new(src)
	zoom_lock_action = new(src)

/obj/item/weapon/gun/energy/beam_rifle/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	set_user(null)
	QDEL_NULL(current_tracer)
	return ..()

/obj/item/weapon/gun/energy/beam_rifle/emp_act(severity)
	chambered = null
	recharge_newshot()

/obj/item/weapon/gun/energy/beam_rifle/proc/aiming_beam(force_update = FALSE)
	var/diff = abs(aiming_lastangle - lastangle)
	check_user()
	if(diff < AIMING_BEAM_ANGLE_CHANGE_THRESHOLD && !force_update)
		return
	aiming_lastangle = lastangle
	var/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/P = new
	P.gun = src
	P.wall_pierce_amount = wall_pierce_amount
	P.structure_pierce_amount = structure_piercing
	P.do_pierce = projectile_setting_pierce
	if(aiming_time)
		var/percent = ((100/aiming_time)*aiming_time_left)
		P.color = rgb(255 * percent,255 * ((100 - percent) / 100),0)
	else
		P.color = rgb(0, 255, 0)
	var/turf/curloc = get_turf(src)
	var/turf/targloc = get_turf(current_user.client.mouseObject)
	if(!istype(targloc))
		if(!istype(curloc))
			return
		targloc = get_turf_in_angle(lastangle, curloc, 10)
	P.preparePixelProjectile(targloc, targloc, current_user, current_user.client.mouseParams, 0)
	P.fire(lastangle)

/obj/item/weapon/gun/energy/beam_rifle/process()
	if(!aiming)
		return
	check_user()
	handle_zooming()
	if(aiming_time_left > 0)
		aiming_time_left--
		aiming_beam(TRUE)

/obj/item/weapon/gun/energy/beam_rifle/proc/check_user(automatic_cleanup = TRUE)
	if(!istype(current_user) || !isturf(current_user.loc) || !(src in current_user.held_items) || current_user.incapacitated())	//Doesn't work if you're not holding it!
		if(automatic_cleanup)
			stop_aiming()
			set_user(null)
		return FALSE
	return TRUE

/obj/item/weapon/gun/energy/beam_rifle/proc/process_aim()
	if(istype(current_user) && current_user.client && current_user.client.mouseParams)
		var/angle = mouse_angle_from_client(current_user.client)
		switch(angle)
			if(316 to 360)
				current_user.setDir(NORTH)
			if(0 to 45)
				current_user.setDir(NORTH)
			if(46 to 135)
				current_user.setDir(EAST)
			if(136 to 225)
				current_user.setDir(SOUTH)
			if(226 to 315)
				current_user.setDir(WEST)
		var/difference = abs(lastangle - angle)
		if(difference > 350)			//Too lazy to properly math, detects 360 --> 0 changes.
			difference = (lastangle > 350? ((360 - lastangle) + angle) : ((360 - angle) + lastangle))
		delay_penalty(difference * aiming_time_increase_angle_multiplier)
		lastangle = angle

/obj/item/weapon/gun/energy/beam_rifle/on_mob_move()
	check_user()
	if(aiming)
		delay_penalty(aiming_time_increase_user_movement)
		process_aim()
		aiming_beam(TRUE)

/obj/item/weapon/gun/energy/beam_rifle/proc/start_aiming()
	aiming_time_left = aiming_time
	aiming = TRUE
	process_aim()
	aiming_beam(TRUE)
	zooming_angle = lastangle
	start_zooming()

/obj/item/weapon/gun/energy/beam_rifle/proc/stop_aiming()
	set waitfor = FALSE
	aiming_time_left = aiming_time
	aiming = FALSE
	QDEL_NULL(current_tracer)
	stop_zooming()

/obj/item/weapon/gun/energy/beam_rifle/proc/set_user(mob/user)
	if(user == current_user)
		return
	stop_aiming()
	if(istype(current_user))
		LAZYREMOVE(current_user.mousemove_intercept_objects, src)
		current_user = null
	if(istype(user))
		current_user = user
		LAZYADD(current_user.mousemove_intercept_objects, src)

/obj/item/weapon/gun/energy/beam_rifle/onMouseDrag(src_object, over_object, src_location, over_location, params, mob)
	if(aiming)
		process_aim()
		aiming_beam()
		if(zoom_lock == ZOOM_LOCK_AUTOZOOM_FREEMOVE)
			zooming_angle = lastangle
			set_autozoom_pixel_offsets_immediate(zooming_angle)
			smooth_zooming(2)
	return ..()

/obj/item/weapon/gun/energy/beam_rifle/onMouseDown(object, location, params, mob/mob)
	if(istype(mob))
		set_user(mob)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	if((object in mob.contents) || (object == mob))
		return
	start_aiming()
	return ..()

/obj/item/weapon/gun/energy/beam_rifle/onMouseUp(object, location, params, mob/M)
	if(istype(object, /obj/screen) && !istype(object, /obj/screen/click_catcher))
		return
	process_aim()
	if(aiming_time_left <= aiming_time_fire_threshold && check_user())
		sync_ammo()
		afterattack(M.client.mouseObject, M, FALSE, M.client.mouseParams, passthrough = TRUE)
	stop_aiming()
	QDEL_NULL(current_tracer)
	return ..()

/obj/item/weapon/gun/energy/beam_rifle/afterattack(atom/target, mob/living/user, flag, params, passthrough = FALSE)
	if(flag) //It's adjacent, is the user, or is on the user's person
		if(target in user.contents) //can't shoot stuff inside us.
			return
		if(!ismob(target) || user.a_intent == INTENT_HARM) //melee attack
			return
		if(target == user && user.zone_selected != "mouth") //so we can't shoot ourselves (unless mouth selected)
			return
	if(!passthrough && (aiming_time > aiming_time_fire_threshold))
		return
	if(lastfire > world.time + delay)
		return
	lastfire = world.time
	stop_aiming()
	return ..()

/obj/item/weapon/gun/energy/beam_rifle/proc/sync_ammo()
	for(var/obj/item/ammo_casing/energy/beam_rifle/AC in contents)
		AC.sync_stats()

/obj/item/weapon/gun/energy/beam_rifle/proc/delay_penalty(amount)
	aiming_time_left = Clamp(aiming_time_left + amount, 0, aiming_time)

/obj/item/ammo_casing/energy/beam_rifle
	name = "particle acceleration lens"
	desc = "Don't look into barrel!"
	var/wall_pierce_amount = 0
	var/wall_devastate = 0
	var/aoe_structure_range = 1
	var/aoe_structure_damage = 30
	var/aoe_fire_range = 2
	var/aoe_fire_chance = 66
	var/aoe_mob_range = 1
	var/aoe_mob_damage = 20
	var/impact_structure_damage = 50
	var/projectile_damage = 40
	var/projectile_stun = 0
	var/structure_piercing = 2
	var/structure_bleed_coeff = 0.7
	var/do_pierce = TRUE
	var/obj/item/weapon/gun/energy/beam_rifle/host

/obj/item/ammo_casing/energy/beam_rifle/proc/sync_stats()
	var/obj/item/weapon/gun/energy/beam_rifle/BR = loc
	if(!istype(BR))
		stack_trace("Beam rifle syncing error")
	host = BR
	do_pierce = BR.projectile_setting_pierce
	wall_pierce_amount = BR.wall_pierce_amount
	wall_devastate = BR.wall_devastate
	aoe_structure_range = BR.aoe_structure_range
	aoe_structure_damage = BR.aoe_structure_damage
	aoe_fire_range = BR.aoe_fire_range
	aoe_fire_chance = BR.aoe_fire_chance
	aoe_mob_range = BR.aoe_mob_range
	aoe_mob_damage = BR.aoe_mob_damage
	impact_structure_damage = BR.impact_structure_damage
	projectile_damage = BR.projectile_damage
	projectile_stun = BR.projectile_stun
	delay = BR.delay
	structure_piercing = BR.structure_piercing
	structure_bleed_coeff = BR.structure_bleed_coeff

/obj/item/ammo_casing/energy/beam_rifle/ready_proj(atom/target, mob/living/user, quiet, zone_override)
	. = ..(target, user, quiet, zone_override)
	var/obj/item/projectile/beam/beam_rifle/hitscan/HS_BB = BB
	if(!istype(HS_BB))
		return
	HS_BB.impact_direct_damage = projectile_damage
	HS_BB.stun = projectile_stun
	HS_BB.impact_structure_damage = impact_structure_damage
	HS_BB.aoe_mob_damage = aoe_mob_damage
	HS_BB.aoe_mob_range = Clamp(aoe_mob_range, 0, 15)				//Badmin safety lock
	HS_BB.aoe_fire_chance = aoe_fire_chance
	HS_BB.aoe_fire_range = aoe_fire_range
	HS_BB.aoe_structure_damage = aoe_structure_damage
	HS_BB.aoe_structure_range = Clamp(aoe_structure_range, 0, 15)	//Badmin safety lock
	HS_BB.wall_devastate = wall_devastate
	HS_BB.wall_pierce_amount = wall_pierce_amount
	HS_BB.structure_pierce_amount = structure_piercing
	HS_BB.structure_bleed_coeff = structure_bleed_coeff
	HS_BB.do_pierce = do_pierce
	HS_BB.gun = host

/obj/item/ammo_casing/energy/beam_rifle/throw_proj(atom/target, turf/targloc, mob/living/user, params, spread)
	var/turf/curloc = get_turf(user)
	if(!istype(curloc) || !BB)
		return FALSE
	var/obj/item/weapon/gun/energy/beam_rifle/gun = loc
	if(!targloc && gun)
		targloc = get_turf_in_angle(gun.lastangle, curloc, 10)
	else if(!targloc)
		return FALSE
	var/firing_dir
	if(BB.firer)
		firing_dir = BB.firer.dir
	if(!BB.suppressed && firing_effect_type)
		new firing_effect_type(get_turf(src), firing_dir)
	BB.preparePixelProjectile(target, targloc, user, params, spread)
	BB.fire(gun? gun.lastangle : null, null)
	BB = null
	return TRUE

/obj/item/ammo_casing/energy/beam_rifle/hitscan
	projectile_type = /obj/item/projectile/beam/beam_rifle/hitscan
	select_name = "beam"
	e_cost = 5000
	fire_sound = 'sound/weapons/beam_sniper.ogg'

/obj/item/projectile/beam/beam_rifle
	name = "particle beam"
	icon = ""
	hitsound = 'sound/effects/explosion3.ogg'
	damage = 0				//Handled manually.
	damage_type = BURN
	flag = "energy"
	range = 150
	jitter = 10
	var/obj/item/weapon/gun/energy/beam_rifle/gun
	var/structure_pierce_amount = 0				//All set to 0 so the gun can manually set them during firing.
	var/structure_bleed_coeff = 0
	var/structure_pierce = 0
	var/do_pierce = TRUE
	var/wall_pierce_amount = 0
	var/wall_pierce = 0
	var/wall_devastate = 0
	var/aoe_structure_range = 0
	var/aoe_structure_damage = 0
	var/aoe_fire_range = 0
	var/aoe_fire_chance = 0
	var/aoe_mob_range = 0
	var/aoe_mob_damage = 0
	var/impact_structure_damage = 0
	var/impact_direct_damage = 0
	var/turf/cached
	var/list/pierced = list()

/obj/item/projectile/beam/beam_rifle/proc/AOE(turf/epicenter)
	set waitfor = FALSE
	if(!epicenter)
		return
	new /obj/effect/temp_visual/explosion/fast(epicenter)
	for(var/mob/living/L in range(aoe_mob_range, epicenter))		//handle aoe mob damage
		L.adjustFireLoss(aoe_mob_damage)
		to_chat(L, "<span class='userdanger'>\The [src] sears you!</span>")
	for(var/turf/T in range(aoe_fire_range, epicenter))		//handle aoe fire
		if(prob(aoe_fire_chance))
			new /obj/effect/hotspot(T)
	for(var/obj/O in range(aoe_structure_range, epicenter))
		if(!isitem(O))
			if(O.level == 1)	//Please don't break underfloor items!
				continue
			O.take_damage(aoe_structure_damage * get_damage_coeff(O), BURN, "laser", FALSE)

/obj/item/projectile/beam/beam_rifle/proc/check_pierce(atom/target)
	if(!do_pierce)
		return FALSE
	if(pierced[target])		//we already pierced them go away
		loc = get_turf(target)
		return TRUE
	if(isclosedturf(target))
		if(wall_pierce++ < wall_pierce_amount)
			loc = target
			if(prob(wall_devastate))
				if(istype(target, /turf/closed/wall))
					var/turf/closed/wall/W = target
					W.dismantle_wall(TRUE, TRUE)
				else
					target.ex_act(EXPLODE_HEAVY)
			return TRUE
	if(ismovableatom(target))
		var/atom/movable/AM = target
		if(AM.density && !AM.CanPass(src, get_turf(target)) && !ismob(AM))
			if(structure_pierce < structure_pierce_amount)
				if(isobj(AM))
					var/obj/O = AM
					O.take_damage((impact_structure_damage + aoe_structure_damage) * structure_bleed_coeff * get_damage_coeff(AM), BURN, "energy", FALSE)
				pierced[AM] = TRUE
				loc = get_turf(AM)
				structure_pierce++
				return TRUE
	return FALSE

/obj/item/projectile/beam/beam_rifle/proc/get_damage_coeff(atom/target)
	if(istype(target, /obj/machinery/door))
		return 0.4
	if(istype(target, /obj/structure/window))
		return 0.5
	return 1

/obj/item/projectile/beam/beam_rifle/proc/handle_impact(atom/target)
	if(isobj(target))
		var/obj/O = target
		O.take_damage(impact_structure_damage * get_damage_coeff(target), BURN, "laser", FALSE)
	if(isliving(target))
		var/mob/living/L = target
		L.adjustFireLoss(impact_direct_damage)
		L.emote("scream")

/obj/item/projectile/beam/beam_rifle/proc/handle_hit(atom/target)
	set waitfor = FALSE
	if(!cached && !QDELETED(target))
		cached = get_turf(target)
	if(nodamage)
		return FALSE
	playsound(cached, 'sound/effects/explosion3.ogg', 100, 1)
	AOE(cached)
	if(!QDELETED(target))
		handle_impact(target)

/obj/item/projectile/beam/beam_rifle/Collide(atom/target)
	paused = TRUE
	if(check_pierce(target))
		permutated += target
		return FALSE
	if(!QDELETED(target))
		cached = get_turf(target)
	paused = FALSE
	. = ..()

/obj/item/projectile/beam/beam_rifle/on_hit(atom/target, blocked = FALSE)
	paused = TRUE
	if(!QDELETED(target))
		cached = get_turf(target)
	handle_hit(target)
	paused = FALSE
	. = ..()

/obj/item/projectile/beam/beam_rifle/hitscan
	icon_state = ""
	var/tracer_type = /obj/effect/projectile_beam/tracer
	var/starting_z
	var/starting_p_x
	var/starting_p_y
	var/constant_tracer = FALSE
	var/travelled_p_x = 0
	var/travelled_p_y = 0
	var/tracer_spawned = FALSE

/obj/item/projectile/beam/beam_rifle/hitscan/Destroy()
	paused = TRUE	//STOP HITTING WHEN YOU'RE ALREADY BEING DELETED!
	spawn_tracer(constant_tracer)
	return ..()

/obj/item/projectile/beam/beam_rifle/hitscan/proc/spawn_tracer(put_in_rifle = FALSE)
	if(tracer_spawned)
		return
	tracer_spawned = TRUE
	//Remind me to port baystation trajectories so this shit isn't needed...
	var/pixels_travelled = round(sqrt(travelled_p_x**2 + travelled_p_y**2),1)
	var/scaling = pixels_travelled/world.icon_size
	var/midpoint_p_x = round(starting_p_x + (travelled_p_x / 2))
	var/midpoint_p_y = round(starting_p_y + (travelled_p_y / 2))
	var/tracer_px = midpoint_p_x % world.icon_size
	var/tracer_py = midpoint_p_y % world.icon_size
	var/tracer_lx = (midpoint_p_x - tracer_px) / world.icon_size
	var/tracer_ly = (midpoint_p_y - tracer_py) / world.icon_size
	var/obj/effect/projectile_beam/PB = new tracer_type(src)
	PB.apply_vars(Angle, tracer_px, tracer_py, color, scaling, locate(tracer_lx,tracer_ly,starting_z))
	if(put_in_rifle && istype(gun))
		if(gun.current_tracer)
			QDEL_NULL(gun.current_tracer)
		gun.current_tracer = PB
	else
		QDEL_IN(PB, 5)

/obj/item/projectile/beam/beam_rifle/hitscan/proc/check_for_turf_edge(turf/T)
	if(!istype(T))
		return TRUE
	var/tx = T.x
	var/ty = T.y
	if(tx < 10 || tx > (world.maxx - 10) || ty < 10 || ty > (world.maxy-10))
		return TRUE
	return FALSE

/obj/item/projectile/beam/beam_rifle/hitscan/fire(setAngle, atom/direct_target)	//oranges didn't let me make this a var the first time around so copypasta time
	set waitfor = 0
	if(!log_override && firer && original)
		add_logs(firer, original, "fired at", src, " [get_area(src)]")
	if(setAngle)
		Angle = setAngle
	var/next_run = world.time
	var/old_pixel_x = pixel_x
	var/old_pixel_y = pixel_y
	var/safety = 0	//The code works fine, but... just in case...
	var/turf/c2
	var/starting_x = loc.x
	var/starting_y = loc.y
	starting_z = loc.z
	starting_p_x = starting_x * world.icon_size + pixel_x
	starting_p_y = starting_y * world.icon_size + pixel_y
	while(loc)
		if(++safety > (range * 3))	//If it's looping for way, way too long...
			return	//Kill!
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
		travelled_p_x += Pixel_x
		travelled_p_y += Pixel_y
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
					Collide(original)
    c2 = loc
		Range()
		if(check_for_turf_edge(loc))
			spawn_tracer(constant_tracer)
	if(istype(c2))
		cached = c2

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam
	tracer_type = /obj/effect/projectile_beam/tracer/aiming
	name = "aiming beam"
	hitsound = null
	hitsound_wall = null
	nodamage = TRUE
	damage = 0
	constant_tracer = TRUE

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/prehit(atom/target)
	qdel(src)
	return FALSE

/obj/item/projectile/beam/beam_rifle/hitscan/aiming_beam/on_hit()
	qdel(src)
	return FALSE

/obj/effect/projectile_beam
	icon = 'icons/obj/projectiles.dmi'
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	light_power = 1
	light_range = 2
	light_color = "#00ffff"
	mouse_opacity = 0
	flags = ABSTRACT
	appearance_flags = 0

/obj/effect/projectile_beam/proc/scale_to(nx,ny,override=TRUE)
	var/matrix/M
	if(!override)
		M = transform
	else
		M = new
	M.Scale(nx,ny)
	transform = M

/obj/effect/projectile_beam/proc/turn_to(angle,override=TRUE)
	var/matrix/M
	if(!override)
		M = transform
	else
		M = new
	M.Turn(angle)
	transform = M

/obj/effect/projectile_beam/New(angle_override, p_x, p_y, color_override, scaling = 1)
	if(angle_override && p_x && p_y && color_override && scaling)
		apply_vars(angle_override, p_x, p_y, color_override, scaling)
	return ..()

/obj/effect/projectile_beam/proc/apply_vars(angle_override, p_x, p_y, color_override, scaling = 1, new_loc, increment = 0)
	var/mutable_appearance/look = new(src)
	look.pixel_x = p_x
	look.pixel_y = p_y
	if(color_override)
		look.color = color_override
	appearance = look
	scale_to(1,scaling, FALSE)
	turn_to(angle_override, FALSE)
	if(!isnull(new_loc))	//If you want to null it just delete it...
		forceMove(new_loc)
	for(var/i in 1 to increment)
		pixel_x += round((sin(angle_override)+16*sin(angle_override)*2), 1)
		pixel_y += round((cos(angle_override)+16*cos(angle_override)*2), 1)

/obj/effect/projectile_beam/tracer
	icon_state = "tracer_beam"

/obj/effect/projectile_beam/tracer/aiming
	icon_state = "gbeam"

/datum/action/item_action/zoom_speed_action
	name = "Toggle Zooming Speed"
	button_icon_state = "projectile"
	background_icon_state = "bg_tech"

/datum/action/item_action/zoom_lock_action
	name = "Switch Zoom Mode"
	button_icon_state = "zoom_mode"
	background_icon_state = "bg_tech"
