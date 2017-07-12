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
		return
	if(isanimal(target))
		var/mob/living/simple_animal/L = target
		L.adjustHealth(25)

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
			if(isanimal(L))
				var/mob/living/simple_animal/A = L
				A.adjustHealth(25)
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
		if(AIStatus == AI_ON && !projectile_ready && !ckey)
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
	if(target && AIStatus == AI_ON && projectile_ready && !ckey)
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

////JUNGLE MOOK////

#define MOOK_ATTACK_NEUTRAL 0
#define MOOK_ATTACK_WARMUP 1
#define MOOK_ATTACK_ACTIVE 2
#define MOOK_ATTACK_RECOVERY 3

#define ATTACK_INTERMISSION_TIME 5

/mob/living/simple_animal/hostile/jungle/mook
	name = "wanderer"
	desc = "This unhealthy looking primitive is wielding a rudimentary hatchet, swinging it with wild abandon. One isn't much of a threat, but in numbers they can quickly overwhelm a superior opponent."
	maxHealth = 45
	health = 45
	melee_damage_lower = 30
	melee_damage_upper = 30
	icon = 'icons/mob/jungle/arachnid.dmi'
	icon_state = "mook"
	icon_living = "mook"
	icon_dead = "mook_dead"
	pixel_x = -16
	pixel_y = -8
	ranged = TRUE
	ranged_cooldown_time = 10
	pass_flags = LETPASSTHROW
	robust_searching = TRUE
	stat_attack = UNCONSCIOUS
	attack_sound = 'sound/weapons/rapierhit.ogg'
	death_sound = 'sound/voice/mook_death.ogg'
	aggro_vision_range = 15 //A little more aggressive once in combat to balance out their really low HP
	var/attack_state = MOOK_ATTACK_NEUTRAL
	var/struck_target_leap = FALSE

/mob/living/simple_animal/hostile/jungle/mook/CanPass(atom/movable/O)
	if(istype(O, /mob/living/simple_animal/hostile/jungle/mook))
		var/mob/living/simple_animal/hostile/jungle/mook/M = O
		if(M.attack_state == MOOK_ATTACK_ACTIVE && M.throwing)
			return TRUE
	return ..()

/mob/living/simple_animal/hostile/jungle/mook/death()
	desc = "A deceased primitive. Upon closer inspection, it was suffering from severe cellular degeneration and its garments are machine made..."//Can you guess the twist
	return ..()

/mob/living/simple_animal/hostile/jungle/mook/AttackingTarget()
	if(isliving(target))
		if(ranged_cooldown <= world.time && attack_state == MOOK_ATTACK_NEUTRAL)
			var/mob/living/L = target
			if(L.incapacitated())
				WarmupAttack(forced_slash_combo = TRUE)
				return
			WarmupAttack()
		return
	return ..()

/mob/living/simple_animal/hostile/jungle/mook/Goto()
	if(attack_state != MOOK_ATTACK_NEUTRAL)
		return
	return ..()

/mob/living/simple_animal/hostile/jungle/mook/Move()
	if(attack_state == MOOK_ATTACK_WARMUP || attack_state == MOOK_ATTACK_RECOVERY)
		return
	return ..()

/mob/living/simple_animal/hostile/jungle/mook/proc/WarmupAttack(forced_slash_combo = FALSE)
	if(attack_state == MOOK_ATTACK_NEUTRAL && target)
		attack_state = MOOK_ATTACK_WARMUP
		walk(src,0)
		update_icons()
		if(prob(50) && get_dist(src,target) <= 3 || forced_slash_combo)
			addtimer(CALLBACK(src, .proc/SlashCombo), ATTACK_INTERMISSION_TIME)
			return
		addtimer(CALLBACK(src, .proc/LeapAttack), ATTACK_INTERMISSION_TIME + rand(0,3))
		return
	attack_state = MOOK_ATTACK_RECOVERY
	ResetNeutral()

