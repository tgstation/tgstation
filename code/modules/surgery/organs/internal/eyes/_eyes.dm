/obj/item/organ/eyes
	name = BODY_ZONE_PRECISE_EYES
	icon_state = "eyes"
	desc = "I see you!"
	visual = TRUE
	zone = BODY_ZONE_PRECISE_EYES
	slot = ORGAN_SLOT_EYES
	gender = PLURAL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY
	maxHealth = 0.5 * STANDARD_ORGAN_THRESHOLD //half the normal health max since we go blind at 30, a permanent blindness at 50 therefore makes sense unless medicine is administered
	high_threshold = 0.3 * STANDARD_ORGAN_THRESHOLD //threshold at 30
	low_threshold = 0.2 * STANDARD_ORGAN_THRESHOLD //threshold at 20

	low_threshold_passed = span_info("Distant objects become somewhat less tangible.")
	high_threshold_passed = span_info("Everything starts to look a lot less clear.")
	now_failing = span_warning("Darkness envelopes you, as your eyes go blind!")
	now_fixed = span_info("Color and shapes are once again perceivable.")
	high_threshold_cleared = span_info("Your vision functions passably once more.")
	low_threshold_cleared = span_info("Your vision is cleared of any ailment.")

	/// Sight flags this eye pair imparts on its user.
	var/sight_flags = NONE
	/// How much innate tint these eyes have
	var/tint = 0
	/// How much innare flash protection these eyes have, usually paired with tint
	var/flash_protect = FLASH_PROTECTION_NONE
	/// What level of invisibility these eyes can see
	var/see_invisible = SEE_INVISIBLE_LIVING
	/// How much darkness to cut out of your view (basically, night vision)
	var/lighting_cutoff = null
	/// List of color cutoffs from eyes, or null if not applicable
	var/list/color_cutoffs = null
	/// Are these eyes immune to pepperspray?
	var/pepperspray_protect = FALSE

	var/eye_color_left = null // set to a hex code to override a mob's left eye color
	var/eye_color_right = null // set to a hex code to override a mob's right eye color
	/// The icon file of that eyes as its applied to the mob
	var/eye_icon = 'icons/mob/human/human_eyes.dmi'
	/// The icon state of that eyes as its applied to the mob
	var/eye_icon_state = "eyes"
	/// Do these eyes have blinking animations
	var/blink_animation = TRUE
	/// Icon state for iris overlays
	var/iris_overlay = "eyes_iris"
	/// Should our blinking be synchronized or can separate eyes have (slightly) separate blinking times
	var/synchronized_blinking = TRUE
	// A pair of abstract eyelid objects (yes, really) used to animate blinking
	var/obj/effect/abstract/eyelid_effect/eyelid_left
	var/obj/effect/abstract/eyelid_effect/eyelid_right

	/// Glasses cannot be worn over these eyes. Currently unused
	var/no_glasses = FALSE
	/// Native FOV that will be applied if a config is enabled
	var/native_fov = FOV_90_DEGREES
	/// Scarring on this organ
	var/scarring = NONE

	/// The (custom, sometimes) messages we get when we use a flashlight or penlight on these eyes.
	/// Completely optional but good if you wanna be FANCY

	/// this message should never show up for default eyes, do not change on default eyes.
	var/penlight_message = "useless default please report"
	/// what are the pupils called? eg. pupils, apertures, etc.
	var/pupils_name = "pupils"
	/// do these eyes have pupils (or equivalent) that react to light when penlighted.
	var/light_reactive = TRUE

/obj/item/organ/eyes/Initialize(mapload)
	. = ..()
	if (blink_animation)
		eyelid_left = new(src, "[eye_icon_state]_l")
		eyelid_right = new(src, "[eye_icon_state]_r")

/obj/item/organ/eyes/Destroy()
	QDEL_NULL(eyelid_left)
	QDEL_NULL(eyelid_right)
	return ..()

