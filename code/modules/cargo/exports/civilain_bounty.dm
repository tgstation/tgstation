/datum/export/bounty_box
	cost = 1
	k_elasticity = 0 //Bounties are non-elastic funds.
	unit_name = "completed bounty cube"
	export_types = list(/obj/item/bounty_cube)

/datum/export/bounty_box/get_base_cost(obj/item/bounty_cube/cube)
	return cube.bounty_value + (cube.bounty_value * cube.speed_bonus)
