/obj/item/organ/internal/eyes
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

	low_threshold_passed = "<span class='info'>Distant objects become somewhat less tangible.</span>"
	high_threshold_passed = "<span class='info'>Everything starts to look a lot less clear.</span>"
	now_failing = "<span class='warning'>Darkness envelopes you, as your eyes go blind!</span>"
	now_fixed = "<span class='info'>Color and shapes are once again perceivable.</span>"
	high_threshold_cleared = "<span class='info'>Your vision functions passably once more.</span>"
	low_threshold_cleared = "<span class='info'>Your vision is cleared of any ailment.</span>"

	/// Sight flags this eye pair imparts on its user.
	var/sight_flags = NONE
	/// changes how the eyes overlay is applied, makes it apply over the lighting layer
	var/overlay_ignore_lighting = FALSE
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

	var/eye_color_left = "" //set to a hex code to override a mob's left eye color
	var/eye_color_right = "" //set to a hex code to override a mob's right eye color
	var/eye_icon_state = "eyes"
	/// The color of the previous left eye before this one was inserted
	var/old_eye_color_left = "fff"
	/// The color of the previous right eye before this one was inserted
	var/old_eye_color_right = "fff"

	/// Glasses cannot be worn over these eyes. Currently unused
	var/no_glasses = FALSE
	/// indication that the eyes are undergoing some negative effect
	var/damaged = FALSE
	/// Native FOV that will be applied if a config is enabled
	var/native_fov = FOV_90_DEGREES

/obj/item/organ/internal/eyes/Insert(mob/living/carbon/eye_recipient, special = FALSE, movement_flags = DELETE_IF_REPLACED)
	// If we don't do this before everything else, heterochromia will be reset leading to eye_color_right no longer being accurate
	if(ishuman(eye_recipient))
		var/mob/living/carbon/human/human_recipient = eye_recipient
		old_eye_color_left = human_recipient.eye_color_left
		old_eye_color_right = human_recipient.eye_color_right

	. = ..()

	if(!.)
		return

	eye_recipient.cure_blind(NO_EYES)
	apply_damaged_eye_effects()
	refresh(eye_recipient, call_update = TRUE)

/// Refreshes the visuals of the eyes
/// If call_update is TRUE, we also will call update_body
/obj/item/organ/internal/eyes/proc/refresh(mob/living/carbon/eye_owner = owner, call_update = TRUE)
	owner.update_sight()
	owner.update_tint()

	if(!ishuman(eye_owner))
		return

	var/mob/living/carbon/human/affected_human = eye_owner
	if(initial(eye_color_left))
		affected_human.eye_color_left = eye_color_left
	else
		eye_color_left = affected_human.eye_color_left
	if(initial(eye_color_right))
		affected_human.eye_color_right = eye_color_right
	else
		eye_color_right = affected_human.eye_color_right
	if(HAS_TRAIT(affected_human, TRAIT_NIGHT_VISION) && !lighting_cutoff)
		lighting_cutoff = LIGHTING_CUTOFF_REAL_LOW
	if(CONFIG_GET(flag/native_fov) && native_fov)
		affected_human.add_fov_trait(type, native_fov)

	if(call_update)
		affected_human.update_body()

/obj/item/organ/internal/eyes/Remove(mob/living/carbon/eye_owner, special, movement_flags)
	. = ..()
	if(ishuman(eye_owner))
		var/mob/living/carbon/human/human_owner = eye_owner
		if(initial(eye_color_left))
			human_owner.eye_color_left = old_eye_color_left
		if(initial(eye_color_right))
			human_owner.eye_color_right = old_eye_color_right
		if(native_fov)
			eye_owner.remove_fov_trait(type)
		if(!special)
			human_owner.update_body()

	// Cure blindness from eye damage
	eye_owner.cure_blind(EYE_DAMAGE)
	eye_owner.cure_nearsighted(EYE_DAMAGE)
	// Eye blind and temp blind go to, even if this is a bit of cheesy way to clear blindness
	eye_owner.remove_status_effect(/datum/status_effect/eye_blur)
	eye_owner.remove_status_effect(/datum/status_effect/temporary_blindness)
	// Then become blind anyways (if not special)
	if(!special)
		eye_owner.become_blind(NO_EYES)

	eye_owner.update_tint()
	eye_owner.update_sight()

