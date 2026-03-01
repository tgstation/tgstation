/**
 * # Reagent Injector Component
 *
 * Injects reagents into the user.
 * Requires a shell that can be inserted into a mob that reagents can be injected into.
 */

/obj/item/circuit_component/reagent_injector
	display_name = "Reagent Injector"
	desc = "A component that can inject reagents from the circuit's reagent storage."
	category = "Entity"
	circuit_flags = CIRCUIT_NO_DUPLICATES

	required_shells = list(/obj/item/organ/cyberimp/bci, /obj/item/implant)

	var/datum/port/input/inject
	var/datum/port/output/injected

	var/obj/item/shell_item

/obj/item/circuit_component/reagent_injector/Initialize(mapload)
	. = ..()
	create_reagents(15, OPENCONTAINER) //This is mostly used in the case of the shell still having reagents in it when the component is removed.

/obj/item/circuit_component/reagent_injector/populate_ports()
	. = ..()
	inject = add_input_port("Inject", PORT_TYPE_SIGNAL, trigger = PROC_REF(trigger_inject))
	injected = add_output_port("Injected", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/reagent_injector/proc/get_mob()
	if(istype(shell_item, /obj/item/organ/cyberimp/bci))
		var/obj/item/organ/cyberimp/bci/shell_bci = shell_item
		return shell_bci.owner
	if(istype(shell_item, /obj/item/implant))
		var/obj/item/implant/shell_implant = shell_item
		return shell_implant.imp_in

/obj/item/circuit_component/reagent_injector/proc/trigger_inject()
	CIRCUIT_TRIGGER
	var/mob/living/mob_to_inject = get_mob()
	if(!istype(mob_to_inject))
		return
	if(!mob_to_inject.reagents)
		return
	if(mob_to_inject.reagents.total_volume + shell_item.reagents.total_volume > mob_to_inject.reagents.maximum_volume)
		return
	var/contained = shell_item.reagents.get_reagent_log_string()
	var/units = shell_item.reagents.trans_to(mob_to_inject.reagents, shell_item.reagents.total_volume, methods = INJECT)
	if(units)
		injected.set_output(COMPONENT_SIGNAL)
		log_combat(mob_to_inject, mob_to_inject, "injected", shell_item, "which had [contained]")

/obj/item/circuit_component/reagent_injector/register_shell(atom/movable/shell)
	. = ..()
	if(is_type_in_list(shell, required_shells))
		shell_item = shell
		shell_item.create_reagents(15, OPENCONTAINER)
		if(reagents.total_volume)
			reagents.trans_to(shell_item, reagents.total_volume)

/obj/item/circuit_component/reagent_injector/unregister_shell(atom/movable/shell)
	. = ..()
	if(shell_item?.reagents)
		if(shell_item.reagents.total_volume)
			shell_item.reagents.trans_to(src, shell_item.reagents.total_volume)
		QDEL_NULL(shell_item.reagents)
	shell_item = null
