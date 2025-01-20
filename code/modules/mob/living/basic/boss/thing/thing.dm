#define PHASEREGEN_FILTER "healing_glow"
#define RUIN_QUEUE "the_thing_depleter"
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
	speed = 3.5 //dont make this any faster PLEASE
	gps_name = "L-4 Biohazard Beacon"
	ai_controller = /datum/ai_controller/basic_controller/thing_boss
	loot = list(/obj/item/keycard/thing_boss)
	crusher_loot = list(/obj/item/keycard/thing_boss, /obj/item/crusher_trophy/flesh_glob)
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	/// Current phase of the boss fight
	var/phase = 1
	/// Time the Thing will be invulnerable between phases
	var/phase_invul_time = 10 SECONDS
	/// timer of phase invulnerability between phases
	var/phase_invulnerability_timer

	// ruin logic

	/// if true, this boss may only be killed proper in its ruin by the associated machines as part of the bossfight. Turn off if admin shitspawn
	var/maploaded = TRUE

/mob/living/basic/boss/thing/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/the_thing/decimate = BB_THETHING_DECIMATE,
		/datum/action/cooldown/mob_cooldown/charge/the_thing = BB_THETHING_CHARGE,
		/datum/action/cooldown/mob_cooldown/the_thing/big_tendrils = BB_THETHING_BIGTENDRILS,
		/datum/action/cooldown/mob_cooldown/the_thing/shriek = BB_THETHING_SHRIEK,
		/datum/action/cooldown/mob_cooldown/the_thing/cardinal_tendrils = BB_THETHING_CARDTENDRILS,
		/datum/action/cooldown/mob_cooldown/the_thing/acid_spit = BB_THETHING_ACIDSPIT,
	)
	grant_actions_by_list(innate_actions)
	AddComponent(/datum/component/basic_mob_attack_telegraph, telegraph_duration = 0.3 SECONDS)
	maploaded = mapload
	if(maploaded)
		SSqueuelinks.add_to_queue(src, RUIN_QUEUE, 0)
		return INITIALIZE_HINT_LATELOAD

/mob/living/basic/boss/thing/LateInitialize()
	SSqueuelinks.pop_link(RUIN_QUEUE)

/mob/living/basic/boss/thing/update_icon_state()
	. = ..()
	if(stat)
		icon_state = "dead"
		return
	icon_state = "p[phase]"
	icon_living = icon_state

/mob/living/basic/boss/thing/adjust_health(amount, updating_health = TRUE, forced = FALSE)
	if(phase_invulnerability_timer || phase == 3 || stat || amount <= 0)
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
	if(!maploaded)
		phase_successfully_depleted()
		return
	add_traits(list(TRAIT_GODMODE, TRAIT_IMMOBILIZED), MEGAFAUNA_TRAIT)
	balloon_alert_to_viewers("invulnerable! overload the machines!")
	visible_message(span_danger("[src] drops to the ground staggered, unable to keep up with injuries!"))
	phase_invulnerability_timer = addtimer(CALLBACK(src, PROC_REF(phase_too_slow)), phase_invul_time, TIMER_STOPPABLE|TIMER_UNIQUE)
	add_filter(PHASEREGEN_FILTER, 2, list("type" = "outline", "color" = COLOR_PALE_GREEN, "alpha" = 0, "size" = 1))
	var/filter = get_filter(PHASEREGEN_FILTER)
	animate(filter, alpha = 200, time = 0.5 SECONDS, loop = -1)
	animate(alpha = 0, time = 0.5 SECONDS)
	SEND_SIGNAL(src, COMSIG_MEGAFAUNA_THETHING_PHASEUPDATED)

/// The Thing is successfully hit by incendiary fire while downed by damage (alternatively takes too much damage if not ruin spawned)
/mob/living/basic/boss/thing/proc/phase_successfully_depleted()
	playsound(src, 'sound/effects/pop_expl.ogg', 65)
	ai_controller?.set_blackboard_key(BB_THETHING_NOAOE, FALSE)
	remove_traits(list(TRAIT_GODMODE, TRAIT_IMMOBILIZED), MEGAFAUNA_TRAIT)
	deltimer(phase_invulnerability_timer)
	phase_invulnerability_timer = null
	if(phase < 3) //after phase 3 we literally just die
		phase++
		emote("scream")
	update_appearance()
	var/filter = get_filter(PHASEREGEN_FILTER)
	if(!isnull(filter))
		animate(filter)
		remove_filter(PHASEREGEN_FILTER)
	SEND_SIGNAL(src, COMSIG_MEGAFAUNA_THETHING_PHASEUPDATED)
	new /obj/effect/gibspawner/human/bodypartless(loc)

/mob/living/basic/boss/thing/proc/phase_too_slow()
	phase_invulnerability_timer = null
	remove_traits(list(TRAIT_GODMODE, TRAIT_IMMOBILIZED), MEGAFAUNA_TRAIT)
	balloon_alert_to_viewers("recovers!")
	visible_message(span_danger("[src] recovers from the damage! Too slow!"))
	adjust_health(-(maxHealth/3) * 0.5) //half of a phase (which is a third of maxhealth)
	var/filter = get_filter(PHASEREGEN_FILTER)
	if(!isnull(filter))
		animate(filter)
		remove_filter(PHASEREGEN_FILTER)
	emote("roar")
	SEND_SIGNAL(src, COMSIG_MEGAFAUNA_THETHING_PHASEUPDATED)

