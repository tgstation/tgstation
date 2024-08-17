/obj/item/organ/internal/ears
	name = "ears"
	icon_state = "ears"
	desc = "There are three parts to the ear. Inner, middle and outer. Only one of these parts should be normally visible."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS
	visual = FALSE
	gender = PLURAL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	low_threshold_passed = "<span class='info'>Your ears begin to resonate with an internal ring sometimes.</span>"
	now_failing = "<span class='warning'>You are unable to hear at all!</span>"
	now_fixed = "<span class='info'>Noise slowly begins filling your ears once more.</span>"
	low_threshold_cleared = "<span class='info'>The ringing in your ears has died down.</span>"

	/// `deaf` measures "ticks" of deafness. While > 0, the person is unable to hear anything.
	var/deaf = 0

	// `damage` in this case measures long term damage to the ears, if too high,
	// the person will not have either `deaf` or `ear_damage` decrease
	// without external aid (earmuffs, drugs)

	/// Resistance against loud noises
	var/bang_protect = 0
	/// Multiplier for both long term and short term ear damage
	var/damage_multiplier = 1

/obj/item/organ/internal/ears/on_life(seconds_per_tick, times_fired)
	// only inform when things got worse, needs to happen before we heal
	if((damage > low_threshold && prev_damage < low_threshold) || (damage > high_threshold && prev_damage < high_threshold))
		to_chat(owner, span_warning("The ringing in your ears grows louder, blocking out any external noises for a moment."))

	. = ..()
	// if we have non-damage related deafness like mutations, quirks or clothing (earmuffs), don't bother processing here.
	// Ear healing from earmuffs or chems happen elsewhere
	if(HAS_TRAIT_NOT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
		return
	// no healing if failing
	if(organ_flags & ORGAN_FAILING)
		return
	adjustEarDamage(0, -0.5 * seconds_per_tick)
	if((damage > low_threshold) && SPT_PROB(damage / 60, seconds_per_tick))
		adjustEarDamage(0, 4)
		SEND_SOUND(owner, sound('sound/weapons/flash_ring.ogg'))

/obj/item/organ/internal/ears/apply_organ_damage(damage_amount, maximum, required_organ_flag)
	. = ..()
	update_temp_deafness()

/obj/item/organ/internal/ears/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	update_temp_deafness()

/obj/item/organ/internal/ears/on_mob_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_MOB_SAY)
	REMOVE_TRAIT(organ_owner, TRAIT_DEAF, EAR_DAMAGE)

/**
 * Snowflake proc to handle temporary deafness
 *
 * * ddmg: Handles normal organ damage
 * * ddeaf: Handles temporary deafness, 1 ddeaf = 2 seconds of deafness, by default (with no multiplier)
 */
/obj/item/organ/internal/ears/proc/adjustEarDamage(ddmg = 0, ddeaf = 0)
	if(owner.status_flags & GODMODE)
		update_temp_deafness()
		return

	var/mod_damage = ddmg > 0 ? (ddmg * damage_multiplier) : ddmg
	if(mod_damage)
		apply_organ_damage(mod_damage)
	var/mod_deaf = ddeaf > 0 ? (ddeaf * damage_multiplier) : ddeaf
	if(mod_deaf)
		deaf = max(deaf + mod_deaf, 0)
	update_temp_deafness()

/// Updates status of deafness
/obj/item/organ/internal/ears/proc/update_temp_deafness()
	// if we're failing we always have at least some deaf stacks (and thus deafness)
	if(organ_flags & ORGAN_FAILING)
		deaf = max(deaf, 1 * damage_multiplier)

	if(isnull(owner))
		return

	if(owner.status_flags & GODMODE)
		deaf = 0

	if(deaf > 0)
		if(!HAS_TRAIT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
			RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(adjust_speech))
			ADD_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
	else
		REMOVE_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
		UnregisterSignal(owner, COMSIG_MOB_SAY)

/// Being deafened by loud noises makes you shout
/obj/item/organ/internal/ears/proc/adjust_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(HAS_TRAIT_NOT_FROM(source, TRAIT_DEAF, EAR_DAMAGE))
		return
	if(HAS_TRAIT(source, TRAIT_SIGN_LANG))
		return

	var/message = speech_args[SPEECH_MESSAGE]
	// Replace only end-of-sentence punctuation with exclamation marks (hence the empty space)
	// We don't wanna mess with things like ellipses
	message = replacetext(message, ". ", "! ")
	message = replacetext(message, "? ", "?! ")
	// Special case for the last character
	switch(copytext_char(message, -1))
		if(".")
			if(copytext_char(message, -2) != "..") // Once again ignoring ellipses, let people trail off
				message = copytext_char(message, 1, -1) + "!"
		if("?")
			message = copytext_char(message, 1, -1) + "?!"
		if("!")
			pass()
		else
			message += "!"

	speech_args[SPEECH_MESSAGE] = message
	return COMPONENT_UPPERCASE_SPEECH

