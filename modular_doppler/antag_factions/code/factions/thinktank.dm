/datum/antag_faction/thinktank
	name = "Grey Think-Tank"
	description = "A group of greys from a mothership, collaborating on one of their many esoteric projects; From evaluating how many brains can fit in a moth's body, to engineering fruit that meets every nutritional need in one bite, no field of science is spared from a think-tank's purview.\n\n\
	However, samples, materials and even control data do not come idly. To reduce their workload and maximize research time, think-tanks often hire or brainwash capable individuals.\n\n\
	Additionally, think-tanks have attracted a cult of personality in recent years. Conspiracy theorists and scientific fanatics who come upon a discarded piece of Grey technology often become obssessed, performing criminal acts to gain an audience with the elusive faction."
	antagonist_types = list(/datum/antagonist/traitor, /datum/antagonist/spy)
	faction_category = /datum/uplink_category/faction_special/thinktank
	entry_line = span_boldnotice("Research issuance acknowledged: the Think-Tank welcomes you, contractor. Consult your uplink device for sortie-specific equipment to assist you in your fieldwork. Results will be expected by the conclusion of your shift.")

/datum/uplink_category/faction_special/thinktank
	name = "Research Operative Issued Equipment"
	weight = 100

/datum/antag_faction_item/thinktank
	faction = /datum/antag_faction/thinktank

// items

/obj/item/gun/energy/shrink_ray/thinktank
	pin = /obj/item/firing_pin

/datum/antag_faction_item/thinktank/shrink_ray
	name = "Shrink Ray"
	description = "This is a piece of frightening Grey tech that enhances the magnetic pull of atoms in a localized space to temporarily make an object shrink. Great for break-ins, or cutting a foe down to size. "
	item = /obj/item/gun/energy/shrink_ray/thinktank
	cost = 6

/datum/antag_faction_item/thinktank/grey_toolkit
	name = "Grey Tool Kit"
	description = "A complete set of bleeding edge engineering tools. The multitool even identifies wire functions for you and your lesser mind. How considerate of your sponsor."
	item = /obj/item/storage/belt/military/abductor/full
	cost = 2