/mob/living/basic/boss/thing/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, phase))
		ai_controller?.set_blackboard_key(BB_THETHING_NOAOE, phase > 1 ? FALSE : TRUE)
		update_appearance()

/mob/living/basic/boss/thing/with_ruin_loot
	loot = list(/obj/item/organ/brain/cybernetic/ai) // the main loot of the ruin, but if admin spawned the keycard is useless
	crusher_loot = list(/obj/item/organ/brain/cybernetic/ai, /obj/item/crusher_trophy/flesh_glob)

// special stuff for our ruin to make a cooler bossfight

/obj/structure/thing_boss_phase_depleter
	name = "Molecular Accelerator"
	desc = "Weird-ass lab equipment."
	icon_state = "thingdepleter"
	anchored = TRUE
	density = TRUE
	move_resist = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	/// is this not broken yet
	var/functional = TRUE
	/// boss weakref
	var/datum/weakref/boss_weakref

/obj/structure/thing_boss_phase_depleter/Initialize(mapload)
	. = ..()
	go_in_floor()
	SSqueuelinks.add_to_queue(src, RUIN_QUEUE, 0)

/obj/structure/thing_boss_phase_depleter/MatchedLinks(id, list/partners)
	if(id != RUIN_QUEUE)
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

/obj/structure/thing_boss_phase_depleter/proc/set_circuit_floor(state)
	for(var/turf/open/floor/circuit/circuit in RANGE_TURFS(1, loc))
		circuit.on = state
		circuit.update_appearance()

/obj/structure/thing_boss_phase_depleter/proc/go_in_floor()
	if(!density)
		return
	density = FALSE
	obj_flags &= ~CAN_BE_HIT
	set_circuit_floor(FALSE)
	name = "hatch"
	icon_state = "thingdepleter_infloor"

/obj/structure/thing_boss_phase_depleter/proc/go_out_floor()
	if(density)
		return
	density = TRUE
	obj_flags |= CAN_BE_HIT
	set_circuit_floor(TRUE)
	name = initial(name)
	icon_state = "thingdepleter"
	new /obj/effect/temp_visual/mook_dust(loc)

/obj/structure/thing_boss_phase_depleter/interact(mob/user, list/modifiers)
	var/mob/living/basic/boss/thing/the_thing = boss_weakref?.resolve()
	if(!the_thing || !functional || !density)
		return
	if(!user.can_perform_action(src) || !user.can_interact_with(src))
		return
	balloon_alert_to_viewers("overloading...")
	icon_state = "thingdepleter_overriding"
	if(!do_after(user, 1 SECONDS, target = src))
		if(density)
			icon_state = "thingdepleter"
		return
	new /obj/effect/temp_visual/circle_wave/orange(loc)
	playsound(src, 'sound/effects/explosion/explosion3.ogg', 100)
	animate(src, transform = matrix()*1.5, time = 0.2 SECONDS)
	animate(transform = matrix(), time = 0)
	the_thing.phase_successfully_depleted()
	functional = FALSE
	go_in_floor()
	icon_state = "thingdepleter_overriding"
	addtimer(VARSET_CALLBACK(src, icon_state, "thingdepleter_broken"), 0.2 SECONDS)

/obj/effect/temp_visual/circle_wave/orange
	color = COLOR_ORANGE

/obj/structure/aggro_gate
	name = "biohazard gate"
	desc = "A wall of solid light, only activating when a human is endangered by a biohazard, unfortunately that does little for safety as it locks you in with said biohazard. Virtually indestructible, you must evade (or kill) the threat."
	icon = 'icons/effects/effects.dmi'
	icon_state = "wave2"
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	move_resist = MOVE_FORCE_OVERPOWERING
	opacity = FALSE
	density = FALSE
	invisibility = INVISIBILITY_MAXIMUM
	anchored = TRUE
	/// queue id
	var/queue_id = RUIN_QUEUE
	/// blackboard key for target
	var/target_bb_key = BB_BASIC_MOB_CURRENT_TARGET

/obj/structure/aggro_gate/Initialize(mapload)
	. = ..()
	SSqueuelinks.add_to_queue(src, queue_id)

/obj/structure/aggro_gate/MatchedLinks(id, list/partners)
	if(id != queue_id)
		return
	for(var/mob/living/partner in partners)
		RegisterSignal(partner, COMSIG_AI_BLACKBOARD_KEY_SET(target_bb_key), PROC_REF(bar_the_gates))
		RegisterSignals(partner, list(COMSIG_AI_BLACKBOARD_KEY_CLEARED(target_bb_key), COMSIG_LIVING_DEATH, COMSIG_MOB_LOGIN), PROC_REF(open_gates))

/obj/structure/aggro_gate/proc/bar_the_gates(mob/living/source)
	SIGNAL_HANDLER
	var/atom/target = source.ai_controller?.blackboard[target_bb_key]
	if (QDELETED(target))
		return
	invisibility = INVISIBILITY_NONE
	density = TRUE
	playsound(src, SFX_SPARKS, 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)

/obj/structure/aggro_gate/proc/open_gates(mob/living/source)
	playsound(src, SFX_SPARKS, 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)
	density = FALSE
	invisibility = INVISIBILITY_MAXIMUM

#undef PHASEREGEN_FILTER
#undef RUIN_QUEUE
