/datum/wound/muscle/robotic
	sound_effect = 'sound/effects/servostep.ogg'

/datum/wound_pregen_data/muscle/robotic
	required_limb_biostate = (BIO_METAL)

/datum/wound/muscle/robotic/moderate
	name = "Overworked Servo"
	desc = "A servo has been overworked, and will operate with reduced efficiency until rested."
	treat_text = "The affected limb should have a tight splint applied. A wrapping of gauze can suffice in a pinch. \
		Follow with plenty of rest."
	treat_text_short = "Apply a splint or a gauze wrapping and allow the patient to rest."
	examine_desc = "appears to be moving sluggishly"
	occur_text = "jitters for a moment before moving sluggishly"
	severity = WOUND_SEVERITY_MODERATE
	interaction_efficiency_penalty = 1.5
	limp_slowdown = 2
	limp_chance = 30
	threshold_penalty = 15
	status_effect_type = /datum/status_effect/wound/muscle/robotic/moderate
	regen_ticks_needed = 90

/datum/wound_pregen_data/muscle/robotic/servo
	abstract = FALSE
	wound_path_to_generate = /datum/wound/muscle/robotic/moderate
	threshold_minimum = 35

/datum/wound/muscle/robotic/severe
	name = "Exhausted Piston"
	sound_effect = 'sound/effects/stall.ogg'
	desc = "An important hydraulic piston has been critically overused, resulting in total dysfunction until it recovers."
	treat_text = "The affected limb should have a tight splint applied. A wrapping of gauze can suffice in a pinch. \
		Follow with plenty of rest."
	treat_text_short = "Apply a splint or a gauze wrapping and allow the patient to rest."
	examine_desc = "is stiffly limp, the extremities splayed out widely"
	occur_text = "goes completely stiff, seeming to lock into position"
	severity = WOUND_SEVERITY_SEVERE
	interaction_efficiency_penalty = 2
	limp_slowdown = 5
	limp_chance = 40
	threshold_penalty = 35
	disabling = TRUE
	status_effect_type = /datum/status_effect/wound/muscle/robotic/severe
	regen_ticks_needed = 150

/datum/wound_pregen_data/muscle/robotic/hydraulic
	abstract = FALSE

	wound_path_to_generate = /datum/wound/muscle/robotic/severe
	threshold_minimum = 80