/mob/living/simple_animal/hostile/jungle/mook/proc/SlashCombo()
	if(attack_state == MOOK_ATTACK_WARMUP && !stat)
		attack_state = MOOK_ATTACK_ACTIVE
		update_icons()
		SlashAttack()
		addtimer(CALLBACK(src, .proc/SlashAttack), 3)
		addtimer(CALLBACK(src, .proc/SlashAttack), 6)
		addtimer(CALLBACK(src, .proc/AttackRecovery), 9)

/mob/living/simple_animal/hostile/jungle/mook/proc/SlashAttack()
	if(target && !stat && attack_state == MOOK_ATTACK_ACTIVE)
		melee_damage_lower = 15
		melee_damage_upper = 15
		var/mob_direction = get_dir(src,target)
		if(get_dist(src,target) > 1)
			step(src,mob_direction)
		if(targets_from && isturf(targets_from.loc) && target.Adjacent(targets_from) && isliving(target))
			var/mob/living/L = target
			L.attack_animal(src)
			return
		var/swing_turf = get_step(src,mob_direction)
		new /obj/effect/temp_visual/kinetic_blast(swing_turf)
		playsound(src, 'sound/weapons/slashmiss.ogg', 50, 1)

/mob/living/simple_animal/hostile/jungle/mook/proc/LeapAttack()
	if(target && !stat && attack_state == MOOK_ATTACK_WARMUP)
		attack_state = MOOK_ATTACK_ACTIVE
		density = FALSE
		melee_damage_lower = 30
		melee_damage_upper = 30
		update_icons()
		new /obj/effect/temp_visual/mook_dust(get_turf(src))
		playsound(src, 'sound/weapons/thudswoosh.ogg', 25, 1)
		playsound(src, 'sound/voice/mook_leap_yell.ogg', 100, 1)
		var/target_turf = get_turf(target)
		throw_at(target_turf, 7, 1, src, FALSE, callback = CALLBACK(src, .proc/AttackRecovery))
		return
	attack_state = MOOK_ATTACK_RECOVERY
	ResetNeutral()

/mob/living/simple_animal/hostile/jungle/mook/proc/AttackRecovery()
	if(attack_state == MOOK_ATTACK_ACTIVE && !stat)
		attack_state = MOOK_ATTACK_RECOVERY
		density = TRUE
		face_atom(target)
		if(!struck_target_leap)
			update_icons()
		struck_target_leap = FALSE
		if(prob(40))
			attack_state = MOOK_ATTACK_NEUTRAL
			if(target)
				if(isliving(target))
					var/mob/living/L = target
					if(L.incapacitated() && L.stat != DEAD)
						addtimer(CALLBACK(src, .proc/WarmupAttack, TRUE), ATTACK_INTERMISSION_TIME)
						return
			addtimer(CALLBACK(src, .proc/WarmupAttack), ATTACK_INTERMISSION_TIME)
			return
		addtimer(CALLBACK(src, .proc/ResetNeutral), ATTACK_INTERMISSION_TIME)

/mob/living/simple_animal/hostile/jungle/mook/proc/ResetNeutral()
	if(attack_state == MOOK_ATTACK_RECOVERY)
		attack_state = MOOK_ATTACK_NEUTRAL
		ranged_cooldown = world.time + ranged_cooldown_time
		update_icons()
		if(target && !stat)
			update_icons()
			Goto(target, move_to_delay, minimum_distance)

