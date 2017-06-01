/obj/item/organ/eyes
	name = "eyes"
	icon_state = "eyeballs"
	desc = "I see you!"
	zone = "eyes"
	slot = "eye_sight"
	gender = PLURAL

	var/sight_flags = 0
	var/see_in_dark = 2
	var/tint = 0
	var/eye_color = "" //set to a hex code to override a mob's eye color
	var/old_eye_color = "fff"
	var/flash_protect = 0
	var/see_invisible = SEE_INVISIBLE_LIVING
	var/lighting_alpha

/obj/item/organ/eyes/Insert(mob/living/carbon/M, special = 0)
	..()
	if(ishuman(owner))
		var/mob/living/carbon/human/HMN = owner
		old_eye_color = HMN.eye_color
		if(eye_color)
			HMN.eye_color = eye_color
			HMN.regenerate_icons()
		else
			eye_color = HMN.eye_color
	M.update_tint()
	owner.update_sight()

/obj/item/organ/eyes/Remove(mob/living/carbon/M, special = 0)
	..()
	if(ishuman(M) && eye_color)
		var/mob/living/carbon/human/HMN = M
		HMN.eye_color = old_eye_color
		HMN.regenerate_icons()
	M.update_tint()
	M.update_sight()

/obj/item/organ/eyes/night_vision
	name = "shadow eyes"
	desc = "A spooky set of eyes that can see in the dark."
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	actions_types = list(/datum/action/item_action/organ_action/use)
	var/night_vision = TRUE

