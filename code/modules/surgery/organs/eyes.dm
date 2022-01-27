/obj/item/organ/eyes
	name = BODY_ZONE_PRECISE_EYES
	icon_state = "eyeballs"
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

	var/sight_flags = 0
	/// changes how the eyes overlay is applied, makes it apply over the lighting layer
	var/overlay_ignore_lighting = FALSE
	var/see_in_dark = 2
	var/tint = 0
	var/eye_color = "" //set to a hex code to override a mob's eye color
	var/eye_icon_state = "eyes"
	var/old_eye_color = "fff"
	var/flash_protect = FLASH_PROTECTION_NONE
	var/see_invisible = SEE_INVISIBLE_LIVING
	var/lighting_alpha
	var/no_glasses
	/// indication that the eyes are undergoing some negative effect
	var/damaged = FALSE

/obj/item/organ/eyes/Insert(mob/living/carbon/eye_owner, special = FALSE, drop_if_replaced = FALSE, initialising)
	. = ..()
	if(ishuman(eye_owner))
		var/mob/living/carbon/human/human_owner = eye_owner
		old_eye_color = human_owner.eye_color
		if(eye_color)
			human_owner.eye_color = eye_color
		else
			eye_color = human_owner.eye_color
		if(HAS_TRAIT(human_owner, TRAIT_NIGHT_VISION) && !lighting_alpha)
			lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT
	eye_owner.update_tint()
	owner.update_sight()
	if(eye_owner.has_dna() && ishuman(eye_owner))
		eye_owner.dna.species.handle_body(eye_owner) //updates eye icon

/obj/item/organ/eyes/proc/refresh()
	if(ishuman(owner))
		var/mob/living/carbon/human/affected_human = owner
		old_eye_color = affected_human.eye_color
		if(eye_color)
			affected_human.eye_color = eye_color
		else
			eye_color = affected_human.eye_color
		if(HAS_TRAIT(affected_human, TRAIT_NIGHT_VISION) && !lighting_alpha)
			lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT
	owner.update_tint()
	owner.update_sight()
	if(owner.has_dna() && ishuman(owner))
		var/mob/living/carbon/human/affected_human = owner
		affected_human.dna.species.handle_body(affected_human) //updates eye icon


/obj/item/organ/eyes/Remove(mob/living/carbon/eye_owner, special = 0)
	..()
	if(ishuman(eye_owner) && eye_color)
		var/mob/living/carbon/human/human_owner = eye_owner
		human_owner.eye_color = old_eye_color
		human_owner.update_body()
	eye_owner.cure_blind(EYE_DAMAGE)
	eye_owner.cure_nearsighted(EYE_DAMAGE)
	eye_owner.set_blindness(0)
	eye_owner.set_blurriness(0)
	eye_owner.clear_fullscreen("eye_damage", 0)
	eye_owner.update_sight()

//Gotta reset the eye color, because that persists
/obj/item/organ/eyes/enter_wardrobe()
	. = ..()
	eye_color = initial(eye_color)

/obj/item/organ/eyes/on_life(delta_time, times_fired)
	. = ..()
	var/mob/living/carbon/eye_owner = owner
	//various degrees of "oh fuck my eyes", from "point a laser at your eye" to "staring at the Sun" intensities
	if(damage > 20)
		damaged = TRUE
		if((organ_flags & ORGAN_FAILING))
			eye_owner.become_blind(EYE_DAMAGE)
		else if(damage > 30)
			eye_owner.overlay_fullscreen("eye_damage", /atom/movable/screen/fullscreen/impaired, 2)
		else
			eye_owner.overlay_fullscreen("eye_damage", /atom/movable/screen/fullscreen/impaired, 1)
	//called once since we don't want to keep clearing the screen of eye damage for people who are below 20 damage
	else if(damaged)
		damaged = FALSE
		eye_owner.clear_fullscreen("eye_damage")
		eye_owner.cure_blind(EYE_DAMAGE)
	return

/obj/item/organ/eyes/night_vision
	name = "shadow eyes"
	desc = "A spooky set of eyes that can see in the dark."
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/night_vision = TRUE

