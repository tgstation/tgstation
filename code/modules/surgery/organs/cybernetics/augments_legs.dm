/obj/item/organ/cyberimp/leg
	name = "leg-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_LEG
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_SMALL
	encode_info = NT_LOWLEVEL

	var/double_legged = FALSE

/obj/item/organ/cyberimp/leg/Initialize()
	. = ..()
	update_icon()
	SetSlotFromZone()

/obj/item/organ/cyberimp/leg/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_R_LEG)
			slot = ORGAN_SLOT_LEFT_LEG_AUG
		if(BODY_ZONE_L_LEG)
			slot = ORGAN_SLOT_RIGHT_LEG_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/cyberimp/leg/update_icon()
	if(zone == BODY_ZONE_R_LEG)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/cyberimp/leg/examine(mob/user)
	. = ..()
	. += "<span class='info'>[src] is assembled in the [zone == BODY_ZONE_R_LEG ? "right" : "left"] LEG configuration. You can use a screwdriver to reassemble it.</span>"

/obj/item/organ/cyberimp/leg/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	I.play_tool_sound(src)
	if(zone == BODY_ZONE_R_LEG)
		zone = BODY_ZONE_L_LEG
	else
		zone = BODY_ZONE_R_LEG
	SetSlotFromZone()
	to_chat(user, "<span class='notice'>You modify [src] to be installed on the [zone == BODY_ZONE_R_LEG ? "right" : "left"] leg.</span>")
	update_icon()

/obj/item/organ/cyberimp/leg/Insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	if(!double_legged)
		on_full_insert(M, special, drop_if_replaced)
		return
	var/obj/item/organ/organ = M.getorganslot(slot == ORGAN_SLOT_LEFT_LEG_AUG ? ORGAN_SLOT_RIGHT_LEG_AUG : ORGAN_SLOT_LEFT_LEG_AUG)
	if(organ && organ.type == type)
		on_full_insert(M, special, drop_if_replaced)

/obj/item/organ/cyberimp/leg/proc/on_full_insert(mob/living/carbon/M, special, drop_if_replaced)
	return

/obj/item/organ/cyberimp/leg/table_glider
	name = "table-glider implant"
	desc = "Implant that allows you quickly glide tables, if you have this installed in both of your legs."
	encode_info = NT_LOWLEVEL
	double_legged = TRUE

/obj/item/organ/cyberimp/leg/table_glider/update_implants()
	if(!check_compatibility())
		REMOVE_TRAIT(M,TRAIT_FAST_CLIMBER,type)
		return
	ADD_TRAIT(M,TRAIT_FAST_CLIMBER,type)

/obj/item/organ/cyberimp/leg/table_glider/on_full_insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	if(!check_compatibility())
		return
	ADD_TRAIT(M,TRAIT_FAST_CLIMBER,type)

/obj/item/organ/cyberimp/leg/table_glider/Remove(mob/living/carbon/M, special)
	REMOVE_TRAIT(M,TRAIT_FAST_CLIMBER,type)
	return ..()

/obj/item/organ/cyberimp/leg/shove_resist
	name = "shove-resist implant"
	desc = "Implant that allows you to resist shoves, instead shoves deal pure stamina damage."
	encode_info = NT_HIGHLEVEL
	double_legged = TRUE

/obj/item/organ/cyberimp/leg/table_glider/update_implants()
	if(!check_compatibility())
		REMOVE_TRAIT(M,TRAIT_SHOVE_RESIST,type)
		return
	ADD_TRAIT(M,TRAIT_SHOVE_RESIST,type)

/obj/item/organ/cyberimp/leg/shove_resist/on_full_insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	if(!check_compatibility())
		return
	ADD_TRAIT(M,TRAIT_SHOVE_RESIST,type)

/obj/item/organ/cyberimp/leg/shove_resist/Remove(mob/living/carbon/M, special)
	REMOVE_TRAIT(M,TRAIT_SHOVE_RESIST,type)
	return ..()
