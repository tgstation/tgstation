/obj/item/gun/magic
	name = "staff of nothing"
	desc = "This staff is boring to watch because even though it came first you've seen everything it can do in other staves for years."
	icon = 'icons/obj/weapons/guns/magic.dmi'
	icon_state = "staffofnothing"
	inhand_icon_state = "staff"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi' //not really a gun and some toys use these inhands
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	fire_sound = 'sound/items/weapons/emitter.ogg'
	obj_flags = CONDUCTS_ELECTRICITY
	w_class = WEIGHT_CLASS_HUGE
	///what kind of magic is this
	var/school = SCHOOL_EVOCATION
	var/antimagic_flags = MAGIC_RESISTANCE
	var/max_charges = 6
	var/charges = 0
	var/recharge_rate = 8
	var/charge_timer = 0
	/// Whether this wand/staff recharges on its own over time.
	/// (This is not related to the spell "Charge" whatsoever!)
	var/can_charge = TRUE
	var/ammo_type
	var/no_den_usage
	clumsy_check = 0
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL // Has no trigger at all, uses magic instead
	pin = /obj/item/firing_pin/magic

/obj/item/gun/magic/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_MAGICALLY_CHARGED, PROC_REF(on_magic_charge))

/obj/item/gun/magic/apply_fantasy_bonuses(bonus)
	. = ..()
	recharge_rate = modify_fantasy_variable("recharge_rate", recharge_rate, -bonus, minimum = 1)
	max_charges = modify_fantasy_variable("max_charges", max_charges, bonus)
	charges = modify_fantasy_variable("charges", charges, bonus)

/obj/item/gun/magic/remove_fantasy_bonuses(bonus)
	recharge_rate = reset_fantasy_variable("recharge_rate", recharge_rate)
	max_charges = reset_fantasy_variable("max_charges", max_charges)
	charges = reset_fantasy_variable("charges", charges)
	return ..()

/obj/item/gun/magic/fire_sounds()
	var/frequency_to_use = sin((90/max_charges) * charges)
	if(suppressed)
		playsound(src, suppressed_sound, suppressed_volume, vary_fire_sound, ignore_walls = FALSE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0, frequency = frequency_to_use)
	else
		playsound(src, fire_sound, fire_sound_volume, vary_fire_sound, frequency = frequency_to_use)

/**
 * Signal proc for [COMSIG_ITEM_MAGICALLY_CHARGED]
 *
 * Adds uses to wands or staffs.
 */
/obj/item/gun/magic/proc/on_magic_charge(datum/source, datum/action/cooldown/spell/charge/spell, mob/living/caster)
	SIGNAL_HANDLER

	. = COMPONENT_ITEM_CHARGED

	// Non-self charging staves and wands can potentially expire
	if(!can_charge && max_charges && prob(80))
		max_charges--

	if(max_charges <= 0)
		max_charges = 0
		. |= COMPONENT_ITEM_BURNT_OUT

	charges = max_charges
	update_appearance(UPDATE_ICON_STATE)
	recharge_newshot()

	return .

/obj/item/gun/magic/process_fire(atom/target, mob/living/user, message, params, zone_override, bonus_spread)
	if(no_den_usage)
		var/area/A = get_area(user)
		if(istype(A, /area/centcom/wizard_station))
			add_fingerprint(user)
			to_chat(user, span_warning("You know better than to violate the security of The Den, best wait until you leave to use [src]."))
			return
		else
			no_den_usage = 0
	if(!user.can_cast_magic(antimagic_flags))
		add_fingerprint(user)
		return
	. = ..()

/obj/item/gun/magic/can_shoot()
	return charges

/obj/item/gun/magic/recharge_newshot()
	if (charges && chambered && !chambered.loaded_projectile)
		chambered.newshot()

/obj/item/gun/magic/handle_chamber()
	if(chambered && !chambered.loaded_projectile) //if BB is null, i.e the shot has been fired...
		charges--//... drain a charge
		recharge_newshot()

/obj/item/gun/magic/Initialize(mapload)
	. = ..()
	charges = max_charges
	if(ammo_type)
		chambered = new ammo_type(src)
	if(can_charge)
		START_PROCESSING(SSobj, src)
	RegisterSignal(src, COMSIG_ITEM_RECHARGED, PROC_REF(instant_recharge))


/obj/item/gun/magic/Destroy()
	if(can_charge)
		STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/gun/magic/process(seconds_per_tick)
	if (charges >= max_charges)
		charge_timer = 0
		return
	charge_timer += seconds_per_tick
	if(charge_timer < recharge_rate)
		return 0
	charge_timer = 0
	charges++
	if(charges == 1)
		recharge_newshot()
	return 1


/obj/item/gun/magic/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, span_warning("\The [src] whizzles quietly."))

/obj/item/gun/magic/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is twisting [src] above [user.p_their()] head, releasing a magical blast! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, fire_sound, 50, TRUE, -1)
	return FIRELOSS

/obj/item/gun/magic/vv_edit_var(var_name, var_value)
	. = ..()
	switch(var_name)
		if(NAMEOF(src, charges))
			recharge_newshot()

/obj/item/gun/magic/proc/instant_recharge()
	SIGNAL_HANDLER
	charges = max_charges
	recharge_newshot()
	update_appearance()
