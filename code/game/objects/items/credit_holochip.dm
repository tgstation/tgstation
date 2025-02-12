/obj/item/holochip
	name = "credit holochip"
	desc = "A hard-light chip encoded with an amount of credits. It is a modern replacement for physical money that can be directly converted to virtual currency and vice-versa. Keep away from magnets."
	icon = 'icons/obj/economy.dmi'
	icon_state = "holochip"
	base_icon_state = "holochip"
	throwforce = 0
	force = 0
	w_class = WEIGHT_CLASS_TINY
	interaction_flags_click = NEED_DEXTERITY|FORBID_TELEKINESIS_REACH|ALLOW_RESTING
	/// Amount on money on the card
	var/credits = 0

/obj/item/holochip/Initialize(mapload, amount = 1)
	. = ..()
	if(!credits && amount)
		credits = amount
	if(credits <= 0 && !mapload)
		stack_trace("Holochip created with 0 or less credits in [get_area_name(src)]!")
		return INITIALIZE_HINT_QDEL
	add_traits(list(TRAIT_FISHING_BAIT, TRAIT_BAIT_ALLOW_FISHING_DUD), INNATE_TRAIT)
	update_appearance()

/obj/item/holochip/examine(mob/user)
	. = ..()
	. += "[span_notice("It's loaded with [credits] credit[( credits > 1 ) ? "s" : ""]")]\n"+\
	span_notice("Alt-Click to split.")

/obj/item/holochip/get_item_credit_value()
	return credits

/obj/item/holochip/update_name()
	name = "\improper [credits] credit holochip"
	return ..()

/obj/item/holochip/update_icon_state()
	var/icon_suffix = ""
	switch(credits)
		if(1e3 to (1e6 - 1))
			icon_suffix = "_kilo"
		if(1e6 to (1e9 - 1))
			icon_suffix = "_mega"
		if(1e9 to INFINITY)
			icon_suffix = "_giga"

	icon_state = "[base_icon_state][icon_suffix]"
	return ..()

/obj/item/holochip/update_overlays()
	. = ..()
	var/rounded_credits
	switch(credits)
		if(0 to (1e3 - 1))
			rounded_credits = round(credits)
		if(1e3 to (1e6 - 1))
			rounded_credits = round(credits * 1e-3)
		if(1e6 to (1e9 - 1))
			rounded_credits = round(credits * 1e-6)
		if(1e9 to INFINITY)
			rounded_credits = round(credits * 1e-9)

	var/overlay_color = "#914792"
	switch(rounded_credits)
		if(0 to 4)
			overlay_color = "#8E2E38"
		if(5 to 9)
			overlay_color = "#914792"
		if(10 to 19)
			overlay_color = "#BF5E0A"
		if(20 to 49)
			overlay_color = "#358F34"
		if(50 to 99)
			overlay_color = COLOR_SLIME_METAL
		if(100 to 199)
			overlay_color = "#009D9B"
		if(200 to 499)
			overlay_color = "#0153C1"
		if(500 to INFINITY)
			overlay_color = "#2C2C2C"

	var/mutable_appearance/holochip_overlay = mutable_appearance('icons/obj/economy.dmi', "[icon_state]-color")
	holochip_overlay.color = overlay_color
	. += holochip_overlay

/obj/item/holochip/proc/spend(amount, pay_anyway = FALSE)
	if(credits >= amount)
		credits -= amount
		if(credits == 0)
			qdel(src)
		update_appearance()
		return amount
	else if(pay_anyway)
		qdel(src)
		return credits
	else
		return 0

/obj/item/holochip/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/holochip))
		var/obj/item/holochip/H = I
		credits += H.credits
		to_chat(user, span_notice("You insert the credits into [src]."))
		update_appearance()
		qdel(H)

/obj/item/holochip/click_alt(mob/user)
	if(loc != user)
		to_chat(user, span_warning("You must be holding the holochip to continue!"))
		return CLICK_ACTION_BLOCKING
	var/split_amount = tgui_input_number(user, "How many credits do you want to extract from the holochip? (Max: [credits] cr)", "Holochip", max_value = credits)
	if(!split_amount || QDELETED(user) || QDELETED(src) || issilicon(user) || !usr.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH) || loc != user)
		return CLICK_ACTION_BLOCKING
	var/new_credits = spend(split_amount, TRUE)
	var/obj/item/holochip/chip = new(user ? user : drop_location(), new_credits)
	if(user)
		if(!user.put_in_hands(chip))
			chip.forceMove(user.drop_location())
		add_fingerprint(user)
	to_chat(user, span_notice("You extract [split_amount] credits into a new holochip."))
	return CLICK_ACTION_SUCCESS

/obj/item/holochip/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	var/wipe_chance = 60 / severity
	if(prob(wipe_chance))
		visible_message(span_warning("[src] fizzles and disappears!"))
		qdel(src) //rip cash

/obj/item/holochip/thousand
	credits = 1000