/obj/item/organ/internal/ears/invincible
	damage_multiplier = 0

/obj/item/organ/internal/ears/cat
	name = "cat ears"
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "kitty"
	visual = TRUE
	damage_multiplier = 2
	// Keeps track of which cat ears sprite is associated with this.
	var/variant = "Cat"

/obj/item/organ/internal/ears/cat/Initialize(mapload, variant_pref)
	. = ..()
	if(variant_pref)
		variant = variant_pref

/obj/item/organ/internal/ears/cat/on_mob_insert(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner) && ear_owner.dna)
		color = ear_owner.hair_color
		ear_owner.dna.features["ears"] = ear_owner.dna.species.mutant_bodyparts["ears"] = variant
		ear_owner.dna.update_uf_block(DNA_EARS_BLOCK)
		ear_owner.update_body()

/obj/item/organ/internal/ears/cat/on_mob_remove(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner) && ear_owner.dna)
		color = ear_owner.hair_color
		ear_owner.dna.species.mutant_bodyparts -= "ears"
		ear_owner.update_body()

/obj/item/organ/internal/ears/penguin
	name = "penguin ears"
	desc = "The source of a penguin's happy feet."

/obj/item/organ/internal/ears/penguin/on_mob_insert(mob/living/carbon/human/ear_owner)
	. = ..()
	to_chat(ear_owner, span_notice("You suddenly feel like you've lost your balance."))
	ear_owner.AddElementTrait(TRAIT_WADDLING, ORGAN_TRAIT, /datum/element/waddling)

/obj/item/organ/internal/ears/penguin/on_mob_remove(mob/living/carbon/human/ear_owner)
	. = ..()
	to_chat(ear_owner, span_notice("Your sense of balance comes back to you."))
	REMOVE_TRAIT(ear_owner, TRAIT_WADDLING, ORGAN_TRAIT)

/obj/item/organ/internal/ears/cybernetic
	name = "basic cybernetic ears"
	icon_state = "ears-c"
	desc = "A basic cybernetic organ designed to mimic the operation of ears."
	damage_multiplier = 0.9
	organ_flags = ORGAN_ROBOTIC
	failing_desc = "seems to be broken."

/obj/item/organ/internal/ears/cybernetic/upgraded
	name = "cybernetic ears"
	icon_state = "ears-c-u"
	desc =  "An advanced cybernetic ear, surpassing the performance of organic ears."
	damage_multiplier = 0.5

/obj/item/organ/internal/ears/cybernetic/whisper
	name = "whisper-sensitive cybernetic ears"
	icon_state = "ears-c-u"
	desc = "Allows the user to more easily hear whispers. The user becomes extra vulnerable to loud noises, however"
	// Same sensitivity as felinid ears
	damage_multiplier = 2

// The original idea was to use signals to do this not traits. Unfortunately, the star effect used for whispers applies before any relevant signals
// This seems like the least invasive solution
/obj/item/organ/internal/ears/cybernetic/whisper/on_mob_insert(mob/living/carbon/ear_owner)
	. = ..()
	ADD_TRAIT(ear_owner, TRAIT_GOOD_HEARING, ORGAN_TRAIT)

/obj/item/organ/internal/ears/cybernetic/whisper/on_mob_remove(mob/living/carbon/ear_owner)
	. = ..()
	REMOVE_TRAIT(ear_owner, TRAIT_GOOD_HEARING, ORGAN_TRAIT)

// "X-ray ears" that let you hear through walls
/obj/item/organ/internal/ears/cybernetic/xray
	name = "wall-penetrating cybernetic ears"
	icon_state = "ears-c-u"
	desc = "Throguh the power of modern engineering, allows the user to hear speech through walls. The user becomes extra vulnerable to loud noises, however"
	// Same sensitivity as felinid ears
	damage_multiplier = 2

/obj/item/organ/internal/ears/cybernetic/xray/on_mob_insert(mob/living/carbon/ear_owner)
	. = ..()
	ADD_TRAIT(ear_owner, TRAIT_XRAY_HEARING, ORGAN_TRAIT)

/obj/item/organ/internal/ears/cybernetic/xray/on_mob_remove(mob/living/carbon/ear_owner)
	. = ..()
	REMOVE_TRAIT(ear_owner, TRAIT_XRAY_HEARING, ORGAN_TRAIT)

/obj/item/organ/internal/ears/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	apply_organ_damage(20 / severity)