/obj/item/organ/eyes/night_vision/ui_action_click()
	sight_flags = initial(sight_flags)
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			sight_flags &= ~SEE_BLACKNESS
	owner.update_sight()

/obj/item/organ/eyes/night_vision/alien
	name = "alien eyes"
	desc = "It turned out they had them after all!"
	sight_flags = SEE_MOBS

/obj/item/organ/eyes/night_vision/zombie
	name = "undead eyes"
	desc = "Somewhat counterintuitively, these half-rotten eyes actually have superior vision to those of a living human."

/obj/item/organ/eyes/night_vision/nightmare
	name = "burning red eyes"
	desc = "Even without their shadowy owner, looking at these eyes gives you a sense of dread."
	icon_state = "burning_eyes"

/obj/item/organ/eyes/night_vision/mushroom
	name = "fung-eye"
	desc = "While on the outside they look inert and dead, the eyes of mushroom people are actually very advanced."

///Robotic

/obj/item/organ/eyes/robotic
	name = "robotic eyes"
	icon_state = "cybernetic_eyeballs"
	desc = "Your vision is augmented."
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC

/obj/item/organ/eyes/robotic/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	if(prob(10 * severity))
		return
	to_chat(owner, span_warning("Static obfuscates your vision!"))
	owner.flash_act(visual = 1)

/obj/item/organ/eyes/robotic/basic
	name = "basic robotic eyes"
	desc = "A pair of basic cybernetic eyes that restore vision, but at some vulnerability to light."
	eye_color = "5500ff"
	flash_protect = FLASH_PROTECTION_SENSITIVE

/obj/item/organ/eyes/robotic/basic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(10 * severity))
		damage += 20 * severity
		to_chat(owner, span_warning("Your eyes start to fizzle in their sockets!"))
		do_sparks(2, TRUE, owner)
		owner.emote("scream")

/obj/item/organ/eyes/robotic/xray
	name = "\improper X-ray eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	eye_color = "000"
	see_in_dark = 8
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS

/obj/item/organ/eyes/robotic/thermals
	name = "thermal eyes"
	desc = "These cybernetic eye implants will give you thermal vision. Vertical slit pupil included."
	eye_color = "FC0"
	sight_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = FLASH_PROTECTION_SENSITIVE
	see_in_dark = 8

/obj/item/organ/eyes/robotic/flashlight
	name = "flashlight eyes"
	desc = "It's two flashlights rigged together with some wire. Why would you put these in someone's head?"
	eye_color ="fee5a3"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight_eyes"
	flash_protect = FLASH_PROTECTION_WELDER
	tint = INFINITY
	var/obj/item/flashlight/eyelight/eye

/obj/item/organ/eyes/robotic/flashlight/emp_act(severity)
	return

/obj/item/organ/eyes/robotic/flashlight/Insert(mob/living/carbon/victim, special = FALSE, drop_if_replaced = FALSE)
	..()
	if(!eye)
		eye = new /obj/item/flashlight/eyelight()
	eye.on = TRUE
	eye.forceMove(victim)
	eye.update_brightness(victim)
	victim.become_blind(FLASHLIGHT_EYES)


/obj/item/organ/eyes/robotic/flashlight/Remove(mob/living/carbon/victim, special = 0)
	eye.on = FALSE
	eye.update_brightness(victim)
	eye.forceMove(src)
	victim.cure_blind(FLASHLIGHT_EYES)
	..()

// Welding shield implant
/obj/item/organ/eyes/robotic/shield
	name = "shielded robotic eyes"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	flash_protect = FLASH_PROTECTION_WELDER

/obj/item/organ/eyes/robotic/shield/emp_act(severity)
	return

#define RGB2EYECOLORSTRING(definitionvar) ("[copytext_char(definitionvar, 2, 3)][copytext_char(definitionvar, 4, 5)][copytext_char(definitionvar, 6, 7)]")

/obj/item/organ/eyes/robotic/glow
	name = "High Luminosity Eyes"
	desc = "Special glowing eyes, used by snowflakes who want to be special."
	eye_color = "000"
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

