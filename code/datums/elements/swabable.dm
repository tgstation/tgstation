/*!

This element is used in vat growing to allow for swabable behavior. This swabbing usually results in receiving a biological sample in this case.

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
	///Amount of viruses on a single sample
	var/virus_chance

/datum/element/swabable/Attach(datum/target, cell_line_list_define, virus_define, cell_line_amount = 3, virus_chance = 50)
	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_SWAB_FOR_SAMPLES, .proc/GetSwabbed)

	src.cell_line_define = cell_line_define
	src.virus_define = virus_define
	src.cell_line_amount = cell_line_amount
	src.virus_chance = virus_chance

///Ran when the parent is swabbed by an object that can swab that type of obj. The list is sent by ref, which means it's updated on the list it came from
/datum/element/swabable/proc/GetSwabbed(datum/source, list/mutable_results)
	. = COMPONENT_SWAB_FOUND //Return this so the swabbing component knows hes a good boy and found something that needs swabbing.

	mutable_results += GenerateSample()

///Generates a /datum/biological_sample
/datum/element/swabable/proc/GenerateSample()
	var/datum/biological_sample/generated_sample = new
	generated_sample.GenerateSample(cell_line_define, virus_define, cell_line_amount, virus_chance)
	return generated_sample
