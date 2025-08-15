// AMOK
/datum/status_effect/amok
	id = "amok"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 10 SECONDS
	tick_interval = 1 SECONDS

/datum/status_effect/amok/on_apply(mob/living/afflicted)
	to_chat(owner, span_boldwarning("You feel filled with a rage that is not your own!"))
	return TRUE

/datum/status_effect/amok/tick(seconds_between_ticks)
	var/prev_combat_mode = owner.combat_mode
	owner.set_combat_mode(TRUE)

	// If we're holding a gun, expand the range a bit.
	// Otherwise, just look for adjacent targets
	var/search_radius = isgun(owner.get_active_held_item()) ? 3 : 1

	var/list/mob/living/targets = list()
	for(var/mob/living/potential_target in oview(owner, search_radius))
		if(IS_HERETIC_OR_MONSTER(potential_target))
			continue
		targets += potential_target

	if(LAZYLEN(targets))
		owner.log_message(" attacked someone due to the amok debuff.", LOG_ATTACK) //the following attack will log itself
		owner.ClickOn(pick(targets))

	owner.set_combat_mode(prev_combat_mode)

/datum/status_effect/cloudstruck
	id = "cloudstruck"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	duration = 3 SECONDS
	on_remove_on_mob_delete = TRUE
	///This overlay is applied to the owner for the duration of the effect.
	var/static/mutable_appearance/mob_overlay

/datum/status_effect/cloudstruck/on_creation(mob/living/new_owner, duration = 10 SECONDS)
	src.duration = duration
	if(!mob_overlay)
		mob_overlay = mutable_appearance('icons/effects/eldritch.dmi', "cloud_swirl", ABOVE_MOB_LAYER)
	return ..()

/datum/status_effect/cloudstruck/on_apply()
	owner.add_overlay(mob_overlay)
	owner.become_blind(id)
	return TRUE

/datum/status_effect/cloudstruck/on_remove()
	owner.cure_blind(id)
	owner.cut_overlay(mob_overlay)

/datum/status_effect/corrosion_curse
	id = "corrosion_curse"
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	tick_interval = 1 SECONDS

/datum/status_effect/corrosion_curse/on_apply()
	to_chat(owner, span_userdanger("Your body starts to break apart!"))
	return TRUE

/datum/status_effect/corrosion_curse/tick(seconds_between_ticks)
	. = ..()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/human_owner = owner
	var/chance = rand(0, 100)
	switch(chance)
		if(0 to 10)
			human_owner.vomit(VOMIT_CATEGORY_DEFAULT)
		if(20 to 30)
			human_owner.set_timed_status_effect(100 SECONDS, /datum/status_effect/dizziness, only_if_higher = TRUE)
			human_owner.set_timed_status_effect(100 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
		if(30 to 40)
			// Don't fully kill liver that's important
			human_owner.adjustOrganLoss(ORGAN_SLOT_LIVER, 10, 90)
		if(40 to 50)
			// Don't fully kill heart that's important
			human_owner.adjustOrganLoss(ORGAN_SLOT_HEART, 10, 90)
		if(50 to 60)
			// You can fully kill the stomach that's not crucial
			human_owner.adjustOrganLoss(ORGAN_SLOT_STOMACH, 10)
		if(60 to 70)
			// Same with eyes
			human_owner.adjustOrganLoss(ORGAN_SLOT_EYES, 5)
		if(70 to 80)
			// And same with ears
			human_owner.adjustOrganLoss(ORGAN_SLOT_EARS, 10)
		if(80 to 90)
			// But don't fully kill lungs that's usually important
			human_owner.adjustOrganLoss(ORGAN_SLOT_LUNGS, 10, 90)
		if(90 to 95)
			// And definitely don't fully kil brains
			human_owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, 20, 190)
		if(95 to 100)
			human_owner.adjust_confusion_up_to(12 SECONDS, 24 SECONDS)

/datum/status_effect/star_mark
	id = "star_mark"
	alert_type = /atom/movable/screen/alert/status_effect/star_mark
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	///overlay used to indicate that someone is marked
	var/mutable_appearance/cosmic_overlay
	/// icon file for the overlay
	var/effect_icon = 'icons/effects/eldritch.dmi'
	/// icon state for the overlay
	var/effect_icon_state = "cosmic_ring"
	/// Storage for the spell caster
	var/datum/weakref/spell_caster

