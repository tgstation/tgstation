/obj/item/organ/ears
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

	// `deaf` measures "ticks" of deafness. While > 0, the person is unable
	// to hear anything.
	var/deaf = 0

	// `damage` in this case measures long term damage to the ears, if too high,
	// the person will not have either `deaf` or `ear_damage` decrease
	// without external aid (earmuffs, drugs)

	//Resistance against loud noises
	var/bang_protect = 0
	// Multiplier for both long term and short term ear damage
	var/damage_multiplier = 1

/obj/item/organ/ears/transfer_to_limb(obj/item/bodypart/new_bodypart, special = FALSE)
	. = ..()
	//bastard
	if(!istype(new_bodypart, /obj/item/bodypart/head))
		return
	var/obj/item/bodypart/head/new_head = new_bodypart
	new_head.ears = src

/obj/item/organ/ears/remove_from_limb(obj/item/bodypart/new_bodypart, special)
	. = ..()
	//bastard
	if(!istype(new_bodypart, /obj/item/bodypart/head))
		return
	var/obj/item/bodypart/head/new_head = new_bodypart
	new_head.ears = null

/obj/item/organ/ears/on_life(seconds_per_tick, times_fired)
	// only inform when things got worse, needs to happen before we heal
	if((damage > low_threshold && prev_damage < low_threshold) || (damage > high_threshold && prev_damage < high_threshold))
		to_chat(owner, span_warning("The ringing in your ears grows louder, blocking out any external noises for a moment."))

	. = ..()
	// if we have non-damage related deafness like mutations, quirks or clothing (earmuffs), don't bother processing here. Ear healing from earmuffs or chems happen elsewhere
	if(HAS_TRAIT_NOT_FROM(owner, TRAIT_DEAF, EAR_DAMAGE))
		return

	if((organ_flags & ORGAN_FAILING))
		deaf = max(deaf, 1) // if we're failing we always have at least 1 deaf stack (and thus deafness)
	else // only clear deaf stacks if we're not failing
		deaf = max(deaf - (0.5 * seconds_per_tick), 0)
		if((damage > low_threshold) && SPT_PROB(damage / 60, seconds_per_tick))
			adjustEarDamage(0, 4)
			SEND_SOUND(owner, sound('sound/weapons/flash_ring.ogg'))

	if(deaf)
		ADD_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)
	else
		REMOVE_TRAIT(owner, TRAIT_DEAF, EAR_DAMAGE)

/obj/item/organ/ears/proc/adjustEarDamage(ddmg, ddeaf)
	if(owner.status_flags & GODMODE)
		return
	set_organ_damage(clamp(damage + (ddmg * damage_multiplier), 0, maxHealth))
	deaf = max(deaf + (ddeaf * damage_multiplier), 0)

/datum/bodypart_overlay/mutant/ears
	layers = EXTERNAL_FRONT|EXTERNAL_BEHIND
	color_source = ORGAN_COLOR_HAIR
	feature_key = "ears"

/datum/bodypart_overlay/mutant/ears/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!(human.head?.flags_inv & HIDEEARS))
		return TRUE
	return FALSE

/datum/bodypart_overlay/mutant/ears/get_global_feature_list()
	return GLOB.ears_list

/datum/bodypart_overlay/mutant/ears/get_overlays(layer, obj/item/bodypart/limb)
	. = ..()
	//fucking lovely, we have to deal with the inners
	layer = bitflag_to_layer(layer)
	if(sprite_datum.hasinner)
		var/gender = (limb?.limb_gender == FEMALE) ? "f" : "m"
		var/list/icon_state_builder = list()
		icon_state_builder += sprite_datum.gender_specific ? gender : "m" //Male is default because sprite accessories are so ancient they predate the concept of not hardcoding gender
		icon_state_builder += "[feature_key]inner"
		icon_state_builder += get_base_icon_state()
		icon_state_builder += mutant_bodyparts_layertext(layer)

		var/finished_icon_state = icon_state_builder.Join("_")

		var/mutable_appearance/inner_appearance = mutable_appearance(sprite_datum.icon, finished_icon_state, layer = layer)
		. += inner_appearance

/datum/bodypart_overlay/mutant/ears/generate_icon_cache()
	. = ..()
	. += "[sprite_datum.hasinner]"

/obj/item/organ/ears/invincible
	damage_multiplier = 0

/obj/item/organ/ears/cat
	name = "cat ears"
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	icon_state = "kitty"
	damage_multiplier = 2

	visual = TRUE
	dna_block = DNA_EARS_BLOCK
	bodypart_overlay = /datum/bodypart_overlay/mutant/ears

/obj/item/organ/ears/penguin
	name = "penguin ears"
	desc = "The source of a penguin's happy feet."

/obj/item/organ/ears/penguin/on_insert(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner))
		to_chat(ear_owner, span_notice("You suddenly feel like you've lost your balance."))
		ear_owner.AddElement(/datum/element/waddling)

/obj/item/organ/ears/penguin/on_remove(mob/living/carbon/human/ear_owner)
	. = ..()
	if(istype(ear_owner))
		to_chat(ear_owner, span_notice("Your sense of balance comes back to you."))
		ear_owner.RemoveElement(/datum/element/waddling)

/obj/item/organ/ears/cybernetic
	name = "cybernetic ears"
	icon_state = "ears-c"
	desc = "A basic cybernetic organ designed to mimic the operation of ears."
	damage_multiplier = 0.9
	organ_flags = ORGAN_ROBOTIC

/obj/item/organ/ears/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	apply_organ_damage(40/severity)

/obj/item/organ/ears/cybernetic/upgraded
	name = "upgraded cybernetic ears"
	icon_state = "ears-c-u"
	desc = "An advanced cybernetic ear, surpassing the performance of organic ears."
	damage_multiplier = 0.5
