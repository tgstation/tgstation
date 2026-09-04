/obj/item/knife/butcher/heretic
	name = "\improper Crimson Cleaver"
	desc = "A cleaver with an intricately designed red handle and slightly curved back. A tool of war, rather than cooking, no doubt."
	icon = 'icons/obj/weapons/khopesh.dmi'
	force = 20
	throwforce = 20
	wound_bonus = 30
	exposed_wound_bonus = 0
	toolspeed = 0.25
	armour_penetration = 50
	throw_speed = 4
	throw_range = 7

	COOLDOWN_DECLARE(lifesteal_cd)

	var/boomerange_range = 5
	var/boomerang_examine = ""

/obj/item/knife/butcher/heretic/Initialize(mapload)
	. = ..()
	add_lifesteal_filter()
	boomerang_examine ||= span_mansus("[src]'s blade is curved so subtly, that it may return to your hand when thrown...")
	AddComponent(/datum/component/boomerang, boomerange_range, FALSE, boomerang_examine)

/obj/item/knife/butcher/heretic/equipped(mob/living/user, slot, initial)
	. = ..()
	if(!isliving(user))
		return
	if(IS_HERETIC_OR_MONSTER(user))
		AddComponent(/datum/component/boomerang, boomerange_range, TRUE, boomerang_examine)
	else
		AddComponent(/datum/component/boomerang, boomerange_range, FALSE, boomerang_examine)
		user.apply_status_effect(/datum/status_effect/crimson_cleaver_curse)

/obj/item/knife/butcher/heretic/proc/add_lifesteal_filter()
	add_filter("lifesteal_filter", 1.5, outline_filter(1.5, LIGHT_COLOR_BLOOD_MAGIC))
	var/the_filter = get_filter("lifesteal_filter")
	animate(the_filter, alpha = 0) // start at 0 alpha
	animate(the_filter, alpha = 150, time = 3 SECONDS, loop = -1, easing = SINE_EASING) // fade in and out
	animate(alpha = 50, time = 3 SECONDS, loop = -1, easing = SINE_EASING)

/obj/item/knife/butcher/heretic/proc/remove_lifesteal_filter()
	var/the_filter = get_filter("lifesteal_filter")
	animate(the_filter, alpha = 0, time = 1 SECONDS, easing = SINE_EASING)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/datum, remove_filter), "lifesteal_filter"), 2 SECONDS)

/obj/item/knife/butcher/heretic/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	var/mob/living/thrower = throwingdatum?.get_thrower()
	if(!isliving(hit_atom) || !isliving(thrower) || hit_atom == thrower || !COOLDOWN_FINISHED(src, lifesteal_cd))
		return

	lifesteal(hit_atom, thrower, coefficient = 0.75, amount = throwforce)

/obj/item/knife/butcher/heretic/proc/lifesteal(mob/living/target, mob/living/user, coefficient = 1, amount = force)
	if(target == user)
		CRASH("[type] attempted to lifesteal from one guy to themselves")

	// you can brutalize corpses a little bit, but don't go too crazy
	if(target.stat == DEAD && target.get_brute_loss() > target.maxHealth * 2)
		return

	if(user.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY, charge_cost = (coefficient < 1 ? 0 : 1)) )
		start_lifesteal_cd(6 SECONDS)
		if(coefficient < 1)
			if(IS_HERETIC_OR_MONSTER(user))
				to_chat(user, span_warning("You fail to unleash the energies within [src] - something is suppressing it!"))
			else
				to_chat(user, span_warning("Some evil energy attempts to escape from [src], but you suppress it!"))
		return

	if(target.can_block_magic(MAGIC_RESISTANCE, charge_cost = 1))
		start_lifesteal_cd(8 SECONDS)
		if(IS_HERETIC_OR_MONSTER(user))
			to_chat(user, span_warning("Your attempt to siphon the life force of [target] is resisted!"))
		else
			to_chat(user, span_warning("Some evil energy attempts to flow into [target], but they resist it!"))
		return

	user.adjust_brute_loss(-0.5 * coefficient * amount)
	user.adjust_nutrition(0.75 * coefficient * amount)
	target.transfer_blood_to(user, coefficient * amount, ignore_low_blood = TRUE, ignore_incompatibility = TRUE, transfer_viruses = FALSE)
	target.adjust_nutrition(-0.75 * coefficient * amount)
	to_chat(target, span_warning("You feel your life force drain away..."))
	new /obj/effect/temp_visual/cleave(get_turf(target))

	for(var/datum/wound/active_wound as anything in astype(user, /mob/living/carbon)?.all_wounds)
		if(active_wound.blood_flow)
			active_wound.adjust_blood_flow(-0.1 * coefficient * amount)

	start_lifesteal_cd(10 SECONDS)

	// using the power satiates the curse
	if(!IS_HERETIC_OR_MONSTER(user))
		var/datum/status_effect/crimson_cleaver_curse/curse = user.has_status_effect(/datum/status_effect/crimson_cleaver_curse)
		curse?.curse_timer -= ceil(4 * coefficient)
		user.mob_mood?.direct_sanity_drain(-0.5 * coefficient * amount)

