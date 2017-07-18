// Large objects that don't fit in crates, but must be sellable anyway.

// Crates, boxes, lockers.
/datum/export/large/crate
	cost = 500
	k_elasticity = 0
	unit_name = "crate"
	export_types = list(/obj/structure/closet/crate)
	exclude_types = list(/obj/structure/closet/crate/large, /obj/structure/closet/crate/wooden)

/datum/export/large/crate/total_printout() // That's why a goddamn metal crate costs that much.
	. = ..()
	if(.)
		. += " Thanks for participating in Nanotrasen Crates Recycling Program."

/datum/export/large/crate/wooden
	cost = 100
	unit_name = "large wooden crate"
	export_types = list(/obj/structure/closet/crate/large)
	exclude_types = list()

/datum/export/large/crate/wooden/ore
	unit_name = "ore box"
	export_types = list(/obj/structure/ore_box)

/datum/export/large/crate/wood
	cost = 240
	unit_name = "wooden crate"
	export_types = list(/obj/structure/closet/crate/wooden)
	exclude_types = list()



// Reagent dispensers.
/datum/export/large/reagent_dispenser
	cost = 100 // +0-400 depending on amount of reagents left
	var/contents_cost = 400

/datum/export/large/reagent_dispenser/get_cost(obj/O)
	var/obj/structure/reagent_dispensers/D = O
	var/ratio = D.reagents.total_volume / D.reagents.maximum_volume

	return ..() + round(contents_cost * ratio)

/datum/export/large/reagent_dispenser/water
	unit_name = "watertank"
	export_types = list(/obj/structure/reagent_dispensers/watertank)
	contents_cost = 200

/datum/export/large/reagent_dispenser/fuel
	unit_name = "fueltank"
	export_types = list(/obj/structure/reagent_dispensers/fueltank)

/datum/export/large/reagent_dispenser/beer
	unit_name = "beer keg"
	contents_cost = 700
	export_types = list(/obj/structure/reagent_dispensers/beerkeg)



// Heavy engineering equipment. Singulo/Tesla parts mostly.
/datum/export/large/emitter
	cost = 400
	unit_name = "emitter"
	export_types = list(/obj/machinery/power/emitter)

/datum/export/large/field_generator
	cost = 400
	unit_name = "field generator"
	export_types = list(/obj/machinery/field/generator)

/datum/export/large/collector
	cost = 600
	unit_name = "collector"
	export_types = list(/obj/machinery/power/rad_collector)

/datum/export/large/collector/pa
	cost = 300
	unit_name = "particle accelerator part"
	export_types = list(/obj/structure/particle_accelerator)

/datum/export/large/collector/pa/controls
	cost = 500
	unit_name = "particle accelerator control console"
	export_types = list(/obj/machinery/particle_accelerator/control_box)

/datum/export/large/pipedispenser
	cost = 500
	unit_name = "pipe dispenser"
	export_types = list(/obj/machinery/pipedispenser)

/datum/export/large/supermatter
	cost = 9000
	unit_name = "supermatter shard"
	export_types = list(/obj/machinery/power/supermatter_shard)

// Misc
/datum/export/large/iv
	cost = 300
	unit_name = "iv drip"
	export_types = list(/obj/machinery/iv_drip)

/datum/export/large/barrier
	cost = 325
	unit_name = "security barrier"
	export_types = list(/obj/item/weapon/grenade/barrier, /obj/structure/barricade/security)

//Mecha
/datum/export/large/mech
	export_types = list(/obj/mecha)
	var/sellable

/datum/export/large/mech/applies_to(obj/O)
	if(!..())
		return FALSE

	var/obj/mecha/ME = O
	ME.wreckage = null // So the mech doesn't blow up in the cargo shuttle
	if(sellable)
		return TRUE

/datum/export/large/mech/sellable
	export_types = list()
	sellable = TRUE

/datum/export/large/mech/sellable/ripley
	cost = 7500 //boards cost 2500 and takes another 1566 worth of materials (glass, metal, plaseel) to build + significant labor
	unit_name = "APLU \"Ripley\""
	export_types = list(/obj/mecha/working/ripley)
	exclude_types = list(/obj/mecha/working/ripley/firefighter)

/datum/export/large/mech/sellable/firefighter
	cost = 9000 //same as a ripley but takes 10 more plasteel and 5 less metal
	unit_name = "APLU \"Firefighter\""
	export_types = list(/obj/mecha/working/ripley/firefighter)

/datum/export/large/mech/sellable/odysseus
	cost = 6000 // 1540 of material + 2000 price boards + labor
	unit_name = "odysseus"
	export_types = list(/obj/mecha/medical/odysseus)

/datum/export/large/mech/sellable/gygax
	cost = 25000 // The material is worth 22631 alone. Not as big of a premium as one would expect, since R&D would have provided upgrades by then.
	unit_name = "gygax"
	export_types = list(/obj/mecha/combat/gygax)
	exclude_types = list(/obj/mecha/combat/gygax/dark)

/datum/export/large/mech/sellable/honkmech
	cost = 80000 // The bananium alone is worth around 64887 credits
	unit_name = "H.O.N.K"
	message = "- HONK HONK HONK HONK HONK HONK HONK HONK HONK HONK HONK HONK HONK HONK HONK HONK HONK HONK HONK HONK HONKHONKHONKHONK"
	export_types = list(/obj/mecha/combat/honker)

/datum/export/large/mech/sellable/durand
	cost = 12000 // 7586 worth of material. That's less than a gygax. Players will be disappointed by the durand's comparative lack of worth but oh well. Still a large premium because this requires significant cooperation between R&D, robotics, and cargo.
	unit_name = "durand"
	export_types = list(/obj/mecha/combat/durand)

/datum/export/large/mech/sellable/phazon
	cost = 50000 // 15767 material + anomaly core. Fuck it, if you're willing to try selling one of these you should get BIG FUCKING MONEY
	unit_name = "phazon"
	export_types = list(/obj/mecha/combat/phazon)

/datum/export/large/mech/sellable/syndiegygax
	cost = 50000 // You somehow stole a nuke op's gygax and sold it to nanotrasen. Go you.
	unit_name = "captured syndicate gygax"
	export_types = list(/obj/mecha/combat/gygax/dark)

/datum/export/large/mech/sellable/syndiegygax/syndie
	cost = 25000 // You somehow stole a nuke op's gygax and sold it back to the syndicate. Why would you do this?
	unit_name = "gygax"
	emagged = TRUE

/datum/export/large/mech/sellable/mauler
	cost = 87500 // Whoa, momma.
	unit_name = "captured mauler"
	export_types = list(/obj/mecha/combat/marauder/mauler)

/datum/export/large/mech/sellable/mauler/syndie
	cost = 43750 // Just like the mauler is worth 1.75x the telecrystals compared to the gygax, the price reflects this
	unit_name = "mauler"
	emagged = TRUE
