/*!

This component is used in vat growing to swab for microbiological samples which can then be mixed with reagents in a petridish to create a culture plate.

*/
/datum/component/swabbing
	///The current datums on the swab
	var/list/swabbed_items
	///Can we swab objs?
	var/CanSwabObj
	///Can we swab turfs?
	var/CanSwabTurf
	///Can we swab mobs?
	var/CanSwabMob
	///Callback for update_icon()
	var/datum/callback/UpdateIcons
	///Callback for update_overlays()
	var/datum/callback/UpdateOverlays

/datum/component/swabbing/Initialize(CanSwabObj = TRUE, CanSwabTurf = TRUE, CanSwabMob = FALSE, datum/callback/UpdateIcons, datum/callback/UpdateOverlays, swab_time = 1 SECONDS, max_items = 3)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, .proc/TryToSwab)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examine)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/handle_overlays)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON, .proc/handle_icon)

	src.CanSwabObj = CanSwabObj
	src.CanSwabTurf = CanSwabTurf
	src.CanSwabMob = CanSwabMob
	src.UpdateIcons = UpdateIcons
	src.UpdateOverlays = UpdateOverlays

/datum/component/swabbing/Destroy()
	. = ..()
	for(var/swabbed in swabbed_items)
		qdel(swabbed)


///Changes examine based on your sample
/datum/component/swabbing/proc/examine(datum/source, mob/user, list/examine_list)
	if(LAZYLEN(swabbed_items))
		examine_list += "<span class='nicegreen'>There is a microbiological sample on [parent]!</span>"
		examine_list += "<span class='notice'>You can see the following micro-organisms:</span>\n"
		for(var/i in swabbed_items)
			var/datum/biological_sample/samp = i
			examine_list += samp.GetAllDetails(user.research_scanner) //Get just the names nicely parsed.

///Ran when you attack an object, tries to get a swab of the object. if a swabbable surface is found it will run behavior and hopefully
/datum/component/swabbing/proc/TryToSwab(datum/source, atom/target, mob/user, params)
	set waitfor = FALSE //This prevents do_after() from making this proc not return it's value.

	if(istype(target, /obj/structure/table))//help how do i do this less shitty
		return NONE //idk bro pls send help

	if(istype(target, /obj/item/petri_dish))
		if(!LAZYLEN(swabbed_items))
			return NONE
		var/obj/item/petri_dish/dish = target
		if(dish.sample)
			return

		var/datum/biological_sample/deposited_sample

		for(var/i in swabbed_items) //Typed in case there is a non sample on the swabbing tool because someone was fucking with swabbable element
			if(!istype(i, /datum/biological_sample/))
				stack_trace("Non biological sample being swabbed, no bueno.")
				continue
			var/datum/biological_sample/sample = i
			//Collapse the samples into one sample; one gooey mess essentialy.
			if(!deposited_sample)
				deposited_sample = sample
			else
				deposited_sample.Merge(sample)

		dish.deposit_sample(user, deposited_sample)
		LAZYCLEARLIST(swabbed_items)

		var/obj/item/I = parent
		I.update_icon()

		return COMPONENT_NO_ATTACK
	if(!can_swab(target))
		return NONE //Just do the normal attack.


	. = COMPONENT_NO_ATTACK //Point of no return. No more attacking after this.

	if(LAZYLEN(swabbed_items))
		to_chat(user, "<span class='warning'>You cannot collect another sample on [parent]!</span>")
		return

	to_chat(user, "<span class='notice'>You start swabbing [target] for samples!</span>")
	if(!do_after(user, 3 SECONDS, TRUE, target)) // Start swabbing boi
		return

	LAZYINITLIST(swabbed_items) //If it isn't initialized, initialize it. As we need to pass it by reference

	if(SEND_SIGNAL(target, COMSIG_SWAB_FOR_SAMPLES, swabbed_items) == NONE) //If we found something to swab now we let the swabbed thing handle what it would do, we just sit back and relax now.
		to_chat(user, "<span class='warning'>You do not manage to find a anything on [target]!</span>")
		return

	to_chat(user, "<span class='nicegreen'>You manage to collect a microbiological sample from [target]!</span>")

	var/obj/item/parent_item = parent
	parent_item.update_icon()

///Checks if the swabbing component can swab the specific object or nots
/datum/component/swabbing/proc/can_swab(atom/target)
	if(isobj(target))
		return CanSwabObj
	if(isturf(target))
		return CanSwabTurf
	if(ismob(target))
		return CanSwabMob

///Handle any special overlay cases on the item itself
/datum/component/swabbing/proc/handle_overlays(datum/source, list/overlays)
	UpdateOverlays?.Invoke(overlays, swabbed_items)

///Handle any special icon cases on the item itself
/datum/component/swabbing/proc/handle_icon(datum/source)
	if(UpdateIcons)
		UpdateIcons.Invoke(swabbed_items)
