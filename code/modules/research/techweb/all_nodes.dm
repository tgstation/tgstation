
//Base Node
/datum/techweb_node/base
	id = "base"
	starting_node = TRUE
	display_name = "Basic Research Technology"
	description = "NT default research technologies."
	design_ids = list("basic_matter_bin", "basic_scanning", "basic_capacitor", "basic_micro_laser", "micro_mani",
	"destructive_analyzer", "protolathe", "circuit_imprinter", "experimentor", "rdconsole", "design_disk", "tech_disk")			//Default research tech, prevents bricking

/datum/techweb_node/biotech
	id = "biotech"
	display_name = "Biological Technology"
	description = "What makes us tick."	//the MC, silly!
	prereq_ids = list("base")
	design_ids = list("mass_spectrometer")
	research_cost =
	export_price =

/datum/techweb_node/mmi
	id = "mmi"
	display_name = "Man Machine Interface"
	description = "A slightly Frankensteinian device that allows human brains to interface natively with software APIs."
	prereq_ids = list("biotech", "neural_programming")
	design_ids = list("mmi")
	research_cost =
	export_price =

/datum/techweb_node/posibrain
	id = "posibrain"
	display_name = "Positronic Brain"
	description = "Applied usage of neural technology allowing for autonomous AI units based on special metallic cubes with conductive and processing circuits."
	prereq_ids = list("mmi", "neural_programming")
	design_ids = list("mmi_posi")
	research_cost =
	export_price =

/datum/techweb_node/datatheory
	id = "datatheory"
	display_name = "Data Theory"
	description = "Big Data, in space!"
	prereq_ids = list("base")
	research_cost =
	export_price =

/datum/techweb_node/neural_programming
	id = "neural_programming"
	display_name = "Neural Programming"
	description = "Study into networks of processing units that mimic our brains."
	prereq_ids = list("biotech", "datatheory")
	research_cost =
	export_price =

/datum/techweb_node/computer_hardware_basic				//Modular computers are shitty and nearly useless so until someone makes them actually useful this can be easy to get.
	id = "computer_hardware_basic"
	display_name = "Computer Hardware"
	description = "How computer hardware are made."
	prereq_ids = list("datatheory")
	research_cost =
	export_price =
	design_ids = list("

/*
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
*/
