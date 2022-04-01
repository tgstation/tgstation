#define DISPENSE_LOLLIPOP_MODE 1
#define THROW_LOLLIPOP_MODE 2
#define THROW_GUMBALL_MODE 3
#define DISPENSE_ICECREAM_MODE 4

/obj/item/borg/lollipop
	name = "treat fabricator"
	desc = "Reward humans with various treats. Toggle in-module to switch between dispensing and high velocity ejection modes."
	icon_state = "lollipop"
	var/candy = 5
	var/candymax = 5
	var/charge_delay = 10 SECONDS
	var/charging = FALSE
	var/mode = DISPENSE_LOLLIPOP_MODE

	var/firedelay = 0
	var/hitspeed = 2

/obj/item/borg/lollipop/clown

/obj/item/borg/lollipop/equipped()
	. = ..()
	check_amount()

/obj/item/borg/lollipop/dropped()
	. = ..()
	check_amount()

/obj/item/borg/lollipop/proc/check_amount() //Doesn't even use processing ticks.
	if(!charging && candy < candymax)
		addtimer(CALLBACK(src, .proc/charge_lollipops), charge_delay)
		charging = TRUE

/obj/item/borg/lollipop/proc/charge_lollipops()
	candy++
	charging = FALSE
	check_amount()

/obj/item/borg/lollipop/proc/dispense(atom/A, mob/user)
	if(candy <= 0)
		to_chat(user, span_warning("No treats left in storage!"))
		return FALSE
	var/turf/T = get_turf(A)
	if(!T || !istype(T) || !isopenturf(T))
		return FALSE
	if(isobj(A))
		var/obj/O = A
		if(O.density)
			return FALSE

	var/obj/item/food_item
	switch(mode)
		if(DISPENSE_LOLLIPOP_MODE)
			food_item = new /obj/item/food/lollipop/cyborg(T)
		if(DISPENSE_ICECREAM_MODE)
			food_item = new /obj/item/food/icecream(T, list(ICE_CREAM_VANILLA))
			food_item.desc = "Eat the ice cream."

	var/into_hands = FALSE
	if(ismob(A))
		var/mob/M = A
		into_hands = M.put_in_hands(food_item)

	candy--
	check_amount()

	if(into_hands)
		user.visible_message(span_notice("[user] dispenses a treat into the hands of [A]."), span_notice("You dispense a treat into the hands of [A]."), span_hear("You hear a click."))
	else
		user.visible_message(span_notice("[user] dispenses a treat."), span_notice("You dispense a treat."), span_hear("You hear a click."))

	playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	return TRUE

/obj/item/borg/lollipop/proc/shootL(atom/target, mob/living/user, params)
	if(candy <= 0)
		to_chat(user, span_warning("Not enough lollipops left!"))
		return FALSE
	candy--

	var/obj/item/ammo_casing/caseless/lollipop/A
	var/mob/living/silicon/robot/R = user
	if(istype(R) && R.emagged)
		A = new /obj/item/ammo_casing/caseless/lollipop/harmful(src)
	else
		A = new /obj/item/ammo_casing/caseless/lollipop(src)

	playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	A.fire_casing(target, user, params, 0, 0, null, 0, src)
	user.visible_message(span_warning("[user] blasts a flying lollipop at [target]!"))
	check_amount()

/obj/item/borg/lollipop/proc/shootG(atom/target, mob/living/user, params) //Most certainly a good idea.
	if(candy <= 0)
		to_chat(user, span_warning("Not enough gumballs left!"))
		return FALSE
	candy--
	var/obj/item/ammo_casing/caseless/gumball/A
	var/mob/living/silicon/robot/R = user
	if(istype(R) && R.emagged)
		A = new /obj/item/ammo_casing/caseless/gumball/harmful(src)
	else
		A = new /obj/item/ammo_casing/caseless/gumball(src)

	A.loaded_projectile.color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	playsound(src.loc, 'sound/weapons/bulletflyby3.ogg', 50, TRUE)
	A.fire_casing(target, user, params, 0, 0, null, 0, src)
	user.visible_message(span_warning("[user] shoots a high-velocity gumball at [target]!"))
	check_amount()

/obj/item/borg/lollipop/afterattack(atom/target, mob/living/user, proximity, click_params)
	. = ..()
	check_amount()
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(!R.cell.use(12))
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

#undef DISPENSE_LOLLIPOP_MODE
#undef THROW_LOLLIPOP_MODE
#undef THROW_GUMBALL_MODE
#undef DISPENSE_ICECREAM_MODE

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
	damage = 10 //mediborgs get 5 shots before needing to reload at a rate of 1 shot/10 seconds, so they can do 50 damage from range max before needing to close the distance or retreat

/obj/projectile/bullet/reusable/gumball/handle_drop()
	if(!dropped)
		var/turf/T = get_turf(src)
		var/obj/item/food/gumball/S = new ammo_type(T)
		S.color = color
		dropped = TRUE

/obj/item/ammo_casing/caseless/lollipop //NEEDS RANDOMIZED COLOR LOGIC.
	name = "Lollipop"
	desc = "Why are you seeing this?!"
	projectile_type = /obj/projectile/bullet/reusable/lollipop
	click_cooldown_override = 2

// rejected name: DumDum lollipop (get it, cause it embeds?)
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
	embedding = list(embed_chance=35, fall_chance=2, jostle_chance=0, ignore_throwspeed_threshold=TRUE, pain_stam_pct=0.5, pain_mult=3, rip_time=10)
	damage = 10
	nodamage = FALSE
	embed_falloff_tile = 0

/obj/projectile/bullet/reusable/lollipop/Initialize(mapload)
	. = ..()
	var/obj/item/food/lollipop/S = new ammo_type(src)
	color2 = S.head_color
	var/mutable_appearance/head = mutable_appearance('icons/obj/guns/projectiles.dmi', "lollipop_2")
	head.color = color2
	add_overlay(head)

/obj/projectile/bullet/reusable/lollipop/handle_drop()
	if(!dropped)
		var/turf/T = get_turf(src)
		var/obj/item/food/lollipop/S = new ammo_type(T)
		S.change_head_color(color2)
		dropped = TRUE
