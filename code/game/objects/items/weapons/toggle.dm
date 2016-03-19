/obj/item/weapon/toggle
	var/active = FALSE
	var/force_on = 0
	var/throwforce_on = 0
	var/icon_state_on = "null"
	var/list/attack_verb_on = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	var/w_class_on = 4
	var/armour_penetration_on = 0
	var/activation_sound
	var/active_hitsound

/obj/item/weapon/toggle/attack_self(mob/living/carbon/user)
	if(active)
		active = FALSE
		force = initial(force)
		throwforce = initial(throwforce)
		hitsound = initial(hitsound)
		attack_verb = list()
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		armour_penetration = initial(armour_penetration)
		w_class = initial(w_class)
	else
		active = TRUE
		force = force_on
		throwforce = throwforce_on
		if(active_hitsound)
			hitsound = active_hitsound
		w_class = w_class_on
		item_state = icon_state_on
		icon_state = icon_state_on
		armour_penetration = armour_penetration_on
		attack_verb = attack_verb_on
		if(activation_sound)
			playsound(user, activation_sound, 35, 1)