#define OFFSET_X 1
#define OFFSET_Y 2

/// This proc generates a list of overlays that the eye should be displayed using for the given parent
/obj/item/organ/internal/eyes/proc/generate_body_overlay(mob/living/carbon/human/parent)
	if(!istype(parent) || parent.get_organ_by_type(/obj/item/organ/internal/eyes) != src)
		CRASH("Generating a body overlay for [src] targeting an invalid parent '[parent]'.")

	if(isnull(eye_icon_state))
		return list()

	var/mutable_appearance/eye_left = mutable_appearance('icons/mob/human/human_face.dmi', "[eye_icon_state]_l", -BODY_LAYER)
	var/mutable_appearance/eye_right = mutable_appearance('icons/mob/human/human_face.dmi', "[eye_icon_state]_r", -BODY_LAYER)
	var/list/overlays = list(eye_left, eye_right)

	var/obscured = parent.check_obscured_slots(TRUE)
	if(overlay_ignore_lighting && !(obscured & ITEM_SLOT_EYES))
		overlays += emissive_appearance(eye_left.icon, eye_left.icon_state, parent, -BODY_LAYER, alpha = eye_left.alpha)
		overlays += emissive_appearance(eye_right.icon, eye_right.icon_state, parent, -BODY_LAYER, alpha = eye_right.alpha)
	var/obj/item/bodypart/head/my_head = parent.get_bodypart(BODY_ZONE_HEAD)
	if(my_head)
		if(my_head.head_flags & HEAD_EYECOLOR)
			eye_right.color = eye_color_right
			eye_left.color = eye_color_left
		if(my_head.worn_face_offset)
			my_head.worn_face_offset.apply_offset(eye_left)
			my_head.worn_face_offset.apply_offset(eye_right)

	return overlays

#undef OFFSET_X
#undef OFFSET_Y

//Gotta reset the eye color, because that persists
/obj/item/organ/internal/eyes/enter_wardrobe()
	. = ..()
	eye_color_left = initial(eye_color_left)
	eye_color_right = initial(eye_color_right)

/obj/item/organ/internal/eyes/apply_organ_damage(damage_amount, maximum = maxHealth, required_organ_flag)
	. = ..()
	if(!owner)
		return FALSE
	apply_damaged_eye_effects()

/// Applies effects to our owner based on how damaged our eyes are
/obj/item/organ/internal/eyes/proc/apply_damaged_eye_effects()
	// we're in healthy threshold, either try to heal (if damaged) or do nothing
	if(damage <= low_threshold)
		if(damaged)
			damaged = FALSE
			// clear nearsightedness from damage
			owner.cure_nearsighted(EYE_DAMAGE)
			// if we're still nearsighted, reset its severity
			// this is kinda icky, ideally we'd track severity to source but that's way more complex
			var/datum/status_effect/grouped/nearsighted/nearsightedness = owner.is_nearsighted()
			nearsightedness?.set_nearsighted_severity(1)
			// and cure blindness from damage
			owner.cure_blind(EYE_DAMAGE)
		return

	//various degrees of "oh fuck my eyes", from "point a laser at your eye" to "staring at the Sun" intensities
	// 50 - blind
	// 49-31 - nearsighted (2 severity)
	// 30-20 - nearsighted (1 severity)
	if(organ_flags & ORGAN_FAILING)
		// become blind from damage
		owner.become_blind(EYE_DAMAGE)

	else
		// become nearsighted from damage
		owner.become_nearsighted(EYE_DAMAGE)
		// update the severity of our nearsightedness based on our eye damage
		var/datum/status_effect/grouped/nearsighted/nearsightedness = owner.is_nearsighted()
		nearsightedness.set_nearsighted_severity(damage > high_threshold ? 2 : 1)

	damaged = TRUE

#define NIGHTVISION_LIGHT_OFF 0
#define NIGHTVISION_LIGHT_LOW 1
#define NIGHTVISION_LIGHT_MID 2
#define NIGHTVISION_LIGHT_HIG 3