/obj/item/organ/eyes/night_vision/ui_action_click()
	switch(lighting_alpha)
		if (LIGHTING_PLANE_ALPHA_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		if (LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
	owner.update_sight()

/obj/item/organ/eyes/night_vision/alien
	name = "alien eyes"
	desc = "It turned out they had them after all!"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	sight_flags = SEE_MOBS

/obj/item/organ/eyes/night_vision/zombie
	name = "undead eyes"
	desc = "Somewhat counterintuitively, these half rotten eyes actually have superior vision to those of a living human."

///Robotic

/obj/item/organ/eyes/robotic
	name = "robotic eyes"
	icon_state = "cybernetic_eyeballs"
	desc = "Your vision is augmented."
	status = ORGAN_ROBOTIC

/obj/item/organ/eyes/robotic/emp_act(severity)
	if(!owner)
		return
	if(severity > 1)
		if(prob(10 * severity))
			return
	to_chat(owner, "<span class='warning'>Static obfuscates your vision!</span>")
	owner.flash_act(visual = 1)

/obj/item/organ/eyes/robotic/xray
	name = "X-ray eyes"
	desc = "These cybernetic eyes will give you X-ray vision. Blinking is futile."
	eye_color = "000"
	see_in_dark = 8
	sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS

/obj/item/organ/eyes/robotic/thermals
	name = "Thermals eyes"
	desc = "These cybernetic eye implants will give you Thermal vision. Vertical slit pupil included."
	eye_color = "FC0"
	origin_tech = "materials=5;programming=4;biotech=4;magnets=4;syndicate=1"
	sight_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	flash_protect = -1
	see_in_dark = 8

/obj/item/organ/eyes/robotic/flashlight
	name = "flashlight eyes"
	desc = "It's two flashlights rigged together with some wire. Why would you put these in someones head?"
	eye_color ="fee5a3"
	icon = 'icons/obj/lighting.dmi'
	icon_state = "flashlight_eyes"
	flash_protect = 2
	tint = INFINITY
	var/obj/item/device/flashlight/eyelight/eye

/obj/item/organ/eyes/robotic/flashlight/emp_act(severity)
	return

/obj/item/organ/eyes/robotic/flashlight/Insert(var/mob/living/carbon/M, var/special = 0)
	..()
	if(!eye)
		eye = new /obj/item/device/flashlight/eyelight()
	eye.on = TRUE
	eye.forceMove(M)
	eye.update_brightness(M)


/obj/item/organ/eyes/robotic/flashlight/Remove(var/mob/living/carbon/M, var/special = 0)
	eye.on = FALSE
	eye.update_brightness(M)
	eye.forceMove(src)
	..()

// Welding shield implant
/obj/item/organ/eyes/robotic/shield
	name = "shielded robotic eyes"
	desc = "These reactive micro-shields will protect you from welders and flashes without obscuring your vision."
	origin_tech = "materials=4;biotech=3;engineering=4;plasmatech=3"
	flash_protect = 2

/obj/item/organ/eyes/robotic/shield/emp_act(severity)
	return

#define RGB2EYECOLORSTRING(definitionvar) ("[copytext(definitionvar,2,3)][copytext(definitionvar,4,5)][copytext(definitionvar,6,7)]")

/obj/item/organ/eyes/robotic/glow
	name = "High Luminosity Eyes"
	desc = "Special glowing eyes, used by snowflakes who want to be special."
	origin_tech = "material=3;biotech=3;engineering=3;magnets=4"
	var/current_color_string = "#000000"
	eye_color = "000"
	var/active = FALSE
	actions_types = list(/datum/action/item_action/organ_action/use, /datum/action/item_action/organ_action/toggle)
	var/olddir = 0
	var/max_light_beam_distance = 5
	var/light_beam_distance = 5
	var/light_object_range = 1
	var/light_object_power = 1
	var/list/obj/effect/abstract/eye_lighting/eye_lighting
	var/image/mob_overlay

/obj/item/organ/eyes/robotic/glow/Initialize()
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	eye_lighting = list()
	mob_overlay = icon('icons/mob/human_face.dmi', "eyes_glow_gs")

/obj/item/organ/eyes/robotic/glow/Destroy()
	terminate_effects()
	..()

/obj/item/organ/eyes/robotic/glow/Remove()
	terminate_effects()
	..()

/obj/item/organ/eyes/robotic/glow/proc/terminate_effects()
	if(owner && active)
		deactivate()
	clear_visuals(TRUE)
	STOP_PROCESSING(SSfastprocess, src)

/obj/item/organ/eyes/robotic/glow/process()
	if(owner && (olddir != owner.dir) && active)
		update_visuals()
		olddir = owner.dir
		world << "Direction change detected."

/obj/item/organ/eyes/robotic/glow/ui_action_click(owner, action)
	if(istype(action, /datum/action/item_action/organ_action/toggle))
		toggle_active()
	else if(istype(action, /datum/action/item_action/organ_action/use))
		prompt_for_controls(owner)

/obj/item/organ/eyes/robotic/glow/proc/toggle_active()
	active ? deactivate() : activate()

/obj/item/organ/eyes/robotic/glow/proc/prompt_for_controls(owner)
	var/r = input(owner, "Enter red value (0 - 255)", "Color Select", 0) as null|num
	if(!r)
		return
	var/g = input(owner, "Enter green value (0 - 255)", "Color Select", 0) as null|num
	if(!g)
		return
	var/b = input(owner, "Enter blue value (0 - 255)", "Color Select", 0) as null|num
	if(!b)
		return
	var/range = input(owner, "Enter range (0 - [max_light_beam_distance]", "Range Select", 0) as null|num
	if(!range)
		return

	set_distance(Clamp(range, 0, max_light_beam_distance))
	assume_rgb(Clamp(r, 0, 255),Clamp(g, 0, 255),Clamp(b, 0, 255))

/obj/item/organ/eyes/robotic/glow/proc/assume_rgb(red,green,blue)
	current_color_string = rgb(red,green,blue)
	eye_color = RGB2EYECOLORSTRING(current_color_string)
	sync_light_effects()
	sync_mob_overlay()
	if(owner)
		owner.regenerate_icons()

/obj/item/organ/eyes/robotic/glow/proc/sync_mob_overlay()
	remove_mob_overlay()
	mob_overlay.color = current_color_string
	add_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/add_mob_overlay()
	if(owner)
		owner.add_overlay(mob_overlay)

/obj/item/organ/eyes/robotic/glow/proc/remove_mob_overlay()
	if(owner)
		owner.cut_overlay(mob_overlay)

/obj/item/organ/eyes/robotic/glow/emp_act()
	if(active)
		deactivate(silent = TRUE)

/obj/item/organ/eyes/robotic/glow/on_mob_move()
	if(active)
		update_visuals()
	world << "OnMobMove detection chain"

/obj/item/organ/eyes/robotic/glow/proc/activate(silent = FALSE)
	start_visuals()
	if(!silent)
		to_chat(owner, "<span class='warning'>Your [src] clicks and makes a whining noise, before shooting out a beam of light!</span>")
	active = TRUE
	sync_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/deactivate(silent = FALSE)
	clear_visuals()
	if(!silent)
		to_chat(owner, "<span class='warning'>Your [src] shuts off!</span>")
	active = FALSE
	remove_mob_overlay()

/obj/item/organ/eyes/robotic/glow/proc/update_visuals()
	var/turf/scanfrom = get_turf(owner)
	var/scandir = owner.dir
	if(!istype(scanfrom))
		clear_visuals()
	var/turf/scanning = scanfrom
	var/stop = FALSE
	for(var/i in 1 to light_beam_distance)
		scanning = get_step(scanning, scandir)
		if(scanning.opacity)
			stop = TRUE
		else
			for(var/v in scanning)
				var/atom/A = v
				if(A.opacity)
					stop = TRUE
		var/obj/effect/abstract/eye_lighting/L = eye_lighting[i]
		L.forceMove(stop ? src : scanning)

/obj/item/organ/eyes/robotic/glow/proc/clear_visuals(delete_everything = FALSE)
	if(delete_everything)
		QDEL_LIST(eye_lighting)
	else
		for(var/i in eye_lighting)
			var/obj/effect/abstract/eye_lighting/L = i
			L.forceMove(src)

/obj/item/organ/eyes/robotic/glow/proc/start_visuals()
	if(!initialized)
		return
	if(eye_lighting.len < light_beam_distance)
		regenerate_light_effects()
	sync_light_effects()
	update_visuals()

/obj/item/organ/eyes/robotic/glow/proc/set_distance(dist)
	light_beam_distance = dist
	regenerate_light_effects()

/obj/item/organ/eyes/robotic/glow/proc/regenerate_light_effects()
	QDEL_LIST(eye_lighting)
	eye_lighting = list()
	for(var/i in 1 to light_beam_distance)
		eye_lighting[i] = new /obj/effect/abstract/eye_lighting(src)
	sync_light_effects()

/obj/item/organ/eyes/robotic/glow/proc/sync_light_effects()
	for(var/I in eye_lighting)
		var/obj/effect/abstract/eye_lighting/L = I
		L.light_color = current_color_string
		L.set_light(light_object_range)
		L.light_power = light_object_power

/obj/effect/abstract/eye_lighting
	var/obj/item/organ/eyes/robotic/glow/parent

/obj/effect/abstract/eye_lighting/Initialize()
	. = ..()
	parent = loc
	if(!istype(parent))
		return INITIALIZE_HINT_QDEL
