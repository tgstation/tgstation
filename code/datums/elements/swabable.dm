/*!

This element is used in vat growing to allow for swabable behavior. This swabbing usually results in receiving a biological sample in this case.

*/
/datum/element/swabable
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///Weighted list of /datum/micro_organism/cell_line || spawn weight
	var/list/cell_line_weightlist
	///Weighted list of /datum/micro_organism/virus || spawn weight
	var/list/virus_weightlist
	///Amount of cell lines on a single sample
	var/cell_line_amount
	///Amount of viruses on a single sample
	var/virus_chance

/datum/element/swabable/Attach(datum/target, list/cell_line_weightlist = list(), list/virus_weightlist = list(), var/cell_line_amount, var/virus_chance)
	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_PRE_ATTACK, .proc/UseOnObj)

	src.cell_line_weightlist = cell_line_weightlist
	src.virus_weightlist = virus_weightlist
	src.cell_line_amount = cell_line_amount
	src.virus_chance = virus_chance

///Ran when the parent is swabbed by an object that can swab that type of obj. The list is sent by ref, which means it's updated on the list it came from
/datum/element/swabable/proc/GetSwabbed(datum/source, list/mutable_results)
	. = COMPONENT_SWAB_FOUND //Return this so the swabbing component knows hes a good boy and found something that needs swabbing.

	mutable_results += new GenerateSample()
	swab_results = null //Results have been "taken".

///Generates a /datum/biological_sample
/datum/element/swabable/proc/GenerateSample()
	var/datum/biological_sample/generated_sample = new
	generated_sample.GenerateSample(micro_organism_weightlist, cell_line_amount, virus_chance)
	return generated_sample