/obj/item/organ/eyes/on_mob_insert(mob/living/carbon/receiver, special, movement_flags)
	. = ..()
	if(organ_flags & ORGAN_FAILING)
		receiver.become_blind(EYE_DAMAGE)
	if(damage >= low_threshold)
		receiver.assign_nearsightedness(EYE_DAMAGE, damage >= high_threshold ? 3 : 2, TRUE)

	receiver.cure_blind(NO_EYES)

	// Ensures that non-player mobs get their eye colors assigned, as players get them from prefs
	if (ishuman(receiver))
		var/mob/living/carbon/human/as_human = receiver
		if (!eye_color_left)
			eye_color_left = as_human.eye_color_left
		if (!eye_color_right)
			eye_color_right = as_human.eye_color_right
		RegisterSignals(receiver, list(
			SIGNAL_ADDTRAIT(TRAIT_LUMINESCENT_EYES),
			SIGNAL_REMOVETRAIT(TRAIT_LUMINESCENT_EYES),
			SIGNAL_ADDTRAIT(TRAIT_REFLECTIVE_EYES),
			SIGNAL_REMOVETRAIT(TRAIT_REFLECTIVE_EYES),
		), PROC_REF(on_shiny_eyes_trait_update))

	refresh(receiver, call_update = TRUE)
	RegisterSignal(receiver, COMSIG_ATOM_BULLET_ACT, PROC_REF(on_bullet_act))
	RegisterSignal(receiver, COMSIG_COMPONENT_CLEAN_FACE_ACT, PROC_REF(on_face_wash))

	if (scarring)
		apply_scarring_effects()

/// Refreshes the visuals of the eyes
/// If call_update is TRUE, we also will call update_body
/obj/item/organ/eyes/proc/refresh(mob/living/carbon/eye_owner = owner, call_update = TRUE)
	owner.update_sight()
	owner.update_tint()

	if(!ishuman(eye_owner))
		return

	var/mob/living/carbon/human/affected_human = eye_owner
	if(eye_color_left)
		affected_human.add_eye_color_left(eye_color_left, EYE_COLOR_ORGAN_PRIORITY, update_body = FALSE)
	if(eye_color_right)
		affected_human.add_eye_color_right(eye_color_right, EYE_COLOR_ORGAN_PRIORITY, update_body = FALSE)
	refresh_atom_color_overrides()

	if(HAS_TRAIT(affected_human, TRAIT_NIGHT_VISION) && !lighting_cutoff)
		lighting_cutoff = LIGHTING_CUTOFF_REAL_LOW
	if(CONFIG_GET(flag/native_fov) && native_fov)
		affected_human.add_fov_trait(type, native_fov)

	if(call_update)
		affected_human.update_eyes()

/obj/item/organ/eyes/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()

	if(ishuman(organ_owner))
		var/mob/living/carbon/human/human_owner = organ_owner
		human_owner.remove_eye_color(EYE_COLOR_ORGAN_PRIORITY, update_body = FALSE)
		for(var/i in 1 to COLOUR_PRIORITY_AMOUNT)
			human_owner.remove_eye_color(EYE_COLOR_ATOM_COLOR_PRIORITY + i, update_body = FALSE)
		if(native_fov)
			organ_owner.remove_fov_trait(type)
		if(!special)
			human_owner.update_eyes(refresh = FALSE)

	// become blind (if not special)
	if(!special)
		organ_owner.become_blind(NO_EYES)

	// Cure blindness from eye damage
	organ_owner.cure_blind(EYE_DAMAGE)
	organ_owner.cure_nearsighted(EYE_DAMAGE)
	// Eye blind and temp blind go to, even if this is a bit of cheesy way to clear blindness
	organ_owner.remove_status_effect(/datum/status_effect/eye_blur)
	organ_owner.remove_status_effect(/datum/status_effect/temporary_blindness)

	if (scarring)
		organ_owner.cure_nearsighted(TRAIT_RIGHT_EYE_SCAR)
		organ_owner.cure_nearsighted(TRAIT_LEFT_EYE_SCAR)
		organ_owner.cure_blind(EYE_SCARRING_TRAIT)

	organ_owner.update_tint()
	organ_owner.update_sight()
	UnregisterSignal(organ_owner, list(
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_COMPONENT_CLEAN_FACE_ACT,
		SIGNAL_ADDTRAIT(TRAIT_LUMINESCENT_EYES),
		SIGNAL_REMOVETRAIT(TRAIT_LUMINESCENT_EYES),
		SIGNAL_ADDTRAIT(TRAIT_REFLECTIVE_EYES),
		SIGNAL_REMOVETRAIT(TRAIT_REFLECTIVE_EYES),
	))

