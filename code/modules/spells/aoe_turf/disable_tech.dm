/spell/aoe_turf/disable_tech
	name = "Disable Tech"
	desc = "This spell disables all weapons, cameras and most other technology in range."
	charge_max = 400
	spell_flags = NEEDSCLOTHES
	invocation = "NEC CANTIO"
	invocation_type = SpI_SHOUT
	selection_type = "range"
	range = 0
	inner_radius = -1

	cooldown_min = 200 //50 deciseconds reduction per rank

	var/emp_heavy = 6
	var/emp_light = 10

	hud_state = "wiz_tech"

/spell/aoe_turf/disable_tech/cast(list/targets)

	for(var/turf/target in targets)
		empulse(get_turf(target), emp_heavy, emp_light)
	return