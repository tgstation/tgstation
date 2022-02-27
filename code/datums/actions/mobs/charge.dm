/datum/action/cooldown/mob_cooldown/charge
	name = "Charge"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to charge at a chosen position."
	cooldown_time = 1.5 SECONDS
	/// Delay before the charge actually occurs
	var/charge_delay = 0.3 SECONDS
	/// The amount of turfs we move past the target
	var/charge_past = 2
	/// The maximum distance we can charge
	var/charge_distance = 50
	/// The sleep time before moving in deciseconds while charging
	var/charge_speed = 0.5
	/// The damage the charger does when bumping into something
	var/charge_damage = 30
	/// If we destroy objects while charging
	var/destroy_objects = TRUE
	/// If the current move is being triggered by us or not
	var/actively_moving = FALSE
	/// List of charging mobs
	var/list/charging = list()

/datum/action/cooldown/mob_cooldown/charge/New(Target, delay, past, distance, speed, damage, destroy)
	. = ..()
	if(delay)
		charge_delay = delay
	if(past)
		charge_past = past
	if(distance)
		charge_distance = distance
	if(speed)
		charge_speed = speed
	if(damage)
		charge_damage = damage
	if(destroy)
		destroy_objects = destroy

/datum/action/cooldown/mob_cooldown/charge/Activate(atom/target_atom)
	// start pre-cooldown so that the ability can't come up while the charge is happening
	StartCooldown(10 SECONDS)
	charge_sequence(owner, target_atom, charge_delay, charge_past)
	StartCooldown()

/datum/action/cooldown/mob_cooldown/charge/proc/charge_sequence(atom/movable/charger, atom/target_atom, delay, past)
	do_charge(owner, target_atom, charge_delay, charge_past)

