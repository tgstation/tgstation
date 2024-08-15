/datum/techweb_node/medbay_equip
	id = TECHWEB_NODE_MEDBAY_EQUIP
	starting_node = TRUE
	display_name = "Medbay Equipment"
	description = "Essential medical tools to patch you up while medbay is still intact."
	design_ids = list(
		"operating",
		"medicalbed",
		"defibmountdefault",
		"defibrillator",
		"surgical_drapes",
		"scalpel",
		"retractor",
		"hemostat",
		"cautery",
		"circular_saw",
		"surgicaldrill",
		"bonesetter",
		"blood_filter",
		"surgical_tape",
		"penlight",
		"penlight_paramedic",
		"stethoscope",
		"beaker",
		"large_beaker",
		"chem_pack",
		"blood_pack",
		"syringe",
		"dropper",
		"pillbottle",
		"xlarge_beaker",
	)
	experiments_to_unlock = list(
		/datum/experiment/autopsy/human,
		/datum/experiment/autopsy/nonhuman,
		/datum/experiment/autopsy/xenomorph,
		/datum/experiment/scanning/reagent/haloperidol,
		/datum/experiment/scanning/reagent/cryostylane,
	)

/datum/techweb_node/chem_synthesis
	id = TECHWEB_NODE_CHEM_SYNTHESIS
	display_name = "Chemical Synthesis"
	description = "Synthesizing complex chemicals from electricity and thin air... Don't ask how..."
	prereq_ids = list(TECHWEB_NODE_MEDBAY_EQUIP)
	design_ids = list(
		"med_spray_bottle",
		"medigel",
		"medipen_refiller",
		"soda_dispenser",
		"beer_dispenser",
		"chem_dispenser",
		"portable_chem_mixer",
		"chem_heater",
		"w-recycler",
		"meta_beaker",
		"plumbing_rcd",
		"plumbing_rcd_service",
		"plunger",
		"fluid_ducts",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_1_POINTS)

/datum/techweb_node/medbay_equip_adv
	id = TECHWEB_NODE_MEDBAY_EQUIP_ADV
	display_name = "Advanced Medbay Equipment"
	description = "State-of-the-art medical gear for keeping the crew in one piece — mostly."
	prereq_ids = list(TECHWEB_NODE_CHEM_SYNTHESIS)
	design_ids = list(
		"smoke_machine",
		"chem_mass_spec",
		"healthanalyzer_advanced",
		"mod_health_analyzer",
		"crewpinpointer",
		"defibrillator_compact",
		"defibmount",
		"medicalbed_emergency",
		"piercesyringe",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_3_POINTS)
	required_experiments = list(/datum/experiment/scanning/reagent/haloperidol)

/datum/techweb_node/cryostasis
	id = TECHWEB_NODE_CRYOSTASIS
	display_name = "Cryostasis"
	description = "The result of clown accidentally drinking a chemical, now repurposed for safely preserving crew members in suspended animation."
	prereq_ids = list(TECHWEB_NODE_MEDBAY_EQUIP_ADV, TECHWEB_NODE_FUSION)
	design_ids = list(
		"cryotube",
		"mech_sleeper",
		"stasis",
		"cryo_grenade",
		"splitbeaker",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = TECHWEB_TIER_4_POINTS)
	discount_experiments = list(/datum/experiment/scanning/reagent/cryostylane = TECHWEB_TIER_4_POINTS)
