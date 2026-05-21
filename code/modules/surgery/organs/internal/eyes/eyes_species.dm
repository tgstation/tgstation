/obj/item/organ/eyes/night_vision/mushroom
	name = "fung-eye"
	desc = "While on the outside they look inert and dead, the eyes of mushroom people are actually very advanced."
	low_light_cutoff = list(0, 15, 20)
	medium_light_cutoff = list(0, 20, 35)
	high_light_cutoff = list(0, 40, 50)
	pupils_name = "photosensory openings"
	penlight_message = "are attached to fungal stalks"

/obj/item/organ/eyes/zombie
	name = "undead eyes"
	desc = "Somewhat counterintuitively, these half-rotten eyes actually have superior vision to those of a living human."
	color_cutoffs = list(25, 35, 5)
	penlight_message = "are rotten and decayed!"

/obj/item/organ/eyes/zombie/penlight_examine(mob/living/viewer, obj/item/examtool)
	return span_danger("[owner.p_Their()] eyes [penlight_message]")

/obj/item/organ/eyes/alien
	name = "alien eyes"
	desc = "It turned out they had them after all!"
	sight_flags = SEE_MOBS
	color_cutoffs = list(25, 5, 42)

/obj/item/organ/eyes/golem
	name = "resonating crystal"
	desc = "Golems somehow measure external light levels and detect nearby ore using this sensitive mineral lattice."
	icon_state = "adamantine_cords"
	eye_icon_state = null
	blink_animation = FALSE
	iris_overlay = null
	color = COLOR_GOLEM_GRAY
	visual = FALSE
	organ_flags = ORGAN_MINERAL
	color_cutoffs = list(10, 15, 5)
	actions_types = list(/datum/action/cooldown/golem_ore_sight)
	penlight_message = "glimmer, their crystaline structure refracting light inwards"
	pupils_name = "lensing gems" // Given it says these are a "mineral lattice" that collects light i assume they work like artifical ruby laser foci

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

/obj/item/organ/eyes/moth
	name = "moth eyes"
	desc = "These eyes seem to have increased sensitivity to bright light, with no improvement to low light vision."
	icon_state = "eyes_moth"
	eye_icon_state = "motheyes"
	blink_animation = FALSE
	iris_overlay = null
	flash_protect = FLASH_PROTECTION_SENSITIVE
	pupils_name = "ommatidia" //yes i know compound eyes have no pupils shut up
	penlight_message = "are bulbous and insectoid"

/obj/item/organ/eyes/ghost
	name = "ghost eyes"
	desc = "Despite lacking pupils, these can see pretty well."
	icon_state = "eyes-ghost"
	blink_animation = FALSE
	movement_type = PHASING
	organ_flags = parent_type::organ_flags | ORGAN_GHOST

/obj/item/organ/eyes/snail
	name = "snail eyes"
	desc = "These eyes seem to have a large range, but might be cumbersome with glasses."
	icon_state = "eyes_snail"
	eye_icon_state = "snail_eyes"
	blink_animation = FALSE
	pupils_name = "eyestalks" //many species of snails can retract their eyes into their face! (my lame science excuse for not having better writing here)
	penlight_message = "are sat upon retractable tentacles"

/obj/item/organ/eyes/jelly
	name = "jelly eyes"
	desc = "These eyes are made of a soft jelly. Unlike all other eyes, though, there are three of them."
	icon_state = "eyes_jelly"
	eye_icon_state = "jelleyes"
	blink_animation = FALSE
	iris_overlay = null
	pupils_name = "lensing bubbles" //imagine a water lens physics demo but with goo. thats how these work.
	penlight_message = "are three bubbles of refractive jelly"

/obj/item/organ/eyes/lizard
	name = "reptile eyes"
	desc = "A pair of reptile eyes with thin vertical slits for pupils."
	icon_state = "lizard_eyes"
	synchronized_blinking = FALSE
	pupils_name = "slit pupils"
	penlight_message = "have vertically slit pupils and tinted whites"

/obj/item/organ/eyes/pod
	name = "pod eyes"
	desc = "Strangest salad you've ever seen."
	icon_state = "eyes_pod"
	eye_color_left = "#375846"
	eye_color_right = "#375846"
	iris_overlay = null
	foodtype_flags = PODPERSON_ORGAN_FOODTYPES
	penlight_message = "are green and plant-like"

/obj/item/organ/eyes/felinid
	name = "felinid eyes"
	desc = "A pair of highly reflective eyes with slit pupils, like those of a cat."
	pupils_name = "slit pupils"
	penlight_message = "shine under the pearly light"
