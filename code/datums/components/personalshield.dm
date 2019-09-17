/datum/component/personalshield
	var/current_charges = 3
	var/max_charges = 3 //How many charges total the shielding has
	///How long after we've been shot before we can start recharging.
	var/recharge_delay = 20 SECONDS
	///How often recharge_rate charges are added when recharging
	var/recharge_speed = 2 SECONDS
	//var/recharge_cooldown = 0 //Time since we've last been shot
	var/recharge_rate = 1 //How quickly the shield recharges once it starts charging
	/// for clothing this requires it to be equiped, for non-clothing it must be in-hand
	var/must_be_worn_or_held = FALSE
	/// timerid of recharging
	var/recharge_timer
	var/mob/living/carbon/wearer

/datum/component/personalshield/Initialize(max_charges = 3, recharge_delay = 20 SECONDS, recharge_speed = 2 SECONDS, recharge_rate = 1, must_be_worn_or_held = FALSE)
	src.max_charges = max_charges
	src.recharge_delay = recharge_delay
	src.recharge_speed = recharge_speed
	src.recharge_rate = recharge_rate
	src.must_be_worn = must_be_worn

/datum/component/personalshield/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/equipped)
	RegisterSignal(parent, COMSIG_ITEM_AFTER_PICKUP, .proc/pickup)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/dropped)

/datum/component/personalshield/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED, 
		COMSIG_ITEM_AFTER_PICKUP, 
		COMSIG_ITEM_DROPPED))

/datum/component/personalshield/proc/update_overlay(mob/user, state = "shield-old")
	if(!iscarbon(user))
		return

	wearer = user
	wearer.remove_overlay(SHIELD_LAYER)
	switch(state)
		if("shield-old", "broken")
			wearer.overlays_standing[SHIELD_LAYER] = list(mutable_appearance('icons/effects/effects.dmi', state, MOB_LAYER + 0.01))
			wearer.apply_overlay(SHIELD_LAYER)

/datum/component/personalshield/proc/recharge()
	current_charges = CLAMP((current_charges + recharge_rate), 0, max_charges)
	if(wearer)
		update_overlay(wearer)
	if(current_charges == max_charges)
		playsound(parent, 'sound/machines/ding.ogg', 50, TRUE)
		return
	playsound(parent, 'sound/magic/charge.ogg', 50, TRUE)
	recharge_timer = addtimer(CALLBACK(src, .proc/recharge), recharge_speed, TIMER_STOPPABLE)

/datum/component/personalshield/proc/start_recharge()
	if(recharge_timer)
		deltimer(recharge_timer)
	recharge_timer = addtimer(CALLBACK(src, .proc/recharge), recharge_delay, TIMER_STOPPABLE)

/datum/component/personalshield/proc/shield_activate(mob/user)
	RegisterSignal(parent, COMSIG_ITEM_HIT_REACT, .proc/hit_reaction)
	if(current_charges)
		update_overlay(user, "shield_old")
	else
		update_overlay(user, "broken")

/datum/component/personalshield/proc/shield_deactivate(mob/user)
	UnregisterSignal(parent, COMSIG_ITEM_HIT_REACT)
	update_overlay(user, "off")

/datum/component/personalshield/proc/equipped(datum/source, mob/user, slot)
	if((must_be_worn_or_held && !isclothing(parent)) || isclothing(parent))
		shield_deactivate(user)
		return
	shield_activate(user)

/datum/component/personalshield/proc/pickup(datum/source, mob/user)
	if(must_be_worn_or_held && isclothing(parent))
		shield_deactivate(user)
		return
	shield_activate(user)

/datum/component/personalshield/proc/dropped(datum/source, mob/user)
	shield_deactivate(user)
	wearer = null

/datum/component/personalshield/proc/hit_reaction(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance, damage, attack_type)
	recharge_cooldown = world.time + recharge_delay
	if(current_charges <= 0)
		return FALSE
	var/datum/effect_system/spark_spread/s = new
	s.set_up(2, 1, parent)
	s.start()
	owner.visible_message("<span class='danger'>[owner]'s shields deflect [attack_text] in a shower of sparks!</span>")
	current_charges--
	if(recharge_rate)
		start_recharge()
	if(current_charges <= 0)
		owner.visible_message("<span class='warning'>[owner]'s shield overloads!</span>")
		update_overlay(user, "broken")
	return COMPONENT_HIT_STOPPED