/obj/item/organ/internal/eyes/night_vision
	actions_types = list(/datum/action/item_action/organ_action/use)

	// These lists are used as the color cutoff for the eye
	// They need to be filled out for subtypes
	var/list/low_light_cutoff
	var/list/medium_light_cutoff
	var/list/high_light_cutoff
	var/light_level = NIGHTVISION_LIGHT_OFF

/obj/item/organ/internal/eyes/night_vision/Initialize(mapload)
	. = ..()
	if (PERFORM_ALL_TESTS(focus_only/nightvision_color_cutoffs) && type != /obj/item/organ/internal/eyes/night_vision)
		if(length(low_light_cutoff) != 3 || length(medium_light_cutoff) != 3 || length(high_light_cutoff) != 3)
			stack_trace("[type] did not have fully filled out color cutoff lists")
	if(low_light_cutoff)
		color_cutoffs = low_light_cutoff.Copy()
	light_level = NIGHTVISION_LIGHT_LOW

/obj/item/organ/internal/eyes/night_vision/ui_action_click()
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

/obj/item/organ/internal/eyes/night_vision/mushroom
	name = "fung-eye"
	desc = "While on the outside they look inert and dead, the eyes of mushroom people are actually very advanced."
	low_light_cutoff = list(0, 15, 20)
	medium_light_cutoff = list(0, 20, 35)
	high_light_cutoff = list(0, 40, 50)

/obj/item/organ/internal/eyes/zombie
	name = "undead eyes"
	desc = "Somewhat counterintuitively, these half-rotten eyes actually have superior vision to those of a living human."
	color_cutoffs = list(25, 35, 5)

/obj/item/organ/internal/eyes/alien
	name = "alien eyes"
	desc = "It turned out they had them after all!"
	sight_flags = SEE_MOBS
	color_cutoffs = list(25, 5, 42)

/obj/item/organ/internal/eyes/golem
	name = "resonating crystal"
	icon_state = "adamantine_cords"
	eye_icon_state = null
	desc = "Golems somehow measure external light levels and detect nearby ore using this sensitive mineral lattice."
	color = COLOR_GOLEM_GRAY
	visual = FALSE
	organ_flags = ORGAN_MINERAL
	color_cutoffs = list(10, 15, 5)
	actions_types = list(/datum/action/cooldown/golem_ore_sight)

/// Send an ore detection pulse on a cooldown
/datum/action/cooldown/golem_ore_sight
	name = "Ore Resonance"
	desc = "Causes nearby ores to vibrate, revealing their location."
	button_icon = 'icons/obj/devices/scanner.dmi'
	button_icon_state = "manual_mining"
	check_flags = AB_CHECK_CONSCIOUS
	cooldown_time = 10 SECONDS

/datum/action/cooldown/golem_ore_sight/Activate(atom/target)
	. = ..()
	mineral_scan_pulse(get_turf(target), scanner = target)

///Robotic

/obj/item/organ/internal/eyes/robotic
	name = "robotic eyes"
	icon_state = "cybernetic_eyeballs"
	desc = "Your vision is augmented."
	organ_flags = ORGAN_ROBOTIC
	failing_desc = "seems to be broken."

/obj/item/organ/internal/eyes/robotic/emp_act(severity)
	. = ..()
	if((. & EMP_PROTECT_SELF) || !owner)
		return
	if(prob(10 * severity))
		return
	to_chat(owner, span_warning("Static obfuscates your vision!"))
	owner.flash_act(visual = 1)

/obj/item/organ/internal/eyes/robotic/basic
	name = "basic robotic eyes"
	desc = "A pair of basic cybernetic eyes that restore vision, but at some vulnerability to light."
	eye_color_left = "5500ff"
	eye_color_right = "5500ff"
	flash_protect = FLASH_PROTECTION_SENSITIVE

/obj/item/organ/internal/eyes/robotic/basic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(10 * severity))
		apply_organ_damage(20 * severity)
		to_chat(owner, span_warning("Your eyes start to fizzle in their sockets!"))
		do_sparks(2, TRUE, owner)
		owner.emote("scream")

/obj/item/organ/internal/eyes/robotic/xray
	name = "\improper X-ray eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	eye_color_left = "000"
	eye_color_right = "000"
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS

