/datum/component/personalshield
	var/current_charges = 3
	var/max_charges = 3 //How many charges total the shielding has
	var/recharge_delay = 20 SECONDS //How long after we've been shot before we can start recharging. 20 seconds here
	var/recharge_cooldown = 0 //Time since we've last been shot
	var/recharge_rate = 1 //How quickly the shield recharges once it starts charging
	var/must_be_worn = FALSE

/datum/component/personalshield/Initialize(max_charges = 3, recharge_delay = 20 SECONDS, recharge_rate = 1, must_be_worn = FALSE)
	src.max_charges = max_charges
	src.recharge_delay = recharge_delay
	src.recharge_rate = recharge_rate
	src.must_be_worn = must_be_worn

/datum/component/personalshield/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/equipped)
	RegisterSignal(parent, COMSIG_ITEM_AFTER_PICKUP, .proc/pickup)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/dropped)

/datum/component/personalshield/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_AFTER_PICKUP, COMSIG_ITEM_DROPPED))

/datum/component/personalshield/proc/shield_activate(mob/user)

/datum/component/personalshield/proc/shield_deactivate(mob/user)

/datum/component/personalshield/proc/equipped(datum/source, mob/user, slot)


/datum/component/personalshield/proc/pickup(datum/source, mob/user)
	

/datum/component/personalshield/proc/dropped(datum/source, mob/user)

/datum/component/personalshield/proc/hit_reaction(datum/source, mob/living/carbon/human/owner, attack_text = "the attack")
	recharge_cooldown = world.time + recharge_delay
	if(current_charges <= 0)
		return FALSE
	var/datum/effect_system/spark_spread/s = new
	s.set_up(2, 1, parent)
	s.start()
	owner.visible_message("<span class='danger'>[owner]'s shields deflect [attack_text] in a shower of sparks!</span>")
	current_charges--
	if(recharge_rate)
		START_PROCESSING(SSobj, src)
	if(current_charges <= 0)
		owner.visible_message("<span class='warning'>[owner]'s shield overloads!</span>")
		update_overlay()
	return 1

/datum/component/personalshield/proc/update_overlay()

	mutable_appearance('icons/effects/effects.dmi', shield_state, MOB_LAYER + 0.01)
