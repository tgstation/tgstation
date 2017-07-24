

//Base Node
/datum/techweb_node/base
	id = "base"
	starting_node = TRUE
	display_name = "Basic Research Technology"
	description = "NT default research technologies."
	design_ids = list("basic_matter_bin", "basic_scanning", "basic_capacitor", "basic_micro_laser", "micro_mani",
	"destructive_analyzer", "protolathe", "circuit_imprinter", "experimentor", "rdconsole")		//Prevents research from getting bricked.

/datum/techweb_node/materials/basic
	id = "basicmaterials"
	display_name = "Basic Materials Processing"
	description = "The study into processing and use of basic materials, like glass, and steel."
	prereq_ids = list("base")

/datum/techweb_node/materials/advanced
	id = "advancedmaterials"
	display_name = "Advanced Materials Processing"
	description = "The study into processing and use of more advanced materials, like gold and silver."
	prereq_ids = list("basicmaterials")
	design_ids = list("adv_matter_bin")

/datum/techweb_node/materials/industrial
	id = "industrialmaterials"
	display_name = "Industrial Materials Processing"
	description = "The study into processing and use of industrial materials, including uranium, diamond, and titanium."
	prereq_ids = list("advancedmaterials")
	design_ids = list("plasteel", "plastitanium", "alienalloy", "super_matter_bin")

/datum/techweb_node/materials/bluespace
	id = "bluespacematerials"
	display_name = "Bluespace Materials Processing"
	description = "Highly advanced research into processing and use of rare materials with transdimensional bluespace properties."
	prereq_ids = list("industrialmaterials")
	design_ids = list("bluespace_matter_bin")

/datum/techweb_node/bluespace/basic
	id = "bluespace_basic"
	display_name = "Bluespace Research"
	description = "Basic technology that uses the barely-understood dimension known as \"bluespace\"."
	prereq_ids = list("base")
	design_ids = list("beacon")

/datum/techweb_node/bluespace/GPS
	id = "bluespace_gps"
	display_name = "Bluespace - Precision Tracking"
	description = "Technology allowing for precise location of devices that emit a bluespace tracking signal."
	prereq_ids = list("bluespace_basic", "adv_data")
	design_ids = list("telesci_gps")

/datum/techweb_node/data_theory/basic
	id = "basic_data"
	display_name = "Basic Data Theory"
	description = "Basic research into programming and computer logic"
	prereq_ids = list("base")

/datum/techweb_node/data_theory/advanced
	id = "adv_data"
	display_name = "Advanced Data Theory"
	description = "Advanced programming research allowing for complex integrated circuits and logic processing."
	prereq_ids = list("basic_data")

/datum/techweb_node/processing/basic
	id = "basic_processing"
	display_name = "Basic Material Processing"
	description = "Primitive automation and manipulation technology for automated machinery and lathes."
	prereq_ids = list("adv_data", "advancedmaterials")
	design_ids = list("autolathe")

/datum/techweb_node/biotech/basic
	id = "basic_biotech"
	display_name = "Basic Biological Technology"
	description = "The study of what makes us tick."
	prereq_ids = list("base")

/datum/techweb_node/robotics/interface
	id = "robotics_interface"
	display_name = "Man Machine Interfacing"
	description = "Research into a device that can directly interpret neural signals to computer data, allowing for attached brains to control various devices."
	prereq_ids = list("basic_biotech", "adv_data")
	design_ids = list("mmi")

/datum/techweb_node/weapons/firearm
	id = "firearm"
	display_name = "Firearm Research"
	description = "How guns work."
	prereq_ids = list("adv_data", "advancedmaterials")
	design_ids = list("pin_testing")

/datum/techweb_node/weapons/grenades
	id = "grenades"
	display_name = "Grenade Casings"
	description = "Fire in the hole!"
	prereq_ids = list("firearm", "advancedmaterials")
	design_ids = list("large_grenade", "pyro_grenade", "adv_grenade")

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
