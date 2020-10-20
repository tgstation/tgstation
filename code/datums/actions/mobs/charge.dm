/datum/action/cooldown/charge
	name = "Charge"
	icon_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	desc = "Allows you to charge at a chosen position."
	cooldown_time = 20
	text_cooldown = FALSE
	click_to_activate = TRUE
	shared_cooldown = MOB_SHARED_COOLDOWN
	var/charge_delay = 3
	var/charge_past = 2
	var/charge_speed = 0.7
	var/charge_damage = 30
	var/destroy_objects = TRUE
	var/list/revving_charge = list()
	var/list/charging = list()

/datum/action/cooldown/charge/New(Target, delay, past, speed, damage, destroy)
	. = ..()
	if(delay)
		charge_delay = delay
	if(past)
		charge_past = past
	if(speed)
		charge_speed = speed
	if(damage)
		charge_damage = damage
	if(destroy)
		destroy_objects = destroy

/datum/action/cooldown/charge/Activate(atom/target_atom)
	do_charge(owner, target_atom, charge_delay, charge_past, TRUE)

/datum/action/cooldown/charge/proc/do_charge(atom/movable/charger, atom/target_atom, delay, past, apply_cooldown)
	if(!target_atom || target_atom == owner)
		return
	var/chargeturf = get_turf(target_atom)
	if(!chargeturf)
		return
	var/distance = get_dist(charger, chargeturf) + past
	var/turf/T = get_ranged_target_turf(chargeturf, owner.dir, past)
	if(!T)
		return
	if(apply_cooldown)
		StartCooldown()
	new /obj/effect/temp_visual/dragon_swoop/bubblegum(T)
	revving_charge[charger] = TRUE
	charging[charger] = TRUE
	RegisterSignal(charger, COMSIG_MOVABLE_BUMP, .proc/on_bump)
	RegisterSignal(charger, COMSIG_MOVABLE_PRE_MOVE, .proc/on_move)
	RegisterSignal(charger, COMSIG_MOVABLE_MOVED, .proc/on_moved)
	DestroySurroundings(charger)
	walk(charger, 0)
	charger.setDir(get_dir(charger, target_atom))
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(charger.loc, charger)
	animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 3)
	SLEEP_CHECK_DEATH(delay, charger)
	revving_charge[charger] = FALSE
	walk_towards(charger, T, charge_speed)
	SLEEP_CHECK_DEATH(distance * charge_speed, charger)
	walk(charger, 0) // cancel the movement
	charging[charger] = FALSE
	UnregisterSignal(charger, COMSIG_MOVABLE_BUMP)
	UnregisterSignal(charger, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(charger, COMSIG_MOVABLE_MOVED)

/datum/action/cooldown/charge/proc/DestroySurroundings(atom/movable/charger)
	if(!destroy_objects)
		return
	for(var/dir in GLOB.cardinals)
		var/turf/T = get_step(charger, dir)
		if(QDELETED(T))
			return
		if(T.Adjacent(charger))
			if(iswallturf(T) || ismineralturf(T))
				T.attack_animal(charger)
				return
		for(var/obj/O in T.contents)
			if(!O.Adjacent(charger))
				continue
			if((ismachinery(O) || isstructure(O)) && O.density && !O.IsObscured())
				O.attack_animal(charger)
				return

/datum/action/cooldown/charge/proc/on_bump(atom/movable/source, atom/A)
	if(charging[source])
		if(isturf(A) || isobj(A) && A.density)
			if(isobj(A))
				SSexplosions.med_mov_atom += A
			else
				SSexplosions.medturf += A
		DestroySurroundings()
		hit_target(source, A, charge_damage)

/datum/action/cooldown/charge/proc/hit_target(atom/movable/source, atom/A, damage_dealt)
	if(!isliving(A))
		return
	var/mob/living/L = A
	L.visible_message("<span class='danger'>[source] slams into [L]!</span>", "<span class='userdanger'>[source] tramples you into the ground!</span>")
	source.forceMove(get_turf(L))
	L.apply_damage(damage_dealt, BRUTE, wound_bonus = CANT_WOUND)
	playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, TRUE)
	shake_camera(L, 4, 3)
	shake_camera(source, 2, 3)

