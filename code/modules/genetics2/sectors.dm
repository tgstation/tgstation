var/global/current_sector_id=0
/datum/genetic_sector
	var/name = "UNKNOWN SECTOR"
	var/desc = "LOLIDK"

	var/id = ""
	var/uniqid = "" // 3-char ID, shown when locked.
	var/list/prerequisites = list()
	var/list/blocks_txt = list()
	var/list/blocks = list() // DO NOT FUCKING USE THIS
	var/required_biomass = 0 // In hominids (/mob/living/carbon)
	var/time_required = 300  // Decaseconds required to unlock
	var/time_researched = 0
	var/active=0             // Accessible
	var/locked=0             // Cannot be purchased (yet)

/datum/genetic_sector/New()
	uniqid = add_zero2("[current_sector_id++]",3)

	// Set blocks
	for(var/blockname in blocks_txt)
		var/block = assigned_blocks[blockname]
		if(block)
			blocks += block

///////////////////////////////////////
// SECTORS
///////////////////////////////////////

/datum/genetic_sector/metabolism
	id = "metabolism"
	name = "Metabolism"
	desc = "Grants access to areas of DNA that affect how the body controls its temperature."
	required_biomass = 1
	time_required = 30 SECONDS
	blocks_txt=list(
		"COLD",
		"FIRE",
		"IMMOLATE",
		"SOBER",
		"MELT",
		"FAT"
	)

/datum/genetic_sector/mind
	id = "mind"
	name = "Mental Aptitude"
	desc = "Reveals parts of DNA that affect mental capabilities"
	required_biomass = 2
	time_required = 30 SECONDS
	blocks_txt=list(
		"PSYRESIST",
		"HALLUCINATION",
		"TWITCH",
		"EPILEPSY",
	)

/datum/genetic_sector/teleability
	id = "teleability"
	name = "Teleability"
	desc = "Activates unused portions of the brain that can affect people a great distance away."
	prerequisites = list("mind")
	required_biomass = 4
	time_required = 1 MINUTES
	blocks_txt = list(
		"REMOTEVIEW",
		"REMOTETALK",
		"CRYO",
		"EMPATH"
	)

/datum/genetic_sector/telekinesis
	id = "telekinesis"
	name = "Telekinesis"
	desc = "Activates unused portions of the brain that can affect objects a great distance away."
	prerequisites = list("teleability")
	required_biomass = 5
	time_required = 2 MINUTES
	blocks_txt = list(
		"TELE",
		"FAKE"
	)

/datum/genetic_sector/senses
	id = "senses"
	name = "Senses"
	desc = "Accesses genes that affect vision and hearing."
	prerequisites = list("mind")
	required_biomass = 4
	time_required = 30 SECONDS
	blocks_txt = list(
		"XRAY",
		"BLIND",
		"GLASSES",
		"EMPATH",
		"DEAF"
	)

/datum/genetic_sector/respiration
	id = "respiration"
	name = "Respiration"
	desc = "Mess around with genes that affect breathing and lungs."
	prerequisites = list("metabolism")
	time_required = 1 MINUTES
	required_biomass = 4
	blocks_txt = list(
		"NOBREATH",
		"COUGH",
		"INCREASERUN",
	)