/atom/movable/screen/alert/status_effect/star_mark
	name = "Star Mark"
	desc = "A ring above your head prevents you from entering cosmic fields or teleporting through cosmic runes..."
	icon_state = "star_mark"

/datum/status_effect/star_mark/on_creation(mob/living/new_owner, mob/living/new_spell_caster)
	cosmic_overlay = mutable_appearance(effect_icon, effect_icon_state, BELOW_MOB_LAYER)
	if(new_spell_caster)
		spell_caster = WEAKREF(new_spell_caster)
	return ..()

/datum/status_effect/star_mark/Destroy()
	QDEL_NULL(cosmic_overlay)
	return ..()

/datum/status_effect/star_mark/on_apply()
	if(istype(owner, /mob/living/basic/heretic_summon/star_gazer))
		return FALSE
	var/mob/living/spell_caster_resolved = spell_caster?.resolve()
	var/datum/antagonist/heretic_monster/monster = owner.mind?.has_antag_datum(/datum/antagonist/heretic_monster)
	if(spell_caster_resolved && monster)
		if(monster.master?.current == spell_caster_resolved)
			return FALSE
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))
	owner.update_appearance(UPDATE_OVERLAYS)
	return TRUE

/// Updates the overlay of the owner
/datum/status_effect/star_mark/proc/update_owner_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER

	overlays += cosmic_overlay

/datum/status_effect/star_mark/on_remove()
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	owner.update_appearance(UPDATE_OVERLAYS)
	return ..()

/datum/status_effect/star_mark/extended
	duration = 3 MINUTES

// Last Resort
/datum/status_effect/heretic_lastresort
	id = "heretic_lastresort"
	alert_type = /atom/movable/screen/alert/status_effect/heretic_lastresort
	duration = 12 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	tick_interval = STATUS_EFFECT_NO_TICK

/atom/movable/screen/alert/status_effect/heretic_lastresort
	name = "Last Resort"
	desc = "Your head spins, heart pumping as fast as it can, losing the fight with the ground. Run to safety!"
	icon_state = "lastresort"

/datum/status_effect/heretic_lastresort/on_apply()
	ADD_TRAIT(owner, TRAIT_IGNORESLOWDOWN, TRAIT_STATUS_EFFECT(id))
	to_chat(owner, span_userdanger("You are on the brink of losing consciousness, run!"))
	return TRUE

/datum/status_effect/heretic_lastresort/on_remove()
	REMOVE_TRAIT(owner, TRAIT_IGNORESLOWDOWN, TRAIT_STATUS_EFFECT(id))
	owner.AdjustUnconscious(20 SECONDS, ignore_canstun = TRUE)

/// Used by moon heretics to make people mad
/datum/status_effect/moon_converted
	id = "moon converted"
	alert_type = /atom/movable/screen/alert/status_effect/moon_converted
	duration = STATUS_EFFECT_PERMANENT
	status_type = STATUS_EFFECT_REPLACE
	///used to track damage
	var/damage_sustained = 0
	///overlay used to indicate that someone is marked
	var/mutable_appearance/moon_insanity_overlay
	/// icon file for the overlay
	var/effect_icon = 'icons/effects/eldritch.dmi'
	/// icon state for the overlay
	var/effect_icon_state = "moon_insanity_overlay"

/atom/movable/screen/alert/status_effect/moon_converted
	name = "Moon Converted"
	desc = "THEY LIE, THEY ALL LIE!!! SLAY THEM!!! BURN THEM!!! MAKE THEM SEE THE TRUTH!!!"
	icon_state = "lastresort"

/datum/status_effect/moon_converted/on_creation()
	. = ..()
	moon_insanity_overlay = mutable_appearance(effect_icon, effect_icon_state, ABOVE_MOB_LAYER)

/datum/status_effect/moon_converted/Destroy()
	QDEL_NULL(moon_insanity_overlay)
	return ..()

