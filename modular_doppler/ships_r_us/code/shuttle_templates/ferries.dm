/datum/map_template/shuttle/personal_buyable/ferries
	personal_shuttle_type = PERSONAL_SHIP_TYPE_FERRY
	port_id = "ferry"

// Little people mover

/datum/map_template/shuttle/personal_buyable/ferries/people_mover
	name = "CAS Hafila"
	description = "A common shuttle used for ferrying crew short distances. \
		Has seating for six plus the pilot, as well as basic ship supplies. \
		Powered by two large power cells, with an onboard SOFIE generator \
		as backup in case those cells run dry."
	credit_cost = CARGO_CRATE_VALUE * 8
	suffix = "hafila"
	width = 15
	height = 11
	personal_shuttle_size = PERSONAL_SHIP_MEDIUM

/area/shuttle/personally_bought/people_mover
	name = "CAS Hafila"

// Personal ship with some commodities

/datum/map_template/shuttle/personal_buyable/ferries/house_boat
	name = "CAS Manzil"
	description = "A common personal shuttle used often by solo spacers. \
		An upgraded version of the CAS Hafila, sharing \
		its general shape and power plant. The bonus is that instead of \
		six seats for ferrying crew, there is a small suite and kitchen for life \
		in the void."
	credit_cost = CARGO_CRATE_VALUE * 10
	suffix = "manzil"
	width = 15
	height = 11
	personal_shuttle_size = PERSONAL_SHIP_MEDIUM

/area/shuttle/personally_bought/house_boat
	name = "CAS Manzil"

// Basically, a private jet

/datum/map_template/shuttle/personal_buyable/ferries/private_liner
	name = "CAS Khasun"
	description = "The SolFed VIP transport standard. \
		Room enough for one man of the hour and his two insanely bored bodyguards. \
		Has half of the power storage capacity of other ships, but you wouldn't go exploring \
		in a VIP transport shuttle, would you?"
	credit_cost = CARGO_CRATE_VALUE * 12
	suffix = "khasun"
	width = 23
	height = 11
	personal_shuttle_size = PERSONAL_SHIP_MEDIUM

/area/shuttle/personally_bought/private_liner
	name = "CAS Khasun"
