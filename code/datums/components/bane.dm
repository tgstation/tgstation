/datum/component/bane
	dupe_mode = COMPONENT_DUPE_ALLOWED

	var/mobtype
	var/damage_multiplier

/datum/component/bane/Initialize(mobtype, damage_multiplier=1)
	if(!isitem(parent) || !ispath(mobtype, /mob/living))
		return COMPONENT_INCOMPATIBLE

	src.mobtype = mobtype
	src.damage_multiplier = damage_multiplier

/datum/component/bane/RegisterWithParent()
	var/obj/item/master = parent
	RegisterSignal(master, COMSIG_ITEM_AFTERATTACK, .proc/afterattack_react)

/datum/component/bane/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_ITEM_AFTERATTACK)

/datum/component/bane/proc/afterattack_react(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	if(!istype(target, mobtype))
		return
	var/mob/living/target_mob = target
	
	if(user.a_intent != INTENT_HARM)
		return

	var/extra_damage = max(0, source.force * damage_multiplier)
	target_mob.apply_damage(extra_damage, source.damtype, user.zone_selected)
