
/datum/techweb_node/basic_materials
	id = "basicmaterials"
	starting_node = TRUE
	display_name = "Basic Materials Processing"
	description = "The study into processing and use of basic materials, like glass, and steel."
	unlock_ids = list("advancedmaterials")
	design_ids = list("basic_matter_bin")

/datum/techweb_node/advanced_materials
	id = "advancedmaterials"
	display_name = "Advanced Materials Processing"
	description = "The study into processing and use of more advanced materials, like gold and silver."
	unlock_ids = list("industrialmaterials")
	design_ids = list("adv_matter_bin")

/datum/techweb_node/industrial_materials
	id = "industrialmaterials"
	display_name = "Industrial Materials Processing"
	description = "The study into processing and use of industrial materials, including uranium, diamond, and titanium."
	unlock_ids = list("bluespacematerials")
	design_ids = list("plasteel", "plastitanium", "alienalloy", "super_matter_bin")

/datum/techweb_node/bluespace_materials
	id = "bluespacematerials"
	display_name = "Bluespace Materials Processing"
	description = "Highly advanced research into processing and use of rare materials with transdimensional bluespace properties."
	design_ids = list("bluespace_matter_bin")





/*
/datum/techweb_node
	var/id
	var/display_name = "Errored Node"
	var/description = "Why are you seeing this?"
	var/starting_node = FALSE	//Whether it's available without any research.
	var/list/prereq_ids = list()
	var/list/unlock_ids = list()
	var/list/design_ids = list()
/	var/list/datum/techweb_node/prerequisites = list()
	var/list/datum/techweb_node/unlocks = list()
	var/list/datum/design/designs = list()

*/




//basicelectronicprocessing basicmaterialprocessing basicmechanicaltechnology opticstechnology illegaltechnology biologicaltechnology basicmedicaltechnology advancedmedicaltech advancedbiotech xenobiotech basicpowertech advpower basicdata advelectronicprocessing advancedmaterialprocessing plasmaprocessing advancedmechanicaltechnology mechatech ballisticcombattech lasercombattech illegalballisticcombattech hypodermicimplanttech cyberneticimplanttech advxenobiotech xenobioimplanttech combustiontech nuclearteach advdatatheory cyborgtech bluespacematerialprocessing xenobiomaterialprocessing bluespacemechatech bluespacecombatmechatech combatmechatech advlasertech illegalcombatmechatech illegalcyberimplanttech aitech basicbluespacetech advbluespacetech





