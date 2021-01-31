/*!

This element is used in vat growing to allow for the object to be

*/
/datum/element/swabable
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///The define of the cell_line list to use
	var/cell_line_define
	///The define of the cell_virus list to use
	var/virus_define
	///Amount of cell lines on a single sample
	var/cell_line_amount
	///The chance the sample will be infected with a virus.
	var/virus_chance

///Listens for the swab signal and then generate a sample based on pre-determined lists that are saved as GLOBs. this allows us to have very few swabbable element instances.
/datum/element/swabable/Attach(datum/target, cell_line_define, virus_define, cell_line_amount = 1, virus_chance = 10)
	. = ..()
	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_SWAB_FOR_SAMPLES, .proc/GetSwabbed)

	src.cell_line_define = cell_line_define
	src.virus_define = virus_define
	src.cell_line_amount = cell_line_amount
	src.virus_chance = virus_chance

///Stops listening to the swab signal; you can no longer be swabbed.
/datum/element/swabable/Detach(datum/source, force)
	. = ..()
	if(!isatom(source) || isarea(source))
		return ELEMENT_INCOMPATIBLE
	UnregisterSignal(source, COMSIG_SWAB_FOR_SAMPLES)

///Ran when the parent is swabbed by an object that can swab that type of obj. The list is sent by ref, which means the thing which sent the signal will still have the updated list.
/datum/element/swabable/proc/GetSwabbed(datum/source, list/mutable_results)
	SIGNAL_HANDLER
	. = COMPONENT_SWAB_FOUND //Return this so the swabbing component knows hes a good boy and found something that needs swabbing.

	LAZYADD(mutable_results, GenerateSample())
	Detach(source)

///Generates a /datum/biological_sample
/datum/element/swabable/proc/GenerateSample()
	var/datum/biological_sample/generated_sample = new
	generated_sample.GenerateSample(cell_line_define, virus_define, cell_line_amount, virus_chance)
	return generated_sample