/obj/item/knife/butcher/heretic/proc/start_lifesteal_cd(duration = 10 SECONDS)
	if(!COOLDOWN_FINISHED(src, lifesteal_cd))
		return // if cooldown is already running, that's fine, but don't reset it

	COOLDOWN_START(src, lifesteal_cd, duration)
	remove_lifesteal_filter()
	addtimer(CALLBACK(src, PROC_REF(add_lifesteal_filter)), duration)

/obj/item/knife/butcher/heretic/afterattack(atom/target, mob/user, list/modifiers, list/attack_modifiers)
	if(!isliving(target) || !isliving(user) || target == user)
		return

	var/is_cleaving = LAZYACCESS(attack_modifiers, "cleave")
	if(is_cleaving || COOLDOWN_FINISHED(src, lifesteal_cd))
		lifesteal(target, user, coefficient = (is_cleaving ? 0.5 : 1), amount = LAZYACCESS(attack_modifiers, DAMAGE_DONE))

	if(is_cleaving)
		return

	// attacking satisfies the curse
	if(!IS_HERETIC_OR_MONSTER(user))
		var/datum/status_effect/crimson_cleaver_curse/curse = user.has_status_effect(/datum/status_effect/crimson_cleaver_curse)
		curse?.curse_timer -= (is_cleaving ? 2 : 1)

	var/turf/dir_to_target = get_dir(user, target)
	var/turf/left_turf = get_step(target, turn(dir_to_target, 90))
	var/turf/right_turf = get_step(target, turn(dir_to_target, -90))

	LAZYSET(attack_modifiers, "cleave", TRUE)
	if(isopenturf(target.loc))
		cleave_attack(target.loc, user, modifiers, attack_modifiers, list(target))
	if(isopenturf(left_turf))
		cleave_attack(left_turf, user, modifiers, attack_modifiers)
	if(isopenturf(right_turf))
		cleave_attack(right_turf, user, modifiers, attack_modifiers)

/obj/item/knife/butcher/heretic/proc/cleave_attack(turf/open/cleaving_over, mob/user, list/modifiers, list/attack_modifiers, list/blacklist_targets)
	var/list/attack_pool = list()
	// Collect viable mobs
	for(var/mob/living/cleaved in cleaving_over)
		if(cleaved.invisibility > user.see_invisible || !cleaved.IsReachableBy(user, reach) || (cleaved in blacklist_targets))
			continue
		attack_pool += cleaved
	// Sort by health, most damaged first
	sortTim(attack_pool, GLOBAL_PROC_REF(cmp_mob_health))
	// Attack the first valid mob in the pool
	for(var/mob/living/cleaved in attack_pool)
		melee_attack_chain(user, cleaved, modifiers, attack_modifiers)
		return

/datum/status_effect/crimson_cleaver_curse
	id = "crimson_cleaver_curse"
	alert_type = null
	remove_on_fullheal = TRUE
	/// Counter for the curse's progression
	VAR_FINAL/curse_timer = 0
	/// Tracks the level the curse is at
	VAR_PRIVATE/curse_level = 0

