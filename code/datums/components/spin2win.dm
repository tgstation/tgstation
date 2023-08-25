/**
 * ### Spin 2 Win component!
 *
 * Component that attaches to items, making their attack_self begin a spin 2 win
 */
/datum/component/spin2win
	///the cooldown for spinning to winning
	COOLDOWN_DECLARE(spin_cooldown)
	///how long a spin2win takes to recharge.
	var/spin_cooldown_time
	///whether we are currently spin2winning or not.
	var/spinning = FALSE
	///Timer id for when we should stop spinning.
	var/stop_spinning_timer_id

	var/datum/callback/on_spin_callback
	var/datum/callback/on_unspin_callback

	var/start_spin_message
	var/end_spin_message

/datum/component/spin2win/Initialize(
		spin_cooldown_time = 10 SECONDS,
		on_spin_callback = null,
		on_unspin_callback = null,
		start_spin_message = "",
		end_spin_message = ""
	)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.spin_cooldown_time = spin_cooldown_time
	src.on_spin_callback = on_spin_callback
	src.on_unspin_callback = on_unspin_callback
	src.start_spin_message = start_spin_message
	src.end_spin_message = end_spin_message

/datum/component/spin2win/Destroy(force, silent)
	on_spin_callback = null
	on_unspin_callback = null
	return ..()

/datum/component/spin2win/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))

/datum/component/spin2win/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_ITEM_ATTACK_SECONDARY))

///signal called on parent being examined
/datum/component/spin2win/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("Using [parent] in your hands will make you spin your weapon around for a few moments, attacking everyone near you repeatedly!")
	if(spinning)
		examine_list += span_warning("...Of which you are currently doing right now!")
		return
	if(COOLDOWN_FINISHED(src, spin_cooldown))
		examine_list += span_notice("It has a cooldown of [DisplayTimeText(spin_cooldown_time)].")
	else
		examine_list += span_notice("It will be ready to spin again in [DisplayTimeText(COOLDOWN_TIMELEFT(src, spin_cooldown))].")

/datum/component/spin2win/proc/on_attack_self(datum/source, mob/user, location, direction)
	SIGNAL_HANDLER

	if(spinning)
		user.balloon_alert(user, "already active!")
		return
	if(!COOLDOWN_FINISHED(src, spin_cooldown))
		user.balloon_alert(user, "on cooldown!")
		return

	start_spinning(user)

/datum/component/spin2win/proc/start_spinning(mob/living/spinning_user)
	//user will always exist for the start
	spinning = TRUE
	spinning_user.changeNext_move(5 SECONDS)
	if(on_spin_callback)
		on_spin_callback.Invoke(spinning_user)
	if(start_spin_message)
		var/message = replacetext(start_spin_message, "%USER", spinning_user)
		spinning_user.visible_message(message)
	playsound(spinning_user, 'sound/weapons/fwoosh.ogg', 75, FALSE)
	stop_spinning_timer_id = addtimer(CALLBACK(src, PROC_REF(stop_spinning), spinning_user), 5 SECONDS, TIMER_STOPPABLE|TIMER_DELETE_ME)
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_spin_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_spin_dropped))
	START_PROCESSING(SSprocessing, src)

/datum/component/spin2win/proc/stop_spinning(mob/living/user)
	//user might not exist for the end
	STOP_PROCESSING(SSprocessing, src)
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	deltimer(stop_spinning_timer_id)
	playsound(user, 'sound/weapons/fwoosh.ogg', 75, FALSE)
	if(user && end_spin_message)
		var/message = replacetext(end_spin_message, "%USER", user)
		user.visible_message(message)
	if(on_unspin_callback)
		on_unspin_callback.Invoke(user, 5 SECONDS)
	COOLDOWN_START(src, spin_cooldown, spin_cooldown_time)
	spinning = FALSE

/datum/component/spin2win/process(seconds_per_tick)
	var/obj/item/spinning_item = parent
	if(!isliving(spinning_item.loc))
		stop_spinning()
		return PROCESS_KILL
	var/mob/living/item_owner = spinning_item.loc
	item_owner.emote("spin")
	playsound(item_owner, 'sound/weapons/fwoosh.ogg', 75, FALSE)
	for(var/mob/living/victim in orange(1, item_owner))
		spinning_item.attack(victim, item_owner)

/datum/component/spin2win/proc/on_spin_dropped(datum/source, mob/user)
	SIGNAL_HANDLER

	stop_spinning(user)

/datum/component/spin2win/proc/on_spin_equipped(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(slot != ITEM_SLOT_HANDS)
		stop_spinning(equipper)