/mob/living/simple_animal/hostile/jungle/mook/throw_impact(atom/hit_atom, throwingdatum)
	. = ..()
	if(isliving(hit_atom) && attack_state == MOOK_ATTACK_ACTIVE)
		var/mob/living/L = hit_atom
		if(CanAttack(L))
			L.attack_animal(src)
			struck_target_leap = TRUE
			density = TRUE
			update_icons()
	var/mook_under_us = FALSE
	for(var/A in get_turf(src))
		if(struck_target_leap && mook_under_us)
			break
		if(A == src)
			continue
		if(isliving(A))
			var/mob/living/ML = A
			if(!struck_target_leap && CanAttack(ML))//Check if some joker is attempting to use rest to evade us
				struck_target_leap = TRUE
				ML.attack_animal(src)
				density = TRUE
				struck_target_leap = TRUE
				update_icons()
				continue
			if(istype(ML, /mob/living/simple_animal/hostile/jungle/mook) && !mook_under_us)//If we land on the same tile as another mook, spread out so we don't stack our sprite on the same tile
				var/mob/living/simple_animal/hostile/jungle/mook/M = ML
				if(!M.stat)
					mook_under_us = TRUE
					var/anydir = pick(GLOB.cardinal)
					Move(get_step(src, anydir), anydir)
					continue

/mob/living/simple_animal/hostile/jungle/mook/handle_automated_action()
	if(attack_state)
		return
	return ..()

/mob/living/simple_animal/hostile/jungle/mook/OpenFire()
	if(isliving(target))
		var/mob/living/L = target
		if(L.incapacitated())
			return
	WarmupAttack()

/mob/living/simple_animal/hostile/jungle/mook/update_icons()
	. = ..()
	if(!stat)
		switch(attack_state)
			if(MOOK_ATTACK_NEUTRAL)
				icon_state = "mook"
			if(MOOK_ATTACK_WARMUP)
				icon_state = "mook_warmup"
			if(MOOK_ATTACK_ACTIVE)
				if(!density)
					icon_state = "mook_leap"
					return
				if(struck_target_leap)
					icon_state = "mook_strike"
					return
				icon_state = "mook_slash_combo"
			if(MOOK_ATTACK_RECOVERY)
				icon_state = "mook"

/obj/effect/temp_visual/mook_dust
	name = "dust"
	desc = "it's just a dust cloud!"
	icon = 'icons/mob/jungle/arachnid.dmi'
	icon_state = "mook_leap_cloud"
	layer = BELOW_MOB_LAYER
	pixel_x = -16
	pixel_y = -12
	duration = 10

#undef MOOK_ATTACK_NEUTRAL
#undef MOOK_ATTACK_WARMUP
#undef MOOK_ATTACK_ACTIVE
#undef MOOK_ATTACK_RECOVERY
#undef ATTACK_INTERMISSION_TIME

////Jungle Seedling////

#define SEEDLING_STATE_NEUTRAL 0
#define SEEDLING_STATE_WARMUP 1
#define SEEDLING_STATE_ACTIVE 2
#define SEEDLING_STATE_RECOVERY 3

#define SEEDLING_STATE_REGENERATING 4
#define SEEDLING_REGENERATION_TIME 30


/mob/living/simple_animal/hostile/jungle/seedling
	name = "seedling"
	desc = "This oversized, predatory flower conceals what can only be described as an organic energy cannon, and it will not die until its hidden vital organs are sliced out. \
	 The concentrated streams of energy it sometimes produces require its full attention, attacking it during this time will prevent it from finishing its attack."
	maxHealth = 100
	health = 100
	melee_damage_lower = 30
	melee_damage_upper = 30
	icon = 'icons/mob/jungle/arachnid.dmi'
	icon_state = "seedling"
	icon_living = "seedling"
	icon_dead = "seedling_dead"
	pixel_x = -16
	pixel_y = -14
	minimum_distance = 3
	move_to_delay = 20
	aggro_vision_range = 15
	ranged = TRUE
	ranged_cooldown_time = 10
	projectiletype = /obj/item/projectile/seedling
	projectilesound = 'sound/weapons/pierce.ogg'
	robust_searching = TRUE
	stat_attack = UNCONSCIOUS
	anchored = TRUE
	var/combatant_state = SEEDLING_STATE_NEUTRAL
	var/obj/seedling_weakpoint/weak_point
	var/datum/beam/solar_beam = null
	var/mob/living/beam_debuff_target
	var/solar_beam_identifier = 0