/obj/item/organ/internal/eyes/robotic/xray/on_mob_insert(mob/living/carbon/eye_owner)
	. = ..()
	ADD_TRAIT(eye_owner, TRAIT_XRAY_VISION, ORGAN_TRAIT)

/obj/item/organ/internal/eyes/robotic/xray/on_mob_remove(mob/living/carbon/eye_owner)
	. = ..()
	REMOVE_TRAIT(eye_owner, TRAIT_XRAY_VISION, ORGAN_TRAIT)

/obj/item/organ/internal/eyes/robotic/thermals
	name = "thermal eyes"
	desc = "These cybernetic eye implants will give you thermal vision. Vertical slit pupil included."
	eye_color_left = "FC0"
	eye_color_right = "FC0"
	// We're gonna downshift green and blue a bit so darkness looks yellow
	color_cutoffs = list(25, 8, 5)
	sight_flags = SEE_MOBS
	flash_protect = FLASH_PROTECTION_SENSITIVE

/obj/item/organ/internal/eyes/robotic/flashlight
	name = "flashlight eyes"
	desc = "It's two flashlights rigged together with some wire. Why would you put these in someone's head?"
	eye_color_left ="fee5a3"
	eye_color_right ="fee5a3"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight_eyes"
	flash_protect = FLASH_PROTECTION_WELDER
	tint = INFINITY
	var/obj/item/flashlight/eyelight/eye

/obj/item/organ/internal/eyes/robotic/flashlight/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

/obj/item/organ/internal/eyes/robotic/flashlight/on_mob_insert(mob/living/carbon/victim)
	. = ..()
	if(!eye)
		eye = new /obj/item/flashlight/eyelight()
	eye.set_light_on(TRUE)
	eye.forceMove(victim)
	eye.update_brightness(victim)
	victim.become_blind(FLASHLIGHT_EYES)

/obj/item/organ/internal/eyes/robotic/flashlight/on_mob_remove(mob/living/carbon/victim)
	. = ..()
	eye.set_light_on(FALSE)
	eye.update_brightness(victim)
	eye.forceMove(src)
	victim.cure_blind(FLASHLIGHT_EYES)

// Welding shield implant
/obj/item/organ/internal/eyes/robotic/shield
	name = "shielded robotic eyes"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/organ/internal/eyes/robotic/shield/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/empprotection, EMP_PROTECT_ALL)

#define MATCH_LIGHT_COLOR 1
#define USE_CUSTOM_COLOR 0
#define UPDATE_LIGHT 0
#define UPDATE_EYES_LEFT 1
#define UPDATE_EYES_RIGHT 2

/obj/item/organ/internal/eyes/robotic/glow
	name = "High Luminosity Eyes"
	desc = "Special glowing eyes, used by snowflakes who want to be special."
	eye_color_left = "000"
	eye_color_right = "000"
	actions_types = list(/datum/action/item_action/organ_action/use, /datum/action/item_action/organ_action/toggle)
	var/max_light_beam_distance = 5
	var/obj/item/flashlight/eyelight/glow/eye
	/// base icon state for eye overlays
	var/base_eye_state = "eyes_glow_gs"
	/// Whether or not to match the eye color to the light or use a custom selection
	var/eye_color_mode = USE_CUSTOM_COLOR
	/// The selected color for the light beam itself
	var/light_color_string = "#ffffff"
	/// The custom selected eye color for the left eye. Defaults to the mob's natural eye color
	var/left_eye_color_string
	/// The custom selected eye color for the right eye. Defaults to the mob's natural eye color
	var/right_eye_color_string

/obj/item/organ/internal/eyes/robotic/glow/Initialize(mapload)
	. = ..()
	eye = new /obj/item/flashlight/eyelight/glow

/obj/item/organ/internal/eyes/robotic/glow/Destroy()
	. = ..()
	deactivate(close_ui = TRUE)
	QDEL_NULL(eye)

/obj/item/organ/internal/eyes/robotic/glow/emp_act(severity)
	. = ..()
	if(!eye.light_on || . & EMP_PROTECT_SELF)
		return
	deactivate(close_ui = TRUE)

