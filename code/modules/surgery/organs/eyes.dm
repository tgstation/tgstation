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
	var/old_eye_color_left = "fff"
	var/old_eye_color_right = "fff"

	/// Glasses cannot be worn over these eyes. Currently unused
	var/no_glasses = FALSE
	/// indication that the eyes are undergoing some negative effect
	var/damaged = FALSE
	/// Native FOV that will be applied if a config is enabled
	var/native_fov = FOV_90_DEGREES

/obj/item/organ/internal/eyes/Insert(mob/living/carbon/eye_owner, special = FALSE, drop_if_replaced = FALSE)
	. = ..()
	owner.cure_blind(NO_EYES)
	apply_damaged_eye_effects()
	refresh()

/// Refreshes the visuals of the eyes
/// If call_update is TRUE, we also will call udpate_body
/obj/item/organ/internal/eyes/proc/refresh(call_update = TRUE)
	owner.update_sight()
	owner.update_tint()

	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/affected_human = owner
	old_eye_color_left = affected_human.eye_color_left
	old_eye_color_right = affected_human.eye_color_right
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
		owner.add_fov_trait(type, native_fov)

	if(call_update)
		owner.dna?.species?.handle_body(affected_human) //updates eye icon

/obj/item/organ/internal/eyes/Remove(mob/living/carbon/eye_owner, special = FALSE)
	..()
	if(ishuman(eye_owner))
		var/mob/living/carbon/human/human_owner = eye_owner
		if(initial(eye_color_left))
			human_owner.eye_color_left = old_eye_color_left
		if(initial(eye_color_right))
			human_owner.eye_color_right = old_eye_color_right
		human_owner.update_body()
		if(native_fov)
			eye_owner.remove_fov_trait(type)

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
	if(!istype(parent) || parent.getorgan(/obj/item/organ/internal/eyes) != src)
		CRASH("Generating a body overlay for [src] targeting an invalid parent '[parent]'.")

	var/mutable_appearance/eye_left = mutable_appearance('icons/mob/species/human/human_face.dmi', "[eye_icon_state]_l", -BODY_LAYER)
	var/mutable_appearance/eye_right = mutable_appearance('icons/mob/species/human/human_face.dmi', "[eye_icon_state]_r", -BODY_LAYER)
	var/list/overlays = list(eye_left, eye_right)

	if(EYECOLOR in parent.dna?.species.species_traits)
		eye_right.color = eye_color_right
		eye_left.color = eye_color_left

	var/obscured = parent.check_obscured_slots(TRUE)
	if(overlay_ignore_lighting && !(obscured & ITEM_SLOT_EYES))
		eye_left.overlays += emissive_appearance(eye_left.icon, eye_left.icon_state, parent, alpha = eye_left.alpha)
		eye_right.overlays += emissive_appearance(eye_right.icon, eye_right.icon_state, parent, alpha = eye_right.alpha)

	if(OFFSET_FACE in parent.dna?.species.offset_features)
		var/offset = parent.dna.species.offset_features[OFFSET_FACE]
		for(var/mutable_appearance/overlay in overlays)
			overlay.pixel_x += offset[OFFSET_X]
			overlay.pixel_y += offset[OFFSET_Y]

	return overlays

#undef OFFSET_X
#undef OFFSET_Y

//Gotta reset the eye color, because that persists
/obj/item/organ/internal/eyes/enter_wardrobe()
	. = ..()
	eye_color_left = initial(eye_color_left)
	eye_color_right = initial(eye_color_right)

/obj/item/organ/internal/eyes/applyOrganDamage(damage_amount, maximum, required_organtype)
	. = ..()
	if(!owner)
		return
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
			color_cutoffs = list()
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

///Robotic

/obj/item/organ/internal/eyes/robotic
	name = "robotic eyes"
	icon_state = "cybernetic_eyeballs"
	desc = "Your vision is augmented."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/internal/eyes/robotic/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
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
		applyOrganDamage(20 * severity)
		to_chat(owner, span_warning("Your eyes start to fizzle in their sockets!"))
		do_sparks(2, TRUE, owner)
		owner.emote("scream")

