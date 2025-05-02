/// Left behind when a legion infects you, for medical enrichment
/obj/item/organ/legion_tumour
	name = "legion tumour"
	desc = "A mass of pulsing flesh and dark tendrils, containing the power to regenerate flesh at a terrible cost."
	failing_desc = "pulses and writhes with horrible life, reaching towards you with its tendrils!"
	icon = 'icons/obj/medical/organs/mining_organs.dmi'
	icon_state = "legion_remains"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_PARASITE_EGG
	organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS
	decay_factor = STANDARD_ORGAN_DECAY * 3 // About 5 minutes outside of a host
	/// What stage of growth the corruption has reached.
	var/stage = 0
	/// We apply this status effect periodically or when used on someone
	var/applied_status = /datum/status_effect/regenerative_core
	/// How long have we been in this stage?
	var/elapsed_time = 0 SECONDS
	/// How long does it take to advance one stage?
	var/growth_time = 80 SECONDS // Long enough that if you go back to lavaland without realising it you're not totally fucked
	/// What kind of mob will we transform into?
	var/spawn_type = /mob/living/basic/mining/legion
	/// Spooky sounds to play as you start to turn
	var/static/list/spooky_sounds = list(
		'sound/mobs/non-humanoids/hiss/lowHiss1.ogg',
		'sound/mobs/non-humanoids/hiss/lowHiss2.ogg',
		'sound/mobs/non-humanoids/hiss/lowHiss3.ogg',
		'sound/mobs/non-humanoids/hiss/lowHiss4.ogg',
	)

/obj/item/organ/legion_tumour/Initialize(mapload)
	. = ..()
	animate_pulse()

/obj/item/organ/legion_tumour/apply_organ_damage(damage_amount, maximum, required_organ_flag)
	var/was_failing = organ_flags & ORGAN_FAILING
	. = ..()
	if (was_failing != (organ_flags & ORGAN_FAILING))
		animate_pulse()

/obj/item/organ/legion_tumour/set_organ_damage(damage_amount, required_organ_flag)
	. = ..()
	animate_pulse()

/// Do a heartbeat animation depending on if we're failing or not
/obj/item/organ/legion_tumour/proc/animate_pulse()
	animate(src, transform = matrix()) // Stop any current animation

	var/speed_divider = organ_flags & ORGAN_FAILING ? 2 : 1

	animate(src, transform = matrix().Scale(1.1), time = 0.5 SECONDS / speed_divider, easing = SINE_EASING | EASE_OUT, loop = -1, flags = ANIMATION_PARALLEL)
	animate(transform = matrix(), time = 0.5 SECONDS / speed_divider, easing = SINE_EASING | EASE_IN)
	animate(transform = matrix(), time = 2 SECONDS / speed_divider)

/obj/item/organ/legion_tumour/Remove(mob/living/carbon/egg_owner, special, movement_flags)
	. = ..()
	stage = 0
	elapsed_time = 0

/obj/item/organ/legion_tumour/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	owner.log_message("has received [src] which will eventually turn them into a Legion.", LOG_VICTIM)

/obj/item/organ/legion_tumour/attack(mob/living/target, mob/living/user, params)
	if (try_apply(target, user))
		qdel(src)
		return
	return ..()

/// Smear it on someone like a regen core, why not. Make sure they're alive though.
/obj/item/organ/legion_tumour/proc/try_apply(mob/living/target, mob/user)
	if(!user.Adjacent(target) || !isliving(target))
		return FALSE

	if (target.stat <= SOFT_CRIT && !(organ_flags & ORGAN_FAILING))
		target.add_mood_event("legion_core", /datum/mood_event/healsbadman)
		target.apply_status_effect(applied_status)

		if (target != user)
			target.visible_message(span_notice("[user] splatters [target] with [src]... Disgusting tendrils pull [target.p_their()] wounds shut!"))
		else
			to_chat(user, span_notice("You smear [src] on yourself. Disgusting tendrils pull your wounds closed."))
		return TRUE

	if (!ishuman(target))
		return FALSE

	log_combat(user, target, "used a Legion Tumour on", src, "as they are in crit, this will turn them into a Legion.")
	target.visible_message(span_boldwarning("[user] splatters [target] with [src]... and it springs into horrible life!"))
	var/mob/living/basic/legion_brood/skull = new(target.loc)
	skull.melee_attack(target)
	return TRUE

/obj/item/organ/legion_tumour/on_life(seconds_per_tick, times_fired)
	. = ..()
	if (QDELETED(src) || QDELETED(owner))
		return

	if (stage >= 2)
		if(SPT_PROB(stage / 5, seconds_per_tick))
			to_chat(owner, span_notice("You feel a bit better."))
			owner.apply_status_effect(applied_status) // It's not all bad!
		if(SPT_PROB(1, seconds_per_tick))
			owner.emote("twitch")

	switch(stage)
		if(2, 3)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(owner, span_danger("Your chest spasms!"))
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(owner, span_danger("You feel weak."))
			if(SPT_PROB(1, seconds_per_tick))
				SEND_SOUND(owner, sound(pick(spooky_sounds)))
			if(SPT_PROB(2, seconds_per_tick))
				owner.vomit()
		if(4, 5)
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(owner, span_danger("Something flexes under your skin."))
			if(SPT_PROB(2, seconds_per_tick))
				if (prob(40))
					SEND_SOUND(owner, sound('sound/music/antag/bloodcult/ghost_whisper.ogg'))
				else
					SEND_SOUND(owner, sound(pick(spooky_sounds)))
			if(SPT_PROB(3, seconds_per_tick))
				owner.vomit(vomit_type = /obj/effect/decal/cleanable/vomit/old/black_bile)
				if (prob(50))
					var/turf/check_turf = get_step(owner.loc, owner.dir)
					var/atom/land_turf = (check_turf.is_blocked_turf()) ? owner.loc : check_turf
					var/mob/living/basic/legion_brood/child = new(land_turf)
					child.assign_creator(owner, copy_full_faction = FALSE)

			if(SPT_PROB(3, seconds_per_tick))
				to_chat(owner, span_danger("Your muscles ache."))
				owner.take_bodypart_damage(3)

	if (stage == 5)
		if (SPT_PROB(10, seconds_per_tick))
			infest()
		return

	elapsed_time += seconds_per_tick SECONDS * ((organ_flags & ORGAN_FAILING) ? 3 : 1) // Let's call it "matured" rather than failed
	if (elapsed_time < growth_time)
		return
	stage++
	elapsed_time = 0
	if (stage == 5)
		to_chat(owner, span_bolddanger("Something is moving under your skin!"))

/// Consume our host
/obj/item/organ/legion_tumour/proc/infest()
	if (QDELETED(src) || QDELETED(owner))
		return
	owner.log_message("has been turned into a Legion by their tumour.", LOG_VICTIM)
	owner.visible_message(span_boldwarning("Black tendrils burst from [owner]'s flesh, covering them in amorphous flesh!"))
	var/mob/living/basic/mining/legion/new_legion = new spawn_type(owner.loc)
	new_legion.consume(owner)
	qdel(src)

/obj/item/organ/legion_tumour/on_find(mob/living/finder)
	. = ..()
	to_chat(finder, span_warning("There's an enormous tumour in [owner]'s [zone]!"))
	if(stage < 4)
		to_chat(finder, span_notice("Its tendrils seem to twitch towards the light."))
		return
	to_chat(finder, span_notice("Its pulsing tendrils reach all throughout the body."))
	if(prob(stage * 2))
		infest()

/obj/item/organ/legion_tumour/feel_for_damage(self_aware)
	// keep stealthy for now, revisit later
	return ""