/obj/item/organ/eyes/robotic/glow/Initialize(mapload)
	. = ..()
	mob_overlay = image('icons/mob/human_face.dmi', "eyes_glow_gs")

/obj/item/organ/eyes/robotic/glow/Destroy()
	terminate_effects()
	. = ..()

/obj/item/organ/eyes/robotic/glow/Remove(mob/living/carbon/eye_owner, special = FALSE)
	terminate_effects()
	. = ..()

/obj/item/organ/eyes/robotic/glow/proc/terminate_effects()
	if(owner && active)
		deactivate()
	active = FALSE
	clear_visuals(TRUE)
	STOP_PROCESSING(SSfastprocess, src)

/obj/item/organ/eyes/robotic/glow/ui_action_click(owner, action)
	if(istype(action, /datum/action/item_action/organ_action/toggle))
		toggle_active()
	else if(istype(action, /datum/action/item_action/organ_action/use))
		prompt_for_controls(owner)

/obj/item/organ/eyes/robotic/glow/proc/toggle_active()
	if(active)
		deactivate()
	else
		activate()

/obj/item/organ/eyes/robotic/glow/proc/prompt_for_controls(mob/user)
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

/obj/item/organ/eyes/robotic/glow/proc/assume_rgb(newcolor)
	current_color_string = newcolor
	eye_color = RGB2EYECOLORSTRING(current_color_string)
	if(!QDELETED(owner) && ishuman(owner)) //Other carbon mobs don't have eye color.
		owner.dna.species.handle_body(owner)

/obj/item/organ/eyes/robotic/glow/proc/cycle_mob_overlay()
	remove_mob_overlay()
	mob_overlay.color = current_color_string
	add_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/add_mob_overlay()
	if(!QDELETED(owner))
		owner.add_overlay(mob_overlay)

/obj/item/organ/eyes/robotic/glow/proc/remove_mob_overlay()
	if(!QDELETED(owner))
		owner.cut_overlay(mob_overlay)

/obj/item/organ/eyes/robotic/glow/emp_act()
	. = ..()
	if(!active || . & EMP_PROTECT_SELF)
		return
	deactivate(silent = TRUE)

/obj/item/organ/eyes/robotic/glow/Insert(mob/living/carbon/eye_owner, special = FALSE, drop_if_replaced = FALSE)
	. = ..()
	RegisterSignal(eye_owner, COMSIG_ATOM_DIR_CHANGE, .proc/update_visuals)

/obj/item/organ/eyes/robotic/glow/Remove(mob/living/carbon/eye_owner, special = FALSE)
	. = ..()
	UnregisterSignal(eye_owner, COMSIG_ATOM_DIR_CHANGE)

/obj/item/organ/eyes/robotic/glow/Destroy()
	QDEL_NULL(mobhook) // mobhook is not our component
	return ..()

/obj/item/organ/eyes/robotic/glow/proc/activate(silent = FALSE)
	start_visuals()
	if(!silent)
		to_chat(owner, span_warning("Your [src] clicks and makes a whining noise, before shooting out a beam of light!"))
	cycle_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/deactivate(silent = FALSE)
	clear_visuals()
	if(!silent)
		to_chat(owner, span_warning("Your [src] shuts off!"))
	remove_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/update_visuals(datum/source, olddir, newdir)
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

/obj/item/organ/eyes/robotic/glow/proc/clear_visuals(delete_everything = FALSE)
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

/obj/item/organ/eyes/robotic/glow/proc/start_visuals()
	if(!islist(eye_lighting))
		eye_lighting = list()
		regenerate_light_effects()
	if((eye_lighting.len < light_beam_distance) || !on_mob)
		regenerate_light_effects()
	sync_light_effects()
	active = TRUE
	update_visuals()

/obj/item/organ/eyes/robotic/glow/proc/set_distance(dist)
	light_beam_distance = dist
	regenerate_light_effects()

/obj/item/organ/eyes/robotic/glow/proc/regenerate_light_effects()
	clear_visuals(TRUE)
	on_mob = new (src, light_object_range, light_object_power, current_color_string, LIGHT_ATTACHED)
	for(var/i in 1 to light_beam_distance)
		LAZYADD(eye_lighting, new /obj/effect/abstract/eye_lighting(src, light_object_range, light_object_power, current_color_string))
	sync_light_effects()