/obj/item/projectile/seedling
	name = "solar energy"
	icon_state = "seedling"
	damage = 10
	damage_type = BURN
	light_range = 2
	flag = "energy"
	light_color = LIGHT_COLOR_YELLOW
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	nondirectional_sprite = TRUE

/obj/item/projectile/seedling/Bump(atom/A, yes)//Stops seedlings from destroying other jungle mobs through FF
	if(isliving(A))
		var/mob/living/L = A
		if("jungle" in L.faction)
			return FALSE
	return ..()

/obj/effect/ebeam/solarbeam
	name = "beam of solar energy"

/datum/status_effect/seedling_beam_indicator
	id = "seedling beam indicator"
	duration = 30
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	tick_interval = 1
	var/mutable_appearance/beam_overlay
	var/atom/target
	var/angle = 0

/datum/status_effect/seedling_beam_indicator/on_creation(mob/living/new_owner, target_plant)
	. = ..()
	if(.)
		target = target_plant
		tick()

/datum/status_effect/seedling_beam_indicator/on_apply()
	beam_overlay = mutable_appearance('icons/mob/jungle/arachnid.dmi', "seedling_beam_indicator")
	beam_overlay.pixel_x = -16 -owner.pixel_x
	beam_overlay.pixel_y = -16 -owner.pixel_y
	tick()
	return ..()

/datum/status_effect/seedling_beam_indicator/Destroy()
	if(owner)
		owner.overlays -= beam_overlay
	QDEL_NULL(beam_overlay)
	return ..()

/datum/status_effect/seedling_beam_indicator/tick()
	var/target_angle = Get_Angle(owner, target)
	owner.overlays -= beam_overlay
	angle = target_angle
	var/matrix/final = matrix()
	final.Turn(target_angle)
	beam_overlay.transform = final
	owner.overlays += beam_overlay


/datum/status_effect/seedling_beam_indicator/be_replaced()
	owner.underlays -= beam_overlay
	..()

/mob/living/simple_animal/hostile/jungle/seedling/Initialize()
	. = ..()
	var/obj/seedling_weakpoint/W = new /obj/seedling_weakpoint(src)
	weak_point = W
	W.our_seedling = src

/mob/living/simple_animal/hostile/jungle/seedling/Goto()
	if(combatant_state != SEEDLING_STATE_NEUTRAL)
		return
	return ..()

/mob/living/simple_animal/hostile/jungle/seedling/AttackingTarget()
	if(isliving(target))
		if(ranged_cooldown <= world.time && combatant_state == SEEDLING_STATE_NEUTRAL)
			OpenFire(target)
		return
	return ..()

/mob/living/simple_animal/hostile/jungle/seedling/OpenFire()
	WarmupAttack()

/mob/living/simple_animal/hostile/jungle/seedling/proc/WarmupAttack()
	if(combatant_state == SEEDLING_STATE_NEUTRAL)
		combatant_state = SEEDLING_STATE_WARMUP
		walk(src,0)
		update_icons()
		var/target_dist = get_dist(src,target)
		var/living_target_check = isliving(target)
		if(living_target_check)
			if(target_dist > 7)//Offscreen check
				SolarBeamStartup(target)
				return
			if(get_dist(src,target) >= 4 && prob(40))
				SolarBeamStartup(target)
				return
		addtimer(CALLBACK(src, .proc/Volley), 5)

/mob/living/simple_animal/hostile/jungle/seedling/proc/SolarBeamStartup(mob/living/living_target)//It's more like requiem than final spark
	if(combatant_state == SEEDLING_STATE_WARMUP && target)
		combatant_state = SEEDLING_STATE_ACTIVE
		living_target.apply_status_effect(/datum/status_effect/seedling_beam_indicator, src)
		beam_debuff_target = living_target
		playsound(src,'sound/effects/seedling_chargeup.ogg', 100, 0)
		if(get_dist(src,living_target) > 7)
			playsound(living_target,'sound/effects/seedling_chargeup.ogg', 100, 0)
		solar_beam_identifier = world.time
		addtimer(CALLBACK(src, .proc/Beamu, living_target, solar_beam_identifier), 35)

