///Items with these will have a chance to get knocked off when disarming or being knocked down
/datum/component/knockoff
	///Chance to knockoff
	var/knockoff_chance = 100
	///Aiming for these zones will cause the knockoff, null means all zones allowed
	var/list/target_zones
	///Can be only knocked off from these slots, null means all slots allowed
	var/list/slots_knockoffable

/datum/component/knockoff/Initialize(knockoff_chance,zone_override,slots_knockoffable)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED,.proc/OnEquipped)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED,.proc/OnDropped)

	src.knockoff_chance = knockoff_chance

	if(zone_override)
		target_zones = zone_override

	if(slots_knockoffable)
		src.slots_knockoffable = slots_knockoffable

///Tries to knockoff the item when disarmed
/datum/component/knockoff/proc/Knockoff(mob/living/carbon/human/wearer,mob/living/attacker,zone)
	SIGNAL_HANDLER

	var/obj/item/item = parent
	if(!istype(wearer))
		return
	if(target_zones && !(zone in target_zones))
		return
	if(!prob(knockoff_chance))
		return
	if(!wearer.dropItemToGround(item))
		return
	wearer.visible_message(span_warning("[attacker] knocks off [wearer]'s [item.name]!"),span_userdanger("[attacker] knocks off your [item.name]!"))

///Tries to knockoff the item when user is knocked down
/datum/component/knockoff/proc/Knockoff_knockdown(mob/living/carbon/human/wearer,amount)
	SIGNAL_HANDLER

	if(amount <= 0)
		return

	var/obj/item/item = parent
	if(!istype(wearer))
		return
	if(!prob(knockoff_chance))
		return
	if(!wearer.dropItemToGround(item))
		return
	wearer.visible_message(span_warning("[wearer]'s [item.name] get[item.p_s()] knocked off!"),span_userdanger("Your [item.name] [item.p_were()] knocked off!"))


/datum/component/knockoff/proc/OnEquipped(datum/source, mob/living/carbon/human/H,slot)
	SIGNAL_HANDLER
	if(!istype(H))
		return
	if(slots_knockoffable && !(slot in slots_knockoffable))
		UnregisterSignal(H, COMSIG_HUMAN_DISARM_HIT)
		UnregisterSignal(H, COMSIG_LIVING_STATUS_KNOCKDOWN)
		return
	RegisterSignal(H, COMSIG_HUMAN_DISARM_HIT, .proc/Knockoff, TRUE)
	RegisterSignal(H, COMSIG_LIVING_STATUS_KNOCKDOWN, .proc/Knockoff_knockdown, TRUE)

/datum/component/knockoff/proc/OnDropped(datum/source, mob/living/M)
	SIGNAL_HANDLER

	UnregisterSignal(M, COMSIG_HUMAN_DISARM_HIT)
	UnregisterSignal(M, COMSIG_LIVING_STATUS_KNOCKDOWN)
