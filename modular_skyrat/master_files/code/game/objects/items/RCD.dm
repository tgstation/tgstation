/obj/item/construction/rcd/mattermanipulator
	name = "Matter Manipulator"
	desc = "A strange, familiar yet distinctly different analogue to the Nanotrasen Standard RCD. Works at range, and can deconstruct reinforced walls. Reload using Metal, Glass, or Plasteel."
	icon = 'modular_skyrat/master_files/icons/obj/tools.dmi'
	ranged = TRUE
	canRturf = TRUE
	max_matter = 500
	matter = 500
	canRturf = TRUE
	upgrade = RCD_UPGRADE_FRAMES | RCD_UPGRADE_SIMPLE_CIRCUITS | RCD_UPGRADE_FURNISHING

/obj/item/construction/plumbing/mining
	name = "mining plumbing constructor"
	desc = "A type of plumbing constructor designed to harvest from geysers and collect their fluids."
	icon = 'modular_skyrat/modules/liquids/icons/obj/tools.dmi'
	icon_state = "plumberer_mining"
	has_ammobar = TRUE

/obj/item/construction/plumbing/mining/set_plumbing_designs()
	plumbing_design_types = list(
	/obj/machinery/plumbing/input = 5,
	/obj/machinery/plumbing/output = 5,
	/obj/machinery/plumbing/tank = 20,
	/obj/machinery/plumbing/buffer = 10,
	/obj/machinery/plumbing/layer_manifold = 5,
	//Above are the most common machinery which is shown on the first cycle. Keep new additions below THIS line, unless they're probably gonna be needed alot
	/obj/machinery/plumbing/acclimator = 10,
	/obj/machinery/plumbing/bottler = 50,
	/obj/machinery/plumbing/disposer = 10,
	/obj/machinery/plumbing/filter = 5,
	/obj/machinery/plumbing/grinder_chemical = 30,
	/obj/machinery/plumbing/liquid_pump = 35,
	/obj/machinery/plumbing/splitter = 5,
	/obj/machinery/plumbing/sender = 20
)