/mob/living/simple_animal/hostile/jungle/seedling/proc/Beamu(mob/living/living_target, beam_id = 0)
	if(combatant_state == SEEDLING_STATE_ACTIVE && living_target && beam_id == solar_beam_identifier)
		if(living_target.z == z)
			update_icons()
			solar_beam = new(src,target,time=5,beam_icon_state="solar_beam",maxdistance = INFINITY,btype=/obj/effect/ebeam/solarbeam,beam_sleep_time = 0.5)
			INVOKE_ASYNC(solar_beam, /datum/beam.proc/Start)
			living_target.adjustFireLoss(30)
			living_target.adjust_fire_stacks(0.2)//Just here for the showmanship
			living_target.IgniteMob()
			playsound(living_target,'sound/weapons/sear.ogg', 50, 1)
			addtimer(CALLBACK(src, .proc/AttackRecovery), 5)
			return
	AttackRecovery()

/mob/living/simple_animal/hostile/jungle/seedling/proc/Volley()
	if(combatant_state == SEEDLING_STATE_WARMUP && target)
		combatant_state = SEEDLING_STATE_ACTIVE
		update_icons()
		var/datum/callback/cb = CALLBACK(src, .proc/InaccurateShot)
		var/i
		for(i=0, i<13, i++)
			addtimer(cb, i)
		addtimer(CALLBACK(src, .proc/AttackRecovery), 14)

/mob/living/simple_animal/hostile/jungle/seedling/proc/InaccurateShot()
	if(target && !QDELETED(target) && combatant_state == SEEDLING_STATE_ACTIVE)
		if(get_dist(src,target) <= 3)//If they're close enough just aim straight at them so we don't miss at point blank ranges
			Shoot(target)
			return
		var/turf/our_turf = get_turf(src)
		var/obj/item/projectile/seedling/readied_shot = new /obj/item/projectile/seedling(our_turf)
		readied_shot.current = our_turf
		readied_shot.starting = our_turf
		readied_shot.firer = src
		readied_shot.original = target
		readied_shot.yo = target.y - our_turf.y + rand(-1,1)
		readied_shot.xo = target.x - our_turf.x + rand(-1,1)
		readied_shot.fire()
		playsound(src, projectilesound, 100, 1)

/mob/living/simple_animal/hostile/jungle/seedling/proc/AttackRecovery()
	if(combatant_state == SEEDLING_STATE_ACTIVE)
		combatant_state = SEEDLING_STATE_RECOVERY
		update_icons()
		ranged_cooldown = world.time + ranged_cooldown_time
		if(target)
			face_atom(target)
		if(solar_beam)
			qdel(solar_beam)
			solar_beam = null
		addtimer(CALLBACK(src, .proc/ResetNeutral), 10)

/mob/living/simple_animal/hostile/jungle/seedling/proc/ResetNeutral()
	if(combatant_state != SEEDLING_STATE_REGENERATING)
		combatant_state = SEEDLING_STATE_NEUTRAL
		if(target && !stat)
			update_icons()
			Goto(target, move_to_delay, minimum_distance)

/mob/living/simple_animal/hostile/jungle/seedling/adjustHealth()
	. = ..()
	if(combatant_state == SEEDLING_STATE_ACTIVE && beam_debuff_target)
		beam_debuff_target.remove_status_effect(/datum/status_effect/seedling_beam_indicator)
		beam_debuff_target = null
		AttackRecovery()
	if(health <= 0)
		if(combatant_state == SEEDLING_STATE_REGENERATING)
			return
		if(weak_point && !stat)
			SeedlingStartRegeneration()

/mob/living/simple_animal/hostile/jungle/seedling/update_stat()
	if(combatant_state == SEEDLING_STATE_REGENERATING)
		return
	return ..()

