/obj/item/weapon/gun/magic
	name = "staff of nothing"
	desc = "This staff is boring to watch because even though it came first you've seen everything it can do in other staves for years."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "staffofnothing"
	item_state = "staff"
	fire_sound = 'sound/weapons/emitter.ogg'
	flags =  CONDUCT
	w_class = WEIGHT_CLASS_HUGE
	var/max_charges = 6
	var/charges = 0
	var/recharge_rate = 4
	var/charge_tick = 0
	var/can_charge = 1
	var/ammo_type
	var/no_den_usage
	origin_tech = null
	clumsy_check = 0
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL // Has no trigger at all, uses magic instead
	pin = /obj/item/device/firing_pin/magic

	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi' //not really a gun and some toys use these inhands
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'

/obj/item/weapon/gun/magic/afterattack(atom/target, mob/living/user, flag)
	if(no_den_usage)
		var/area/A = get_area(user)
		if(istype(A, /area/wizard_station))
			to_chat(user, "<span class='warning'>You know better than to violate the security of The Den, best wait until you leave to use [src].<span>")
			return
		else
			no_den_usage = 0
	..()

/obj/item/weapon/gun/magic/can_shoot()
	return charges

/obj/item/weapon/gun/magic/recharge_newshot()
	if (charges && chambered && !chambered.BB)
		chambered.newshot()

/obj/item/weapon/gun/magic/process_chamber()
	if(chambered && !chambered.BB) //if BB is null, i.e the shot has been fired...
		charges--//... drain a charge
		recharge_newshot()

/obj/item/weapon/gun/magic/Initialize()
	. = ..()
	charges = max_charges
	chambered = new ammo_type(src)
	if(can_charge)
		START_PROCESSING(SSobj, src)


/obj/item/weapon/gun/magic/Destroy()
	if(can_charge)
		STOP_PROCESSING(SSobj, src)
	return ..()


/obj/item/weapon/gun/magic/process()
	charge_tick++
	if(charge_tick < recharge_rate || charges >= max_charges)
		return 0
	charge_tick = 0
	charges++
	if(charges == 1)
		recharge_newshot()
	return 1

/obj/item/weapon/gun/magic/update_icon()
	return

/obj/item/weapon/gun/magic/shoot_with_empty_chamber(mob/living/user as mob|obj)
	to_chat(user, "<span class='warning'>The [name] whizzles quietly.<span>")

/obj/item/weapon/gun/magic/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is twisting [src] above [user.p_their()] head, releasing a magical blast! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, fire_sound, 50, 1, -1)
	return (FIRELOSS)

/obj/item/weapon/gun/magic/vv_edit_var(var_name, var_value)
	. = ..()
	switch (var_name)
		if ("charges")
			recharge_newshot()