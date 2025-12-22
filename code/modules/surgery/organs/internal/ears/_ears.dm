/obj/item/organ/ears
	name = "ears"
	icon_state = "ears"
	desc = "There are three parts to the ear. Inner, middle and outer. Only one of these parts should be normally visible."
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EARS
	gender = PLURAL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	low_threshold_passed = span_info("Your ears begin to resonate with an internal ring sometimes.")
	now_failing = span_warning("You are unable to hear at all!")
	now_fixed = span_info("Noise slowly begins filling your ears once more.")
	low_threshold_cleared = span_info("The ringing in your ears has died down.")

	/// temporary deafness, measured in seconds. While > 0, the person is unable to hear anything.
	var/temporary_deafness = 0

	// `damage` in this case measures long term damage to the ears, if too high,
	// the person will not have either `deaf` or `ear_damage` decrease
	// without external aid (earmuffs, drugs)

	/// Resistance against loud noises
	var/bang_protect = EAR_PROTECTION_NONE
	/// Multiplier for both long term and short term ear damage
	var/damage_multiplier = 1

/obj/item/organ/ears/on_life(seconds_per_tick, times_fired)
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
	adjust_temporary_deafness(-seconds_per_tick SECONDS)
	if((damage > low_threshold) && SPT_PROB(damage / 60, seconds_per_tick))
		adjust_temporary_deafness(4 SECONDS)
		SEND_SOUND(owner, sound('sound/items/weapons/flash_ring.ogg'))

/obj/item/organ/ears/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	if(temporary_deafness)
		on_deafened()

/obj/item/organ/ears/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	if(temporary_deafness)
		on_undeafened(organ_owner)