/datum/status_effect/moon_converted/on_apply()
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))
	// Heals them so people who are in crit can have this affect applied on them and still be of some use for the heretic
	owner.adjustBruteLoss( -150 + owner.mob_mood.sanity)
	owner.adjustFireLoss(-150 + owner.mob_mood.sanity)

	to_chat(owner, span_hypnophrase(("THE MOON SHOWS YOU THE TRUTH AND THE LIARS WISH TO COVER IT, SLAY THEM ALL!!!</span>")))
	owner.balloon_alert(owner, "they lie..THEY ALL LIE!!!")
	owner.AdjustUnconscious(7 SECONDS, ignore_canstun = FALSE)
	ADD_TRAIT(owner, TRAIT_MUTE, TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_overlay))
	owner.update_appearance(UPDATE_OVERLAYS)
	owner.cause_hallucination(/datum/hallucination/delusion/preset/moon, "[id] status effect", duration = duration, affects_us = FALSE, affects_others = TRUE)
	return TRUE

/datum/status_effect/moon_converted/proc/on_damaged(datum/source, damage, damagetype)
	SIGNAL_HANDLER

	// Stamina damage is funky so we will ignore it
	if(damagetype == STAMINA)
		return

	damage_sustained += damage

	if (damage_sustained < 75)
		return

	qdel(src)

/datum/status_effect/moon_converted/proc/update_owner_overlay(atom/source, list/overlays)
	SIGNAL_HANDLER
	overlays += moon_insanity_overlay

/datum/status_effect/moon_converted/on_remove()
	// Span warning and unconscious so they realize they aren't evil anymore
	to_chat(owner, span_warning("Your mind is cleared from the effect of the mansus, your alligiences are as they were before"))
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAIT_STATUS_EFFECT(id))
	owner.AdjustUnconscious(5 SECONDS, ignore_canstun = FALSE)
	owner.log_message("[owner] is no longer insane.", LOG_GAME)
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damaged))
	owner.update_appearance(UPDATE_OVERLAYS)
	return ..()


/atom/movable/screen/alert/status_effect/moon_converted
	name = "Moon Converted"
	desc = "They LIE, SLAY ALL OF THE THEM!!! THE LIARS OF THE SUN MUST FALL!!!"
	icon_state = "moon_insanity"

// Status effects that eldritch paintings apply
//The debug painting status effect. To make sure this isn't applying to heretics.
/datum/status_effect/eldritch_painting
	id = "eldritch_painting"
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_painting
	duration = 10 MINUTES
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/eldritch_painting/on_apply()
	if(IS_HERETIC_OR_MONSTER(owner))
		return FALSE
	if(!ishuman(owner))
		return FALSE
	if(owner.reagents.has_reagent(/datum/reagent/water/holywater))
		return FALSE
	return TRUE

/atom/movable/screen/alert/status_effect/eldritch_painting
	name = "Rick Roll'd"
	desc = "Fucking coders are at it again."
	icon_state = "eldritch_painting_debug"

//"The Sister and He Who Wept": /obj/structure/sign/painting/eldritch
/datum/status_effect/eldritch_painting/weeping
	id = "painting_weeping"
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_painting/weeping
	tick_interval = 10 SECONDS

/datum/status_effect/eldritch_painting/weeping/tick(seconds_between_ticks)
	if(owner.stat != CONSCIOUS || owner.IsSleeping() || owner.IsUnconscious())
		return
	if(HAS_TRAIT(owner, TRAIT_ELDRITCH_PAINTING_EXAMINE))
		return

	owner.cause_hallucination(/datum/hallucination/delusion/preset/heretic, "Caused by The Weeping status effect")
	owner.add_mood_event("eldritch_weeping", /datum/mood_event/eldritch_painting/weeping)

/atom/movable/screen/alert/status_effect/eldritch_painting/weeping
	name = "The Sister and He Who Wept"
	desc = "The weeping echos through your mind like an echo, undoing your psyche! Maybe if you look at the painting again, it won't hurt so badly..."
	icon_state = "eldritch_painting_weeping"

//"The First Desire": /obj/structure/sign/painting/eldritch/desire
/datum/status_effect/eldritch_painting/desire
	id = "painting_desire"
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_painting/desire
	/// How much faster we loose hunger
	var/hunger_rate = 15