/// Set the initial color of the eyes on insert to be the mob's previous eye color.
/obj/item/organ/internal/eyes/robotic/glow/Insert(mob/living/carbon/eye_recipient, special = FALSE, movement_flags = DELETE_IF_REPLACED)
	. = ..()
	left_eye_color_string = old_eye_color_left
	right_eye_color_string = old_eye_color_right
	update_mob_eye_color(eye_recipient)

/obj/item/organ/internal/eyes/robotic/glow/on_mob_insert(mob/living/carbon/eye_recipient)
	. = ..()
	deactivate(close_ui = TRUE)
	eye.forceMove(eye_recipient)

/obj/item/organ/internal/eyes/robotic/glow/on_mob_remove(mob/living/carbon/eye_owner)
	deactivate(eye_owner, close_ui = TRUE)
	if(!QDELETED(eye))
		eye.forceMove(src)
	return ..()

/obj/item/organ/internal/eyes/robotic/glow/ui_state(mob/user)
	return GLOB.default_state

/obj/item/organ/internal/eyes/robotic/glow/ui_status(mob/user, datum/ui_state/state)
	if(!QDELETED(owner))
		if(owner == user)
			return min(
				ui_status_user_is_abled(user, src),
				ui_status_only_living(user),
			)
		else return UI_CLOSE
	return ..()

/obj/item/organ/internal/eyes/robotic/glow/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HighLuminosityEyesMenu")
		ui.autoupdate = FALSE
		ui.open()

/obj/item/organ/internal/eyes/robotic/glow/ui_data(mob/user)
	var/list/data = list()

	data["eyeColor"] = list(
		mode = eye_color_mode,
		hasOwner = owner ? TRUE : FALSE,
		left = left_eye_color_string,
		right = right_eye_color_string,
	)
	data["lightColor"] = light_color_string
	data["range"] = eye.light_range

	return data

/obj/item/organ/internal/eyes/robotic/glow/ui_act(action, list/params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("set_range")
			var/new_range = params["new_range"]
			set_beam_range(new_range)
			return TRUE
		if("pick_color")
			var/new_color = input(
				usr,
				"Choose eye color color:",
				"High Luminosity Eyes Menu",
				light_color_string
			) as color|null
			if(new_color)
				var/to_update = params["to_update"]
				set_beam_color(new_color, to_update)
				return TRUE
		if("enter_color")
			var/new_color = LOWER_TEXT(params["new_color"])
			var/to_update = params["to_update"]
			set_beam_color(new_color, to_update, sanitize = TRUE)
			return TRUE
		if("random_color")
			var/to_update = params["to_update"]
			randomize_color(to_update)
			return TRUE
		if("toggle_eye_color")
			toggle_eye_color_mode()
			return TRUE

/obj/item/organ/internal/eyes/robotic/glow/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/organ_action/toggle))
		toggle_active()
	else if(istype(action, /datum/action/item_action/organ_action/use))
		ui_interact(user)

/**
 * Activates the light
 *
 * Turns on the attached flashlight object, updates the mob overlay to be added.
 */
/obj/item/organ/internal/eyes/robotic/glow/proc/activate()
	if(eye.light_range)
		eye.set_light_on(TRUE)
	else
		eye.light_on = TRUE // at range 0 we are just going to make the eyes glow emissively, no light overlay
	update_mob_eye_color()

/**
 * Deactivates the light
 *
 * Turns off the attached flashlight object, closes UIs, updates the mob overlay to be removed.
 * Arguments:
 * * mob/living/carbon/eye_owner - the mob who the eyes belong to
 * * close_ui - whether or not to close the ui
 */
/obj/item/organ/internal/eyes/robotic/glow/proc/deactivate(mob/living/carbon/eye_owner = owner, close_ui = FALSE)
	if(close_ui)
		SStgui.close_uis(src)
	eye.set_light_on(FALSE)
	update_mob_eye_color(eye_owner)

/**
 * Randomizes the light color
 *
 * Picks a random color and sets the beam color to that
 * Arguments:
 * * to_update - whether we are setting the color for the light beam itself, or the individual eyes
 */
/obj/item/organ/internal/eyes/robotic/glow/proc/randomize_color(to_update = UPDATE_LIGHT)
	var/new_color = "#"
	for(var/i in 1 to 3)
		new_color += num2hex(rand(0, 255), 2)
	set_beam_color(new_color, to_update)