/obj/item/organ/eyes/robotic/glow/proc/sync_light_effects()
	for(var/obj/effect/abstract/eye_lighting/eye_lighting as anything in eye_lighting)
		eye_lighting.set_light_color(current_color_string)
	on_mob?.set_light_color(current_color_string)


/obj/effect/abstract/eye_lighting
	light_system = MOVABLE_LIGHT
	var/obj/item/organ/eyes/robotic/glow/parent


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


/obj/item/organ/eyes/moth
	name = "moth eyes"
	desc = "These eyes seem to have increased sensitivity to bright light, with no improvement to low light vision."
	eye_icon_state = "motheyes"
	icon_state = "eyeballs-moth"
	flash_protect = FLASH_PROTECTION_SENSITIVE

/obj/item/organ/eyes/snail
	name = "snail eyes"
	desc = "These eyes seem to have a large range, but might be cumbersome with glasses."
	eye_icon_state = "snail_eyes"
	icon_state = "snail_eyeballs"

/obj/item/organ/eyes/fly
	name = "fly eyes"
	desc = "These eyes seem to stare back no matter the direction you look at it from."
	eye_icon_state = "flyeyes"
	icon_state = "eyeballs-fly"

/obj/item/organ/eyes/fly/Insert(mob/living/carbon/eye_owner, special = FALSE)
	. = ..()
	ADD_TRAIT(eye_owner, TRAIT_FLASH_SENSITIVE, ORGAN_TRAIT)

/obj/item/organ/eyes/fly/Remove(mob/living/carbon/eye_owner, special = FALSE)
	REMOVE_TRAIT(eye_owner, TRAIT_FLASH_SENSITIVE, ORGAN_TRAIT)
	return ..()

/obj/item/organ/eyes/night_vision/maintenance_adapted
	name = "adapted eyes"
	desc = "These red eyes look like two foggy marbles. They give off a particularly worrying glow in the dark."
	flash_protect = FLASH_PROTECTION_SENSITIVE
	eye_color = "f00"
	icon_state = "adapted_eyes"
	eye_icon_state = "eyes_glow"
	overlay_ignore_lighting = TRUE
	var/obj/item/flashlight/eyelight/adapted/adapt_light

/obj/item/organ/eyes/night_vision/maintenance_adapted/Insert(mob/living/carbon/adapted, special = FALSE)
	. = ..()
	//add lighting
	if(!adapt_light)
		adapt_light = new /obj/item/flashlight/eyelight/adapted()
	adapt_light.on = TRUE
	adapt_light.forceMove(adapted)
	adapt_light.update_brightness(adapted)
	//traits
	ADD_TRAIT(adapted, TRAIT_FLASH_SENSITIVE, ORGAN_TRAIT)
	ADD_TRAIT(adapted, TRAIT_UNNATURAL_RED_GLOWY_EYES, ORGAN_TRAIT)

/obj/item/organ/eyes/night_vision/maintenance_adapted/on_life(delta_time, times_fired)
	var/turf/owner_turf = get_turf(owner)
	var/lums = owner_turf.get_lumcount()
	if(lums > 0.5) //we allow a little more than usual so we can produce light from the adapted eyes
		to_chat(owner, span_danger("Your eyes! They burn in the light!"))
		applyOrganDamage(10) //blind quickly
		playsound(owner, 'sound/machines/grill/grillsizzle.ogg', 50)
	else
		applyOrganDamage(-10) //heal quickly
	. = ..()

/obj/item/organ/eyes/night_vision/maintenance_adapted/Remove(mob/living/carbon/unadapted, special = FALSE)
	//remove lighting
	adapt_light.on = FALSE
	adapt_light.update_brightness(unadapted)
	adapt_light.forceMove(src)
	//traits
	REMOVE_TRAIT(unadapted, TRAIT_FLASH_SENSITIVE, ORGAN_TRAIT)
	REMOVE_TRAIT(unadapted, TRAIT_UNNATURAL_RED_GLOWY_EYES, ORGAN_TRAIT)
	return ..()
