/datum/map_template/shuttle/emergency/glass_house_shuttle
	prefix = "monkestation/_maps/shuttles/"
	suffix = "glass_house_shuttle"
	name = "Glass House Shuttle"
	description = "Made of high density poly-carbonates with every surface polished to a fine finish. Only company approved \
	scuffless slippers  are to be worn when boarding to preserve hull integrity"
	credit_cost = 1000

/datum/map_template/shuttle/cargo/holestation
	prefix = "monkestation/_maps/shuttles/"
	suffix = "holestation"
	name = "supply shuttle (Hole)"

/datum/map_template/shuttle/mining/holestation
	prefix = "monkestation/_maps/shuttles/"
	suffix = "holestation"
	name = "mining shuttle (Hole)"

/datum/map_template/shuttle/exploration/holestation
	prefix = "monkestation/_maps/shuttles/"
	suffix = "holestation"
	name = "exploration shuttle (Hole)"

/datum/map_template/shuttle/emergency/holestation
	prefix = "monkestation/_maps/shuttles/"
	suffix = "holestation"
	name = "Hole Station Emergency Shuttle"
	credit_cost = 2500
	description = "A heavily retrofitted Box-Model exfiltration vessel, complete with private rooms for every non-civilian \
	department. Rated maximum safe occupancy: 20. Exceeding this limit may result in the witholding of your health benefeits."
	admin_notes = "Designed for lowpop rounds and will be exceedingly chaotic outside of that setting."

/datum/map_template/shuttle/emergency/brass
	prefix = "monkestation/_maps/shuttles/"
	suffix = "brass"
	name = "Ratvarian Emergency Shuttle"
	credit_cost = 50000
	description = "This shuttle came from a portal with the message: His light shall save us all. Message ends."
	can_be_bought = FALSE
	admin_notes = "Currently an admin only shuttle. Has working cogscarab shells however they lack the power to start the ark \
	and cannot teleport unless Reebe is loaded."

/datum/map_template/shuttle/emergency/metabananium
	prefix = "_maps/shuttles/"
	suffix = "metabananium"
	name = "Clownified Shuttle"
	description = "Honk honk honk honk honk honk honk honk honk honk honk honk henk"
	admin_notes = "Made out of solid bananium, filled with clown mobs. Very evil."
	credit_cost = 7500
	can_be_bought = FALSE
	illegal_shuttle = TRUE

/datum/map_template/shuttle/emergency/pods
	prefix = "_maps/shuttles/"
	suffix = "pods"
	name = "Multiple Escape Pods"
	description = "Well, you can't afford a shuttle but you need more than one or two pods. We got you covered."
	admin_notes = "Multiple tiny pods loosely floating near each other. Painful to experience."
	credit_cost = 1000
	can_be_bought = FALSE
	illegal_shuttle = TRUE