/**
 * Setter function for the light's range
 *
 * Sets the light range of the attached flashlight object
 * Includes some 'unique' logic to accomodate for some quirks of the lighting system
 * Arguments:
 * * new_range - the new range to set
 */
/obj/item/organ/internal/eyes/robotic/glow/proc/set_beam_range(new_range)
	var/old_light_range = eye.light_range
	if(old_light_range == 0 && new_range > 0 && eye.light_on) // turn bring back the light overlay if we were previously at 0 (aka emissive eyes only)
		eye.light_on = FALSE // this is stupid, but this has to be FALSE for set_light_on() to work.
		eye.set_light_on(TRUE)
	eye.set_light_range(clamp(new_range, 0, max_light_beam_distance))

/**
 * Setter function for the light's color
 *
 * Sets the light color of the attached flashlight object. Sets the eye color vars of this eye organ as well and then updates the mob's eye color.
 * Arguments:
 * * newcolor - the new color hex string to set
 * * to_update - whether we are setting the color for the light beam itself, or the individual eyes
 * * sanitize - whether the hex string should be sanitized
 */
/obj/item/organ/internal/eyes/robotic/glow/proc/set_beam_color(newcolor, to_update = UPDATE_LIGHT, sanitize = FALSE)
	var/newcolor_string
	if(sanitize)
		newcolor_string = sanitize_hexcolor(newcolor)
	else
		newcolor_string = newcolor
	switch(to_update)
		if(UPDATE_LIGHT)
			light_color_string = newcolor_string
			eye.set_light_color(newcolor_string)
		if(UPDATE_EYES_LEFT)
			left_eye_color_string = newcolor_string
		if(UPDATE_EYES_RIGHT)
			right_eye_color_string = newcolor_string

	update_mob_eye_color()

/**
 * Toggle the attached flashlight object on or off
 */
/obj/item/organ/internal/eyes/robotic/glow/proc/toggle_active()
	if(eye.light_on)
		deactivate()
	else
		activate()

/**
 * Toggles for the eye color mode
 *
 * Toggles the eye color mode on or off and then calls an update on the mob's eye color
 */
/obj/item/organ/internal/eyes/robotic/glow/proc/toggle_eye_color_mode()
	eye_color_mode = !eye_color_mode
	update_mob_eye_color()

/**
 * Updates the mob eye color
 *
 * Updates the eye color to reflect on the mob's body if it's possible to do so
 * Arguments:
 * * mob/living/carbon/eye_owner - the mob to update the eye color appearance of
 */
/obj/item/organ/internal/eyes/robotic/glow/proc/update_mob_eye_color(mob/living/carbon/eye_owner = owner)
	switch(eye_color_mode)
		if(MATCH_LIGHT_COLOR)
			eye_color_left = light_color_string
			eye_color_right = light_color_string
		if(USE_CUSTOM_COLOR)
			eye_color_left = left_eye_color_string
			eye_color_right = right_eye_color_string

	if(QDELETED(eye_owner) || !ishuman(eye_owner)) //Other carbon mobs don't have eye color.
		return

	if(!eye.light_on)
		eye_icon_state = initial(eye_icon_state)
		overlay_ignore_lighting = FALSE
	else
		overlay_ignore_lighting = TRUE
		eye_icon_state = base_eye_state

	var/obj/item/bodypart/head/head = eye_owner.get_bodypart(BODY_ZONE_HEAD) //if we have eyes we definently have a head anyway
	var/previous_flags = head.head_flags
	head.head_flags = previous_flags | HEAD_EYECOLOR
	eye_owner.dna.species.handle_body(eye_owner)
	head.head_flags = previous_flags

#undef MATCH_LIGHT_COLOR
#undef USE_CUSTOM_COLOR
#undef UPDATE_LIGHT
#undef UPDATE_EYES_LEFT
#undef UPDATE_EYES_RIGHT

/obj/item/organ/internal/eyes/moth
	name = "moth eyes"
	desc = "These eyes seem to have increased sensitivity to bright light, with no improvement to low light vision."
	eye_icon_state = "motheyes"
	icon_state = "eyeballs-moth"
	flash_protect = FLASH_PROTECTION_SENSITIVE

