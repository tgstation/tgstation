/datum/map_template/shuttle/personal_buyable/pod
	personal_shuttle_type = PERSONAL_SHIP_TYPE_POD
	port_id = "personal_pod"

/datum/map_template/shuttle/personal_buyable/pod/cramped_salvage
	name = "RA-Ca Salvage Pod"
	description = "Rendolyne Astronautics prides themselves on their low-cost offerings, and the RA-Ca is absolutely no exception. While hyperspace capable, it sports the barest minimum in 'habitable' life support, and its power solution is a plasma-fed generator bolted on to the back of the ship and accessed entirely through EVA. Mostly bought by indebted shipbreakers, but some also choose to live the 'pod life' and retrofit these things as VERY cramped camper vessels."
	credit_cost = CARGO_CRATE_VALUE * 4
	suffix = "salvage_small"
	width = 7
	height = 5
	personal_shuttle_size = PERSONAL_SHIP_SMALL

/area/shuttle/personally_bought/cramped_salvage
	name = "RA-Ca Salvage Pod"

/datum/map_template/shuttle/personal_buyable/pod/endurance_salvage
	name = "RA-Cu Endurance Pod"
	description = "A larger, tri-engined skew of of the Rendolyne Astronautics RA-Ca, the RA-Cu is an 'endurance' pod intended for extended operations at a particular site, featuring extra appliances, greywater plumbing, and a climate-controlled sleeping bunk that fits one. Space and storage are at a -serious- premium, but the livability of these ships for their relative price is just about second to none for a solo space traveler. They are however, notoriously fuel inefficient and come with a small internal battery, but are at least equipped with an extra external fuel rack to ease hand-reloading."
	credit_cost = CARGO_CRATE_VALUE * 12
	suffix = "salvage_endurance"
	width = 8
	height = 7
	personal_shuttle_size = PERSONAL_SHIP_SMALL

/area/shuttle/personally_bought/endurance_salvage
	name = "RA-Cu Endurance Pod"

