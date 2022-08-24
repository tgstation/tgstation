/obj/machinery/nuclearbomb/syndicate/bananium
	name = "bananium fission explosive"
	desc = "You probably shouldn't stick around to see if this is armed."
	icon_state = "bananiumbomb_base"
	base_icon_state = "bananiumbomb"

/obj/machinery/nuclearbomb/syndicate/bananium/update_icon_state()
	. = ..()
	if(deconstruction_state != NUKESTATE_INTACT)
		icon_state = "[base_icon_state]_base"
		return

	switch(get_nuke_state())
		if(NUKE_OFF_LOCKED, NUKE_OFF_UNLOCKED)
			icon_state = "[base_icon_state]_base"
		if(NUKE_ON_TIMING)
			icon_state = "[base_icon_state]_timing"
		if(NUKE_ON_EXPLODING)
			icon_state = "[base_icon_state]_exploding"

/obj/machinery/nuclearbomb/syndicate/bananium/get_cinematic_type(detonation_status)
	switch(detonation_status)
		if(DETONATION_HIT_STATION)
			return /datum/cinematic/nuke/clown
		if(DETONATION_NEAR_MISSED_STATION)
			return /datum/cinematic/nuke/ops_miss
		if(DETONATION_HIT_SYNDIE_BASE, DETONATION_MISSED_STATION)
			return /datum/cinematic/nuke/fake //it is farther away, so just a bikehorn instead of an airhorn

	stack_trace("[type] - get_cinematic_type got a detonation_status it was not expecting. (Got: [detonation_status])")
	return /datum/cinematic/nuke/fake

/obj/machinery/nuclearbomb/syndicate/bananium/nuke_effects(list/affected_z_levels)
	INVOKE_ASYNC(GLOBAL_PROC, /proc/callback_on_everyone_on_z, affected_z_levels, CALLBACK(GLOBAL_PROC, /proc/make_into_clown), src)

/**
 * Helper proc that handles making someone into a clown after a bananium nuke goes off.
 */
/proc/make_into_clown(mob/living/carbon/human/clowned_on)
	if(!istype(clowned_on))
		return

	clowned_on.Stun(1 SECONDS)
	if(!clowned_on.w_uniform || clowned_on.dropItemToGround(clowned_on.w_uniform))
		var/obj/item/clothing/clown_shirt = new /obj/item/clothing/under/rank/civilian/clown(clowned_on)
		ADD_TRAIT(clown_shirt, TRAIT_NODROP, CLOWN_NUKE_TRAIT)
		clowned_on.equip_to_slot_or_del(clown_shirt, ITEM_SLOT_ICLOTHING)

	if(!clowned_on.shoes || clowned_on.dropItemToGround(clowned_on.shoes))
		var/obj/item/clothing/clown_shoes = new /obj/item/clothing/shoes/clown_shoes(clowned_on)
		ADD_TRAIT(clown_shoes, TRAIT_NODROP, CLOWN_NUKE_TRAIT)
		clowned_on.equip_to_slot_or_del(clown_shoes, ITEM_SLOT_FEET)

	if(!clowned_on.wear_mask || clowned_on.dropItemToGround(clowned_on.wear_mask))
		var/obj/item/clothing/clown_mask = new /obj/item/clothing/mask/gas/clown_hat(clowned_on)
		ADD_TRAIT(clown_mask, TRAIT_NODROP, CLOWN_NUKE_TRAIT)
		clowned_on.equip_to_slot_or_del(clown_mask, ITEM_SLOT_MASK)

	clowned_on.dna.add_mutation(/datum/mutation/human/clumsy)
	clowned_on.gain_trauma(/datum/brain_trauma/mild/phobia/clowns, TRAUMA_RESILIENCE_LOBOTOMY) //MWA HA HA
