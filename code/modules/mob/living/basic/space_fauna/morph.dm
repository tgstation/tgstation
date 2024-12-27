/// The classic morph, Corpus Accipientis (or "The body of the recipient"). It's a blob that can disguise itself as other things simply put.
/mob/living/basic/morph
	name = "morph"
	real_name = "morph"
	desc = "A revolting, pulsating pile of flesh."
	speak_emote = list("gurgles")
	icon = 'icons/mob/simple/animal.dmi'
	icon_state = "morph"
	icon_living = "morph"
	icon_dead = "morph_dead"
	combat_mode = TRUE

	mob_biotypes = MOB_BEAST
	pass_flags = PASSTABLE

	maxHealth = 150
	health = 150
	habitable_atmos = null
	minimum_survivable_temperature = TCMB

	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	melee_attack_cooldown = CLICK_CD_MELEE

	// Oh you KNOW it's gonna be real green
	lighting_cutoff_red = 10
	lighting_cutoff_green = 35
	lighting_cutoff_blue = 15

	attack_verb_continuous = "glomps"
	attack_verb_simple = "glomp"
	attack_sound = 'sound/effects/blob/blobattack.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE //nom nom nom
	butcher_results = list(/obj/item/food/meat/slab = 2)

	ai_controller = /datum/ai_controller/basic_controller/morph

	/// A weakref pointing to the form we are currently assumed as.
	var/datum/weakref/form_weakref = null
	/// A typepath pointing of the form we are currently assumed as. Remember, TYPEPATH!!!
	var/atom/movable/form_typepath = null
	/// The ability that allows us to disguise ourselves.
	var/datum/action/cooldown/mob_cooldown/assume_form/disguise_ability = null

	/// How much damage are we doing while disguised?
	var/melee_damage_disguised = 0
	/// Can we eat while disguised?
	var/eat_while_disguised = FALSE

/mob/living/basic/morph/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	RegisterSignal(src, COMSIG_CLICK_SHIFT, PROC_REF(trigger_ability))
	RegisterSignal(src, COMSIG_ACTION_DISGUISED_APPEARANCE, PROC_REF(on_disguise))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_DISGUISED), PROC_REF(on_undisguise))

	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/content_barfer)

	disguise_ability = new(src)
	disguise_ability.Grant(src)

/mob/living/basic/morph/examine(mob/user)
	if(!HAS_TRAIT(src, TRAIT_DISGUISED))
		return ..()

	var/atom/movable/form_reference = form_weakref.resolve()
	if(!isnull(form_reference))
		. = form_reference.examine(user)

	if(get_dist(user, src) <= 3) // always add this because if the form_reference somehow nulls out we still want to have something look "weird" about an item when someone is close
		. += span_warning("It doesn't look quite right...")

/mob/living/basic/morph/med_hud_set_health()
	if(isliving(form_typepath))
		return ..()

	//we hide medical hud while in regular state or an item
	set_hud_image_state(HEALTH_HUD, null)

/mob/living/basic/morph/med_hud_set_status()
	if(isliving(form_typepath))
		return ..()

	//we hide medical hud while in regular state or an item
	set_hud_image_state(STATUS_HUD, null)

/mob/living/basic/morph/death(gibbed)
	if(HAS_TRAIT(src, TRAIT_DISGUISED))
		visible_message(
			span_warning("[src] twists and dissolves into a pile of green flesh!"),
			span_userdanger("Your skin ruptures! Your flesh breaks apart! No disguise can ward off de--"),
		)

	return ..()

/mob/living/basic/morph/can_track(mob/living/user)
	if(!HAS_TRAIT(src, TRAIT_DISGUISED))
		return FALSE
	return ..()

