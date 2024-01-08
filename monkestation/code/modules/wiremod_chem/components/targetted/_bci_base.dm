/obj/item/circuit_component/chem/bci
	required_shells = list(/obj/item/organ/internal/cyberimp/bci)
	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL

	var/obj/item/organ/internal/cyberimp/bci/bci

/obj/item/circuit_component/chem/bci/register_shell(atom/movable/shell)
	if(istype(shell, /obj/item/organ/internal/cyberimp/bci))
		bci = shell

/obj/item/circuit_component/chem/bci/unregister_shell(atom/movable/shell)
	bci = null
