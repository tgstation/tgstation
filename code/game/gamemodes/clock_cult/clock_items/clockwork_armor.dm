//Clockwork armor: High melee protection but weak to lasers
/obj/item/clothing/head/helmet/clockwork
	name = "clockwork helmet"
	desc = "A heavy helmet made of brass."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_helmet"
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(melee = 80, bullet = 70, laser = -25, energy = 0, bomb = 60, bio = 0, rad = 0, fire = 100, acid = 100)

/obj/item/clothing/head/helmet/clockwork/Initialize()
	. = ..()
	ratvar_act()
	GLOB.all_clockwork_objects += src

/obj/item/clothing/head/helmet/clockwork/Destroy()
	GLOB.all_clockwork_objects -= src
	return ..()

/obj/item/clothing/head/helmet/clockwork/ratvar_act()
	if(GLOB.ratvar_awakens)
		armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100)
		flags |= STOPSPRESSUREDMAGE
		max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
		min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	else
		armor = list(melee = 80, bullet = 70, laser = -25, energy = 0, bomb = 60, bio = 0, rad = 0, fire = 100, acid = 100)
		flags &= ~STOPSPRESSUREDMAGE
		max_heat_protection_temperature = initial(max_heat_protection_temperature)
		min_cold_protection_temperature = initial(min_cold_protection_temperature)

/obj/item/clothing/head/helmet/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == slot_head && !is_servant_of_ratvar(user))
		if(!iscultist(user))
			to_chat(user, "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their head!</span>", "<span class='warning'>The helmet flickers off your head, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20, 1, 1, 0, 1)
		else
			to_chat(user, "<span class='heavy_brass'>\"Do you have a hole in your head? You're about to.\"</span>")
			to_chat(user, "<span class='userdanger'>The helmet tries to drive a spike through your head as you scramble to remove it!</span>")
			user.emote("scream")
			user.apply_damage(30, BRUTE, "head")
			user.adjustBrainLoss(30)
		addtimer(CALLBACK(user, /mob/living.proc/dropItemToGround), src, 1) //equipped happens before putting stuff on(but not before picking items up), 1). thus, we need to wait for it to be on before forcing it off.

/obj/item/clothing/head/helmet/clockwork/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	if(equipper && !is_servant_of_ratvar(equipper))
		return 0
	return ..()

/obj/item/clothing/suit/armor/clockwork
	name = "clockwork cuirass"
	desc = "A bulky cuirass made of brass."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_cuirass"
	w_class = WEIGHT_CLASS_BULKY
	body_parts_covered = CHEST|GROIN|LEGS
	cold_protection = CHEST|GROIN|LEGS
	heat_protection = CHEST|GROIN|LEGS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(melee = 80, bullet = 70, laser = -25, energy = 0, bomb = 60, bio = 0, rad = 0, fire = 100, acid = 100)
	allowed = list(/obj/item/clockwork, /obj/item/clothing/glasses/wraith_spectacles, /obj/item/clothing/glasses/judicial_visor, /obj/item/device/mmi/posibrain/soul_vessel)

/obj/item/clothing/suit/armor/clockwork/Initialize()
	. = ..()
	ratvar_act()
	GLOB.all_clockwork_objects += src

/obj/item/clothing/suit/armor/clockwork/Destroy()
	GLOB.all_clockwork_objects -= src
	return ..()

/obj/item/clothing/suit/armor/clockwork/ratvar_act()
	if(GLOB.ratvar_awakens)
		armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100)
		flags |= STOPSPRESSUREDMAGE
		max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
		min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	else
		armor = list(melee = 80, bullet = 70, laser = -25, energy = 0, bomb = 60, bio = 0, rad = 0, fire = 100, acid = 100)
		flags &= ~STOPSPRESSUREDMAGE
		max_heat_protection_temperature = initial(max_heat_protection_temperature)
		min_cold_protection_temperature = initial(min_cold_protection_temperature)

/obj/item/clothing/suit/armor/clockwork/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	if(equipper && !is_servant_of_ratvar(equipper))
		return 0
	return ..()