/datum/status_effect/crimson_cleaver_curse/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equipped_item))
	RegisterSignal(owner, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_unequipped_item))

/datum/status_effect/crimson_cleaver_curse/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_EQUIPPED_ITEM)
	UnregisterSignal(owner, COMSIG_MOB_UNEQUIPPED_ITEM)

	for(var/obj/item/knife/butcher/heretic/cleaver in owner)
		REMOVE_TRAIT(cleaver, TRAIT_NODROP, TRAIT_STATUS_EFFECT(id))

	owner.clear_mood_event(id)
	owner.clear_mood_event("[id]_lost")
	owner.remove_status_effect(/datum/status_effect/forced_combat)
	owner.remove_traits(list(
		TRAIT_BATON_RESISTANCE,
		TRAIT_DISCOORDINATED_TOOL_USER,
		TRAIT_EASYBLEED,
		TRAIT_FLESH_DESIRE,
		TRAIT_NOGUNS,
		TRAIT_UNNATURAL_RED_GLOWY_EYES,
		TRAIT_VORACIOUS,
	), TRAIT_STATUS_EFFECT(id))
	astype(owner, /mob/living/carbon/human)?.remove_eye_color(EYE_COLOR_CULTLIKE_PRIORITY)

/datum/status_effect/crimson_cleaver_curse/update_particles()
	if(curse_level < 3)
		QDEL_NULL(particle_effect)
		return

	particle_effect ||= new(owner, /particles/crimson_curse)
	particle_effect.alpha = 200

/datum/status_effect/crimson_cleaver_curse/proc/on_equipped_item(datum/source, obj/item/equipped, ...)
	SIGNAL_HANDLER

	if(istype(equipped, /obj/item/knife/butcher/heretic) && curse_level >= 3)
		ADD_TRAIT(equipped, TRAIT_NODROP, TRAIT_STATUS_EFFECT(id))

	for(var/obj/item/knife/butcher/heretic/cleaver in owner)
		if(cleaver != equipped)
			return

	switch(curse_level)
		if(2)
			to_chat(owner, span_mansus("You feel pleased that the cleaver has returned to your hand."))
			owner.add_mood_event("[id]_lost", /datum/mood_event/crimson_curse/reunited/low)

		if(3)
			to_chat(owner, span_hypnophrase("The cleaver is back! Time to get to work!"))
			owner.add_mood_event("[id]_lost", /datum/mood_event/crimson_curse/reunited/medium)

		if(4)
			to_chat(owner, span_hypnophrase("YES! THERE IS STILL BLOOD TO BE SPILT!"))
			owner.add_mood_event("[id]_lost", /datum/mood_event/crimson_curse/reunited/severe)

/datum/status_effect/crimson_cleaver_curse/proc/on_unequipped_item(datum/source, obj/item/unequipped, ...)
	SIGNAL_HANDLER

	if(istype(unequipped, /obj/item/knife/butcher/heretic) && curse_level >= 3)
		REMOVE_TRAIT(unequipped, TRAIT_NODROP, TRAIT_STATUS_EFFECT(id))

	for(var/obj/item/knife/butcher/heretic/cleaver in owner)
		if(cleaver != unequipped)
			return

	switch(curse_level)
		if(2)
			to_chat(owner, span_mansus("You feel reluctant to part with the cleaver."))
			owner.add_mood_event("[id]_lost", /datum/mood_event/crimson_curse/separated/low)

		if(3)
			to_chat(owner, span_hypnophrase("No! The cleaver! How will I satiate myself now?!"))
			owner.add_mood_event("[id]_lost", /datum/mood_event/crimson_curse/separated/medium)

		if(4)
			to_chat(owner, span_hypnophrase("MY TOOL! MY WEAPON! IT HAS BEEN WRESTED FROM ME! I MUST HAVE IT BACK!"))
			owner.add_mood_event("[id]_lost", /datum/mood_event/crimson_curse/separated/severe)

