/**
 * # Reagent Injector Component
 *
 * Injects reagents into the user.
 * Requires a BCI shell.
 */

/obj/item/circuit_component/reagent_injector
	display_name = "Reagent Injector"
	desc = "A component that can inject reagents from a BCI's reagent storage."
	category = "BCI"

	required_shells = list(/obj/item/organ/internal/cyberimp/bci)

	var/datum/port/input/inject
	var/datum/port/output/injected

	var/obj/item/organ/internal/cyberimp/bci/bci

/obj/item/circuit_component/reagent_injector/populate_ports()
	. = ..()
	//Inputs
	inject = add_input_port("Inject", PORT_TYPE_SIGNAL)
	//Outputs
	injected = add_output_port("Injected", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/reagent_injector/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/organ/internal/cyberimp/bci))
		bci = shell

/obj/item/circuit_component/reagent_injector/unregister_shell(atom/movable/shell)
	. = ..()
	bci = null

/obj/item/circuit_component/reagent_injector/input_received(datum/port/input/port)
	if(!bci.owner)
		return
	if(bci.owner.reagents.total_volume + bci.reagents.total_volume > bci.owner.reagents.maximum_volume)
		return
	var/units = bci.reagents.trans_to(bci.owner.reagents, bci.reagents.total_volume, methods = INJECT)
	if(units)
		injected.set_output(COMPONENT_SIGNAL)
