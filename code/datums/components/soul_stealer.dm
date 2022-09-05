/**
 * ### Soul Stealer component!
 *
 * Component that attaches to items, making lethal swings with them steal the victims soul, storing it inside the item.
 * Used in the cult bastard sword!
 */
/datum/component/soul_stealer
	var/list/souls = list()

/datum/component/soul_stealer/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/soul_stealer/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/on_afterattack)

/datum/component/soul_stealer/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_AFTERATTACK))

///signal called on parent being examined
/datum/component/soul_stealer/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("[parent] will steal the soul of anyone it defeats in battle.")

	switch(souls.len)
		if(0)
			examine_list += span_notice("[parent] has not consumed any souls yet.")
		if(1 to 9)
			examine_list += span_notice("There are <b>[souls.len]</b> souls trapped within [parent].")
		if(10 to INFINITY)
			examine_list += span_notice("A staggering <b>[souls.len]</b> souls have been claimed by [parent]! It hungers for more!")

/datum/component/soul_stealer/proc/on_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return

	if(ishuman(target))
		var/mob/living/carbon/human/victim = target
		if(victim.stat != CONSCIOUS)
			var/obj/item/soulstone/soulstone = new /obj/item/soulstone(parent)
			soulstone.attack(victim, user)
			if(!LAZYLEN(soulstone.contents))
				qdel(soulstone)
				return
			souls += soulstone
	if(istype(target, /obj/structure/constructshell) && souls.len)
		var/obj/item/soulstone/soulstone = souls[1]
		INVOKE_ASYNC(soulstone, /obj/item/soulstone/proc/transfer_to_construct, target, user)
		///soulstone will be deleted from souls if successful
