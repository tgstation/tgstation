
/datum/map_template/random_bars
	var/room_id //The SSmapping random_room_template list is ordered by this var
	var/spawned //Whether this template (on the random_room template list) has been spawned
	var/station_name //Matches this template with that right station
	var/centerspawner = TRUE
	var/template_height = 0
	var/template_width = 0
	var/weight = 10 //weight a room has to appear
	var/stock = 1 //how many times this room can appear in a round

/** EXAMPLE OF WEIGHT CHANCES:
 * Given the following list:
 * A = 6, B = 3, C = 1, D = 0
 * A would have a 60% chance of being picked,
 * B would have a 30% chance of being picked,
 * C would have a 10% chance of being picked,
 * and D would have a 0% chance of being picked.
 * You should only pass integers in.
*/

/// BOX STATION BARS
/datum/map_template/random_bars/box_default_bar
	name = "Box Station Default Bar"
	room_id = "box_default_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Box/default_bar.dmm"
	centerspawner = FALSE
	template_height = 9
	template_width = 15
	weight = 1
	station_name = "Box Station"

/datum/map_template/random_bars/box_clown_bar
	name = "Box Station Clown Bar"
	room_id = "box_clown_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Box/clown_bar.dmm"
	centerspawner = FALSE
	template_height = 9
	template_width = 15
	weight = 1
	station_name = "Box Station"

/datum/map_template/random_bars/box_syndi_bar
	name = "Box Station Syndicate Bar"
	room_id = "box_syndi_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Box/syndi_bar.dmm"
	centerspawner = FALSE
	template_height = 9
	template_width = 15
	weight = 1
	station_name = "Box Station"

/datum/map_template/random_bars/box_vietmoth_bar
	name = "Box Station Vietmoth Bar"
	room_id = "box_vietmoth_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Box/vietmoth_bar.dmm"
	centerspawner = FALSE
	template_height = 9
	template_width = 15
	weight = 1
	station_name = "Box Station"

/datum/map_template/random_bars/box_bloody_bar
	name = "Box Station Bloody Bar"
	room_id = "box_bloody_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Box/bloody_bar.dmm"
	centerspawner = FALSE
	template_width = 15
	template_height = 9
	weight = 1
	station_name = "Box Station"

/datum/map_template/random_bars/box_clockwork_bar
	name = "Box Station Clockwork Bar"
	room_id = "box_clockwork_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Box/clockwork_bar.dmm"
	centerspawner = FALSE
	template_width = 15
	template_height = 9
	weight = 1
	station_name = "Box Station"


/// METASTATION BARS
/datum/map_template/random_bars/meta_default_bar
	name = "Metastation Default Bar"
	room_id = "meta_default_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Meta/default_bar.dmm"
	centerspawner = FALSE
	template_height = 9
	template_width = 9
	weight = 1
	station_name = "MetaStation"

/datum/map_template/random_bars/meta_grungy_bar
	name = "Metastation Grungy Bar"
	room_id = "meta_grungy_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Meta/grungy_bar.dmm"
	centerspawner = FALSE
	template_height = 9
	template_width = 9
	weight = 1
	station_name = "MetaStation"

/datum/map_template/random_bars/meta_medical_bar
	name = "Metastation Med-Bar"
	room_id = "meta_med_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Meta/med_bar.dmm"
	centerspawner = FALSE
	template_height = 9
	template_width = 9
	weight = 1
	station_name = "MetaStation"

/datum/map_template/random_bars/meta_tribal_bar
	name = "Metastation Tribal Bar"
	room_id = "meta_tribal_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Meta/tribal_bar.dmm"
	centerspawner = FALSE
	template_height = 9
	template_width = 9
	weight = 1
	station_name = "MetaStation"

/datum/map_template/random_bars/meta_magical_bar
	name = "Metastation Wiz-Bar"
	room_id = "meta_magical_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Meta/magical_bar.dmm"
	centerspawner = FALSE
	template_height = 9
	template_width = 9
	weight = 1
	station_name = "MetaStation"



/// PUBBYSTATION BARS
/datum/map_template/random_bars/pubby_default_bar
	name = "Pubbystation Default Bar"
	room_id = "pubby_default_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Pubby/default_bar.dmm"
	centerspawner = FALSE
	template_height = 12
	template_width = 18
	weight = 1
	station_name = "PubbyStation"

/datum/map_template/random_bars/pubby_japan_bar
	name = "Pubbystation Japanese Bar"
	room_id = "pubby_japanese_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Pubby/japanese_bar.dmm"
	centerspawner = FALSE
	template_height = 12
	template_width = 18
	weight = 1
	station_name = "PubbyStation"

/datum/map_template/random_bars/pubby_pool_bar
	name = "Pubbystation Pool Bar"
	room_id = "pubby_pool_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Pubby/pool_bar.dmm"
	centerspawner = FALSE
	template_height = 12
	template_width = 18
	weight = 1
	station_name = "PubbyStation"

/datum/map_template/random_bars/pubby_hobo_bar
	name = "Pubbystation Hobo Bar"
	room_id = "pubby_hobo_bar"
	mappath = "monkestation/_maps/RandomRooms/_Bars/Pubby/hobo_bar.dmm"
	centerspawner = FALSE
	template_height = 12
	template_width = 18
	weight = 1
	station_name = "PubbyStation"