/obj/item/organ/internal/eyes/robotic/moth
	name = "robotic moth eyes"
	eye_icon_state = "motheyes"
	icon_state = "eyeballs-cybermoth"
	desc = "Your vision is augmented. Much like actual moth eyes, very sensitive to bright lights."
	flash_protect = FLASH_PROTECTION_SENSITIVE

/obj/item/organ/internal/eyes/robotic/basic/moth
	name = "basic robotic moth eyes"
	eye_icon_state = "motheyes"
	icon_state = "eyeballs-cybermoth"
	flash_protect = FLASH_PROTECTION_SENSITIVE

/obj/item/organ/internal/eyes/robotic/xray/moth
	name = "robotic eyes"
	eye_icon_state = "motheyes"
	icon_state = "eyeballs-cybermoth"
	desc = "These cybernetic imitation moth eyes will give you X-ray vision. Blinking is futile. Much like actual moth eyes, very sensitive to bright lights."
	flash_protect = FLASH_PROTECTION_SENSITIVE

/obj/item/organ/internal/eyes/robotic/shield/moth
	name = "shielded robotic moth eyes"
	eye_icon_state = "motheyes"
	icon_state = "eyeballs-cybermoth"

/obj/item/organ/internal/eyes/robotic/glow/moth
	name = "High Luminosity Moth Eyes"
	eye_icon_state = "motheyes"
	base_eye_state = "eyes_mothglow"
	icon_state = "eyeballs-cybermoth"
	desc = "Special glowing eyes, to be one with the lamp. Much like actual moth eyes, very sensitive to bright lights."
	flash_protect = FLASH_PROTECTION_SENSITIVE

/obj/item/organ/internal/eyes/robotic/thermals/moth //we inherit flash weakness from thermals
	name = "thermal moth eyes"
	eye_icon_state = "motheyes"
	icon_state = "eyeballs-cybermoth"

/obj/item/organ/internal/eyes/snail
	name = "snail eyes"
	desc = "These eyes seem to have a large range, but might be cumbersome with glasses."
	eye_icon_state = "snail_eyes"
	icon_state = "snail_eyeballs"

/obj/item/organ/internal/eyes/jelly
	name = "jelly eyes"
	desc = "These eyes are made of a soft jelly. Unlike all other eyes, though, there are three of them."
	eye_icon_state = "jelleyes"
	icon_state = "eyeballs-jelly"

/obj/item/organ/internal/eyes/night_vision/maintenance_adapted
	name = "adapted eyes"
	desc = "These red eyes look like two foggy marbles. They give off a particularly worrying glow in the dark."
	flash_protect = FLASH_PROTECTION_HYPER_SENSITIVE
	eye_color_left = "f00"
	eye_color_right = "f00"
	icon_state = "adapted_eyes"
	eye_icon_state = "eyes_glow"
	overlay_ignore_lighting = TRUE
	low_light_cutoff = list(5, 12, 20)
	medium_light_cutoff = list(15, 20, 30)
	high_light_cutoff = list(30, 35, 50)

/obj/item/organ/internal/eyes/night_vision/maintenance_adapted/on_mob_insert(mob/living/carbon/eye_owner)
	. = ..()
	ADD_TRAIT(eye_owner, TRAIT_UNNATURAL_RED_GLOWY_EYES, ORGAN_TRAIT)

/obj/item/organ/internal/eyes/night_vision/maintenance_adapted/on_life(seconds_per_tick, times_fired)
	if(!owner.is_blind() && isturf(owner.loc) && owner.has_light_nearby(light_amount=0.5)) //we allow a little more than usual so we can produce light from the adapted eyes
		to_chat(owner, span_danger("Your eyes! They burn in the light!"))
		apply_organ_damage(10) //blind quickly
		playsound(owner, 'sound/machines/grill/grillsizzle.ogg', 50)
	else
		apply_organ_damage(-10) //heal quickly
	. = ..()

/obj/item/organ/internal/eyes/night_vision/maintenance_adapted/on_mob_remove(mob/living/carbon/unadapted, special = FALSE)
	REMOVE_TRAIT(unadapted, TRAIT_UNNATURAL_RED_GLOWY_EYES, ORGAN_TRAIT)
	return ..()
