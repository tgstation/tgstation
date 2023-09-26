/// Left behind when a legion infects you, for medical enrichment
/obj/item/organ/internal/legion_tumour
	name = "legion tumour"
	desc = "A mass of pulsing flesh and dark tendrils."
	icon = 'icons/obj/medical/organs/mining_organs.dmi'
	icon_state = "legion_remains"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_PARASITE_EGG
	/// What stage of growth the corruption has reached.
	var/stage = 0
	/// We apply this status effect periodically or when used on someone
	var/applied_status = /datum/status_effect/regenerative_core
	/// How long have we been in this stage?
	var/elapsed_time = 0 SECONDS
	/// How long does it take to advance one stage?
	var/growth_time = 90 SECONDS
	/// What kind of mob will we transform into?
	var/spawn_type = /mob/living/basic/mining/legion
	/// Spooky sounds to play as you start to turn
	var/static/list/spooky_sounds = list(
		'sound/voice/lowHiss1.ogg',
		'sound/voice/lowHiss2.ogg',
		'sound/voice/lowHiss3.ogg',
		'sound/voice/lowHiss4.ogg',
	)

/obj/item/organ/internal/legion_tumour/Remove(mob/living/carbon/egg_owner, special)
	. = ..()
	stage = 0
	elapsed_time = 0

/obj/item/organ/internal/legion_tumour/attack(mob/living/target, mob/living/user, params)
	if (try_apply(target, user))
		return
	return ..()

/// Smear it on someone like a regen core, why not
/obj/item/organ/internal/legion_tumour/proc/try_apply(mob/living/target, mob/user)
	if(!user.Adjacent(target) || !isliving(target) || target.stat == DEAD)
		return FALSE

	target.apply_status_effect(applied_status)
	target.add_mood_event(MOOD_CATEGORY_LEGION_CORE, /datum/mood_event/healsbadman)

	if (target != user)
		target.visible_message(span_notice("[user] splatters [target] with [src]... Black tendrils entangle and reinforce [target.p_them()]!"))
	else
		to_chat(user, span_notice("You start to smear [src] on yourself. Disgusting tendrils hold you together and allow you to keep moving."))
	return TRUE

/obj/item/organ/internal/legion_tumour/on_life(seconds_per_tick, times_fired)
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
					SEND_SOUND(owner, sound('sound/voice/ghost_whisper.ogg'))
				else
					SEND_SOUND(owner, sound(pick(spooky_sounds)))
			if(SPT_PROB(3, seconds_per_tick))
				owner.vomit(vomit_type = /obj/effect/decal/cleanable/vomit/old/black_bile)
				if (prob(50))
					var/mob/living/basic/legion_brood/child = new(owner.loc)
					child.assign_creator(owner, copy_full_faction = FALSE)

			if(SPT_PROB(3, seconds_per_tick))
				to_chat(owner, span_danger("Your muscles ache."))
				owner.take_bodypart_damage(3)

	if (stage == 5)
		if (SPT_PROB(10, seconds_per_tick))
			infest()
		return

	elapsed_time += seconds_per_tick SECONDS
	if (elapsed_time < growth_time)
		return
	stage++
	elapsed_time = 0

/// Consume our host
/obj/item/organ/internal/legion_tumour/proc/infest()
	if (QDELETED(src) || QDELETED(owner))
		return
	new /obj/effect/gibspawner/generic(owner.loc)
	owner.visible_message(span_boldwarning("Black tendrils burst from [owner]'s flesh, covering them in amorphous flesh!"))
	var/mob/living/basic/mining/legion/new_legion = new spawn_type(owner.loc)
	new_legion.consume(owner)
	qdel(src)

/obj/item/organ/internal/legion_tumour/on_find(mob/living/finder)
	. = ..()
	to_chat(finder, span_warning("There's an enormous tumour in [owner]'s [zone]!"))
	if(stage < 4)
		to_chat(finder, span_notice("Its tendrils seem to twitch towards the light."))
		return
	to_chat(finder, span_notice("Its pulsing tendrils reach all throughout the body."))
	if(prob(10))
		infest()
