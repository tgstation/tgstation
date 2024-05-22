//should most likely make these all be a subtype of /random_bar/box/ or something, would need use subtypesof() though
/datum/map_template/random_room/random_bar/box_base
	name = "Box Default Bar"
	room_id = "box_default_bar"
	mappath = "_maps/~monkestation/RandomBars/Box/default_bar.dmm"
	centerspawner = FALSE
	template_height = 17
	template_width = 11
	weight = 6
	station_name = "Box Station"

/datum/map_template/random_room/random_bar/box_base/clockwork
	name = "Clockwork Bar"
	room_id = "box_clockwork"
	mappath = "_maps/~monkestation/RandomBars/Box/clockwork_bar.dmm"
	weight = 2

/datum/map_template/random_room/random_bar/box_base/cult
	name = "Cult Bar"
	room_id = "box_cult"
	mappath = "_maps/~monkestation/RandomBars/Box/bloody_bar.dmm"
	weight = 2

/datum/map_template/random_room/random_bar/box_base/vietmoth
	name = "Jungle Bar"
	room_id = "box_vietmoth"
	mappath = "_maps/~monkestation/RandomBars/Box/vietmoth_bar.dmm"
	weight = 12
