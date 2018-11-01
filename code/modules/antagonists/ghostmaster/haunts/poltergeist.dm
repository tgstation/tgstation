/datum/ghostmaster_power/poltergeist
	name = "Poltergeist"
	spook_cost = 1
	death_cost = 1

/datum/ghostmaster_power/poltergeist/valid_target(atom/A)
	return isopenturf(A)

/datum/ghostmaster_power/poltergeist/effect(turf/T, mob/camera/ghostmaster/G)
	var/mob/living/simple_animal/hostile/haunt/poltergeist/P = new(T)
	P.exorcism = G.exorcism
	offer_control(P)
	return TRUE

/mob/living/simple_animal/hostile/haunt/poltergeist
	name = "poltergeist"
	layer = BELOW_OBJ_LAYER //Good luck, i'm behind 9000 paper sheets
	alpha = 128
	desc = "Boo."
	retreat_distance = 3
	minimum_distance = 3

	melee_damage_lower = 5
	melee_damage_upper = 5
	del_on_death = TRUE

	pass_flags = LETPASSTHROW //Keeps cheese away.

	ranged_cooldown = 10
	var/min_alpha = 60
	var/max_alpha = 200
	var/next_collect = 0
	var/collect_cooldown = 200
	var/max_collect_count = 10
	var/max_junk = 20
	var/list/obj/item/junk = list()
	var/datum/action/innate/poltergeist_collect/collect_action

/mob/living/simple_animal/hostile/haunt/poltergeist/Initialize()
	. = ..()
	RegisterSignal(src,COMSIG_ORBITER_STOPPED,.proc/check_junk)
	collect_action = new
	collect_action.Grant(src)

	alpha = min_alpha
	animate(src, alpha = max_alpha, time = 50, easing = SINE_EASING, loop = -1)
	animate(alpha = min_alpha, time = 50, easing = SINE_EASING, loop = -1)

/mob/living/simple_animal/hostile/haunt/poltergeist/proc/check_junk(datum/source,atom/movable/AM)
	if(AM in junk)
		UnregisterSignal(AM,COMSIG_PARENT_ATTACKBY)
		UnregisterSignal(AM,COMSIG_ATOM_BULLET_ACT)
		junk.Remove(AM)
		update_ranged()

//Debug
/mob/living/simple_animal/hostile/haunt/poltergeist/proc/setup_corpse()
	var/obj/effect/decal/remains/human/haunted/H = new(get_turf(src))
	exorcism = new
	exorcism.generate()
	exorcism.RegisterCorpse(H)
	exorcism.bound_spook = src

/mob/living/simple_animal/hostile/haunt/poltergeist/proc/knockoff_junk(datum/source, obj/item/I, mob/living/user, params)
	throw_away_from(source,user)

/mob/living/simple_animal/hostile/haunt/poltergeist/proc/throw_away_from(obj/item/I,thing)
	I.orbiting.end_orbit(I)
	var/atom/throw_target = get_edge_target_turf(I, get_dir(I, get_step_away(I, thing)))
	I.throw_at(throw_target,5,2)

/mob/living/simple_animal/hostile/haunt/poltergeist/proc/bullethit(datum/source, obj/item/projectile/P, def_zone)
	throw_away_from(source,P.starting)

/mob/living/simple_animal/hostile/haunt/poltergeist/bullet_act(obj/item/projectile/P)
	if(junk.len && P.original != src)
		var/obj/item/J = pick(junk)
		throw_away_from(J,P.starting)
		return TRUE
	else
		return ..()

/mob/living/simple_animal/hostile/haunt/poltergeist/proc/collect_junk(rip_floors = TRUE)
	if(next_collect > world.time || IsParalyzed())
		return
	next_collect = world.time + collect_cooldown
	clean_junk()
	var/list/found = list()
	for(var/obj/item/I in view(4,src))
		if(!I.anchored && !I.orbiting)
			found |= I
	if(!found.len && rip_floors)
		visible_message("<span class='warning'>[src] rips the floor tiles out!</span>")
		var/turf/open/floor/F = get_turf(src)
		if(istype(F) && F.floor_tile)
			var/obj/item/I = new F.floor_tile(F)
			F.break_tile_to_plating()
			found |= I
	var/items_to_collect = min(found.len,min(max_collect_count,max_junk - junk.len))
	for(var/i in 1 to items_to_collect)
		var/obj/item/I = pick_n_take(found)
		if(QDELETED(I))
			continue
		I.orbit(src,rand(8,14),rotation_speed = rand(10,30))
		RegisterSignal(I,COMSIG_ATOM_BULLET_ACT, .proc/bullethit)
		RegisterSignal(I,COMSIG_PARENT_ATTACKBY,.proc/knockoff_junk)
		junk |= I
	
	update_ranged()

/mob/living/simple_animal/hostile/haunt/poltergeist/handle_automated_action()
	. = ..()
	collect_junk()
	
/mob/living/simple_animal/hostile/haunt/poltergeist/death(gibbed)
	GET_COMPONENT(orb,/datum/component/orbiter)
	for(var/obj/item/I in junk)
		orb.end_orbit(I)
	. = ..()

/mob/living/simple_animal/hostile/haunt/poltergeist/proc/update_ranged()
	if(junk.len)
		ranged = TRUE
	else
		ranged = FALSE

/mob/living/simple_animal/hostile/haunt/poltergeist/proc/clean_junk()
	listclearnulls(junk) //outside stacks merging and other memes
	for(var/obj/item/I in junk)
		if(QDELETED(I))
			junk -= I

/mob/living/simple_animal/hostile/haunt/poltergeist/Shoot(atom/targeted_atom)
	if( QDELETED(targeted_atom) || targeted_atom == targets_from.loc || targeted_atom == targets_from )
		return

	clean_junk()
	if(!junk.len)
		update_ranged()
		return

	var/obj/item/I = pick(junk)
	I.orbiting.end_orbit(I)
	I.throw_at(targeted_atom,7,2,src)
	update_ranged()

/mob/living/simple_animal/hostile/haunt/poltergeist/death_effect()
	GET_COMPONENT(orb,/datum/component/orbiter)
	for(var/obj/item/I in junk)
		orb.end_orbit(I)
	. = ..()


/datum/action/innate/poltergeist_collect
	name = "Collect Junk"
	desc = "Pick up items lying around, if there are no items, rips out floor tiles."
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/poltergeist_collect/Activate()
	var/mob/living/simple_animal/hostile/haunt/poltergeist/P = owner
	P.collect_junk()