/obj/item/organ/ears/get_status_appendix(advanced, add_tooltips)
	if(owner.stat == DEAD || !HAS_TRAIT(owner, TRAIT_DEAF))
		return
	if(advanced)
		if(HAS_TRAIT_FROM(owner, TRAIT_DEAF, QUIRK_TRAIT))
			return conditional_tooltip("Subject is permanently deaf.", "Irreparable under normal circumstances.", add_tooltips)
		if(HAS_TRAIT_FROM(owner, TRAIT_DEAF, GENETIC_MUTATION))
			return conditional_tooltip("Subject is genetically deaf.", "Use medication such as [/datum/reagent/medicine/mutadone::name].", add_tooltips)
		if((organ_flags & ORGAN_FAILING) || HAS_TRAIT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
			return conditional_tooltip("Subject is [(organ_flags & ORGAN_FAILING) ? "permanently": "temporarily"] deaf from ear damage.", "Repair surgically, use medication such as [/datum/reagent/medicine/inacusiate::name], or protect ears with earmuffs.", add_tooltips)
	return "Subject is deaf."

/obj/item/organ/ears/show_on_condensed_scans()
	// Always show if we have an appendix
	return ..() || (owner.stat != DEAD && HAS_TRAIT(owner, TRAIT_DEAF))

///Adjust the temporary deafness of the person, up or down
/obj/item/organ/ears/proc/adjust_temporary_deafness(amount)
	// organ failure makes us permanently deafened. Also, doesn't do anything if not in someone or during godmode
	if(amount > 0 && owner && HAS_TRAIT(owner, TRAIT_GODMODE))
		return

	temporary_deafness = max(temporary_deafness + amount * damage_multiplier, 0)

	if(!owner)
		return

	if(temporary_deafness && !HAS_TRAIT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
		on_deafened()
	else if(!temporary_deafness && HAS_TRAIT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
		on_undeafened()

///Called when temporary deafness begins
/obj/item/organ/ears/proc/on_deafened()
	RegisterSignal(owner, COMSIG_MOB_SAY, PROC_REF(adjust_speech))
	ADD_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)

///Called when temporary deafness reaches zero. Has to have an 'organ_owner' arg, because by the time it's called on 'on_mob_remove', owner is already null
/obj/item/organ/ears/proc/on_undeafened(mob/living/organ_owner = owner)
	REMOVE_TRAIT(organ_owner, TRAIT_DEAF, EAR_DAMAGE)
	UnregisterSignal(organ_owner, COMSIG_MOB_SAY)

/obj/item/organ/ears/on_begin_failure()
	add_organ_trait(TRAIT_DEAF)

/obj/item/organ/ears/on_failure_recovery()
	remove_organ_trait(TRAIT_DEAF)

/// Being deafened by loud noises makes you shout
/obj/item/organ/ears/proc/adjust_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	if(HAS_TRAIT_NOT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE) || HAS_TRAIT(owner, TRAIT_SIGN_LANG))
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

/obj/item/organ/ears/feel_for_damage(self_aware)
	// Ear damage has audible effects, so we don't really need to "feel" it when self-examining
	return ""

/obj/item/organ/ears/invincible
	damage_multiplier = 0


/obj/item/organ/ears/cat
	name = "cat ears"
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "kitty"
	visual = TRUE
	damage_multiplier = 2

	restyle_flags = EXTERNAL_RESTYLE_FLESH

	dna_block = /datum/dna_block/feature/accessory/ears

	bodypart_overlay = /datum/bodypart_overlay/mutant/cat_ears

/// Bodypart overlay for the horrible cat ears
/datum/bodypart_overlay/mutant/cat_ears
	layers = EXTERNAL_FRONT | EXTERNAL_BEHIND
	color_source = ORGAN_COLOR_HAIR
	feature_key = FEATURE_EARS
	dyable = TRUE

	/// Layer upon which we add the inner ears overlay
	var/inner_layer = EXTERNAL_FRONT

/datum/bodypart_overlay/mutant/cat_ears/can_draw_on_bodypart(obj/item/bodypart/bodypart_owner)
	return !(bodypart_owner.owner?.obscured_slots & HIDEHAIR)

/datum/bodypart_overlay/mutant/cat_ears/get_image(image_layer, obj/item/bodypart/limb)
	var/mutable_appearance/base_ears = ..()
	base_ears.color = (dye_color || draw_color)

	// Only add inner ears on the inner layer
	if(image_layer != bitflag_to_layer(inner_layer))
		return base_ears

	// Construct image of inner ears, apply to base ears as an overlay
	feature_key += "inner"
	var/mutable_appearance/inner_ears = ..()
	feature_key = initial(feature_key)
	var/mutable_appearance/ear_holder = mutable_appearance(layer = image_layer)
	ear_holder.overlays += base_ears
	ear_holder.overlays += inner_ears
	return ear_holder

/datum/bodypart_overlay/mutant/cat_ears/color_image(image/overlay, layer, obj/item/bodypart/limb)
	return // We color base ears manually above in get_image

/obj/item/organ/ears/cat/cybernetic
	name = "basic cybernetic cat ears"
	icon = 'icons/obj/medical/organs/organs.dmi'
	icon_state = "ears-c-cat"
	desc = "A basic cybernetic organ designed to mimic the operation of ears."
	damage_multiplier = 2.4
	bodypart_overlay = /datum/bodypart_overlay/mutant/cat_ears/cybernetic
	sprite_accessory_override = /datum/sprite_accessory/ears/cat/cybernetic
	organ_flags = ORGAN_ROBOTIC
	failing_desc = "seems to be broken."

/obj/item/organ/ears/cat/cybernetic/upgraded
	name = "cybernetic cat ears"
	icon_state = "ears-c-cat-u"
	desc = "A cybernetic cat ear, still less durable than human ears."
	damage_multiplier = 1.5

/obj/item/organ/ears/cat/cybernetic/volume
	name = "volume-adjusting cybernetic cat ears"
	icon_state = "ears-c-cat-u2"
	desc = "Advanced cybernetic cat ears capable of dampening loud noises to protect their user."
	damage_multiplier = 1
	bang_protect = 1

/obj/item/organ/ears/cat/cybernetic/whisper
	name = "whisper-sensiive cybernetic cat ears"
	icon_state = "ears-c-cat-green"
	desc = "Allows the user to more easily hear whispers. The user becomes extremely vulnerable to loud noises, however."
	damage_multiplier = 3 // 4 would be excessive
	organ_traits = list(TRAIT_GOOD_HEARING)
	bodypart_overlay = /datum/bodypart_overlay/mutant/cat_ears/cybernetic/green

/obj/item/organ/ears/cat/cybernetic/xray
	name = "wall-penetrating cybernetic cat ears"
	icon_state = "ears-c-cat-blue"
	desc = "Through the power of modern feline engineering, allows the user to hear speech through walls. The user becomes extremely vulnerable to loud noises, however."
	damage_multiplier = 3 // As above, 4 would be excessive
	organ_traits = list(TRAIT_XRAY_HEARING)
	bodypart_overlay = /datum/bodypart_overlay/mutant/cat_ears/cybernetic/blue

/datum/bodypart_overlay/mutant/cat_ears/cybernetic
	color_source = null
	dyable = FALSE
	/// Color of the inner ear
	var/inner_color = "#F0004A"

/datum/bodypart_overlay/mutant/cat_ears/cybernetic/get_image(image_layer, obj/item/bodypart/limb)
	if (image_layer != bitflag_to_layer(inner_layer))
		return ..()
	var/mutable_appearance/ear_holder = ..()
	var/mutable_appearance/inner = ear_holder.overlays[2]
	inner.color = inner_color
	return ear_holder

/datum/bodypart_overlay/mutant/cat_ears/cybernetic/get_overlay(layer, obj/item/bodypart/limb)
	if (layer != inner_layer)
		return ..()
	var/list/all_images = ..()
	var/mutable_appearance/ear_holder = all_images[1]
	var/mutable_appearance/inner = ear_holder.overlays[2]
	all_images += emissive_appearance(inner.icon, inner.icon_state, limb, layer = inner.layer, alpha = inner.alpha * 0.75)
	return all_images

/datum/bodypart_overlay/mutant/cat_ears/cybernetic/green
	inner_color = "#0079EA"

/datum/bodypart_overlay/mutant/cat_ears/cybernetic/blue
	inner_color = "#00D844"

/obj/item/organ/ears/ghost
	name = "ghost ears"
	desc = "All the more to hear you... though it can't hear through walls."
	icon_state = "ears-ghost"
	movement_type = PHASING
	organ_flags = parent_type::organ_flags | ORGAN_GHOST

/obj/item/organ/ears/penguin
	name = "penguin ears"
	desc = "The source of a penguin's happy feet."

/obj/item/organ/ears/penguin/on_mob_insert(mob/living/carbon/human/ear_owner)
	. = ..()
	to_chat(ear_owner, span_notice("You suddenly feel like you've lost your balance."))
	ear_owner.AddElementTrait(TRAIT_WADDLING, ORGAN_TRAIT, /datum/element/waddling)

/obj/item/organ/ears/penguin/on_mob_remove(mob/living/carbon/human/ear_owner)
	. = ..()
	to_chat(ear_owner, span_notice("Your sense of balance comes back to you."))
	REMOVE_TRAIT(ear_owner, TRAIT_WADDLING, ORGAN_TRAIT)

/obj/item/organ/ears/cybernetic
	name = "basic cybernetic ears"
	icon_state = "ears-c"
	desc = "A basic cybernetic organ designed to mimic the operation of ears."
	damage_multiplier = 1.2
	organ_flags = ORGAN_ROBOTIC
	failing_desc = "seems to be broken."

/obj/item/organ/ears/cybernetic/upgraded
	name = "cybernetic ears"
	icon_state = "ears-c-u"
	desc =  "A cybernetic ear, surpassing the performance of organic ears."
	damage_multiplier = 0.75

/obj/item/organ/ears/cybernetic/whisper
	name = "whisper-sensitive cybernetic ears"
	icon_state = "ears-c-u"
	desc = "Allows the user to more easily hear whispers. The user becomes extra vulnerable to loud noises, however."
	// Same sensitivity as felinid ears
	damage_multiplier = 2
	// The original idea was to use signals to do this not traits. Unfortunately, the star effect used for whispers applies before any relevant signals
	// This seems like the least invasive solution
	organ_traits = list(TRAIT_GOOD_HEARING)

/obj/item/organ/ears/cybernetic/volume
	name = "volume-adjusting cybernetic ears"
	icon_state = "ears-c-u"
	desc = "Advanced cybernetic ears capable of dampening loud noises to protect their user."
	bang_protect = EAR_PROTECTION_NORMAL
	damage_multiplier = 0.5

// "X-ray ears" that let you hear through walls
/obj/item/organ/ears/cybernetic/xray
	name = "wall-penetrating cybernetic ears"
	icon_state = "ears-c-u"
	desc = "Through the power of modern engineering, allows the user to hear speech through walls. The user becomes extra vulnerable to loud noises, however."
	// Same sensitivity as felinid ears
	damage_multiplier = 2
	organ_traits = list(TRAIT_XRAY_HEARING)

/obj/item/organ/ears/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	apply_organ_damage(20 / severity)

/obj/item/organ/ears/pod
	name = "pod ears"
	desc = "Strangest salad you've ever seen."
	foodtype_flags = PODPERSON_ORGAN_FOODTYPES
	color = COLOR_LIME
