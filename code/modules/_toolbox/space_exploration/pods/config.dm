//var/datum/space_exploration_config/pod/pod_config

GLOBAL_DATUM_INIT(pod_config, /datum/space_exploration_config/pod, new)


/datum/space_exploration_config/pod
	category = "Pod"

	var/damage_notice_cooldown
	var/damage_overlay_threshold
	var/ex_act_damage
	var/blob_act_damage
	var/emp_act_attachment_toggle_chance
	var/emp_act_power_absorb_percent
	var/emp_act_duration
	var/emp_sparkchance
	var/fire_damage
	var/fire_damage_cooldown
	var/fire_oxygen_consumption_percent
	var/fire_damage_oygen_cutoff
	var/pod_pullout_delay
	var/list/drivable = list()
	var/metal_repair_threshold_percent
	var/metal_repair_amount
	var/welding_repair_amount
	var/movement_cost
	var/alien_damage_lower
	var/alien_damage_upper
	var/paw_damage_lower
	var/paw_damage_upper