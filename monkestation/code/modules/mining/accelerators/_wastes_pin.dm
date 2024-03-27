//Wastes firing pin - restricts a weapon to only outside when mining - based on area defines not z-level
/obj/item/firing_pin/wastes
	name = "Wastes firing pin"
	desc = "This safety firing pin allows weapons to be fired only outside on the wastes of lavaland or icemoon."
	fail_message = "Wastes check failed! - Try getting further from the station first."
	pin_hot_swappable = FALSE
	pin_removable = FALSE
	var/list/wastes = list(
		/area/icemoon/surface/outdoors,
		/area/icemoon/underground/unexplored,
		/area/icemoon/underground/explored,

		/area/lavaland/surface/outdoors,

		/area/ocean/generated,
		/area/ocean/generated_above,

		/area/ruin,
	)

/obj/item/firing_pin/wastes/pin_auth(mob/living/user)
	if(!istype(user))
		return FALSE
	if (is_type_in_list(get_area(user), wastes))
		return TRUE
	return FALSE