/mob/living/simple_animal/hostile/jungle/seedling/proc/SeedlingStartRegeneration()
	weak_point.loc = get_turf(src)
	weak_point.RandomizeScreenLocation()
	combatant_state = SEEDLING_STATE_REGENERATING
	mouse_opacity = 0
	update_icons()
	walk(src,0)
	wander = FALSE
	addtimer(CALLBACK(src, .proc/SeedlingRegenerate), SEEDLING_REGENERATION_TIME)

/mob/living/simple_animal/hostile/jungle/seedling/proc/SeedlingRegenerate()
	if(weak_point && !QDELETED(weak_point) && combatant_state == SEEDLING_STATE_REGENERATING)
		revive(TRUE)
		mouse_opacity = 1
		weak_point.loc = src
		wander = TRUE
		combatant_state = SEEDLING_STATE_NEUTRAL
		ResetNeutral()

/obj/seedling_weakpoint
	name = "seedling weakpoint"
	anchored = TRUE
	max_integrity = 45
	icon = 'icons/mob/jungle/arachnid.dmi'
	icon_state = "seedling_weakpoint1"
	pixel_x = -16
	pixel_y = -14
	layer = ABOVE_ALL_MOB_LAYER
	var/mob/living/simple_animal/hostile/jungle/seedling/our_seedling

/obj/seedling_weakpoint/Destroy()
	. = ..()
	if(our_seedling && !QDELETED(our_seedling))
		if(!our_seedling.stat)
			our_seedling.combatant_state = SEEDLING_STATE_NEUTRAL
			our_seedling.death()

/obj/seedling_weakpoint/proc/RandomizeScreenLocation()
	var/diceroll = rand(1,3)
	icon_state = "seedling_weakpoint[diceroll]"

/obj/seedling_weakpoint/attackby(obj/item/weapon/W, mob/user, params)
	if(!W.is_sharp())
		to_chat(user, "<span class='danger'>You need something sharp for this!</span>")
		return
	RandomizeScreenLocation()
	return ..()

/obj/seedling_weakpoint/play_attack_sound()
	playsound(src, 'sound/weapons/bladeslice.ogg', 50, 1)

/mob/living/simple_animal/hostile/jungle/seedling/update_stat()
	if(weak_point && !QDELETED(weak_point))
		return
	return ..()

/mob/living/simple_animal/hostile/jungle/seedling/update_icons()
	. = ..()
	if(!stat)
		switch(combatant_state)
			if(SEEDLING_STATE_NEUTRAL)
				icon_state = "seedling"
			if(SEEDLING_STATE_WARMUP)
				icon_state = "seedling_charging"
			if(SEEDLING_STATE_ACTIVE)
				icon_state = "seedling_fire"
			if(SEEDLING_STATE_RECOVERY)
				icon_state = "seedling"
			if(SEEDLING_STATE_REGENERATING)
				icon_state = "seedling_wilting"

/mob/living/simple_animal/hostile/jungle/seedling/GiveTarget()
	if(target)
		if(combatant_state == SEEDLING_STATE_WARMUP || combatant_state == SEEDLING_STATE_ACTIVE)//So it doesn't 180 and blast you in the face while it's firing at someone else
			return
	return ..()

/mob/living/simple_animal/hostile/jungle/seedling/LoseTarget()
	if(combatant_state == SEEDLING_STATE_WARMUP || combatant_state == SEEDLING_STATE_ACTIVE)
		return
	return ..()

/mob/living/simple_animal/hostile/jungle/seedling/death()
	. = ..()
	mouse_opacity = 1
	anchored = FALSE


#undef SEEDLING_STATE_NEUTRAL
#undef SEEDLING_STATE_WARMUP
#undef SEEDLING_STATE_ACTIVE
#undef SEEDLING_STATE_RECOVERY
#undef SEEDLING_STATE_REGENERATING
#undef SEEDLING_REGENERATION_TIME