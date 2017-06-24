
//Techweb nodes are GLOBAL, there should only be one instance of them in the game. Persistant changes should never be made to them in-game.

/datum/techweb_node
	var/id
	var/display_name = "Errored Node"
	var/description = "Why are you seeing this?"
	var/starting_node = FALSE	//Whether it's available without any research.
	var/list/prereq_ids = list()
	var/list/design_ids = list()
	var/list/datum/techweb_node/prerequisites = list()		//Assoc list id = datum
	var/list/datum/techweb_node/unlocks = list()			//CALCULATED FROM OTHER NODE'S PREREQUISITES. Assoc list id = datum.
	var/list/datum/design/designs = list()					//Assoc list id = datum
	var/list/boost_item_paths = list()		//Associative list, path = point_value.
	var/export_price = 0					//Cargo export price.
	var/research_cost = 0					//Point cost to research.
	var/boosted_path						//If science boosted this by deconning something, it puts the path here to make it one-time-only.

/datum/techweb_node/proc/get_price()
	if(!boosted_path)	//don't bother.
		return research_cost
	var/discount = boost_item_paths[boosted_path]
	return research_cost - discount
