/datum/component/ckey_and_role_locked_pickup
	var/pickup_damage
	var/list/ckeys = list()
	var/offstation_role
	var/refusal_text
	var/binded

/datum/component/ckey_and_role_locked_pickup/Initialize(offstation_role = TRUE, ckey_whitelist, pickup_damage = 0, refusal_text, binded = FALSE)
	src.offstation_role = offstation_role
	src.ckeys = ckey_whitelist
	src.pickup_damage = pickup_damage
	src.refusal_text = refusal_text
	src.binded = binded

/datum/component/ckey_and_role_locked_pickup/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))

/datum/component/ckey_and_role_locked_pickup/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_EQUIPPED)

/datum/component/ckey_and_role_locked_pickup/proc/on_equip(obj/item/I, mob/living/user)
	SIGNAL_HANDLER
	if(check_role_and_ckey(user) || !binded)
		binded = TRUE
		return
	user.Knockdown(10 SECONDS)
	user.dropItemToGround(I, force = TRUE)
	to_chat(user, span_userdanger(refusal_text))
	if(ishuman(user))
		user.apply_damage(rand(pickup_damage, pickup_damage * 2), BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))

/datum/component/ckey_and_role_locked_pickup/proc/check_role_and_ckey(mob/user)
	if(user.client.ckey in ckeys)
		return TRUE
	return user.mind.centcom_role == CENTCOM_ROLE_OFFICER
