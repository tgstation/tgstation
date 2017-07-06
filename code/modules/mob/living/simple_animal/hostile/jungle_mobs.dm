/mob/living/simple_animal/hostile/jungle
	vision_range = 5
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("jungle")
	weather_immunities = list("acid")
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	minbodytemp = 0
	maxbodytemp = 450
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	status_flags = 0
	a_intent = INTENT_HARM
	see_in_dark = 4
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	mob_size = MOB_SIZE_LARGE



//Mega arachnid

/mob/living/simple_animal/hostile/jungle/mega_arachnid
	name = "mega arachnid"
	desc = "Though physically imposing, it prefers to ambush its prey, and it will only engage with an already crippled opponent."
	melee_damage_lower = 30
	melee_damage_upper = 30
	maxHealth = 300
	health = 300
	speed = 1
	ranged = 1
	pixel_x = -16
	move_to_delay = 10
	aggro_vision_range = 9
	speak_emote = list("chitters")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	ranged_cooldown_time = 60
	projectiletype = /obj/item/projectile/mega_arachnid
	projectilesound = 'sound/weapons/pierce.ogg'
	icon = 'icons/mob/jungle/arachnid.dmi'
	icon_state = "arachnid"
	icon_living = "arachnid"
	icon_dead = "dead_purple"
	alpha = 50

/mob/living/simple_animal/hostile/jungle/mega_arachnid/Life()
	..()
	if(target && ranged_cooldown > world.time && iscarbon(target))
		var/mob/living/carbon/C = target
		if(!C.legcuffed && C.health < 50)
			retreat_distance = 9
			minimum_distance = 9
			alpha = 125
			return
	retreat_distance = 0
	minimum_distance = 0
	alpha = 255


/mob/living/simple_animal/hostile/jungle/mega_arachnid/Aggro()
	..()
	alpha = 255

/mob/living/simple_animal/hostile/jungle/mega_arachnid/LoseAggro()
	..()
	alpha = 50

/obj/item/projectile/mega_arachnid
	name = "flesh snare"
	nodamage = 1
	damage = 0
	icon_state = "tentacle_end"

/obj/item/projectile/mega_arachnid/on_hit(atom/target, blocked = 0)
	if(iscarbon(target) && blocked < 100)
		var/obj/item/weapon/restraints/legcuffs/beartrap/mega_arachnid/B = new /obj/item/weapon/restraints/legcuffs/beartrap/mega_arachnid(get_turf(target))
		B.Crossed(target)
	..()

/obj/item/weapon/restraints/legcuffs/beartrap/mega_arachnid
	name = "fleshy restraints"
	desc = "Used by mega arachnids to immobilize their prey."
	flags = DROPDEL
	icon_state = "tentacle_end"
	icon = 'icons/obj/projectiles.dmi'

////Leaper////

#define PLAYER_HOP_DELAY 25

/mob/living/simple_animal/hostile/jungle/leaper
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list("jungle")
	weather_immunities = list("acid")
	obj_damage = 30
	environment_smash = ENVIRONMENT_SMASH_WALLS
	maxHealth = 300
	health = 300
	minbodytemp = 0
	maxbodytemp = 450
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "strikes"
	status_flags = 0
	a_intent = INTENT_HARM
	see_in_dark = 4
	ranged = TRUE
	projectiletype = /obj/item/projectile/leaper
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged_cooldown_time = 30
	pixel_x = -16
	pixel_y = -16
	icon = 'icons/mob/jungle/arachnid.dmi'
	icon_state = "leaper"
	icon_living = "leaper"
	icon_dead = "leaper_dead"
	layer = LARGE_MOB_LAYER
	name = "leaper"
	desc = "Commonly referred to as 'leapers', the Geron Toad is a massive beast that spits out highly pressurized bubbles containing a unique toxin, knocking down its prey and then crushing it with its girth."
	speed = 10
	stat_attack = 1
	robust_searching = 1
	var/hopping = FALSE
	var/hop_cooldown = 0 //Strictly for player controlled leapers
	var/projectile_ready = FALSE //Stopping AI leapers from firing whenever they want, and only doing it after a hop has finished instead

/obj/item/projectile/leaper
	name = "leaper bubble"
	icon_state = "leaper"
	knockdown = 50
	damage = 0
	range = 7
	hitsound = 'sound/effects/snap.ogg'
	nondirectional_sprite = TRUE
	impact_effect_type = /obj/effect/temp_visual/leaper_projectile_impact

/obj/item/projectile/leaper/on_hit(atom/target, blocked = 0)
	..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.reagents.add_reagent("leaper_venom", 5)

/obj/item/projectile/leaper/on_range()
	var/turf/T = get_turf(src)
	..()
	new /obj/structure/leaper_bubble(T)

/obj/effect/temp_visual/leaper_projectile_impact
	name = "leaper bubble"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "leaper_bubble_pop"
	layer = ABOVE_ALL_MOB_LAYER
	duration = 3

/obj/effect/temp_visual/leaper_projectile_impact/Initialize()
	. = ..()
	new /obj/effect/decal/cleanable/leaper_sludge(get_turf(src))

/obj/effect/decal/cleanable/leaper_sludge
	name = "leaper sludge"
	desc = "A small pool of sludge, containing trace amounts of leaper venom"
	icon = 'icons/effects/tomatodecal.dmi'
	icon_state = "tomato_floor1"