/datum/action/cooldown/charge/proc/on_move(atom/source)
	if(charging[source])
		new /obj/effect/temp_visual/decoy/fading(source.loc, source)
		DestroySurroundings(source)
	if(revving_charge[source])
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/datum/action/cooldown/charge/proc/on_moved(atom/source)
	if(charging[source])
		DestroySurroundings(source)

/datum/action/cooldown/charge/triple_charge
	name = "Triple Charge"
	desc = "Allows you to charge three times at a chosen position."
	charge_delay = 6

/datum/action/cooldown/charge/triple_charge/Activate(var/atom/target_atom)
	for(var/i in 0 to 2)
		do_charge(owner, target_atom, charge_delay - 2 * i, charge_past, TRUE)

/datum/action/cooldown/charge/hallucination_charge
	name = "Hallucination Charge"
	icon_icon = 'icons/effects/bubblegum.dmi'
	button_icon_state = "smack ya one"
	desc = "Allows you to create hallucinations that charge around your target."
	charge_past = 0
	var/hallucination_damage = 15
	var/enraged = FALSE

/datum/action/cooldown/charge/hallucination_charge/Activate(var/atom/target_atom)
	if(!enraged)
		hallucination_charge(target_atom, 6, 8, charge_past, 6, TRUE, TRUE)
		return
	for(var/i in 0 to 2)
		hallucination_charge(target_atom, 4, 9 - i, charge_past, 4, TRUE, TRUE)
	for(var/i in 0 to 2)
		do_charge(owner, target_atom, charge_delay - 2 * i, charge_past, TRUE)

/datum/action/cooldown/charge/hallucination_charge/do_charge(atom/movable/charger, atom/target_atom, delay, past, apply_cooldown)
	. = ..()
	if(charger != owner)
		qdel(charger)

/datum/action/cooldown/charge/hallucination_charge/proc/hallucination_charge(atom/target_atom, clone_amount, delay, past, radius, apply_cooldown, use_self)
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
		var/mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination/B = new /mob/living/simple_animal/hostile/megafauna/bubblegum/hallucination(place)
		INVOKE_ASYNC(src, .proc/do_charge, B, target_atom, delay, past, apply_cooldown)
	if(use_self)
		do_charge(owner, target_atom, delay, past, apply_cooldown)

/datum/action/cooldown/charge/hallucination_charge/hit_target(atom/movable/source, atom/A, damage_dealt)
	var/applied_damage = charge_damage
	if(source != owner)
		applied_damage = hallucination_damage
	. = ..(source, A, applied_damage)

/datum/action/cooldown/charge/hallucination_charge/hallucination_surround
	name = "Surround Target"
	icon_icon = 'icons/turf/walls/wall.dmi'
	button_icon_state = "wall-0"
	desc = "Allows you to create hallucinations that charge around your target."
	charge_delay = 6
	charge_past = 2

/datum/action/cooldown/charge/hallucination_charge/hallucination_surround/Activate(var/atom/target_atom)
	for(var/i in 1 to 5)
		hallucination_charge(target_atom, 2, 8, 2, 2, TRUE, FALSE)
		do_charge(owner, target_atom, charge_delay, charge_past, TRUE)

/datum/action/cooldown/blood_warp
	name = "Blood Warp"
	icon_icon = 'icons/effects/blood.dmi'
	button_icon_state = "floor1"
	desc = "Allows you to teleport to blood at a clicked position."
	cooldown_time = 20
	text_cooldown = FALSE
	click_to_activate = TRUE
	shared_cooldown = MOB_SHARED_COOLDOWN

/datum/action/cooldown/blood_warp/Activate(var/atom/target_atom)
	return

/datum/action/cooldown/blood_warp/proc/get_mobs_on_blood(var/mob/target)
	var/list/targets = list(target)
	. = list()
	for(var/mob/living/L in targets)
		var/list/bloodpool = get_pools(get_turf(L), 0)
		if(bloodpool.len && (!owner.faction_check_mob(L) || L.stat == DEAD))
			. += L

/datum/action/cooldown/blood_warp/proc/get_pools(turf/T, range)
	. = list()
	for(var/obj/effect/decal/cleanable/nearby in view(T, range))
		if(nearby.can_bloodcrawl_in())
			. += nearby