/datum/status_effect/eldritch_painting/desire/on_apply()
	if(IS_HERETIC_OR_MONSTER(owner))
		return FALSE
	if(!ishuman(owner))
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_NOHUNGER))
		return FALSE

	// Allows them to eat faster, mainly for flavor
	ADD_TRAIT(owner, TRAIT_VORACIOUS, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_FLESH_DESIRE, TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/eldritch_painting/desire/tick(seconds_between_ticks)
	if(HAS_TRAIT(owner, TRAIT_ELDRITCH_PAINTING_EXAMINE))
		return
	// Causes them to need to eat at 10x the normal rate
	owner.adjust_nutrition(-hunger_rate * HUNGER_FACTOR)
	if(SPT_PROB(10, seconds_between_ticks))
		to_chat(owner, span_notice(pick("You can't stop thinking about raw meat...", "You **NEED** to eat someone.", "The hunger pangs are back...", "You hunger for flesh.", "You are starving!")))
	owner.overeatduration = max(owner.overeatduration - 200 SECONDS, 0)

/datum/status_effect/eldritch_painting/desire/on_remove()
	REMOVE_TRAIT(owner, TRAIT_VORACIOUS, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_FLESH_DESIRE, TRAIT_STATUS_EFFECT(id))
	return ..()

/atom/movable/screen/alert/status_effect/eldritch_painting/desire
	name = "The First Desire"
	desc = "Your are struck with a ravenous hunger! SATIATE IT AT ANY COST! Or maybe just go stare at the painting and long for the excellent meal it promises..."
	icon_state = "eldritch_painting_desire"

/datum/status_effect/eldritch_painting/desire/permanent
	duration = STATUS_EFFECT_PERMANENT

// "Lady out of gates": /obj/item/wallframe/painting/eldritch/beauty
/datum/status_effect/eldritch_painting/beauty
	id = "painting_beauty"
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_painting/beauty
	tick_interval = 3 SECONDS
	/// How much damage we deal with each scratch
	var/scratch_damage = 3

/datum/status_effect/eldritch_painting/beauty/tick(seconds_between_ticks)
	if(owner.incapacitated)
		return

	if(HAS_TRAIT(owner, TRAIT_ELDRITCH_PAINTING_EXAMINE))
		return

	// Scratching code
	var/obj/item/bodypart/bodypart = owner.get_bodypart(owner.get_random_valid_zone(even_weights = TRUE))
	if(!bodypart || !IS_ORGANIC_LIMB(bodypart) || (bodypart.bodypart_flags & BODYPART_PSEUDOPART))
		return
	// Jumpsuits ruin the "perfection" of the body
	var/mob/living/carbon/human/scratcher = owner
	if(!length(scratcher.get_clothing_on_part(bodypart)))
		return

	owner.apply_damage(scratch_damage, BRUTE, bodypart)
	to_chat(owner, span_notice("You scratch furiously at your clothed [bodypart.plaintext_zone]!"))

/atom/movable/screen/alert/status_effect/eldritch_painting/beauty
	name = "Lady Out of Gates"
	desc = "Your clothing obscures the beauty beneath. Remove it, and reach perfection. Or behold perfect for a brief moment of clarity in the painting you saw your ideal image in."
	icon_state = "eldritch_painting_beauty"

// "Climb over the rusted mountain": /obj/structure/sign/painting/eldritch/rust
/datum/status_effect/eldritch_painting/rusting
	id = "painting_rusting"
	alert_type = /atom/movable/screen/alert/status_effect/eldritch_painting/rusting
	tick_interval = 3 SECONDS

/datum/status_effect/eldritch_painting/rusting/tick(seconds_between_ticks)
	var/atom/tile = get_turf(owner)
	if(HAS_TRAIT(owner, TRAIT_ELDRITCH_PAINTING_EXAMINE))
		return

	to_chat(owner, span_notice("You feel the decay..."))
	tile.rust_heretic_act()

/atom/movable/screen/alert/status_effect/eldritch_painting/rusting
	name = "Climb Over the Rusted Mountain"
	desc = "Your every footfall erodes the ground beneath you! Everything crumbles away! Maybe if you looked closer at the mountain in that painting, the path might be clearer..."
	icon_state = "eldritch_painting_rust"
