#define DISPENSE_LOLLIPOP_MODE 1
#define THROW_LOLLIPOP_MODE 2
#define THROW_GUMBALL_MODE 3
#define DISPENSE_ICECREAM_MODE 4

/obj/item/borg/lollipop
	name = "treat fabricator"
	desc = "Reward humans with various treats. Toggle in-module to switch between dispensing and high velocity ejection modes."
	icon_state = "lollipop"
	/// The current amount of available candy
	var/candy = 5
	/// The maximum amount of candy possible to hold
	var/candymax = 5
	/// Length of time it takes to regenerate a new candy
	var/charge_delay = 10 SECONDS
	/// Is the fabricator charging right now?
	var/charging = FALSE
	/// Dispensing mode
	var/mode = DISPENSE_LOLLIPOP_MODE

	/// Delay until next fire
	var/firedelay = 0
	var/hitspeed = 2

/obj/item/borg/lollipop/equipped()
	check_amount()
	return ..()

/obj/item/borg/lollipop/dropped()
	check_amount()
	return ..()

///Queues another lollipop to be fabricated if there is enough room for one
/obj/item/borg/lollipop/proc/check_amount()
	if(!charging && candy < candymax)
		addtimer(CALLBACK(src, .proc/charge_lollipops), charge_delay)
		charging = TRUE

///Increases the amount of lollipops
/obj/item/borg/lollipop/proc/charge_lollipops()
	candy++
	charging = FALSE
	check_amount()

///Dispenses a lollipop
/obj/item/borg/lollipop/proc/dispense(atom/atom_dispensed_to, mob/user)
	if(candy <= 0)
		to_chat(user, span_warning("No treats left in storage!"))
		return FALSE
	var/turf/turf_to_dispense_to = get_turf(atom_dispensed_to)
	if(!turf_to_dispense_to || !isopenturf(turf_to_dispense_to))
		return FALSE
	if(isobj(atom_dispensed_to))
		var/obj/obj_dispensed_to = atom_dispensed_to
		if(obj_dispensed_to.density)
			return FALSE

	var/obj/item/food_item
	switch(mode)
		if(DISPENSE_LOLLIPOP_MODE)
			food_item = new /obj/item/food/lollipop/cyborg(turf_to_dispense_to)
		if(DISPENSE_ICECREAM_MODE)
			food_item = new /obj/item/food/icecream(turf_to_dispense_to, list(ICE_CREAM_VANILLA))
			food_item.desc = "Eat the ice cream."

	var/into_hands = FALSE
	if(ismob(atom_dispensed_to))
		var/mob/mob_dispensed_to = atom_dispensed_to
		into_hands = mob_dispensed_to.put_in_hands(food_item)

	candy--
	check_amount()

	if(into_hands)
		user.visible_message(span_notice("[user] dispenses a treat into the hands of [atom_dispensed_to]."), span_notice("You dispense a treat into the hands of [atom_dispensed_to]."), span_hear("You hear a click."))
	else
		user.visible_message(span_notice("[user] dispenses a treat."), span_notice("You dispense a treat."), span_hear("You hear a click."))

	playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	return TRUE

/// Shoot a lollipop
/obj/item/borg/lollipop/proc/shootL(atom/target, mob/living/user, params)
	if(candy <= 0)
		to_chat(user, span_warning("Not enough lollipops left!"))
		return FALSE
	candy--

	var/obj/item/ammo_casing/caseless/lollipop/lollipop
	var/mob/living/silicon/robot/robot_user = user
	if(istype(robot_user) && robot_user.emagged)
		lollipop = new /obj/item/ammo_casing/caseless/lollipop/harmful(src)
	else
		lollipop = new /obj/item/ammo_casing/caseless/lollipop(src)

	playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	lollipop.fire_casing(target, user, params, 0, 0, null, 0, src)
	user.visible_message(span_warning("[user] blasts a flying lollipop at [target]!"))
	check_amount()

/// Shoot a gumball
/obj/item/borg/lollipop/proc/shootG(atom/target, mob/living/user, params)
	if(candy <= 0)
		to_chat(user, span_warning("Not enough gumballs left!"))
		return FALSE
	candy--
	var/obj/item/ammo_casing/caseless/gumball/gumball
	var/mob/living/silicon/robot/robot_user = user
	if(istype(robot_user) && robot_user.emagged)
		gumball = new /obj/item/ammo_casing/caseless/gumball/harmful(src)
	else
		gumball = new /obj/item/ammo_casing/caseless/gumball(src)

	gumball.loaded_projectile.color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	playsound(src.loc, 'sound/weapons/bulletflyby3.ogg', 50, TRUE)
	gumball.fire_casing(target, user, params, 0, 0, null, 0, src)
	user.visible_message(span_warning("[user] shoots a high-velocity gumball at [target]!"))
	check_amount()

