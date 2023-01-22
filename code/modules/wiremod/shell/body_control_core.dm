
/obj/item/organ/internal/cyberimp/brain/bcc
	name = "Body control core"
	desc = "A small, self-contained computer that interfaces with the nervous system, allowing for direct control of the body's functions"
	icon_state = "bcc"
	status = ORGAN_ROBOTIC
	organ_flags = ORGAN_SYNTHETIC
	modules = list()
	stress = 0



/obj/item/organ/internal/cyberimp/bcc/Initialize()




/obj/item/organ/internal/cyberimp/bcc/on_life(delta_time, times_fired)
	for( module in modules)
		module.trigger(delta_time, times_fired, mob)
		if(stress > 0)
			module.stress(delta_time, mob, stress)


/obj/item/organ/internal/cyberimp/bcc/proc/add_module(module)

	if(module in modules)
		return FALSE
	modules += module
	return TRUE

/obj/item/organ/internal/cyberimp/bcc/proc/remove_module(module)

	if(module in modules)
		modules -= module
		return TRUE
	return FALSE

/obj/item/bcc_module
	name = "BCC module"
	desc = "A module for the BCC"



