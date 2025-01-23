/datum/map_template/shuttle/personal_buyable
	name = "DEBUG: Personal Shuttle Basetype"
	description = "Surely there would be a ship here."
	shuttle_id = "shuttle_personal"
	prefix = "_maps/shuttles/~doppler_shuttles/"
	credit_cost = CARGO_CRATE_VALUE * 10
	who_can_purchase = null
	/// What "type" of ship is this, used in the shopping list
	var/personal_shuttle_type = PERSONAL_SHIP_TYPE_DEBUG
	/// How large, generally, is the ship
	var/personal_shuttle_size = PERSONAL_SHIP_SMALL
