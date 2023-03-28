#define PLAYER_HOP_DELAY 25

//Huge, carnivorous toads that spit an immobilizing toxin at its victims before leaping onto them.
//It has no melee attack, and its damage comes from the toxin in its bubbles and its crushing leap.
//Its eyes will turn red to signal an imminent attack!
/mob/living/simple_animal/hostile/jungle/leaper
	name = "leaper"
	desc = "Commonly referred to as 'leapers', the Geron Toad is a massive beast that spits out highly pressurized bubbles containing a unique toxin, knocking down its prey and then crushing it with its girth."
	icon = 'icons/mob/simple/jungle/leaper.dmi'
	icon_state = "leaper"
	icon_living = "leaper"
	icon_dead = "leaper_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	maxHealth = 300
	health = 300
	ranged = TRUE
	projectiletype = /obj/projectile/leaper
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged_cooldown_time = 30
	pixel_x = -16
	base_pixel_x = -16
	layer = LARGE_MOB_LAYER
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	speed = 10
	stat_attack = HARD_CRIT
	robust_searching = 1
	var/hopping = FALSE
	var/hop_cooldown = 0 //Strictly for player controlled leapers
	var/projectile_ready = FALSE //Stopping AI leapers from firing whenever they want, and only doing it after a hop has finished instead

	footstep_type = FOOTSTEP_MOB_HEAVY

/obj/projectile/leaper
	name = "leaper bubble"
	icon_state = "leaper"
	paralyze = 50
	damage = 0
	range = 7
	hitsound = 'sound/effects/snap.ogg'
	nondirectional_sprite = TRUE
	impact_effect_type = /obj/effect/temp_visual/leaper_projectile_impact

/obj/projectile/leaper/on_hit(atom/target, blocked = FALSE)
	..()
	if (!isliving(target))
		return
	var/mob/living/bubbled = target
	if(iscarbon(target))
		bubbled.reagents.add_reagent(/datum/reagent/toxin/leaper_venom, 5)
		return
	if(isanimal(target))
		var/mob/living/simple_animal/bubbled_animal = bubbled
		bubbled_animal.adjustHealth(25)
		return
	if (isbasicmob(target))
		bubbled.adjustBruteLoss(25)

/obj/projectile/leaper/on_range()
	var/turf/T = get_turf(src)
	..()
	new /obj/structure/leaper_bubble(T)

/obj/effect/temp_visual/leaper_projectile_impact
	name = "leaper bubble"
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "leaper_bubble_pop"
	layer = ABOVE_ALL_MOB_LAYER
	plane = GAME_PLANE_UPPER_FOV_HIDDEN
	duration = 3

/obj/effect/temp_visual/leaper_projectile_impact/Initialize(mapload)
	. = ..()
	new /obj/effect/decal/cleanable/leaper_sludge(get_turf(src))

/obj/effect/decal/cleanable/leaper_sludge
	name = "leaper sludge"
	desc = "A small pool of sludge, containing trace amounts of leaper venom."
	icon = 'icons/effects/tomatodecal.dmi'
	icon_state = "tomato_floor1"

/obj/effect/decal/cleanable/leaper_sludge/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_LEAPER, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/obj/structure/leaper_bubble
	name = "leaper bubble"
	desc = "A floating bubble containing leaper venom. The contents are under a surprising amount of pressure."
	icon = 'icons/obj/weapons/guns/projectiles.dmi'
	icon_state = "leaper"
	max_integrity = 10
	density = FALSE

/obj/structure/leaper_bubble/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/movetype_handler)
	ADD_TRAIT(src, TRAIT_MOVE_FLOATING, LEAPER_BUBBLE_TRAIT)
	QDEL_IN(src, 100)
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_LEAPER, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

/obj/structure/leaper_bubble/Destroy()
	new /obj/effect/temp_visual/leaper_projectile_impact(get_turf(src))
	playsound(src,'sound/effects/snap.ogg',50, TRUE, -1)
	return ..()

/obj/structure/leaper_bubble/proc/on_entered(datum/source, atom/movable/bubbled)
	SIGNAL_HANDLER
	if(!isliving(bubbled) || istype(bubbled, /mob/living/simple_animal/hostile/jungle/leaper))
		return
	var/mob/living/bubbled_mob = bubbled

	playsound(src,'sound/effects/snap.ogg',50, TRUE, -1)
	bubbled_mob.Paralyze(50)
	if(iscarbon(bubbled_mob))
		bubbled_mob.reagents.add_reagent(/datum/reagent/toxin/leaper_venom, 5)
	else if(isanimal(bubbled_mob))
		var/mob/living/simple_animal/bubbled_animal = bubbled_mob
		bubbled_animal.adjustHealth(25)
	else if(isbasicmob(bubbled_mob))
		bubbled_mob.adjustBruteLoss(25)
	qdel(src)

/datum/reagent/toxin/leaper_venom
	name = "Leaper venom"
	description = "A toxin spat out by leapers that, while harmless in small doses, quickly creates a toxic reaction if too much is in the body."
	color = "#801E28" // rgb: 128, 30, 40
	toxpwr = 0
	taste_description = "french cuisine"
	taste_mult = 1.3

/datum/reagent/toxin/leaper_venom/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(volume >= 10)
		M.adjustToxLoss(5 * REAGENTS_EFFECT_MULTIPLIER * delta_time, 0)
	..()

