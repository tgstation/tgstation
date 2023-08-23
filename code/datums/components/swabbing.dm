/*!

This component is used in vat growing to swab for microbiological samples which can then be mixed with reagents in a petridish to create a culture plate.

*/
/datum/component/swabbing
	///The current datums on the swab
	var/list/swabbed_items
	///Can we swab objs?
	var/can_swab_objs
	///Can we swab turfs?
	var/can_swab_turfs
	///Can we swab mobs?
	var/can_swab_mobs
	///Callback for update_icon()
	var/datum/callback/update_icons
	///Callback for update_overlays()
	var/datum/callback/update_overlays

/datum/component/swabbing/Initialize(can_swab_objs = TRUE, can_swab_turfs = TRUE, can_swab_mobs = FALSE, datum/callback/update_icons, datum/callback/update_overlays, swab_time = 1 SECONDS, max_items = 3)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(try_to_swab))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(handle_overlays))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON, PROC_REF(handle_icon))

	src.can_swab_objs = can_swab_objs
	src.can_swab_turfs = can_swab_turfs
	src.can_swab_mobs = can_swab_mobs
	src.update_icons = update_icons
	src.update_overlays = update_overlays

/datum/component/swabbing/Destroy()
	. = ..()
	for(var/swabbed in swabbed_items)
		qdel(swabbed)
	update_icons = null
	update_overlays = null


///Changes examine based on your sample
/datum/component/swabbing/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(LAZYLEN(swabbed_items))
		examine_list += span_nicegreen("There is a microbiological sample on [parent]!")
		examine_list += "[span_notice("You can see the following micro-organisms:")]\n"
		for(var/i in swabbed_items)
			var/datum/biological_sample/samp = i
			for(var/organism in samp.micro_organisms)
				var/datum/micro_organism/MO = organism
				examine_list += MO.get_details()

///Ran when you attack an object, tries to get a swab of the object. if a swabbable surface is found it will run behavior and hopefully
/datum/component/swabbing/proc/try_to_swab(datum/source, atom/target, mob/user, params)
	SIGNAL_HANDLER

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
		I.update_appearance()

		return COMPONENT_CANCEL_ATTACK_CHAIN
	if(!can_swab(target))
		return NONE //Just do the normal attack.


	. = COMPONENT_CANCEL_ATTACK_CHAIN //Point of no return. No more attacking after this.

	if(LAZYLEN(swabbed_items))
		to_chat(user, span_warning("You cannot collect another sample on [parent]!"))
		return

	to_chat(user, span_notice("You start swabbing [target] for samples!"))
	INVOKE_ASYNC(src, PROC_REF(async_try_to_swab), target, user)

/datum/component/swabbing/proc/async_try_to_swab(atom/target, mob/user)
	if(!do_after(user, 3 SECONDS, target)) // Start swabbing boi
		return

	LAZYINITLIST(swabbed_items) //If it isn't initialized, initialize it. As we need to pass it by reference

	if(SEND_SIGNAL(target, COMSIG_SWAB_FOR_SAMPLES, swabbed_items) == NONE) //If we found something to swab now we let the swabbed thing handle what it would do, we just sit back and relax now.
		to_chat(user, span_warning("You do not manage to find a anything on [target]!"))
		return

	to_chat(user, span_nicegreen("You manage to collect a microbiological sample from [target]!"))

	var/obj/item/parent_item = parent
	parent_item.update_appearance()

///Checks if the swabbing component can swab the specific object or nots
/datum/component/swabbing/proc/can_swab(atom/target)
	if(isobj(target))
		return can_swab_objs
	if(isturf(target))
		return can_swab_turfs
	if(ismob(target))
		return can_swab_mobs

///Handle any special overlay cases on the item itself
/datum/component/swabbing/proc/handle_overlays(datum/source, list/overlays)
	SIGNAL_HANDLER
	update_overlays?.Invoke(overlays, swabbed_items)

///Handle any special icon cases on the item itself
/datum/component/swabbing/proc/handle_icon(datum/source)
	SIGNAL_HANDLER
	update_icons?.Invoke(swabbed_items)
