/obj/machinery/rnd/production/techfab
	name = "technology fabricator"
	desc = "Produces researched prototypes with raw materials and energy."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/techfab
	categories = list(
		CATEGORY_POWER_DESIGNS = list(),
		CATEGORY_MEDICAL_DESIGNS = list(),
		CATEGORY_BLUESPACE_DESIGNS = list(),
		CATEGORY_STOCK_PARTS = list(
			CATEGORY_TIER_MATERIALS,
			CATEGORY_TIER_BLUESPACE,
			CATEGORY_TIER_SUPER,
			CATEGORY_TIER_ADVANCED,
			CATEGORY_TIER_BASIC,
			CATEGORY_TIER_TELECOMS
		),
		CATEGORY_EQUIPMENT = list(),
		CATEGORY_TOOL_DESIGNS = list(),
		CATEGORY_MINING_DESIGNS = list(),
		CATEGORY_ELECTRONICS = list(),
		CATEGORY_WEAPONS = list(),
		CATEGORY_AMMO = list(),
		CATEGORY_FIRING_PINS = list(),
		CATEGORY_COMPUTER_PARTS = list(),
		CATEGORY_AI_MODULES = list(),
		CATEGORY_COMPUTER_BOARDS = list(),
		CATEGORY_MACHINERY_TELEPORTATION = list(),
		CATEGORY_MACHINERY_MEDICAL = list(),
		CATEGORY_MACHINERY_ENGINEERING = list(),
		CATEGORY_EXOSUIT_MODULES = list(),
		CATEGORY_MACHINERY_HYDRO = list(),
		CATEGORY_SUBSPACE_TELECOMS = list(),
		CATEGORY_MACHINERY_RESEARCH = list(),
		CATEGORY_MACHINERY_MISC = list(),
		CATEGORY_COMPUTER_PARTS = list()
	)
	console_link = FALSE
	production_animation = "protolathe_n"
	allowed_buildtypes = PROTOLATHE | IMPRINTER