/obj/item/borg/lollipop/afterattack(atom/target, mob/living/user, proximity, click_params)
	check_amount()
	if(iscyborg(user))
		var/mob/living/silicon/robot/robot_user = user
		if(!robot_user.cell.use(12))
			to_chat(user, span_warning("Not enough power."))
			return FALSE
	switch(mode)
		if(DISPENSE_LOLLIPOP_MODE, DISPENSE_ICECREAM_MODE)
			if(!proximity)
				return FALSE
			dispense(target, user)
		if(THROW_LOLLIPOP_MODE)
			shootL(target, user, click_params)
		if(THROW_GUMBALL_MODE)
			shootG(target, user, click_params)
	return ..()

/obj/item/borg/lollipop/attack_self(mob/living/user)
	switch(mode)
		if(DISPENSE_LOLLIPOP_MODE)
			mode = THROW_LOLLIPOP_MODE
			to_chat(user, span_notice("Module is now throwing lollipops."))
		if(THROW_LOLLIPOP_MODE)
			mode = THROW_GUMBALL_MODE
			to_chat(user, span_notice("Module is now blasting gumballs."))
		if(THROW_GUMBALL_MODE)
			mode = DISPENSE_ICECREAM_MODE
			to_chat(user, span_notice("Module is now dispensing ice cream."))
		if(DISPENSE_ICECREAM_MODE)
			mode = DISPENSE_LOLLIPOP_MODE
			to_chat(user, span_notice("Module is now dispensing lollipops."))
	..()

/obj/item/ammo_casing/caseless/gumball
	name = "Gumball"
	desc = "Why are you seeing this?!"
	projectile_type = /obj/projectile/bullet/reusable/gumball
	click_cooldown_override = 2

/obj/item/ammo_casing/caseless/gumball/harmful
	projectile_type = /obj/projectile/bullet/reusable/gumball/harmful

/obj/projectile/bullet/reusable/gumball
	name = "gumball"
	desc = "Oh noes! A fast-moving gumball!"
	icon_state = "gumball"
	ammo_type = /obj/item/food/gumball
	nodamage = TRUE
	damage = 0
	speed = 0.5

/obj/projectile/bullet/reusable/gumball/harmful
	nodamage = FALSE
	damage = 10

/obj/projectile/bullet/reusable/gumball/handle_drop()
	if(!dropped)
		var/turf/turf = get_turf(src)
		var/obj/item/food/gumball/gumball = new ammo_type(turf)
		gumball.color = color
		dropped = TRUE

/obj/item/ammo_casing/caseless/lollipop //NEEDS RANDOMIZED COLOR LOGIC.
	name = "Lollipop"
	desc = "Why are you seeing this?!"
	projectile_type = /obj/projectile/bullet/reusable/lollipop
	click_cooldown_override = 2

/obj/item/ammo_casing/caseless/lollipop/harmful
	projectile_type = /obj/projectile/bullet/reusable/lollipop/harmful

/obj/projectile/bullet/reusable/lollipop
	name = "lollipop"
	desc = "Oh noes! A fast-moving lollipop!"
	icon_state = "lollipop_1"
	ammo_type = /obj/item/food/lollipop/cyborg
	nodamage = TRUE
	damage = 0
	speed = 0.5
	var/color2 = rgb(0, 0, 0)

/obj/projectile/bullet/reusable/lollipop/harmful
	embedding = list(
		embed_chance = 35,
		fall_chance = 2,
		jostle_chance = 0,
		ignore_throwspeed_threshold = TRUE,
		pain_stam_pct = 0.5,
		pain_mult = 3,
		rip_time = 10,
	)
	damage = 10
	nodamage = FALSE
	embed_falloff_tile = 0

/obj/projectile/bullet/reusable/lollipop/Initialize(mapload)
	var/obj/item/food/lollipop/lollipop = new ammo_type(src)
	color2 = lollipop.head_color
	var/mutable_appearance/head = mutable_appearance('icons/obj/guns/projectiles.dmi', "lollipop_2")
	head.color = color2
	add_overlay(head)
	return ..()

/obj/projectile/bullet/reusable/lollipop/handle_drop()
	if(!dropped)
		var/turf/turf = get_turf(src)
		var/obj/item/food/lollipop/lollipop = new ammo_type(turf)
		lollipop.change_head_color(color2)
		dropped = TRUE

#undef DISPENSE_LOLLIPOP_MODE
#undef THROW_LOLLIPOP_MODE
#undef THROW_GUMBALL_MODE
#undef DISPENSE_ICECREAM_MODE