/datum/status_effect/crimson_cleaver_curse/tick(seconds_between_ticks)
	var/curse_ticking = FALSE
	for(var/obj/item/knife/butcher/heretic/cleaver in owner)
		// it's clearly mind based, and it's clearly magical, and it's clearly unholy. so everything fits
		if(owner.can_block_magic(ALL_MAGIC_RESISTANCE, charge_cost = SPT_PROB(50, seconds_between_ticks) ? 1 : 0))
			to_chat(owner, span_notice("The cleaver thrums ominously."))
		else
			curse_timer += seconds_between_ticks
			curse_ticking = TRUE

	if(!curse_ticking)
		curse_timer -= seconds_between_ticks
		if(curse_timer <= 0)
			qdel(src)
		return

	if(curse_timer > 10)
		if(curse_level < 1)
			curse_level = 1
			to_chat(owner, span_mansus("The cleaver sits firmly in your hand. It feels unnaturally well balanced - it would be a joy to swing."))
			owner.add_mood_event(id, /datum/mood_event/crimson_curse/low)
			return
	else
		if(curse_level == 1)
			curse_level = 0
			to_chat(owner, span_mansus("Your mind clears. The cleaver still sits in your hand. It unsettles you."))
			owner.clear_mood_event(id)
			return

	if(curse_timer > 30)
		if(curse_level < 2)
			curse_level = 2
			to_chat(owner, span_mansus("The cleaver starts to feel heavy in your hand. You feel like bringing it down. Hard."))
			owner.add_mood_event(id, /datum/mood_event/crimson_curse/medium)
			return
	else
		if(curse_level == 2)
			curse_level = 1
			to_chat(owner, span_mansus("The cleaver starts to slip from your hand. Your grip is no longer as sure as it was."))
			owner.clear_mood_event(id)
			return

	if(curse_timer > 60)
		if(curse_level < 3)
			curse_level = 3
			to_chat(owner, span_mansus("The cleaver was made to spill blood and cleave flesh. You grip it with all your life, compelled to fulfill its purpose."))
			owner.add_mood_event(id, /datum/mood_event/crimson_curse/severe)
			for(var/obj/item/knife/butcher/heretic/cleaver in owner)
				ADD_TRAIT(src, TRAIT_NODROP, TRAIT_STATUS_EFFECT(id))

			owner.add_traits(list(
				TRAIT_BATON_RESISTANCE,
				TRAIT_DISCOORDINATED_TOOL_USER,
				TRAIT_EASYBLEED,
				TRAIT_FLESH_DESIRE,
				TRAIT_NOGUNS,
				TRAIT_UNNATURAL_RED_GLOWY_EYES,
				TRAIT_VORACIOUS,
			), TRAIT_STATUS_EFFECT(id))
			astype(owner, /mob/living/carbon/human)?.add_eye_color(BLOODCULT_EYE, EYE_COLOR_CULTLIKE_PRIORITY)
			curse_timer += 10 // little buffer
			update_particles()
			return

		if(SPT_PROB(30, seconds_between_ticks))
			owner.adjust_nutrition(-10 * HUNGER_FACTOR)
			owner.overeatduration = max(owner.overeatduration - 200 SECONDS, 0)
			if(prob(33))
				to_chat(owner, span_notice(pick(
					"The cleaver yearns to cut.",
					"The hunger pangs are back...",
					"You can't stop thinking about meat...",
					"You hunger for flesh.",
				)))
		if(SPT_PROB(10, seconds_between_ticks))
			owner.adjust_hallucinations_up_to(6 SECONDS, 60 SECONDS)
		if(SPT_PROB(20, seconds_between_ticks))
			owner.adjust_jitter_up_to(4 SECONDS, 30 SECONDS)
			owner.adjust_staggered_up_to(2 SECONDS, 10 SECONDS)
		if(SPT_PROB(20, seconds_between_ticks))
			owner.adjust_eye_blur_up_to(2 SECONDS, 30 SECONDS)

	else
		if(curse_level == 3)
			curse_level = 2
			to_chat(owner, span_mansus("The cleaver's compulsions fade. Your fingers unclench from the hilt."))
			owner.clear_mood_event(id)
			for(var/obj/item/knife/butcher/heretic/cleaver in owner)
				REMOVE_TRAIT(src, TRAIT_NODROP, TRAIT_STATUS_EFFECT(id))

			owner.remove_status_effect(/datum/status_effect/eldritch_painting/desire)
			owner.remove_traits(list(
				TRAIT_BATON_RESISTANCE,
				TRAIT_DISCOORDINATED_TOOL_USER,
				TRAIT_EASYBLEED,
				TRAIT_FLESH_DESIRE,
				TRAIT_NOGUNS,
				TRAIT_UNNATURAL_RED_GLOWY_EYES,
				TRAIT_VORACIOUS,
			), TRAIT_STATUS_EFFECT(id))
			astype(owner, /mob/living/carbon/human)?.remove_eye_color(EYE_COLOR_CULTLIKE_PRIORITY)
			update_particles()
			return

	if(curse_timer > 120)
		if(curse_level < 4)
			curse_level = 4
			to_chat(owner, span_mansus("The cleaver is an extension of you. It is a tool to rend flesh from bone. You are a tool to rend flesh from bone."))
			to_chat(owner, span_hypnophrase("Swing it. Swing it now."))
			owner.add_mood_event(id, /datum/mood_event/crimson_curse/extreme)
			owner.apply_status_effect(/datum/status_effect/forced_combat, INFINITY)
			curse_timer += 20 // medium buffer
			return

	else
		if(curse_level == 4)
			curse_level = 3
			to_chat(owner, span_mansus("You return to your senses. Or have you truly? The cleaver is still in your hands."))
			owner.clear_mood_event(id)
			owner.remove_status_effect(/datum/status_effect/forced_combat)
			return

