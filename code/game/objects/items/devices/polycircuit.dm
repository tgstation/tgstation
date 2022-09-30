/obj/item/stack/circuit_stack
	name = "polycircuit aggregate"
	desc = "A dense, overdesigned cluster of electronics which attempted to function as a multipurpose circuit electronic. Circuits can be removed from it... if you don't bleed out in the process."
	icon_state = "circuit_mess"
	inhand_icon_state = "rods"
	w_class = WEIGHT_CLASS_TINY
	max_amount = 8
	merge_type = /obj/item/stack/circuit_stack
	singular_name = "circuit aggregate"
	var/circuit_type = /obj/item/electronics/airlock
	var/chosen_circuit = "airlock"

/obj/item/stack/circuit_stack/attack_self(mob/user)// Prevents the crafting menu, and tells you how to use it.
	to_chat(user, span_warning("You can't use [src] by itself, you'll have to try and remove one of these circuits by hand... carefully."))

/obj/item/stack/circuit_stack/attack_hand(mob/user, list/modifiers)
	var/mob/living/carbon/human/H = user
	if(user.get_inactive_held_item() != src)
		return ..()
	else
		if(is_zero_amount(delete_if_zero = TRUE))
			return
		chosen_circuit = tgui_input_list(user, "Circuit to remove", "Circuit Removal", list("airlock","firelock","fire alarm","air alarm","APC"), chosen_circuit)
		if(isnull(chosen_circuit))
			to_chat(user, span_notice("You wisely avoid putting your hands anywhere near [src]."))
			return
		if(is_zero_amount(delete_if_zero = TRUE))
			return
		if(loc != user)
			return
		switch(chosen_circuit)
			if("airlock")
				circuit_type = /obj/item/electronics/airlock
			if("firelock")
				circuit_type = /obj/item/electronics/firelock
			if("fire alarm")
				circuit_type = /obj/item/electronics/firealarm
			if("air alarm")
				circuit_type = /obj/item/electronics/airalarm
			if("APC")
				circuit_type = /obj/item/electronics/apc
		to_chat(user, span_notice("You spot your circuit, and carefully attempt to remove it from [src], hold still!"))
		if(do_after(user, 30, target = user))
			if(!src || QDELETED(src))//Sanity Check.
				return
			var/returned_circuit = new circuit_type(src)
			user.put_in_hands(returned_circuit)
			use(1)
			if(!amount)
				to_chat(user, span_notice("You navigate the sharp edges of circuitry and remove the last board."))
			else
				to_chat(user, span_notice("You navigate the sharp edges of circuitry and remove a single board from [src]"))
		else
			H.apply_damage(15, BRUTE, pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
			to_chat(user, span_warning("You give yourself a wicked cut on [src]'s many sharp corners and edges!"))

/obj/item/stack/circuit_stack/full
	amount = 8