/obj/item/organ/internal/eyes/robotic/xray
	name = "\improper X-ray eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	eye_color_left = "000"
	eye_color_right = "000"
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS

/obj/item/organ/internal/eyes/robotic/xray/Insert(mob/living/carbon/eye_owner, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	ADD_TRAIT(eye_owner, TRAIT_XRAY_VISION, ORGAN_TRAIT)

/obj/item/organ/internal/eyes/robotic/xray/Remove(mob/living/carbon/eye_owner, special = FALSE)
	REMOVE_TRAIT(eye_owner, TRAIT_XRAY_VISION, ORGAN_TRAIT)
	return ..()

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

/obj/item/organ/internal/eyes/robotic/flashlight/emp_act(severity)
	return

/obj/item/organ/internal/eyes/robotic/flashlight/Insert(mob/living/carbon/victim, special = FALSE, drop_if_replaced = FALSE)
	..()
	if(!eye)
		eye = new /obj/item/flashlight/eyelight()
	eye.on = TRUE
	eye.forceMove(victim)
	eye.update_brightness(victim)
	victim.become_blind(FLASHLIGHT_EYES)


/obj/item/organ/internal/eyes/robotic/flashlight/Remove(mob/living/carbon/victim, special = 0)
	eye.on = FALSE
	eye.update_brightness(victim)
	eye.forceMove(src)
	victim.cure_blind(FLASHLIGHT_EYES)
	..()

// Welding shield implant
/obj/item/organ/internal/eyes/robotic/shield
	name = "shielded robotic eyes"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/organ/internal/eyes/robotic/shield/emp_act(severity)
	return

#define RGB2EYECOLORSTRING(definitionvar) ("[copytext_char(definitionvar, 2, 3)][copytext_char(definitionvar, 4, 5)][copytext_char(definitionvar, 6, 7)]")

/obj/item/organ/internal/eyes/robotic/glow
	name = "High Luminosity Eyes"
	desc = "Special glowing eyes, used by snowflakes who want to be special."
	eye_color_left = "000"
	eye_color_right = "000"
	actions_types = list(/datum/action/item_action/organ_action/use, /datum/action/item_action/organ_action/toggle)
	var/current_color_string = "#ffffff"
	var/active = FALSE
	var/max_light_beam_distance = 5
	var/light_beam_distance = 5
	var/light_object_range = 2
	var/light_object_power = 2
	var/list/obj/effect/abstract/eye_lighting/eye_lighting
	var/obj/effect/abstract/eye_lighting/on_mob
	var/image/mob_overlay
	var/datum/component/mobhook

/obj/item/organ/internal/eyes/robotic/glow/Initialize(mapload)
	. = ..()
	mob_overlay = image('icons/mob/species/human/human_face.dmi', "eyes_glow_gs")

/obj/item/organ/internal/eyes/robotic/glow/Destroy()
	terminate_effects()
	. = ..()

/obj/item/organ/internal/eyes/robotic/glow/Remove(mob/living/carbon/eye_owner, special = FALSE)
	terminate_effects()
	. = ..()

/obj/item/organ/internal/eyes/robotic/glow/proc/terminate_effects()
	if(owner && active)
		deactivate()
	active = FALSE
	clear_visuals(TRUE)
	STOP_PROCESSING(SSfastprocess, src)

/obj/item/organ/internal/eyes/robotic/glow/ui_action_click(owner, action)
	if(istype(action, /datum/action/item_action/organ_action/toggle))
		toggle_active()
	else if(istype(action, /datum/action/item_action/organ_action/use))
		prompt_for_controls(owner)

/obj/item/organ/internal/eyes/robotic/glow/proc/toggle_active()
	if(active)
		deactivate()
	else
		activate()

/obj/item/organ/internal/eyes/robotic/glow/proc/prompt_for_controls(mob/user)
	var/color = input(owner, "Select Color", "Select color", "#ffffff") as color|null
	if(!color || QDELETED(src) || QDELETED(user) || QDELETED(owner) || owner != user)
		return
	var/range = input(user, "Enter range (0 - [max_light_beam_distance])", "Range Select", 0) as null|num
	var/old_active = active // Get old active because set_distance() -> clear_visuals()  will set it to FALSE.
	set_distance(clamp(range, 0, max_light_beam_distance))
	assume_rgb(color)
	// Reactivate if eyes were already active for real time colour swapping!
	if(old_active)
		activate(FALSE)

/obj/item/organ/internal/eyes/robotic/glow/proc/assume_rgb(newcolor)
	current_color_string = newcolor
	eye_color_left = RGB2EYECOLORSTRING(current_color_string)
	eye_color_right = eye_color_left
	if(!QDELETED(owner) && ishuman(owner)) //Other carbon mobs don't have eye color.
		owner.dna.species.handle_body(owner)

/obj/item/organ/internal/eyes/robotic/glow/proc/cycle_mob_overlay()
	remove_mob_overlay()
	mob_overlay.color = current_color_string
	add_mob_overlay()

/obj/item/organ/internal/eyes/robotic/glow/proc/add_mob_overlay()
	if(!QDELETED(owner))
		owner.add_overlay(mob_overlay)

/obj/item/organ/internal/eyes/robotic/glow/proc/remove_mob_overlay()
	if(!QDELETED(owner))
		owner.cut_overlay(mob_overlay)

/obj/item/organ/internal/eyes/robotic/glow/emp_act()
	. = ..()
	if(!active || . & EMP_PROTECT_SELF)
		return
	deactivate(silent = TRUE)

/obj/item/organ/internal/eyes/robotic/glow/Insert(mob/living/carbon/eye_owner, special = FALSE, drop_if_replaced = FALSE)
	. = ..()
	RegisterSignal(eye_owner, COMSIG_ATOM_DIR_CHANGE, PROC_REF(update_visuals))

/obj/item/organ/internal/eyes/robotic/glow/Remove(mob/living/carbon/eye_owner, special = FALSE)
	. = ..()
	UnregisterSignal(eye_owner, COMSIG_ATOM_DIR_CHANGE)

/obj/item/organ/internal/eyes/robotic/glow/Destroy()
	QDEL_NULL(mobhook) // mobhook is not our component
	return ..()

/obj/item/organ/internal/eyes/robotic/glow/proc/activate(silent = FALSE)
	start_visuals()
	if(!silent)
		to_chat(owner, span_warning("Your [src] clicks and makes a whining noise, before shooting out a beam of light!"))
	cycle_mob_overlay()

/obj/item/organ/internal/eyes/robotic/glow/proc/deactivate(silent = FALSE)
	clear_visuals()
	if(!silent)
		to_chat(owner, span_warning("Your [src] shuts off!"))
	remove_mob_overlay()

/obj/item/organ/internal/eyes/robotic/glow/proc/update_visuals(datum/source, olddir, newdir)
	SIGNAL_HANDLER
	if(!active)
		return // Don't update if we're not active!
	if((LAZYLEN(eye_lighting) < light_beam_distance) || !on_mob)
		regenerate_light_effects()
	var/turf/scanfrom = get_turf(owner)
	var/scandir = owner.dir
	if (newdir && scandir != newdir) // COMSIG_ATOM_DIR_CHANGE happens before the dir change, but with a reference to the new direction.
		scandir = newdir
	if(!istype(scanfrom))
		clear_visuals()
	var/turf/scanning = scanfrom
	var/stop = FALSE
	on_mob.set_light_flags(on_mob.light_flags & ~LIGHT_ATTACHED)
	on_mob.forceMove(scanning)
	for(var/i in 1 to light_beam_distance)
		scanning = get_step(scanning, scandir)
		if(IS_OPAQUE_TURF(scanning))
			stop = TRUE
		var/obj/effect/abstract/eye_lighting/lighting = LAZYACCESS(eye_lighting, i)
		if(stop)
			lighting.forceMove(src)
		else
			lighting.forceMove(scanning)

/obj/item/organ/internal/eyes/robotic/glow/proc/clear_visuals(delete_everything = FALSE)
	if(delete_everything)
		QDEL_LIST(eye_lighting)
		QDEL_NULL(on_mob)
	else
		for(var/obj/effect/abstract/eye_lighting/lighting as anything in eye_lighting)
			lighting.forceMove(src)
		if(!QDELETED(on_mob))
			on_mob.set_light_flags(on_mob.light_flags | LIGHT_ATTACHED)
			on_mob.forceMove(src)
	active = FALSE

/obj/item/organ/internal/eyes/robotic/glow/proc/start_visuals()
	if(!islist(eye_lighting))
		eye_lighting = list()
		regenerate_light_effects()
	if((eye_lighting.len < light_beam_distance) || !on_mob)
		regenerate_light_effects()
	sync_light_effects()
	active = TRUE
	update_visuals()

/obj/item/organ/internal/eyes/robotic/glow/proc/set_distance(dist)
	light_beam_distance = dist
	regenerate_light_effects()

/obj/item/organ/internal/eyes/robotic/glow/proc/regenerate_light_effects()
	clear_visuals(TRUE)
	on_mob = new (src, light_object_range, light_object_power, current_color_string, LIGHT_ATTACHED)
	for(var/i in 1 to light_beam_distance)
		LAZYADD(eye_lighting, new /obj/effect/abstract/eye_lighting(src, light_object_range, light_object_power, current_color_string))
	sync_light_effects()


/obj/item/organ/internal/eyes/robotic/glow/proc/sync_light_effects()
	for(var/obj/effect/abstract/eye_lighting/eye_lighting as anything in eye_lighting)
		eye_lighting.set_light_color(current_color_string)
	on_mob?.set_light_color(current_color_string)


/obj/effect/abstract/eye_lighting
	light_system = MOVABLE_LIGHT
	var/obj/item/organ/internal/eyes/robotic/glow/parent


/obj/effect/abstract/eye_lighting/Initialize(mapload, light_object_range, light_object_power, current_color_string, light_flags)
	. = ..()
	parent = loc
	if(!istype(parent))
		stack_trace("/obj/effect/abstract/eye_lighting added to improper parent ([loc]). Deleting.")
		return INITIALIZE_HINT_QDEL
	if(!isnull(light_object_range))
		set_light_range(light_object_range)
	if(!isnull(light_object_power))
		set_light_power(light_object_power)
	if(!isnull(current_color_string))
		set_light_color(current_color_string)
	if(!isnull(light_flags))
		set_light_flags(light_flags)


/obj/item/organ/internal/eyes/moth
	name = "moth eyes"
	desc = "These eyes seem to have increased sensitivity to bright light, with no improvement to low light vision."
	eye_icon_state = "motheyes"
	icon_state = "eyeballs-moth"
	flash_protect = FLASH_PROTECTION_SENSITIVE

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
	var/obj/item/flashlight/eyelight/adapted/adapt_light

/obj/item/organ/internal/eyes/night_vision/maintenance_adapted/Insert(mob/living/carbon/adapted, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	//add lighting
	if(!adapt_light)
		adapt_light = new /obj/item/flashlight/eyelight/adapted()
	adapt_light.on = TRUE
	adapt_light.forceMove(adapted)
	adapt_light.update_brightness(adapted)
	ADD_TRAIT(adapted, TRAIT_UNNATURAL_RED_GLOWY_EYES, ORGAN_TRAIT)

/obj/item/organ/internal/eyes/night_vision/maintenance_adapted/on_life(delta_time, times_fired)
	if(!owner.is_blind() && isturf(owner.loc) && owner.has_light_nearby(light_amount=0.5)) //we allow a little more than usual so we can produce light from the adapted eyes
		to_chat(owner, span_danger("Your eyes! They burn in the light!"))
		applyOrganDamage(10) //blind quickly
		playsound(owner, 'sound/machines/grill/grillsizzle.ogg', 50)
	else
		applyOrganDamage(-10) //heal quickly
	. = ..()

/obj/item/organ/internal/eyes/night_vision/maintenance_adapted/Remove(mob/living/carbon/unadapted, special = FALSE)
	//remove lighting
	adapt_light.on = FALSE
	adapt_light.update_brightness(unadapted)
	adapt_light.forceMove(src)
	REMOVE_TRAIT(unadapted, TRAIT_UNNATURAL_RED_GLOWY_EYES, ORGAN_TRAIT)
	return ..()
