/datum/component/personalshield
	var/current_charges = 3
	/// How many charges total the shielding has
	var/max_charges = 3
	/// How long after we've been shot before we can start recharging.
	var/recharge_delay = 20 SECONDS
	/// How often recharge_rate charges are added when recharging
	var/recharge_speed = 2 SECONDS
	/// How many charges it gains per recharge cycle
	var/recharge_rate = 1
	/// for clothing this requires it to be equiped, for non-clothing it must be in-hand
	var/must_be_worn_or_held = FALSE
	/// timerid of recharging
	var/recharge_timer
	/// the current wearer
	var/mob/living/carbon/wearer
	/// icon state of activated shield overlay
	var/shield_on = "shield-old"
	var/shield_broken = "broken"
	/// items that can recharge this
	var/list/item_rechargable
	/// icon_states that can be toggled between
	var/list/togglable_states
	var/toggle_state = 1
	var/recharge_item_amount

/datum/component/personalshield/Initialize(max_charges = 3, current_charges, recharge_delay = 20 SECONDS, recharge_speed = 2 SECONDS, recharge_rate = 1, must_be_worn_or_held = TRUE, shield_on = "shield-old", list/item_rechargable, list/togglable_states, shield_broken = "broken", recharge_item_amount = 0)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	src.max_charges = max_charges
	if(!isnull(current_charges))
		src.current_charges = max_charges
	else
		src.current_charges = current_charges
	src.recharge_delay = recharge_delay
	src.recharge_speed = recharge_speed
	src.recharge_rate = recharge_rate
	src.must_be_worn_or_held = must_be_worn_or_held
	src.shield_on = shield_on
	if(item_rechargable)
		src.item_rechargable = typecacheof(item_rechargable)
	src.togglable_states = togglable_states
	src.shield_broken = shield_broken
	src.recharge_item_amount = recharge_item_amount

/datum/component/personalshield/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/equipped)
	RegisterSignal(parent, COMSIG_ITEM_AFTER_PICKUP, .proc/pickup)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/dropped)
	if(length(togglable_states) > 1)
		RegisterSignal(parent, COMSIG_ATOM_MULTITOOL_ACT, .proc/toggle_shield_color)
	if(!isnull(item_rechargable))
		RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/item_recharge)

/datum/component/personalshield/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED, 
		COMSIG_ITEM_AFTER_PICKUP, 
		COMSIG_ITEM_DROPPED,
		COMSIG_ATOM_MULTITOOL_ACT,
		COMSIG_PARENT_ATTACKBY))
	dropped(null, wearer)

/datum/component/personalshield/proc/toggle_shield_color(datum/source, mob/user)
	if(wearer != user)
		to_chat(user, "<span class='warning'>You can't interface with the shields's software if you haven't equipped it!</span>")
		return
	if(!length(togglable_states) || !current_charges)
		to_chat(user, "<span class='warning'>You can't interface with the shields's software if the shield's broken!</span>")
		return
	to_chat(user, "<span class='warning'>You update the shield's hardware, changing back the shield's color.</span>")
	if(++toggle_state > length(togglable_states))
		toggle_state = 1
	shield_on = togglable_states[toggle_state]
	update_overlay(user)

/datum/component/personalshield/proc/update_overlay(mob/user, state = "on")
	if(!iscarbon(user))
		return

	wearer = user
	wearer.remove_overlay(SHIELD_LAYER)
	if(state == "off" || !shield_broken)
		return
	var/iconstate = "broken"
	if(state == "on")
		iconstate = shield_on
	wearer.overlays_standing[SHIELD_LAYER] = list(mutable_appearance('icons/effects/effects.dmi', iconstate, MOB_LAYER + 0.01))
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
	recharge_timer = null
	if(recharge_delay == INFINITY || !recharge_rate) // don't recharge
		return
	recharge_timer = addtimer(CALLBACK(src, .proc/recharge), recharge_delay, TIMER_STOPPABLE)

/datum/component/personalshield/proc/item_recharge(datum/source, mob/user)
	if(!is_type_in_typecache(source.type, item_rechargable))
		return NONE
	current_charges = CLAMP((current_charges + recharge_item_amount), 0, max_charges)
	to_chat(user, "<span class='notice'>You charge \the [parent]. It can now absorb [current_charges] hits.</span>")
	return COMPONENT_NO_AFTERATTACK

/datum/component/personalshield/proc/shield_activate(mob/user)
	RegisterSignal(parent, COMSIG_ITEM_HIT_REACT, .proc/hit_reaction)
	if(current_charges)
		update_overlay(user, "on")
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
		update_overlay(owner, "broken")
	return COMPONENT_HIT_STOPPED