/obj/item/clothing/suit/armor/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == slot_wear_suit && !is_servant_of_ratvar(user))
		if(!iscultist(user))
			to_chat(user, "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their body!</span>", "<span class='warning'>The curiass flickers off your body, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(20, 1, 1, 0, 1)
		else
			to_chat(user, "<span class='heavy_brass'>\"I think this armor is too hot for you to handle.\"</span>")
			to_chat(user, "<span class='userdanger'>The curiass emits a burst of flame as you scramble to get it off!</span>")
			user.emote("scream")
			user.apply_damage(15, BURN, "chest")
			user.adjust_fire_stacks(2)
			user.IgniteMob()
		addtimer(CALLBACK(user, /mob/living.proc/dropItemToGround, src, TRUE), 1)

/obj/item/clothing/gloves/clockwork
	name = "clockwork gauntlets"
	desc = "Heavy, shock-resistant gauntlets with brass reinforcement."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_gauntlets"
	item_state = "clockwork_gauntlets"
	item_color = null //So they don't wash.
	strip_delay = 50
	put_on_delay = 30
	body_parts_covered = ARMS
	cold_protection = ARMS
	heat_protection = ARMS
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(melee = 80, bullet = 70, laser = -25, energy = 0, bomb = 60, bio = 0, rad = 0, fire = 100, acid = 100)

/obj/item/clothing/gloves/clockwork/Initialize()
	. = ..()
	ratvar_act()
	GLOB.all_clockwork_objects += src

/obj/item/clothing/gloves/clockwork/Destroy()
	GLOB.all_clockwork_objects -= src
	return ..()

/obj/item/clothing/gloves/clockwork/ratvar_act()
	if(GLOB.ratvar_awakens)
		armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100)
		flags |= STOPSPRESSUREDMAGE
		max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
		min_cold_protection_temperature = SPACE_HELM_MIN_TEMP_PROTECT
	else
		armor = list(melee = 80, bullet = 70, laser = -25, energy = 0, bomb = 60, bio = 0, rad = 0, fire = 100, acid = 100)
		flags &= ~STOPSPRESSUREDMAGE
		max_heat_protection_temperature = initial(max_heat_protection_temperature)
		min_cold_protection_temperature = initial(min_cold_protection_temperature)

/obj/item/clothing/gloves/clockwork/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	if(equipper && !is_servant_of_ratvar(equipper))
		return 0
	return ..()

/obj/item/clothing/gloves/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == slot_gloves && !is_servant_of_ratvar(user))
		if(!iscultist(user))
			to_chat(user, "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their arms!</span>", "<span class='warning'>The gauntlets flicker off your arms, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(10, 1, 1, 0, 1)
		else
			to_chat(user, "<span class='heavy_brass'>\"Did you like having arms?\"</span>")
			to_chat(user, "<span class='userdanger'>The gauntlets suddenly squeeze tight, crushing your arms before you manage to get them off!</span>")
			user.emote("scream")
			user.apply_damage(7, BRUTE, "l_arm")
			user.apply_damage(7, BRUTE, "r_arm")
		addtimer(CALLBACK(user, /mob/living.proc/dropItemToGround, src, TRUE), 1)

/obj/item/clothing/shoes/clockwork
	name = "clockwork treads"
	desc = "Industrial boots made of brass. They're very heavy."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "clockwork_treads"
	w_class = WEIGHT_CLASS_NORMAL
	strip_delay = 50
	put_on_delay = 30
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/clockwork/Initialize()
	. = ..()
	ratvar_act()
	GLOB.all_clockwork_objects += src

/obj/item/clothing/shoes/clockwork/Destroy()
	GLOB.all_clockwork_objects -= src
	return ..()

/obj/item/clothing/shoes/clockwork/negates_gravity()
	return TRUE

/obj/item/clothing/shoes/clockwork/ratvar_act()
	if(GLOB.ratvar_awakens)
		flags |= NOSLIP
	else
		flags &= ~NOSLIP

/obj/item/clothing/shoes/clockwork/mob_can_equip(mob/M, mob/equipper, slot, disable_warning = 0)
	if(equipper && !is_servant_of_ratvar(equipper))
		return 0
	return ..()

/obj/item/clothing/shoes/clockwork/equipped(mob/living/user, slot)
	..()
	if(slot == slot_shoes && !is_servant_of_ratvar(user))
		if(!iscultist(user))
			to_chat(user, "<span class='heavy_brass'>\"Now now, this is for my servants, not you.\"</span>")
			user.visible_message("<span class='warning'>As [user] puts [src] on, it flickers off their feet!</span>", "<span class='warning'>The treads flicker off your feet, leaving only nausea!</span>")
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.vomit(10, 1, 1, 0, 1)
		else
			to_chat(user, "<span class='heavy_brass'>\"Let's see if you can dance with these.\"</span>")
			to_chat(user, "<span class='userdanger'>The treads turn searing hot as you scramble to get them off!</span>")
			user.emote("scream")
			user.apply_damage(7, BURN, "l_leg")
			user.apply_damage(7, BURN, "r_leg")
		addtimer(CALLBACK(user, /mob/living.proc/dropItemToGround, src, TRUE), 1)
