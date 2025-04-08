/datum/map_template/shuttle/personal_buyable/incomplete
	personal_shuttle_type = PERSONAL_SHIP_TYPE_DIY
	port_id = "diy"

// Small incomplete ship for finishing yourself

/datum/map_template/shuttle/personal_buyable/incomplete/small
	name = "CAS Khar-Habka"
	description = "A small-sized shuttle that comes without most of it's interior. \
		A popular choice among those who are more of the handy-do-it-yourself type \
		when it comes to high tech shuttle construction."
	credit_cost = CARGO_CRATE_VALUE * 6
	suffix = "diy_small"
	width = 15
	height = 7
	personal_shuttle_size = PERSONAL_SHIP_SMALL

/area/shuttle/personally_bought/do_it_yourself_small
	name = "CAS Khar-Habka"

// Medium sized incomplete ship

/datum/map_template/shuttle/personal_buyable/incomplete/medium
	name = "CAS Khar-Hiktar"
	description = "A medium-sized shuttle that comes without most of it's interior. \
		A popular choice among those who are more of the handy-do-it-yourself type \
		when it comes to high tech shuttle construction."
	credit_cost = CARGO_CRATE_VALUE * 10
	suffix = "diy_medium"
	width = 15
	height = 11
	personal_shuttle_size = PERSONAL_SHIP_MEDIUM

/area/shuttle/personally_bought/do_it_yourself_medium
	name = "CAS Khar-Hiktar"

// Big sized incomplete ship

/datum/map_template/shuttle/personal_buyable/incomplete/large
	name = "CAS Khar-Milkia"
	description = "A large shuttle that comes without most of it's interior. \
		A popular choice among those who are more of the handy-do-it-yourself type \
		when it comes to high tech shuttle construction."
	credit_cost = CARGO_CRATE_VALUE * 20
	suffix = "diy_large"
	width = 28
	height = 11
	personal_shuttle_size = PERSONAL_SHIP_LARGE

/area/shuttle/personally_bought/do_it_yourself_large
	name = "CAS Khar-Milkia"
