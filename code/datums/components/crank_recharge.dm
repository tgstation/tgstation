// Cranking feature on the laser musket and smoothbore disabler, could probably be used on more than guns
/datum/component/crank_recharge
	/// Our cell to charge
	var/obj/item/stock_parts/power_store/charging_cell
	/// Whether we spin our gun to reload (and therefore need the relevant trait)
	var/spin_to_win = FALSE
	/// How much charge we give our cell on each crank
	var/charge_amount
	/// How long is the cooldown time between each charge
	var/cooldown_time
	/// The sound used when charging, renember to adjust the cooldown time to keep it sensible
	var/charge_sound
	/// How long is the cooldown between charging sounds
	var/charge_sound_cooldown_time
	/// Are we currently charging
	var/is_charging = FALSE
	COOLDOWN_DECLARE(charge_sound_cooldown)

/datum/component/crank_recharge/Initialize(charging_cell, spin_to_win = FALSE, charge_amount = 500, cooldown_time = 2 SECONDS, charge_sound = 'sound/weapons/laser_crank.ogg', charge_sound_cooldown_time = 1.8 SECONDS)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(isnull(charging_cell) || !istype(charging_cell, /obj/item/stock_parts/power_store))
		return COMPONENT_INCOMPATIBLE
	src.charging_cell = charging_cell
	src.spin_to_win = spin_to_win
	src.charge_amount = charge_amount
	src.cooldown_time = cooldown_time
	src.charge_sound = charge_sound
	src.charge_sound_cooldown_time = charge_sound_cooldown_time

/datum/component/crank_recharge/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))

/datum/component/crank_recharge/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)

/datum/component/crank_recharge/proc/on_attack_self(obj/source, mob/living/user as mob)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(crank), source, user) //game doesnt like signal handler and do afters mingling

/datum/component/crank_recharge/proc/crank(obj/source, mob/user)
	if(charging_cell.charge >= charging_cell.maxcharge)
		source.balloon_alert(user, "already charged!")
		return
	if(is_charging)
		return
	if(spin_to_win && !HAS_TRAIT(user, TRAIT_GUNFLIP))
		source.balloon_alert(user, "need holster to spin!")
		return

	is_charging = TRUE
	if(COOLDOWN_FINISHED(src, charge_sound_cooldown))
		COOLDOWN_START(src, charge_sound_cooldown, charge_sound_cooldown_time)
		playsound(source, charge_sound, 40)
	source.balloon_alert(user, "charging...")
	if(!do_after(user, cooldown_time, source, interaction_key = DOAFTER_SOURCE_CHARGE_CRANKRECHARGE))
		is_charging = FALSE
		return
	charging_cell.give(charge_amount)
	source.update_appearance()
	is_charging = FALSE
	if(spin_to_win)
		source.SpinAnimation(4, 2) //What a badass
	source.balloon_alert(user, "charged")