/datum/action/cooldown/mob_cooldown/charge/proc/do_charge(atom/movable/charger, atom/target_atom, delay, past)
	if(!target_atom || target_atom == owner)
		return
	var/chargeturf = get_turf(target_atom)
	if(!chargeturf)
		return
	var/dir = get_dir(charger, target_atom)
	var/turf/target = get_ranged_target_turf(chargeturf, dir, past)
	if(!target)
		return

	if(charger in charging)
		// Stop any existing charging, this'll clean things up properly
		SSmove_manager.stop_looping(charger)

	charging += charger
	SEND_SIGNAL(owner, COMSIG_STARTED_CHARGE)
	RegisterSignal(charger, COMSIG_MOVABLE_BUMP, .proc/on_bump)
	RegisterSignal(charger, COMSIG_MOVABLE_PRE_MOVE, .proc/on_move)
	RegisterSignal(charger, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	DestroySurroundings(charger)
	charger.setDir(dir)
	do_charge_indicator(charger, target)

	SLEEP_CHECK_DEATH(delay, charger)

	var/time_to_hit = min(get_dist(charger, target), charge_distance) * charge_speed

	var/datum/move_loop/new_loop = SSmove_manager.home_onto(charger, target, delay = charge_speed, timeout = time_to_hit, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	if(!new_loop)
		return
	RegisterSignal(new_loop, COMSIG_MOVELOOP_PREPROCESS_CHECK, .proc/pre_move)
	RegisterSignal(new_loop, COMSIG_MOVELOOP_POSTPROCESS, .proc/post_move)
	RegisterSignal(new_loop, COMSIG_PARENT_QDELETING, .proc/charge_end)
	if(ismob(charger))
		RegisterSignal(charger, COMSIG_MOB_STATCHANGE, .proc/stat_changed)

	// Yes this is disgusting. But we need to queue this stuff, and this code just isn't setup to support that right now. So gotta do it with sleeps
	sleep(time_to_hit + charge_speed)

	return TRUE

/datum/action/cooldown/mob_cooldown/charge/proc/pre_move(datum)
	SIGNAL_HANDLER
	// If you sleep in Move() you deserve what's coming to you
	actively_moving = TRUE

/datum/action/cooldown/mob_cooldown/charge/proc/post_move(datum)
	SIGNAL_HANDLER
	actively_moving = FALSE

/datum/action/cooldown/mob_cooldown/charge/proc/charge_end(datum/move_loop/source)
	SIGNAL_HANDLER
	var/atom/movable/charger = source.moving
	UnregisterSignal(charger, list(COMSIG_MOVABLE_BUMP, COMSIG_MOVABLE_PRE_MOVE, COMSIG_MOVABLE_MOVED, COMSIG_MOB_STATCHANGE))
	SEND_SIGNAL(owner, COMSIG_FINISHED_CHARGE)
	charging -= charger

/datum/action/cooldown/mob_cooldown/charge/proc/stat_changed(mob/source, new_stat, old_stat)
	SIGNAL_HANDLER
	if(new_stat == DEAD)
		SSmove_manager.stop_looping(source) //This will cause the loop to qdel, triggering an end to our charging

/datum/action/cooldown/mob_cooldown/charge/proc/do_charge_indicator(atom/charger, atom/charge_target)
	var/turf/target_turf = get_turf(charge_target)
	if(!target_turf)
		return
	new /obj/effect/temp_visual/dragon_swoop/bubblegum(target_turf)
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(charger.loc, charger)
	animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 3)

/datum/action/cooldown/mob_cooldown/charge/proc/on_move(atom/source, atom/new_loc)
	SIGNAL_HANDLER
	if(!actively_moving)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	new /obj/effect/temp_visual/decoy/fading(source.loc, source)
	INVOKE_ASYNC(src, .proc/DestroySurroundings, source)

/datum/action/cooldown/mob_cooldown/charge/proc/on_moved(atom/source)
	SIGNAL_HANDLER
	playsound(source, 'sound/effects/meteorimpact.ogg', 200, TRUE, 2, TRUE)
	INVOKE_ASYNC(src, .proc/DestroySurroundings, source)

/datum/action/cooldown/mob_cooldown/charge/proc/DestroySurroundings(atom/movable/charger)
	if(!destroy_objects)
		return
	if(!isanimal(charger))
		return
	for(var/dir in GLOB.cardinals)
		var/turf/next_turf = get_step(charger, dir)
		if(!next_turf)
			continue
		if(next_turf.Adjacent(charger) && (iswallturf(next_turf) || ismineralturf(next_turf)))
			if(!isanimal(charger))
				SSexplosions.medturf += next_turf
				continue
			next_turf.attack_animal(charger)
			continue
		for(var/obj/object in next_turf.contents)
			if(!object.Adjacent(charger))
				continue
			if(!ismachinery(object) && !isstructure(object))
				continue
			if(!object.density || object.IsObscured())
				continue
			if(!isanimal(charger))
				SSexplosions.med_mov_atom += target
				break
			object.attack_animal(charger)
			break

/datum/action/cooldown/mob_cooldown/charge/proc/on_bump(atom/movable/source, atom/target)
	SIGNAL_HANDLER
	if(owner == target)
		return
	if(isturf(target))
		SSexplosions.medturf += target
	if(isobj(target) && target.density)
		SSexplosions.med_mov_atom += target

	INVOKE_ASYNC(src, .proc/DestroySurroundings, source)
	hit_target(source, target, charge_damage)

/datum/action/cooldown/mob_cooldown/charge/proc/hit_target(atom/movable/source, atom/target, damage_dealt)
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	living_target.visible_message("<span class='danger'>[source] slams into [living_target]!</span>", "<span class='userdanger'>[source] tramples you into the ground!</span>")
	source.forceMove(get_turf(living_target))
	living_target.apply_damage(damage_dealt, BRUTE, wound_bonus = CANT_WOUND)
	playsound(get_turf(living_target), 'sound/effects/meteorimpact.ogg', 100, TRUE)
	shake_camera(living_target, 4, 3)
	shake_camera(source, 2, 3)

/datum/action/cooldown/mob_cooldown/charge/basic_charge
	name = "Basic Charge"
	cooldown_time = 6 SECONDS
	charge_delay = 1.5 SECONDS
	charge_distance = 4
	var/shake_duration = 1 SECONDS
	var/shake_pixel_shift = 15

/datum/action/cooldown/mob_cooldown/charge/basic_charge/do_charge_indicator(atom/charger, atom/charge_target)
	charger.Shake(shake_pixel_shift, shake_pixel_shift, shake_duration)

/datum/action/cooldown/mob_cooldown/charge/basic_charge/hit_target(atom/movable/source, atom/target, damage_dealt)
	var/mob/living/living_source
	if(isliving(source))
		living_source = source

	if(!isliving(target))
		if(!target.density || target.CanPass(source, get_dir(target, source)))
			return
		source.visible_message(span_danger("[source] smashes into [target]!"))
		if(!living_source)
			return
		living_source.Stun(6, ignore_canstun = TRUE)
		return

	var/mob/living/living_target = target
	if(ishuman(living_target))
		var/mob/living/carbon/human/human_target = living_target
		if(human_target.check_shields(source, 0, "the [source.name]", attack_type = LEAP_ATTACK) && living_source)
			living_source.Stun(6, ignore_canstun = TRUE)
			return

	living_target.visible_message(span_danger("[source] charges on [living_target]!"), span_userdanger("[source] charges into you!"))
	living_target.Knockdown(6)

/datum/action/cooldown/mob_cooldown/charge/triple_charge
	name = "Triple Charge"
	desc = "Allows you to charge three times at a chosen position."
	charge_delay = 0.6 SECONDS

/datum/action/cooldown/mob_cooldown/charge/triple_charge/charge_sequence(atom/movable/charger, atom/target_atom, delay, past)
	for(var/i in 0 to 2)
		do_charge(owner, target_atom, charge_delay - 2 * i, charge_past)

/datum/action/cooldown/mob_cooldown/charge/hallucination_charge
	name = "Hallucination Charge"
	icon_icon = 'icons/effects/bubblegum.dmi'
	button_icon_state = "smack ya one"
	desc = "Allows you to create hallucinations that charge around your target."
	cooldown_time = 2 SECONDS
	charge_delay = 0.6 SECONDS
	/// The damage the hallucinations in our charge do
	var/hallucination_damage = 15
	/// Check to see if we are enraged, enraged ability does more
	var/enraged = FALSE
	/// Check to see if we should spawn blood
	var/spawn_blood = FALSE

/datum/action/cooldown/mob_cooldown/charge/hallucination_charge/charge_sequence(atom/movable/charger, atom/target_atom, delay, past)
	if(!enraged)
		hallucination_charge(target_atom, 6, 8, 0, 6, TRUE)
		StartCooldown(cooldown_time * 0.5)
		return
	for(var/i in 0 to 2)
		hallucination_charge(target_atom, 4, 9 - 2 * i, 0, 4, TRUE)
	for(var/i in 0 to 2)
		do_charge(owner, target_atom, charge_delay - 2 * i, charge_past)

/datum/action/cooldown/mob_cooldown/charge/hallucination_charge/do_charge(atom/movable/charger, atom/target_atom, delay, past)
	. = ..()
	if(charger != owner)
		qdel(charger)

/datum/action/cooldown/mob_cooldown/charge/hallucination_charge/proc/hallucination_charge(atom/target_atom, clone_amount, delay, past, radius, use_self)
	var/starting_angle = rand(1, 360)
	if(!radius)
		return
	var/angle_difference = 360 / clone_amount
	var/self_placed = FALSE
	for(var/i = 1 to clone_amount)
		var/angle = (starting_angle + angle_difference * i)
		var/turf/place = locate(target_atom.x + cos(angle) * radius, target_atom.y + sin(angle) * radius, target_atom.z)
		if(!place)
			continue
		if(use_self && !self_placed)
			owner.forceMove(place)
			self_placed = TRUE
			continue
		var/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/our_clone = new /mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination(place)
		our_clone.appearance = owner.appearance
		our_clone.name = "[owner]'s hallucination"
		our_clone.alpha = 127.5
		our_clone.move_through_mob = owner
		our_clone.spawn_blood = spawn_blood
		do_charge(our_clone, target_atom, delay, past)
	if(use_self)
		do_charge(owner, target_atom, delay, past)

/datum/action/cooldown/mob_cooldown/charge/hallucination_charge/hit_target(atom/movable/source, atom/A, damage_dealt)
	var/applied_damage = charge_damage
	if(source != owner)
		applied_damage = hallucination_damage
	. = ..(source, A, applied_damage)

/datum/action/cooldown/mob_cooldown/charge/hallucination_charge/hallucination_surround
	name = "Surround Target"
	icon_icon = 'icons/turf/walls/wall.dmi'
	button_icon_state = "wall-0"
	desc = "Allows you to create hallucinations that charge around your target."
	charge_delay = 0.6 SECONDS
	charge_past = 2

/datum/action/cooldown/mob_cooldown/charge/hallucination_charge/hallucination_surround/charge_sequence(atom/movable/charger, atom/target_atom, delay, past)
	for(var/i in 0 to 4)
		hallucination_charge(target_atom, 2, 8, 2, 2, FALSE)
		do_charge(owner, target_atom, charge_delay, charge_past)