///Called whenever the luminescent and/or reflective eyes traits are added or removed
/obj/item/organ/eyes/proc/on_shiny_eyes_trait_update(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	source.update_eyes()

/obj/item/organ/eyes/update_atom_colour()
	. = ..()
	if (ishuman(owner))
		refresh_atom_color_overrides()
		owner.update_eyes()

/// Adds eye color overrides to our owner from our atom color
/obj/item/organ/eyes/proc/refresh_atom_color_overrides()
	if (!atom_colours)
		return

	var/mob/living/carbon/human/human_owner = owner
	for(var/i in 1 to COLOUR_PRIORITY_AMOUNT)
		var/list/checked_color = atom_colours[i]
		if (!checked_color)
			human_owner.remove_eye_color(EYE_COLOR_ATOM_COLOR_PRIORITY + i, update_body = FALSE)
			continue

		var/left_color = COLOR_WHITE
		var/right_color = COLOR_WHITE

		if (eye_color_left)
			left_color = eye_color_left
		if (eye_color_right)
			right_color = eye_color_right

		if (checked_color[ATOM_COLOR_TYPE_INDEX] == ATOM_COLOR_TYPE_FILTER)
			var/color_filter = checked_color[ATOM_COLOR_VALUE_INDEX]
			left_color = apply_matrix_to_color(left_color, color_filter["color"], color_filter["space"] || COLORSPACE_RGB)
			right_color = apply_matrix_to_color(right_color, color_filter["color"], color_filter["space"] || COLORSPACE_RGB)
		else
			var/list/target_color = color_transition_filter(checked_color[ATOM_COLOR_VALUE_INDEX], SATURATION_OVERRIDE)
			left_color = apply_matrix_to_color(left_color, target_color["color"], COLORSPACE_HSL)
			right_color = apply_matrix_to_color(right_color, target_color["color"], COLORSPACE_HSL)

		human_owner.add_eye_color_left(left_color, EYE_COLOR_ATOM_COLOR_PRIORITY + i, update_body = FALSE)
		human_owner.add_eye_color_right(right_color, EYE_COLOR_ATOM_COLOR_PRIORITY + i, update_body = FALSE)

/obj/item/organ/eyes/proc/on_bullet_act(mob/living/carbon/source, obj/projectile/proj, def_zone, piercing_hit, blocked)
	SIGNAL_HANDLER

	// Once-a-dozen-rounds level of rare
	if (def_zone != BODY_ZONE_HEAD || !prob(proj.damage * 0.1) || !(proj.damage_type == BRUTE || proj.damage_type == BURN))
		return

	if (blocked && source.is_eyes_covered())
		if (!proj.armour_penetration || prob(blocked - proj.armour_penetration))
			return

	var/valid_sides = list()
	if (!(scarring & RIGHT_EYE_SCAR))
		valid_sides += RIGHT_EYE_SCAR
	if (!(scarring & LEFT_EYE_SCAR))
		valid_sides += LEFT_EYE_SCAR
	if (!length(valid_sides))
		return

	var/picked_side = pick(valid_sides)
	to_chat(owner, span_userdanger("You feel searing pain shoot though your [picked_side == RIGHT_EYE_SCAR ? "right" : "left"] eye!"))
	// oof ouch my eyes
	apply_organ_damage(rand((maxHealth - high_threshold) * 0.5, maxHealth - low_threshold))
	var/datum/wound/pierce/bleed/severe/eye/eye_puncture = new
	eye_puncture.apply_wound(bodypart_owner, wound_source = "bullet impact", right_side = picked_side)
	apply_scar(picked_side)

/// When our owner washes their face. The idea that spessmen wash their eyeballs is highly disturbing but this is the easiest way to get rid of cursed crayon eye coloring
/obj/item/organ/eyes/proc/on_face_wash()
	SIGNAL_HANDLER
	wash(CLEAN_WASH)

#define OFFSET_X 1
#define OFFSET_Y 2

/// Similar to get_status_text, but appends the text after the damage report, for additional status info
/obj/item/organ/eyes/get_status_appendix(advanced, add_tooltips)
	if(owner.stat == DEAD || HAS_TRAIT(owner, TRAIT_KNOCKEDOUT))
		return
	if(owner.is_blind())
		if(advanced)
			if(owner.is_blind_from(QUIRK_TRAIT))
				return conditional_tooltip("Subject is permanently blind.", "Irreparable under normal circumstances.", add_tooltips)
			if(owner.is_blind_from(EYE_SCARRING_TRAIT))
				return conditional_tooltip("Subject is blind from widespread ocular scarring.", "Surgically replace eyes, irreparable otherwise.", add_tooltips)
			if(owner.is_blind_from(TRAUMA_TRAIT))
				return conditional_tooltip("Subject is blind from mental trauma.", "Repair via treatment of associated trauma.", add_tooltips)
			if(owner.is_blind_from(GENETIC_MUTATION))
				return conditional_tooltip("Subject is genetically blind.", "Use medication such as [/datum/reagent/medicine/mutadone::name].", add_tooltips)
			if(owner.is_blind_from(EYE_DAMAGE))
				return conditional_tooltip("Subject is blind from eye damage.", "Repair surgically, use medication such as [/datum/reagent/medicine/oculine::name], or protect eyes with a blindfold.", add_tooltips)
		return "Subject is blind."
	if(owner.is_nearsighted())
		if(advanced)
			if(owner.is_nearsighted_from(QUIRK_TRAIT))
				return conditional_tooltip("Subject is permanently nearsighted.", "Irreparable under normal circumstances. Prescription glasses will assuage the effects.", add_tooltips)
			if(owner.is_nearsighted_from(TRAIT_RIGHT_EYE_SCAR) || owner.is_nearsighted_from(TRAIT_LEFT_EYE_SCAR))
				return conditional_tooltip("Subject is nearsighted from severe ocular scarring.", "Surgically replace eyes, irreparable otherwise.", add_tooltips)
			if(owner.is_nearsighted_from(GENETIC_MUTATION))
				return conditional_tooltip("Subject is genetically nearsighted.", "Use medication such as [/datum/reagent/medicine/mutadone::name]. Prescription glasses will assuage the effects.", add_tooltips)
			if(owner.is_nearsighted_from(EYE_DAMAGE))
				return conditional_tooltip("Subject is nearsighted from eye damage.", "Repair surgically or use medication such as [/datum/reagent/medicine/oculine::name]. Prescription glasses will assuage the effects.", add_tooltips)
		return "Subject is nearsighted."
	return ""

/obj/item/organ/eyes/show_on_condensed_scans()
	// Always show if we have an appendix
	return ..() || (owner.stat != DEAD && !HAS_TRAIT(owner, TRAIT_KNOCKEDOUT) && (owner.is_blind() || owner.is_nearsighted()))

/// This proc generates a list of overlays that the eye displays on the given head
/obj/item/organ/eyes/proc/generate_body_overlay(obj/item/bodypart/head/my_head)
	if(!eye_icon_state || isnull(my_head))
		return list()

	var/mutable_appearance/eye_left = mutable_appearance(eye_icon, "[eye_icon_state]_l", -EYES_LAYER)
	var/mutable_appearance/eye_right = mutable_appearance(eye_icon, "[eye_icon_state]_r", -EYES_LAYER)
	var/list/overlays = list(eye_left, eye_right)

	if(my_head.owner && !(my_head.owner.obscured_slots & HIDEEYES))
		overlays += get_emissive_overlays(eye_left, eye_right, my_head)

	if(my_head.head_flags & HEAD_EYECOLOR)
		eye_right.color = eye_color_left || my_head.owner?.get_right_eye_color()
		eye_left.color = eye_color_right || my_head.owner?.get_left_eye_color()
		var/list/eyelids = setup_eyelids(eye_left, eye_right, my_head)
		if (LAZYLEN(eyelids))
			overlays += eyelids

	if (scarring & RIGHT_EYE_SCAR)
		var/mutable_appearance/right_scar = mutable_appearance('icons/mob/human/human_eyes.dmi', "eye_scar_right", -EYES_LAYER)
		right_scar.color = my_head.draw_color
		overlays += right_scar

	if (scarring & LEFT_EYE_SCAR)
		var/mutable_appearance/left_scar = mutable_appearance('icons/mob/human/human_eyes.dmi', "eye_scar_left", -EYES_LAYER)
		left_scar.color = my_head.draw_color
		overlays += left_scar

	if(my_head.worn_face_offset)
		for (var/mutable_appearance/overlay as anything in overlays)
			my_head.worn_face_offset.apply_offset(overlay)

	return overlays

///Returns the two emissive overlays built for the left and right eyes, in order.
/obj/item/organ/eyes/proc/get_emissive_overlays(mutable_appearance/eye_left, mutable_appearance/eye_right, atom/spokesman)
	var/list/return_list = list()
	var/emissive_effect
	if((owner && HAS_TRAIT(owner, TRAIT_LUMINESCENT_EYES)) || (TRAIT_LUMINESCENT_EYES in organ_traits))
		emissive_effect = EMISSIVE_BLOOM
	else if((owner && HAS_TRAIT(owner, TRAIT_REFLECTIVE_EYES)) || (TRAIT_REFLECTIVE_EYES in organ_traits))
		emissive_effect = EMISSIVE_SPECULAR

	if(emissive_effect)
		return_list += emissive_appearance(eye_left.icon, eye_left.icon_state, spokesman, -EYES_LAYER, alpha = eye_left.alpha, effect_type = emissive_effect)
		return_list += emissive_appearance(eye_right.icon, eye_right.icon_state, spokesman, -EYES_LAYER, alpha = eye_right.alpha, effect_type = emissive_effect)
	else
		return_list += emissive_blocker(eye_left.icon, eye_left.icon_state, spokesman, -EYES_LAYER, alpha = eye_left.alpha)
		return_list += emissive_blocker(eye_right.icon, eye_right.icon_state, spokesman, -EYES_LAYER, alpha = eye_right.alpha)

	return return_list

/obj/item/organ/eyes/update_overlays()
	. = ..()
	if (scarring & RIGHT_EYE_SCAR)
		var/mutable_appearance/right_scar = mutable_appearance('icons/obj/medical/organs/organs.dmi', "eye_scar_right")
		right_scar.blend_mode = BLEND_INSET_OVERLAY
		. += right_scar

	if (scarring & LEFT_EYE_SCAR)
		var/mutable_appearance/left_scar = mutable_appearance('icons/obj/medical/organs/organs.dmi', "eye_scar_left")
		left_scar.blend_mode = BLEND_INSET_OVERLAY
		. += left_scar

	if (iris_overlay && eye_color_left && eye_color_right)
		var/mutable_appearance/left_iris = mutable_appearance(icon, "[iris_overlay]_l")
		var/mutable_appearance/right_iris = mutable_appearance(icon, "[iris_overlay]_r")
		var/list/color_left = rgb2num(eye_color_left, COLORSPACE_HSL)
		var/list/color_right = rgb2num(eye_color_right, COLORSPACE_HSL)
		// Ugly as sin? Indeed it is! But otherwise eyeballs turn out to be super dark, and this way even lighter colors are mostly preserved
		if (color_left[3])
			color_left[3] /= sqrt(color_left[3] * 0.01)
		if (color_right[3])
			color_right[3] /= sqrt(color_right[3] * 0.01)
		left_iris.color = rgb(color_left[1], color_left[2], color_left[3], space = COLORSPACE_HSL)
		right_iris.color = rgb(color_right[1], color_right[2], color_right[3], space = COLORSPACE_HSL)
		. += left_iris
		. += right_iris

/obj/item/organ/eyes/proc/apply_scar(side)
	if (scarring & side)
		return
	scarring |= side
	maxHealth -= 15
	update_appearance()
	apply_scarring_effects()

/obj/item/organ/eyes/proc/apply_scarring_effects()
	if(!owner)
		return
	// Even if eyes have enough health, our owner still becomes nearsighted
	if(scarring & RIGHT_EYE_SCAR)
		owner.assign_nearsightedness(TRAIT_RIGHT_EYE_SCAR, 1, FALSE)
	if(scarring & LEFT_EYE_SCAR)
		owner.assign_nearsightedness(TRAIT_LEFT_EYE_SCAR, 1, FALSE)
	if((scarring & RIGHT_EYE_SCAR) && (scarring & LEFT_EYE_SCAR))
		owner.become_blind(EYE_SCARRING_TRAIT)
	owner.update_eyes()

/obj/item/organ/eyes/proc/fix_scar(side)
	if (!(scarring & side))
		return
	scarring &= ~side
	maxHealth += 15
	update_appearance()
	if (!owner)
		return
	owner.cure_nearsighted(side == RIGHT_EYE_SCAR ? TRAIT_RIGHT_EYE_SCAR : TRAIT_LEFT_EYE_SCAR)
	owner.cure_blind(EYE_SCARRING_TRAIT)
	owner.update_eyes()

#undef OFFSET_X
#undef OFFSET_Y

//Gotta reset the eye color, because that persists
/obj/item/organ/eyes/enter_wardrobe()
	. = ..()
	eye_color_left = initial(eye_color_left)
	eye_color_right = initial(eye_color_right)

/obj/item/organ/eyes/on_low_damage_received()
	if(damage >= high_threshold)
		return
	owner?.assign_nearsightedness(EYE_DAMAGE, 2, TRUE)

/obj/item/organ/eyes/on_high_damage_received()
	owner?.assign_nearsightedness(EYE_DAMAGE, 3, TRUE)

/obj/item/organ/eyes/on_begin_failure()
	owner?.become_blind(EYE_DAMAGE)

/obj/item/organ/eyes/on_failure_recovery()
	owner?.cure_blind(EYE_DAMAGE)

/obj/item/organ/eyes/on_high_damage_healed()
	if(damage <= low_threshold)
		return
	owner?.assign_nearsightedness(EYE_DAMAGE, 2, TRUE)

/obj/item/organ/eyes/on_low_damage_healed()
	// clear nearsightedness from damage
	owner?.cure_nearsighted(EYE_DAMAGE)

/obj/item/organ/eyes/feel_for_damage(self_aware)
	// Eye damage has visual effects, so we don't really need to "feel" it when self-examining
	return ""

#define BASE_BLINKING_DELAY 5 SECONDS
#define RAND_BLINKING_DELAY 1 SECONDS
#define BLINK_DURATION 0.15 SECONDS
#define BLINK_LOOPS 5

/// Modifies eye overlays to also act as eyelids, both for blinking and for when you're knocked out cold
/obj/item/organ/eyes/proc/setup_eyelids(mutable_appearance/eye_left, mutable_appearance/eye_right, obj/item/bodypart/head/my_head)
	var/mob/living/carbon/human/parent = my_head.owner
	// Robotic eyes or colorless heads don't get the privelege of having eyelids
	if (isnull(parent) || IS_ROBOTIC_ORGAN(src) || !my_head.draw_color || HAS_TRAIT(parent, TRAIT_NO_EYELIDS))
		return

	var/list/base_color = rgb2num(my_head.draw_color, COLORSPACE_HSL)
	base_color[2] *= 0.85
	base_color[3] *= 0.85
	var/eyelid_color = rgb(base_color[1], base_color[2], base_color[3], (length(base_color) >= 4 ? base_color[4] : null), COLORSPACE_HSL)
	// If we're knocked out, just color the eyes
	if (!parent.appears_alive() || HAS_TRAIT(parent, TRAIT_KNOCKEDOUT))
		eye_right.color = eyelid_color
		eye_left.color = eyelid_color
		return

	if (!blink_animation || HAS_TRAIT(parent, TRAIT_PREVENT_BLINKING))
		return

	eyelid_left.color = eyelid_color
	eyelid_right.color = eyelid_color
	eyelid_left.render_target = "*[REF(parent)]_eyelid_left"
	eyelid_right.render_target = "*[REF(parent)]_eyelid_right"
	parent.vis_contents += eyelid_left
	parent.vis_contents += eyelid_right
	animate_eyelids(parent)
	var/mutable_appearance/left_eyelid_overlay = mutable_appearance(layer = -EYES_LAYER, offset_spokesman = parent)
	var/mutable_appearance/right_eyelid_overlay = mutable_appearance(layer = -EYES_LAYER, offset_spokesman = parent)
	left_eyelid_overlay.render_source = "*[REF(parent)]_eyelid_left"
	right_eyelid_overlay.render_source = "*[REF(parent)]_eyelid_right"
	return list(left_eyelid_overlay, right_eyelid_overlay)

/// Animates one eyelid at a time, thanks BYOND and thanks animation chains
/obj/item/organ/eyes/proc/animate_eyelid(obj/effect/abstract/eyelid_effect/eyelid, mob/living/carbon/human/parent, sync_blinking = TRUE, list/anim_times = null)
	. = list()
	if(isnull(eyelid)) // Can't blink if we don't have an eyelid
		return
	var/prevent_loops = HAS_TRAIT(parent, TRAIT_PREVENT_BLINK_LOOPS)
	animate(eyelid, alpha = 0, time = 0, loop = (prevent_loops ? 0 : -1))

	var/wait_time = rand(BASE_BLINKING_DELAY - RAND_BLINKING_DELAY, BASE_BLINKING_DELAY + RAND_BLINKING_DELAY)
	if (anim_times)
		if (sync_blinking)
			wait_time = anim_times[1]
		else
			wait_time = rand(max(BASE_BLINKING_DELAY - RAND_BLINKING_DELAY, anim_times[1] - RAND_BLINKING_DELAY), anim_times[1])

	animate(time = wait_time)
	. += wait_time

	var/cycles = (prevent_loops ? 1 : BLINK_LOOPS)
	for (var/i in 1 to cycles)
		if (anim_times)
			if (sync_blinking)
				wait_time = anim_times[i + 1]
			else
				wait_time = rand(max(BASE_BLINKING_DELAY - RAND_BLINKING_DELAY, anim_times[i + 1] - RAND_BLINKING_DELAY), anim_times[i + 1])
		else
			wait_time = rand(BASE_BLINKING_DELAY - RAND_BLINKING_DELAY, BASE_BLINKING_DELAY + RAND_BLINKING_DELAY)
		. += wait_time
		if (anim_times && !sync_blinking)
			// Make sure that we're somewhat in sync with the other eye
			animate(time = anim_times[i + 1] - wait_time)
		animate(alpha = 255, time = 0)
		animate(time = BLINK_DURATION)
		if (i != cycles)
			animate(alpha = 0, time = 0)
			animate(time = wait_time)

/obj/item/organ/eyes/proc/blink(duration = BLINK_DURATION, restart_animation = TRUE)
	var/left_delayed = prob(50)
	// Storing blink delay so mistimed blinks of lizards don't get cut short
	var/sync_blinking = synchronized_blinking && (owner.get_organ_loss(ORGAN_SLOT_BRAIN) < BRAIN_DAMAGE_ASYNC_BLINKING)
	var/blink_delay = sync_blinking ? 0 : rand(0, RAND_BLINKING_DELAY)
	animate(eyelid_left, alpha = 0, time = 0)
	if (!sync_blinking && left_delayed)
		animate(time = blink_delay)
	animate(alpha = 255, time = 0)
	animate(time = duration)
	animate(alpha = 0, time = 0)
	animate(eyelid_right, alpha = 0, time = 0)
	if (!sync_blinking && !left_delayed)
		animate(time = blink_delay)
	animate(alpha = 255, time = 0)
	animate(time = duration)
	animate(alpha = 0, time = 0)
	if (restart_animation)
		addtimer(CALLBACK(src, PROC_REF(animate_eyelids), owner), blink_delay + duration)

/obj/item/organ/eyes/proc/animate_eyelids(mob/living/carbon/human/parent)
	var/sync_blinking = synchronized_blinking && (parent.get_organ_loss(ORGAN_SLOT_BRAIN) < BRAIN_DAMAGE_ASYNC_BLINKING)
	// Randomize order for unsynched animations
	if (sync_blinking || prob(50))
		var/list/anim_times = animate_eyelid(eyelid_left, parent, sync_blinking)
		animate_eyelid(eyelid_right, parent, sync_blinking, anim_times)
	else
		var/list/anim_times = animate_eyelid(eyelid_right, parent, sync_blinking)
		animate_eyelid(eyelid_left, parent, sync_blinking, anim_times)

/obj/effect/abstract/eyelid_effect
	name = "eyelid"
	icon = 'icons/mob/human/human_eyes.dmi'
	layer = -EYES_LAYER
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE | VIS_INHERIT_ID

/obj/effect/abstract/eyelid_effect/Initialize(mapload, new_state)
	. = ..()
	icon_state = new_state

#undef BASE_BLINKING_DELAY
#undef RAND_BLINKING_DELAY
#undef BLINK_DURATION
#undef BLINK_LOOPS

/// by default, returns the eyes' penlight_message var as a notice span. May do other things when overridden, such as eldritch insanity, or eye damage, or whatnot. Whatever you want, really.
/obj/item/organ/eyes/proc/penlight_examine(mob/living/viewer)
	return span_notice("[owner.p_Their()] eyes [penlight_message].")

#define NIGHTVISION_LIGHT_OFF 0
#define NIGHTVISION_LIGHT_LOW 1
#define NIGHTVISION_LIGHT_MID 2
#define NIGHTVISION_LIGHT_HIG 3

/obj/item/organ/eyes/night_vision
	abstract_type = /obj/item/organ/eyes/night_vision
	actions_types = list(/datum/action/item_action/organ_action/use)

	// These lists are used as the color cutoff for the eye
	// They need to be filled out for subtypes
	var/list/low_light_cutoff
	var/list/medium_light_cutoff
	var/list/high_light_cutoff
	var/light_level = NIGHTVISION_LIGHT_OFF

/obj/item/organ/eyes/night_vision/Initialize(mapload)
	. = ..()
	if (PERFORM_ALL_TESTS(focus_only/nightvision_color_cutoffs) && type != /obj/item/organ/eyes/night_vision)
		if(length(low_light_cutoff) != 3 || length(medium_light_cutoff) != 3 || length(high_light_cutoff) != 3)
			stack_trace("[type] did not have fully filled out color cutoff lists")
	if(low_light_cutoff)
		color_cutoffs = low_light_cutoff.Copy()
	light_level = NIGHTVISION_LIGHT_LOW

/obj/item/organ/eyes/night_vision/ui_action_click()
	sight_flags = initial(sight_flags)
	switch(light_level)
		if (NIGHTVISION_LIGHT_OFF)
			color_cutoffs = low_light_cutoff.Copy()
			light_level = NIGHTVISION_LIGHT_LOW
		if (NIGHTVISION_LIGHT_LOW)
			color_cutoffs = medium_light_cutoff.Copy()
			light_level = NIGHTVISION_LIGHT_MID
		if (NIGHTVISION_LIGHT_MID)
			color_cutoffs = high_light_cutoff.Copy()
			light_level = NIGHTVISION_LIGHT_HIG
		else
			color_cutoffs = null
			light_level = NIGHTVISION_LIGHT_OFF
	owner.update_sight()

#undef NIGHTVISION_LIGHT_OFF
#undef NIGHTVISION_LIGHT_LOW
#undef NIGHTVISION_LIGHT_MID
#undef NIGHTVISION_LIGHT_HIG