/obj/effect/temp_visual/leaper_crush
	name = "grim tidings"
	desc = "Incoming leaper!"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "lily_pad"
	layer = BELOW_MOB_LAYER
	plane = GAME_PLANE
	SET_BASE_PIXEL(-32, -32)
	duration = 30

/mob/living/simple_animal/hostile/jungle/leaper/Initialize(mapload)
	. = ..()
	remove_verb(src, /mob/living/verb/pulled)
	add_cell_sample()

/mob/living/simple_animal/hostile/jungle/leaper/CtrlClickOn(atom/A)
	face_atom(A)
	GiveTarget(A)
	if(!isturf(loc))
		return
	if(next_move > world.time)
		return
	if(hopping)
		return
	if(isliving(A))
		var/mob/living/L = A
		if(L.incapacitated())
			BellyFlop()
			return
	if(hop_cooldown <= world.time)
		Hop(player_hop = TRUE)

/mob/living/simple_animal/hostile/jungle/leaper/AttackingTarget()
	if(isliving(target))
		return
	return ..()

/mob/living/simple_animal/hostile/jungle/leaper/handle_automated_action()
	if(hopping || projectile_ready)
		return
	. = ..()
	if(target)
		if(isliving(target))
			var/mob/living/L = target
			if(L.incapacitated())
				BellyFlop()
				return
		if(!hopping)
			Hop()

/mob/living/simple_animal/hostile/jungle/leaper/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	update_icons()

/mob/living/simple_animal/hostile/jungle/leaper/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(prob(33) && !ckey)
		ranged_cooldown = 0 //Keeps em on their toes instead of a constant rotation
	..()

/mob/living/simple_animal/hostile/jungle/leaper/OpenFire()
	face_atom(target)
	if(ranged_cooldown <= world.time)
		if(ckey)
			if(hopping)
				return
			if(isliving(target))
				var/mob/living/L = target
				if(L.incapacitated())
					return //No stunlocking. Hop on them after you stun them, you donk.
		if(AIStatus == AI_ON && !projectile_ready && !ckey)
			return
		. = ..(target)
		projectile_ready = FALSE
		update_icons()

/mob/living/simple_animal/hostile/jungle/leaper/proc/Hop(player_hop = FALSE)
	if(z != target.z)
		return
	hopping = TRUE
	set_density(FALSE)
	pass_flags |= PASSMOB
	notransform = TRUE
	var/turf/new_turf = locate((target.x + rand(-3,3)),(target.y + rand(-3,3)),target.z)
	if(player_hop)
		new_turf = get_turf(target)
		hop_cooldown = world.time + PLAYER_HOP_DELAY
	if(AIStatus == AI_ON && ranged_cooldown <= world.time)
		projectile_ready = TRUE
		update_icons()
	throw_at(new_turf, max(3,get_dist(src,new_turf)), 1, src, FALSE, callback = CALLBACK(src, PROC_REF(FinishHop)))

/mob/living/simple_animal/hostile/jungle/leaper/proc/FinishHop()
	set_density(TRUE)
	notransform = FALSE
	pass_flags &= ~PASSMOB
	hopping = FALSE
	playsound(src.loc, 'sound/effects/meteorimpact.ogg', 100, TRUE)
	if(target && AIStatus == AI_ON && projectile_ready && !ckey)
		face_atom(target)
		addtimer(CALLBACK(src, PROC_REF(OpenFire), target), 5)

/mob/living/simple_animal/hostile/jungle/leaper/proc/BellyFlop()
	var/turf/new_turf = get_turf(target)
	hopping = TRUE
	notransform = TRUE
	new /obj/effect/temp_visual/leaper_crush(new_turf)
	addtimer(CALLBACK(src, PROC_REF(BellyFlopHop), new_turf), 30)

/mob/living/simple_animal/hostile/jungle/leaper/proc/BellyFlopHop(turf/T)
	set_density(FALSE)
	throw_at(T, get_dist(src,T),1,src, FALSE, callback = CALLBACK(src, PROC_REF(Crush)))

/mob/living/simple_animal/hostile/jungle/leaper/proc/Crush()
	hopping = FALSE
	set_density(TRUE)
	notransform = FALSE
	playsound(src, 'sound/effects/meteorimpact.ogg', 200, TRUE)
	for(var/mob/living/L in orange(1, src))
		L.adjustBruteLoss(35)
		if(!QDELETED(L)) // Some mobs are deleted on death
			var/throw_dir = get_dir(src, L)
			if(L.loc == loc)
				throw_dir = pick(GLOB.alldirs)
			var/throwtarget = get_edge_target_turf(src, throw_dir)
			L.throw_at(throwtarget, 3, 1)
			visible_message(span_warning("[L] is thrown clear of [src]!"))
	if(ckey)//Lessens ability to chain stun as a player
		ranged_cooldown = ranged_cooldown_time + world.time
		update_icons()

/mob/living/simple_animal/hostile/jungle/leaper/Goto()
	return

/mob/living/simple_animal/hostile/jungle/leaper/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	return

/mob/living/simple_animal/hostile/jungle/leaper/update_icons()
	. = ..()
	if(stat)
		icon_state = "leaper_dead"
		return
	if(ranged_cooldown <= world.time)
		if(AIStatus == AI_ON && projectile_ready || ckey)
			icon_state = "leaper_alert"
			return
	icon_state = "leaper"

/mob/living/simple_animal/hostile/jungle/leaper/add_cell_sample()
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_LEAPER, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

#undef PLAYER_HOP_DELAY
