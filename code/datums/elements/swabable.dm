/*!

This element is used in vat growing to allow for swabable behavior. This swabbing usually results in receiving a biological sample in this case.

*/
/datum/element/swabable

/datum/element/swabable/Attach(datum/target, list/swab_results)
	if(!isatom(target) || isarea(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ITEM_PRE_ATTACK, .proc/UseOnObj)

	src.swab_results = swab_results

///Ran when the parent is swabbed by an object that can swab that type of obj. The list is sent by ref, which means it's updated on the list it came from
/datum/element/swabable/proc/GetSwabbed(datum/source, list/mutable_results)
	 . = COMPONENT_SWAB_FOUND //Return this so the swabbing component knows hes a good boy and found something that needs swabbing.

	mutable_results += new
	swab_results = null //Results have been "taken".
