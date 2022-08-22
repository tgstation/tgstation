/obj/machinery/rnd/production/techfab
	name = "technology fabricator"
	desc = "Produces researched prototypes with raw materials and energy."
	icon_state = "protolathe"
	circuit = /obj/item/circuitboard/machine/techfab
	categories = list(
								RND_CATEGORY_POWER_DESIGNS,
								RND_CATEGORY_MEDICAL_DESIGNS,
								RND_CATEGORY_BLUESPACE_DESIGNS,
								RND_CATEGORY_STOCK_PARTS,
								RND_CATEGORY_EQUIPMENT,
								RND_CATEGORY_TOOL_DESIGNS,
								RND_CATEGORY_MINING_DESIGNS,
								RND_CATEGORY_ELECTRONICS,
								RND_CATEGORY_WEAPONS,
								RND_CATEGORY_AMMO,
								RND_CATEGORY_FIRING_PINS,
								RND_CATEGORY_COMPUTER_PARTS,
								RND_CATEGORY_AI_MODULES,
								RND_CATEGORY_COMPUTER_BOARDS,
								RND_CATEGORY_TELEPORTATION_MACHINERY,
								RND_CATEGORY_MEDICAL_MACHINERY,
								RND_CATEGORY_ENGINEERING_MACHINERY,
								RND_CATEGORY_EXOSUIT_MODULES,
								RND_CATEGORY_HYDROPONICS_MACHINERY,
								RND_CATEGORY_SUBSPACE_TELECOMMS,
								RND_CATEGORY_RESEARCH_MACHINERY,
								RND_CATEGORY_MISC_MACHINERY,
								RND_CATEGORY_COMPUTER_PARTS,
								RND_CATEGORY_CIRCUITRY
								)
	console_link = FALSE
	production_animation = "protolathe_n"
	allowed_buildtypes = PROTOLATHE | IMPRINTER
