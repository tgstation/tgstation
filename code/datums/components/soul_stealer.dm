/**
 * ### Soul Stealer component!
 *
 * Component that attaches to items, making lethal swings with them steal the victims soul, storing it inside the item.
 * Used in the cult bastard sword!
 */
/datum/component/soul_stealer
	/// weakref list of soulstones captured by this item.
	var/list/weak_souls = list()

/datum/component/soul_stealer/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/soul_stealer/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))

/datum/component/soul_stealer/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_AFTERATTACK))

///signal called on parent being examined
/datum/component/soul_stealer/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("It will steal the soul of anyone it defeats in battle.")

	//clears out any weakrefs that do not exist anymore
	var/list/souls = recursive_list_resolve(weak_souls)

	switch(souls.len)
		if(0)
			examine_list += span_notice("It has not consumed any souls yet.")
		if(1 to 9)
			examine_list += span_notice("There are <b>[souls.len]</b> souls trapped within it.")
		if(10 to INFINITY)
			examine_list += span_notice("A staggering <b>[souls.len]</b> souls have been claimed by it! And it hungers for more!")

/datum/component/soul_stealer/proc/on_afterattack(obj/item/source, atom/target, mob/living/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return

	if(ishuman(target))
		INVOKE_ASYNC(src, PROC_REF(try_capture), target, user)

	var/list/souls = recursive_list_resolve(weak_souls)

	if(istype(target, /obj/structure/constructshell) && souls.len)
		var/obj/item/soulstone/soulstone = souls[1]
		INVOKE_ASYNC(soulstone, TYPE_PROC_REF(/obj/item/soulstone, transfer_to_construct), target, user)
		///soulstone will be deleted from souls if successful

/datum/component/soul_stealer/proc/try_capture(mob/living/carbon/human/victim, mob/living/captor)
	if(victim.stat == CONSCIOUS)
		return
	var/obj/item/soulstone/soulstone = new /obj/item/soulstone(parent)
	soulstone.attack(victim, captor)
	if(!LAZYLEN(soulstone.contents))
		qdel(soulstone)
		return
	weak_souls += WEAKREF(soulstone)
