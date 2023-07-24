// Cranking feature on the laser musket and smoothbore disabler, could possibly be used on more than guns
/datum/component/gun_crank
	/// Our cell to charge
	var/obj/item/stock_parts/cell/charging_cell
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

/datum/component/gun_crank/Initialize(charging_cell, charge_amount = 500, cooldown_time = 2 SECONDS, charge_sound = 'sound/weapons/laser_crank.ogg', charge_sound_cooldown_time = 1.8 SECONDS)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	if(isnull(charging_cell) || !istype(charging_cell, /obj/item/stock_parts/cell))
		return COMPONENT_INCOMPATIBLE
	src.charging_cell = charging_cell
	src.charge_amount = charge_amount
	src.cooldown_time = cooldown_time
	src.charge_sound = charge_sound
	src.charge_sound_cooldown_time = charge_sound_cooldown_time

/datum/component/gun_crank/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))

/datum/component/gun_crank/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ITEM_ATTACK_SELF)

/datum/component/gun_crank/proc/on_attack_self(obj/source, mob/living/user as mob)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(crank_gun), source, user) //game doesnt like signal handler and do afters mingling

/datum/component/gun_crank/proc/crank_gun(obj/source, mob/user)
	if(charging_cell.charge >= charging_cell.maxcharge)
		source.balloon_alert(user, "already charged!")
		return
	if(is_charging)
		return
	is_charging = TRUE
	if(COOLDOWN_FINISHED(src, charge_sound_cooldown))
		COOLDOWN_START(src, charge_sound_cooldown, charge_sound_cooldown_time)
		playsound(source, charge_sound, 40)
	source.balloon_alert(user, "charging...")
	if(!do_after(user, cooldown_time, source, interaction_key = DOAFTER_SOURCE_CHARGE_GUNCRANK))
		is_charging = FALSE
		return
	charging_cell.give(charge_amount)
	source.update_appearance()
	is_charging = FALSE
	source.balloon_alert(user, "charged")
