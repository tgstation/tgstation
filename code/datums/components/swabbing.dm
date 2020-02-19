/*!

This component is used in vat growing to swab for microbiological samples which can then be mixed with reagents in a petridish to create a culture plate.

*/
/datum/component/swabbing
	///The current sample on the swab.
	var/datum/biological_sample/our_sample


/datum/component/swabbing/Initialize(CanSwabObj = TRUE, CanSwabTurf = TRUE, CanSwabMob = FALSE, swab_time = 10)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, .proc/TryToSwab)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)

///Changes examine based on your sample
/datum/component/swabbing/proc/examine(datum/source, mob/user, list/examine_list)
	if(our_sample)
		examine_list += "<span class='nicegreen'>There is a microbiological sample on [parent]!</span>"
	if(user.research_scanner) //For some reason a mob var
		examine += "<span class='notice'>You can see the following micro-organism:</span>"
		examine_list += our_sample.GetAllDetails() //Get just the names nicely parsed.

///Ran when you attack an object, tries to get a swab of the object. if a swabbable surface is found it will run behavior and hopefully
/datum/component/swabbing/proc/TryToSwab(datum/source, atom/target, mob/user, params)
	set waitfor FALSE //This prevents do_after() from making this proc not return it's value.
	if(!can_swab(target))
		return NONE //Just do the normal attack.

	. = COMPONENT_NO_ATTACK //Point of no return. No more attacking after this.

	to_chat(user, "<span class='notice'>You start swabbing the surface of [target] for samples!</span>")
	if(!do_after(user, eat_time, TRUE, target)) // Start swabbing boi
		return

	if(SEND_SIGNAL(src, COMSIG_SWAB_FOR_SAMPLES, src, user)) //If we found something to swab now we let the swabbed thing handle what it would do, we just sit back and relax now.
		return

	to_chat(user, "<span class='warning'>You do not manage to find a anything on [target]!</span>")

///Checks if the swabbing component can swab the specific object or not
/datum/component/swabbing/proc/can_swab(atom/target)
	if(isobj(target))
		return CanSwabobj
	if(isturf(target))
		return CanSwabTurf
	if(ismob(target))
		return CanSwabMob


