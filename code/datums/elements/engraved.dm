/**
 * # engraved element!
 *
 * bespoke element for walls that applies an engraved overlay and lets you examine it to read a story (+ art element yay)
 */
/datum/element/engraved
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	///the generated story string
	var/engraved_description

/datum/element/engraved/Attach(datum/target, engraved_description)
	. = ..()
	if(!isclosedturf(target))
		return ELEMENT_INCOMPATIBLE

	src.engraved_description = engraved_description
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	target.AddElement(/datum/element/art, rand(10, 30))
	//ADD ENGRAVED OVERLAY HERE

///signal called on parent being examined
/datum/component/engraved/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_boldnotice("[engraved_description]")

/datum/element/engraved/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_PARENT_EXAMINE)
	target.RemoveElement(/datum/element/art)
	//...AND REMOVE ENGRAVED OVERLAY HERE