/datum/mood_event/crimson_curse/low
	description = "What a strange cleaver."

/datum/mood_event/crimson_curse/medium
	description = "It'd be pretty nice to swing that cleaver around."
	mood_change = -2

/datum/mood_event/crimson_curse/severe
	description = "I feel a hunger that only the cleaver can sate."
	mood_change = -4

/datum/mood_event/crimson_curse/extreme
	description = "SWING! SWING! SWING!"
	mood_change = -8
	special_screen_obj = "mood_despair"

/datum/mood_event/crimson_curse/separated
	timeout = 6 MINUTES

/datum/mood_event/crimson_curse/separated/low
	description = "I think I need the cleaver back."
	mood_change = -5

/datum/mood_event/crimson_curse/separated/medium
	description = "I need the cleaver back. I don't think I can live without it."
	mood_change = -12

/datum/mood_event/crimson_curse/separated/severe
	description = "I HAVE BEEN SEPARATED FROM MY TOOL! I MUST HAVE IT BACK!"
	mood_change = -48
	special_screen_obj = "mood_despair"

/datum/mood_event/crimson_curse/reunited
	timeout = 1 MINUTES

/datum/mood_event/crimson_curse/reunited/low
	description = "I feel a little better now that I have the cleaver back."
	mood_change = 2

/datum/mood_event/crimson_curse/reunited/medium
	description = "The cleaver is back in my hands. Time to get to work!"
	mood_change = 6

/datum/mood_event/crimson_curse/reunited/severe
	description = "My tool, my weapon, my body! I feel whole again!"
	mood_change = 12

/particles/crimson_curse
	icon = 'icons/effects/particles/echo.dmi'
	icon_state = list("echo1" = 3, "echo2" = 1, "echo3" = 1)
	width = 40
	height = 80
	count = 100
	spawning = 1
	lifespan = 1.5 SECONDS
	fade = 1 SECONDS
	friction = 0.5
	position = generator(GEN_SPHERE, 12, 12, NORMAL_RAND)
	drift = generator(GEN_VECTOR, list(-1, 1), list(1, 1), NORMAL_RAND)
	color = LIGHT_COLOR_BLOOD_MAGIC