/obj/structure/leaper_bubble
	name = "leaper bubble"
	desc = "A floating bubble containing leaper venom, the contents are under a surprising amount of pressure."
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "leaper"
	obj_integrity = 10
	max_integrity = 10
	density = FALSE

/obj/structure/leaper_bubble/Initialize()
	. = ..()
	float(on = TRUE)
	QDEL_IN(src, 100)

/obj/structure/leaper_bubble/Destroy()
	new /obj/effect/temp_visual/leaper_projectile_impact(get_turf(src))
	playsound(src,'sound/effects/snap.ogg',50, 1, -1)
	return ..()

/obj/structure/leaper_bubble/Crossed(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/L = AM
		if(!istype(L, /mob/living/simple_animal/hostile/jungle/leaper))
			playsound(src,'sound/effects/snap.ogg',50, 1, -1)
			L.Knockdown(50)
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.reagents.add_reagent("leaper_venom", 5)
			qdel(src)
	return ..()

/datum/reagent/toxin/leaper_venom
	name = "Leaper venom"
	id = "leaper_venom"
	description = "A toxin spat out by leapers that while harmless in small doses, quickly creates a toxic reaction if too much is in the body."
	color = "#801E28" // rgb: 128, 30, 40
	toxpwr = 0
	taste_description = "french cuisine"
	taste_mult = 1.3

/datum/reagent/toxin/leaper_venom/on_mob_life(mob/living/M)
	if(volume >= 10)
		M.adjustToxLoss(5, 0)
	..()

/obj/effect/temp_visual/leaper_crush
	name = "Grim tidings"
	desc = "Incoming leaper!"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "lily_pad"
	layer = BELOW_MOB_LAYER
	pixel_x = -32
	pixel_y = -32
	duration = 30

/mob/living/simple_animal/hostile/jungle/leaper/Initialize()
	. = ..()
	verbs -= /mob/living/verb/pulled

/mob/living/simple_animal/hostile/jungle/leaper/CtrlClickOn(atom/A)
	face_atom(A)
	target = A
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

/mob/living/simple_animal/hostile/jungle/leaper/Life()
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
		if(AIStatus == AI_ON && !projectile_ready)
			return
		. = ..(target)
		projectile_ready = FALSE
		update_icons()

/mob/living/simple_animal/hostile/jungle/leaper/proc/Hop(player_hop = FALSE)
	if(z != target.z)
		return
	hopping = TRUE
	density = FALSE
	pass_flags |= PASSMOB
	notransform = TRUE
	var/turf/new_turf = locate((target.x + rand(-3,3)),(target.y + rand(-3,3)),target.z)
	if(player_hop)
		new_turf = get_turf(target)
		hop_cooldown = world.time + PLAYER_HOP_DELAY
	if(AIStatus == AI_ON && ranged_cooldown <= world.time)
		projectile_ready = TRUE
		update_icons()
	throw_at(new_turf, max(3,get_dist(src,new_turf)), 1, src, FALSE, callback = CALLBACK(src, .FinishHop))

/mob/living/simple_animal/hostile/jungle/leaper/proc/FinishHop()
	density = TRUE
	notransform = FALSE
	pass_flags &= ~PASSMOB
	hopping = FALSE
	playsound(src.loc, 'sound/effects/meteorimpact.ogg', 100, 1)
	if(target && AIStatus == AI_ON && projectile_ready)
		face_atom(target)
		addtimer(CALLBACK(src, .proc/OpenFire, target), 5)

/mob/living/simple_animal/hostile/jungle/leaper/proc/BellyFlop()
	var/turf/new_turf = get_turf(target)
	hopping = TRUE
	notransform = TRUE
	new /obj/effect/temp_visual/leaper_crush(new_turf)
	addtimer(CALLBACK(src, .proc/BellyFlopHop, new_turf), 30)

/mob/living/simple_animal/hostile/jungle/leaper/proc/BellyFlopHop(turf/T)
	density = FALSE
	throw_at(T, get_dist(src,T),1,src, FALSE, callback = CALLBACK(src, .proc/Crush))

/mob/living/simple_animal/hostile/jungle/leaper/proc/Crush()
	hopping = FALSE
	density = TRUE
	notransform = FALSE
	playsound(src, 'sound/effects/meteorimpact.ogg', 200, 1)
	for(var/mob/living/L in orange(1, src))
		L.adjustBruteLoss(35)
		if(!QDELETED(L)) // Some mobs are deleted on death
			var/throw_dir = get_dir(src, L)
			if(L.loc == loc)
				throw_dir = pick(GLOB.alldirs)
			var/throwtarget = get_edge_target_turf(src, throw_dir)
			L.throw_at(throwtarget, 3, 1)
			visible_message("<span class='warning'>[L] is thrown clear of [src]!</span>")
	if(ckey)//Lessens ability to chain stun as a player
		ranged_cooldown = ranged_cooldown_time + world.time
		update_icons()

/mob/living/simple_animal/hostile/jungle/leaper/Goto()
	return

/mob/living/simple_animal/hostile/jungle/leaper/throw_impact()
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

#undef PLAYER_HOP_DELAY