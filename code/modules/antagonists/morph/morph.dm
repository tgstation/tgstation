/mob/living/simple_animal/hostile/morph
	name = "morph"
	real_name = "morph"
	desc = "A revolting, pulsating pile of flesh."
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	icon = 'icons/mob/animal.dmi'
	icon_state = "morph"
	icon_living = "morph"
	icon_dead = "morph_dead"
	combat_mode = TRUE
	stop_automated_movement = 1
	status_flags = CANPUSH
	pass_flags = PASSTABLE
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxHealth = 150
	health = 150
	healable = 0
	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	see_in_dark = NIGHTVISION_FOV_RANGE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	vision_range = 1 // Only attack when target is close
	wander = FALSE
	attack_verb_continuous = "glomps"
	attack_verb_simple = "glomp"
	attack_sound = 'sound/effects/blobattack.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE //nom nom nom
	butcher_results = list(/obj/item/food/meat/slab = 2)

	var/morphed = FALSE
	var/melee_damage_disguised = 0
	var/eat_while_disguised = FALSE
	var/atom/movable/form = null
	var/static/list/blacklist_typecache = typecacheof(list(
		/atom/movable/screen,
		/obj/singularity,
		/obj/energy_ball,
		/obj/narsie,
		/mob/living/simple_animal/hostile/morph,
		/obj/effect,
	))

/mob/living/simple_animal/hostile/morph/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_ALERT_GHOSTS_ON_DEATH, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/hostile/morph/examine(mob/user)
	if(morphed)
		. = form.examine(user)
		if(get_dist(user,src)<=3)
			. += span_warning("It doesn't look quite right...")
	else
		. = ..()

/mob/living/simple_animal/hostile/morph/med_hud_set_health()
	if(morphed && !isliving(form))
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = null
		return //we hide medical hud while morphed
	..()

/mob/living/simple_animal/hostile/morph/med_hud_set_status()
	if(morphed && !isliving(form))
		var/image/holder = hud_list[STATUS_HUD]
		holder.icon_state = null
		return //we hide medical hud while morphed
	..()

/mob/living/simple_animal/hostile/morph/proc/allowed(atom/movable/A) // make it into property/proc ? not sure if worth it
	return !is_type_in_typecache(A, blacklist_typecache) && (isobj(A) || ismob(A))

/mob/living/simple_animal/hostile/morph/proc/eat(atom/movable/A)
	if(morphed && !eat_while_disguised)
		to_chat(src, span_warning("You cannot eat anything while you are disguised!"))
		return FALSE
	if(A && A.loc != src)
		visible_message(span_warning("[src] swallows [A] whole!"))
		A.forceMove(src)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/morph/ShiftClickOn(atom/movable/A)
	if(!stat)
		if(A == src)
			restore()
			return
		if(istype(A) && allowed(A))
			assume(A)
	else
		to_chat(src, span_warning("You need to be conscious to transform!"))
		..()

/mob/living/simple_animal/hostile/morph/proc/assume(atom/movable/target)
	morphed = TRUE
	form = target

	visible_message(span_warning("[src] suddenly twists and changes shape, becoming a copy of [target]!"), \
					span_notice("You twist your body and assume the form of [target]."))
	appearance = target.appearance
	copy_overlays(target)
	alpha = max(alpha, 150) //fucking chameleons
	transform = initial(transform)
	pixel_y = base_pixel_y
	pixel_x = base_pixel_x

	//Morphed is weaker
	melee_damage_lower = melee_damage_disguised
	melee_damage_upper = melee_damage_disguised
	add_movespeed_modifier(/datum/movespeed_modifier/morph_disguised)

	med_hud_set_health()
	med_hud_set_status() //we're an object honest
	return

/mob/living/simple_animal/hostile/morph/proc/restore()
	if(!morphed)
		to_chat(src, span_warning("You're already in your normal form!"))
		return
	morphed = FALSE
	form = null
	alpha = initial(alpha)
	color = initial(color)
	desc = initial(desc)
	animate_movement = SLIDE_STEPS
	maptext = null

	visible_message(span_warning("[src] suddenly collapses in on itself, dissolving into a pile of green flesh!"), \
					span_notice("You reform to your normal body."))
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	cut_overlays()

	//Baseline stats
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	remove_movespeed_modifier(/datum/movespeed_modifier/morph_disguised)

	med_hud_set_health()
	med_hud_set_status() //we are not an object

/mob/living/simple_animal/hostile/morph/death(gibbed)
	if(morphed)
		visible_message(span_warning("[src] twists and dissolves into a pile of green flesh!"), \
						span_userdanger("Your skin ruptures! Your flesh breaks apart! No disguise can ward off de--"))
		restore()
	barf_contents()
	..()

/mob/living/simple_animal/hostile/morph/proc/barf_contents()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
		if(prob(90))
			step(AM, pick(GLOB.alldirs))

/mob/living/simple_animal/hostile/morph/wabbajack_act(mob/living/new_mob)
	barf_contents()
	. = ..()

/mob/living/simple_animal/hostile/morph/Aggro() // automated only
	..()
	if(morphed)
		restore()

/mob/living/simple_animal/hostile/morph/LoseAggro()
	vision_range = initial(vision_range)

/mob/living/simple_animal/hostile/morph/AIShouldSleep(list/possible_targets)
	. = ..()
	if(.)
		var/list/things = list()
		for(var/atom/movable/A in view(src))
			if(allowed(A))
				things += A
		var/atom/movable/T = pick(things)
		assume(T)

/mob/living/simple_animal/hostile/morph/can_track(mob/living/user)
	if(morphed)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/morph/AttackingTarget()
	if(morphed && !melee_damage_disguised)
		to_chat(src, span_warning("You can not attack while disguised!"))
		return
	if(isliving(target)) //Eat Corpses to regen health
		var/mob/living/L = target
		if(L.stat == DEAD)
			if(do_after(src, 30, target = L))
				if(eat(L))
					adjustHealth(-50)
			return
	else if(isitem(target)) //Eat items just to be annoying
		var/obj/item/I = target
		if(!I.anchored)
			if(do_after(src, 20, target = I))
				eat(I)
			return
	return ..()

//Spawn Event

/datum/round_event_control/morph
	name = "Spawn Morph"
	typepath = /datum/round_event/ghost_role/morph
	weight = 0 //Admin only
	max_occurrences = 1

/datum/round_event/ghost_role/morph
	minimum_required = 1
	role_name = "morphling"

/datum/round_event/ghost_role/morph/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = TRUE
	if(!GLOB.xeno_spawn)
		return MAP_ERROR
	var/mob/living/simple_animal/hostile/morph/S = new /mob/living/simple_animal/hostile/morph(pick(GLOB.xeno_spawn))
	player_mind.transfer_to(S)
	player_mind.set_assigned_role(SSjob.GetJobType(/datum/job/morph))
	player_mind.special_role = ROLE_MORPH
	player_mind.add_antag_datum(/datum/antagonist/morph)
	SEND_SOUND(S, sound('sound/magic/mutate.ogg'))
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a morph by an event.")
	log_game("[key_name(S)] was spawned as a morph by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN
