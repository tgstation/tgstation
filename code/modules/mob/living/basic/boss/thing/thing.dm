/mob/living/basic/boss/thing
	name = "\improper Thing"
	icon = 'icons/mob/simple/icemoon/thething.dmi'
	icon_state = "p1"
	icon_dead = "dead"
	gender = NEUTER
	maxHealth = 1800 //nicely divisible by three
	health = 1800
	armour_penetration = 40
	melee_damage_lower = 30
	melee_damage_upper = 30
	sharpness = SHARP_EDGED
	melee_attack_cooldown = CLICK_CD_SLOW
	attack_verb_continuous = "eviscerates"
	attack_verb_simple = "eviscerate"
	attack_sound = 'sound/items/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_SLASH
	speed = 3.5 //holy fuck never make this lower its stupid lethal even on p1 with that speed and i havent even added aoe AI yet
	ai_controller = /datum/ai_controller/basic_controller/thing_boss
	/// Current phase of the boss fight
	var/phase = 1
	/// Time the Thing will be invulnerable between phases
	var/phase_invul_time = 10 SECONDS
	/// timer of phase invulnerability between phases
	var/phase_invulnerability_timer

	// ruin logic

	/// if true, this boss may only be killed proper in its ruin by the associated machines as part of the bossfight. Turn off if admin shitspawn
	var/ruin_spawned = TRUE
	/// ruin queue id for the phase depleters if ruin spawned
	var/ruin_queue_id = "the_thing_depleter"

/mob/living/basic/boss/thing/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/the_thing/decimate = BB_THETHING_DECIMATE,
		/datum/action/cooldown/mob_cooldown/charge/the_thing = BB_THETHING_CHARGE,
		/datum/action/cooldown/mob_cooldown/the_thing/big_tendrils = BB_THETHING_BIGTENDRILS,
		/datum/action/cooldown/mob_cooldown/the_thing/shriek = BB_THETHING_SHRIEK,
		/datum/action/cooldown/mob_cooldown/the_thing/cardinal_tendrils = BB_THETHING_CARDTENDRILS,
	)
	grant_actions_by_list(innate_actions)
	AddComponent(/datum/component/basic_mob_attack_telegraph, telegraph_duration = 0.5 SECONDS)
	if(ruin_spawned)
		SSqueuelinks.add_to_queue(src, ruin_queue_id, 0)
		return INITIALIZE_HINT_LATELOAD

/mob/living/basic/boss/thing/LateInitialize()
	. = ..()
	SSqueuelinks.pop_link(ruin_queue_id)

/mob/living/basic/boss/thing/update_icon_state()
	. = ..()
	if(stat)
		icon_state = "dead"
		return
	icon_state = "p[phase][!isnull(phase_invulnerability_timer) ? "-invul" : ""]"
	icon_living = icon_state

/mob/living/basic/boss/thing/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	if(!ruin_spawned || phase_invulnerability_timer || phase == 3 || stat || amount <= 0)
		return ..()
	var/potential_excess = bruteloss + amount - (maxHealth/3)*phase
	if(potential_excess > 0)
		amount -= potential_excess
	. = ..()
	if(bruteloss >= (maxHealth/3)*phase)
		phase_health_depleted()

/mob/living/basic/boss/thing/proc/phase_health_depleted()
	if(phase_invulnerability_timer)
		return //wtf?
	if(!ruin_spawned)
		phase_successfully_depleted()
		return
	ADD_TRAIT(src, TRAIT_GODMODE, MEGAFAUNA_TRAIT)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT)
	balloon_alert_to_viewers("weakened! use the cannons!")
	visible_message(span_danger("[src] drops to the ground staggered, unable to keep up with injuries!"))
	phase_invulnerability_timer = addtimer(CALLBACK(src, PROC_REF(phase_too_slow)), phase_invul_time, TIMER_STOPPABLE|TIMER_UNIQUE)
	update_appearance()
	SEND_SIGNAL(src, COMSIG_MEGAFAUNA_THETHING_PHASEUPDATED)

/// The Thing is successfully hit by incendiary fire while downed by damage (alternatively takes too much damage if not ruin spawned)
/mob/living/basic/boss/thing/proc/phase_successfully_depleted()
	playsound(src, 'sound/effects/pop_expl.ogg', 65)
	ai_controller?.set_blackboard_key(BB_THETHING_NOAOE, FALSE)
	REMOVE_TRAIT(src, TRAIT_GODMODE, MEGAFAUNA_TRAIT)
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT)
	deltimer(phase_invulnerability_timer)
	phase_invulnerability_timer = null
	if(phase < 3) //after phase 3 we literally just die
		phase++
		emote("scream")
	update_appearance()
	SEND_SIGNAL(src, COMSIG_MEGAFAUNA_THETHING_PHASEUPDATED)

/mob/living/basic/boss/thing/proc/phase_too_slow()
	phase_invulnerability_timer = null
	REMOVE_TRAIT(src, TRAIT_GODMODE, MEGAFAUNA_TRAIT)
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, MEGAFAUNA_TRAIT)
	balloon_alert_to_viewers("recovers!")
	visible_message(span_danger("[src] recovers from the damage! Too slow!"))
	adjust_health(-(maxHealth/3) * 0.5) //half of a phase (which is a third of maxhealth)
	update_appearance()
	emote("roar")
	SEND_SIGNAL(src, COMSIG_MEGAFAUNA_THETHING_PHASEUPDATED)

/mob/living/basic/boss/thing/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, phase))
		ai_controller?.set_blackboard_key(BB_THETHING_NOAOE, phase > 1 ? FALSE : TRUE)
		update_appearance()

/mob/living/basic/boss/thing/admin_spawn
	ruin_spawned = FALSE

/obj/structure/thing_boss_phase_depleter
	name = "Molecular Accelerator"
	desc = "Weird-ass lab equipment."
	icon_state = "" //todo sprites
	anchored = TRUE
	density = FALSE
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// is this not broken yet
	var/functional = TRUE
	/// queue id
	var/queue_id = "the_thing_depleter"
	/// boss weakref
	var/datum/weakref/boss_weakref

/obj/structure/thing_boss_phase_depleter/Initialize(mapload)
	. = ..()
	go_in_floor()
	SSqueuelinks.add_to_queue(src, queue_id, 0)

/obj/structure/thing_boss_phase_depleter/MatchedLinks(id, list/partners)
	if(id != queue_id)
		return
	var/mob/living/basic/boss/thing/thing = locate() in partners
	if(isnull(thing))
		qdel(src)
		return
	boss_weakref = WEAKREF(thing)
	RegisterSignal(thing, COMSIG_MEGAFAUNA_THETHING_PHASEUPDATED, PROC_REF(thing_phaseupdated))

/obj/structure/thing_boss_phase_depleter/proc/thing_phaseupdated(mob/living/basic/boss/thing/source)
	SIGNAL_HANDLER
	if(!functional)
		return
	if(source.phase_invulnerability_timer)
		go_out_floor()
	else
		go_in_floor()

/obj/structure/thing_boss_phase_depleter/examine(mob/user)
	. = ..()
	. += density ? span_boldnotice("It may be possible to overload this and destroy that things defenses...") : span_bolddanger("The machine is currently being restrained by tendrils.")

/obj/structure/thing_boss_phase_depleter/update_icon_state()
	. = ..()
	if(!functional)
		icon_state = ""
		return
	icon_state = density ? "" : ""

/obj/structure/thing_boss_phase_depleter/proc/set_circuit_floor(state)
	for(var/turf/open/floor/circuit/circuit in RANGE_TURFS(1, loc))
		circuit.on = state
		circuit.update_appearance()

/obj/structure/thing_boss_phase_depleter/proc/go_in_floor()
	if(!density)
		return
	density = FALSE
	//lights and messages maybe
	obj_flags &= ~CAN_BE_HIT
	update_appearance(UPDATE_ICON)
	set_circuit_floor(FALSE)

/obj/structure/thing_boss_phase_depleter/proc/go_out_floor()
	if(density)
		return
	density = TRUE
	//lights and messages maybe
	update_appearance(UPDATE_ICON)
	obj_flags |= CAN_BE_HIT
	set_circuit_floor(TRUE)

/obj/structure/thing_boss_phase_depleter/interact(mob/user, list/modifiers)
	var/mob/living/basic/boss/thing/the_thing = boss_weakref?.resolve()
	if(!the_thing || !functional || !density)
		return
	if(!user.can_perform_action(src) || !user.can_interact_with(src))
		return
	balloon_alert_to_viewers("overloading...")
	if(!do_after(user, 1 SECONDS, target = src))
		return
	new /obj/effect/temp_visual/circle_wave/orange(loc)
	playsound(src, 'sound/effects/explosion/explosion3.ogg', 100)
	the_thing.phase_successfully_depleted()
	functional = FALSE
	go_in_floor()

/obj/effect/temp_visual/circle_wave/orange
	color = COLOR_ORANGE
