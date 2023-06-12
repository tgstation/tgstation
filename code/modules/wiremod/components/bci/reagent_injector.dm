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
	circuit_flags = CIRCUIT_NO_DUPLICATES

	required_shells = list(/obj/item/organ/internal/cyberimp/bci)

	var/datum/port/input/inject
	var/datum/port/output/injected

	var/obj/item/organ/internal/cyberimp/bci/bci

/obj/item/circuit_component/reagent_injector/Initialize(mapload)
	. = ..()
	create_reagents(15, OPENCONTAINER) //This is mostly used in the case of a BCI still having reagents in it when the component is removed.

/obj/item/circuit_component/reagent_injector/populate_ports()
	. = ..()
	inject = add_input_port("Inject", PORT_TYPE_SIGNAL, trigger = PROC_REF(trigger_inject))
	injected = add_output_port("Injected", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/reagent_injector/proc/trigger_inject()
	CIRCUIT_TRIGGER
	if(!bci.owner)
		return
	if(bci.owner.reagents.total_volume + bci.reagents.total_volume > bci.owner.reagents.maximum_volume)
		return
	var/contained = bci.reagents.get_reagent_log_string()
	var/units = bci.reagents.trans_to(bci.owner.reagents, bci.reagents.total_volume, methods = INJECT)
	if(units)
		injected.set_output(COMPONENT_SIGNAL)
		log_combat(bci.owner, bci.owner, "injected", bci, "which had [contained]")

/obj/item/circuit_component/reagent_injector/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/organ/internal/cyberimp/bci))
		bci = shell
		bci.create_reagents(15, OPENCONTAINER)
		if(reagents.total_volume)
			reagents.trans_to(bci, reagents.total_volume)

/obj/item/circuit_component/reagent_injector/unregister_shell(atom/movable/shell)
	. = ..()
	if(bci?.reagents)
		if(bci.reagents.total_volume)
			bci.reagents.trans_to(src, bci.reagents.total_volume)
		QDEL_NULL(bci.reagents)
	bci = null
