/datum/wound/blunt/robotic/critical
	name = "Collapsed Superstructure"
	desc = "The superstructure has totally collapsed in one or more locations, causing extreme internal oscillation with every move and massive limb dysfunction"
	treat_text = "Immediately bind the affected limb with gauze or a splint. Repair surgically."
	occur_text = "caves in on itself, damaged solder and shrapnel flying out in a miniature explosion"
	examine_desc = "has caved in, with internal components visible through gaps in the metal"
	severity = WOUND_SEVERITY_CRITICAL
	treat_text_short = "Repair surgically."
	disabling = TRUE

	simple_treat_text = "If on the <b>chest</b>, <b>walk</b>, <b>grasp it</b>, <b>splint</b>, <b>rest</b> or <b>buckle yourself</b> to something to reduce movement effects. \
	Afterwards, repair with surgery."

	homemade_treat_text = "The metal can be made <b>malleable</b> by repeated application of a welder, to a <b>moderate burn</b>. Afterwards, a <b>plunger</b> can reset the metal, \
	as can <b>percussive maintenance</b>. After the metal is reset, if <b>unable to screw/wrench</b>, <b>bone gel</b> can, over time, secure inner components at risk of <b>corrossion</b>. \
	Alternatively, <b>crowbar</b> the limb open to expose the internals - this will make it <b>easier</b> to re-secure them, but has a <b>high risk</b> of <b>shocking</b> you, \
	so use insulated gloves. This will <b>cripple the limb</b>, so use it only as a last resort!"

	interaction_efficiency_penalty = 2.5
	limp_slowdown = 7
	limp_chance = 70
	threshold_penalty = 15

	brain_trauma_group = BRAIN_TRAUMA_SEVERE
	trauma_cycle_cooldown = 2.5 MINUTES

	status_effect_type = /datum/status_effect/wound/blunt/robotic/critical

	sound_effect = 'sound/effects/wounds/crack2.ogg'

	wound_flags = (ACCEPTS_GAUZE|MANGLES_INTERIOR|CAN_BE_GRASPED)
	status_effect_type = /datum/status_effect/wound/blunt/robotic/critical
	treatable_tools = list(TOOL_WELDER, TOOL_CROWBAR)

	base_movement_stagger_score = 50

	base_aftershock_camera_shake_duration = 1.75 SECONDS
	base_aftershock_camera_shake_strength = 1

	chest_attacked_stagger_chance_ratio = 6.5
	chest_attacked_stagger_mult = 4

	chest_movement_stagger_chance = 8

	aftershock_stopped_moving_score_mult = 0.3

	stagger_aftershock_knockdown_ratio = 0.5
	stagger_aftershock_knockdown_movement_ratio = 0.3

	a_or_from = "a"

	/// Has the first stage of our treatment been completed?
	var/superstructure_remedied = FALSE

/datum/wound_pregen_data/blunt_metal/superstructure
	abstract = FALSE
	wound_path_to_generate = /datum/wound/blunt/robotic/secures_internals/critical
	threshold_minimum = 125