/// Do some more logic for the morph when we disguise through the action.
/mob/living/basic/morph/proc/on_disguise(mob/living/basic/user, atom/movable/target)
	SIGNAL_HANDLER
	// We are now weaker
	melee_damage_lower = melee_damage_disguised
	melee_damage_upper = melee_damage_disguised
	add_movespeed_modifier(/datum/movespeed_modifier/morph_disguised)

	med_hud_set_health()
	med_hud_set_status() //we're an object honest

	visible_message(
		span_warning("[src] suddenly twists and changes shape, becoming a copy of [target]!"),
		span_notice("You twist your body and assume the form of [target]."),
	)

	form_weakref = WEAKREF(target)
	form_typepath = target.type

/// Do some more logic for the morph when we undisguise through the action.
/mob/living/basic/morph/proc/on_undisguise()
	SIGNAL_HANDLER
	visible_message(
		span_warning("[src] suddenly collapses in on itself, dissolving into a pile of green flesh!"),
		span_notice("You reform to your normal body."),
	)

	//Baseline stats
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	remove_movespeed_modifier(/datum/movespeed_modifier/morph_disguised)

	med_hud_set_health()
	med_hud_set_status() //we are no longer an object

	form_weakref = null
	form_typepath = null

/// Alias for the disguise ability to be used as a keybind.
/mob/living/basic/morph/proc/trigger_ability(mob/living/basic/source, atom/target)
	SIGNAL_HANDLER

	// linters hate this if it's not async for some reason even though nothing blocks
	INVOKE_ASYNC(disguise_ability, TYPE_PROC_REF(/datum/action/cooldown, InterceptClickOn), clicker = source, target = target)
	return COMSIG_MOB_CANCEL_CLICKON

/// Handles the logic for attacking anything.
/mob/living/basic/morph/early_melee_attack(atom/target, list/modifiers, ignore_cooldown)
	. = ..()
	if(!.)
		return FALSE

	if(HAS_TRAIT(src, TRAIT_DISGUISED) && (melee_damage_disguised <= 0))
		balloon_alert(src, "can't attack while disguised!")
		return FALSE

	if(isliving(target)) //Eat Corpses to regen health
		var/mob/living/living_target = target
		if(living_target.stat != DEAD)
			return TRUE

		eat(eatable = living_target, delay = 3 SECONDS, update_health = -50)
		return FALSE

	if(!isitem(target)) //Eat items just to be annoying
		return TRUE

	var/obj/item/item_target = target
	if(item_target.anchored)
		return TRUE
	eat(eatable = item_target, delay = 2 SECONDS)
	return FALSE

/// Eat stuff. Delicious. Return TRUE if we ate something, FALSE otherwise.
/// Required: `eatable` is the thing (item or mob) that we are going to eat.
/// Optional: `delay` is the applicable time-based delay to pass into `do_after()` before the logic is ran.
/// Optional: `update_health` is an integer that will be added (or maybe subtracted if you're cruel) to our health after we eat something. Passed into `adjust_health()` so make sure what you pass in is accurate.
/mob/living/basic/morph/proc/eat(atom/movable/eatable, delay = 0 SECONDS, update_health = 0)
	if(QDELETED(eatable) || eatable.loc == src)
		return FALSE

	if(HAS_TRAIT(src, TRAIT_DISGUISED) && !eat_while_disguised)
		balloon_alert(src, "can't eat while disguised!")
		return FALSE

	balloon_alert(src, "eating...")
	if((delay > 0 SECONDS) && !do_after(src, delay, target = eatable))
		return FALSE

	visible_message(span_warning("[src] swallows [eatable] whole!"))
	eatable.forceMove(src)
	if(update_health != 0)
		adjust_health(update_health)

	return TRUE

/// No fleshed out AI implementation, just something that make these fellers seem lively if they're just dropped into a station.
/// Only real human-powered intelligence is capable of playing prop hunt in SS13 (until further notice).
/datum/ai_controller/basic_controller/morph
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
	)

	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk

	planning_subtrees = list(
		/datum/ai_planning_subtree/target_retaliate,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)
