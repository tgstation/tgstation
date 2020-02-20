/*!

This component is used in vat growing to allow for swabable behavior. This swabbing usually results in receiving a biological sample in this case.

*/
/datum/component/swabable
	///The current sample on the swab.
	var/datum/biological_sample/our_sample


/datum/component/swabable/Initialize(/datum/biological_sample/our_sample)
	if(!isatom(parent) || isarea(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, .proc/UseOnObj)

	src.our_sample = our_sample

///Ran when the parent is swabbed by an object that can swab that type of obj.
/datum/component/swabbing/proc/GetSwabbed(datum/source, mob/user)
	 . = COMPONENT_SWAB_FOUND //Return this so the swabbing component knows hes a good boy and found something that needs swabbing.


	var/datum/component/swabbing/swabber = source //We know for a fact this is a swabber. If it's not we have an omega *redacted* touching the code.

	if(!swabber.our_sample)
		swabber.our_sample = our_sample
		to_chat(user, "<span class='nicegreen'>You manage to collect a microbiological sample from [target]!</span>")
		our_sample = null //Sample is collected
		qdel(src)
		return

	if(swabber.our_sample.Merge())
		to_chat(user, "<span class='warning'>You manage to collect a microbiological sample from [target]...But there was already one there!</span>")
	else
		to_chat(user, "<span class='warning'>You cannot collect another sample on the swabber!</span>")



