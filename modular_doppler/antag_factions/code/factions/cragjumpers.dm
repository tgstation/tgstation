/datum/antag_faction/cragjumpers
	name = "Crag Jumpers"
	description = "When the working man is sufficiently pressed, the consequences are sometimes explosive. The Crag Jumpers are a blue collar union of 'less-than-licensed' miners trawling the belts and moons in the vicinity of the Nine Lives Promenade, and are not thrilled with the sudden encroachment upon their 'claims' brought by the presence of a new Port Authority vessel.\n\n\
	Armed with a litany of Xion-era mining tools previously outlawed for their awful safety record and a wide array of industrial explosives, they're certain to make their ire known with a bang."
	antagonist_types = list(/datum/antagonist/traitor, /datum/antagonist/spy)
	faction_category = /datum/uplink_category/faction_special/cragjumpers
	entry_line = span_boldnotice("A staticky voice trails across the sub-band of your implanted comms device: \"Remember, kid. You're a Crag Jumper now, and the union's riding on your efforts out here. Don't let those 9LP scabs drive our comrades in Echoes-Dark-Locations out. We're countin' on you.\"")

/datum/uplink_category/faction_special/cragjumpers
	name = "Jumper-grade Reacquired Operational Equipment"
	weight = 100

/datum/antag_faction_item/cragjumpers
	faction = /datum/antag_faction/cragjumpers

// items

/datum/antag_faction_item/cragjumpers/lux_medpen
	name = "Stolen Luxury Medpen"
	description = "Liberated straight from PA scabs working Truth's surface. 60u of all the chemicals you'd ever need to support the working man."
	item = /obj/item/reagent_containers/hypospray/medipen/survival/luxury
	cost = 2

/datum/antag_faction_item/cragjumpers/ko_rock
	name = "Knockout Rock"
	description = "Harvested from anomaly-rich asteroid belts, these rocks are crystallized and unstable clumps N20 gas. Crag Jumpers export them, but they double as weapons against their oxygen breathing foes in tight quarters, releasing deadly gas."
	item = /obj/item/grenade/gas_crystal/nitrous_oxide_crystal
	cost = 4
