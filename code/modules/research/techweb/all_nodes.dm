
//Current rate: 135000 research points in 90 minutes
//Current cargo price: 500000 points for fullmaxed R&D.

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
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/mmi
	id = "mmi"
	display_name = "Man Machine Interface"
	description = "A slightly Frankensteinian device that allows human brains to interface natively with software APIs."
	prereq_ids = list("biotech", "neural_programming")
	design_ids = list("mmi")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/posibrain
	id = "posibrain"
	display_name = "Positronic Brain"
	description = "Applied usage of neural technology allowing for autonomous AI units based on special metallic cubes with conductive and processing circuits."
	prereq_ids = list("mmi", "neural_programming")
	design_ids = list("mmi_posi")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/datatheory
	id = "datatheory"
	display_name = "Data Theory"
	description = "Big Data, in space!"
	prereq_ids = list("base")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/neural_programming
	id = "neural_programming"
	display_name = "Neural Programming"
	description = "Study into networks of processing units that mimic our brains."
	prereq_ids = list("biotech", "datatheory")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/computer_hardware_basic				//Modular computers are shitty and nearly useless so until someone makes them actually useful this can be easy to get.
	id = "computer_hardware_basic"
	display_name = "Computer Hardware"
	description = "How computer hardware are made."
	prereq_ids = list("datatheory")
	research_cost = 5000
	export_price = 5000
	design_ids = list("hdd_basic", "hdd_advanced", "hdd_super", "hdd_cluster", "ssd_small", "ssd_micro", "netcard_basic", "netcard_advanced", "netcard_wired",
	"portadrive_basic", "portadrive_advanced", "portadrive_super", "cardslot", "aislot", "miniprinter", "APClink", "bat_control", "bat_normal", "bat_advanced",
	"bat_super", "bat_micro", "bat_nano", "cpu_normal", "pcpu_normal", "cpu_small", "pcpu_small")

/datum/techweb_node/comptech
	id = "comptech"
	display_name = "Computer Consoles"
	description = "Computers and how they work."
	prereq_ids = list("datatheory")
	research_cost = 2000
	export_price = 2000

/datum/techweb_node/computer_board_gaming
	id = "computer_board_gaming"
	display_name = "Arcade Games"
	description = "For the slackers on the station."
	prereq_ids = list("datatheory", "comptech")
	design_ids = list("arcade_battle", "arcade_orion")
	research_cost = 2000
	export_price = 2000

/datum/techweb_node/bluespace_basic
	id = "bluespace_basic"
	display_name = "Basic Bluespace Theory"
	description = "Basic studies into the mysterious alternate dimension known as bluespace."
	prereq_ids = list("base")
	design_ids = list("beacon")
	research_cost = 5000
	export_price = 10000

/datum/techweb_node/telecomms
	id = "telecomms"
	display_name = "Telecommunications Technology"
	description = "Subspace transmission technology for near-instant communications devices."
	prereq_ids = list("datatheory", "bluespace_basic")
	research_cost = 10000
	export_price = 10000
	design_ids = list("s-reciever", "s-bus", "s-broadcaster", "s-processor", "s-hub", "s-server", "s-relay")

/datum/techweb_node/comp_recordkeeping
	id = "comp_recordkeeping"
	display_name = "Computerized Recordkeeping"
	description = "Organized record databases and how they're used."
	prereq_ids = list("comptech")
	research_cost = 5000
	export_price = 5000

/datum/techweb_node/alientech
	id = "alientech"
	display_name = "Alien Technology"
	description = "Things used by the greys."
	prereq_ids = list("base")
	research_cost = 20000
	export_price = 50000
	hidden = TRUE
	design_ids = list("alienalloy")


