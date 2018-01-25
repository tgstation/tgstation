
//Techweb nodes are GLOBAL, there should only be one instance of them in the game. Persistant changes should never be made to them in-game.

/datum/techweb_node
	var/id
	var/display_name = "Errored Node"
	var/description = "Why are you seeing this?"
	var/hidden = FALSE			//Whether it starts off hidden.
	var/starting_node = FALSE	//Whether it's available without any research.
	var/list/prereq_ids = list()
	var/list/design_ids = list()
	var/list/datum/techweb_node/prerequisites = list()		//Assoc list id = datum
	var/list/datum/techweb_node/unlocks = list()			//CALCULATED FROM OTHER NODE'S PREREQUISITES. Assoc list id = datum.
	var/list/datum/design/designs = list()					//Assoc list id = datum
	var/list/boost_item_paths = list()		//Associative list, path = point_value.
	var/autounlock_by_boost = TRUE			//boosting this will autounlock this node.
	var/export_price = 0					//Cargo export price.
	var/research_cost = 0					//Point cost to research.
	var/actual_cost = 0
	var/category = "Misc"				//Category

/datum/techweb_node/New()
	actual_cost = research_cost

/datum/techweb_node/proc/get_price(datum/techweb/host)
	if(host)
		actual_cost = research_cost - host.boosted_nodes[src]
	return actual_cost
