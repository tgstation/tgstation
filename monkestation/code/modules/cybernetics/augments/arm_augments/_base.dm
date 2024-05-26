/obj/item/organ/internal/cyberimp/arm
	name = "arm-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_ARM
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/internal/cyberimp/arm/Initialize(mapload)
	. = ..()
	update_appearance()
	SetSlotFromZone()

/datum/action/item_action/organ_action/toggle/toolkit
	desc = "You can also activate your empty hand or the tool in your hand to open the tools radial menu."

/obj/item/organ/internal/cyberimp/arm/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_ARM)
			slot = ORGAN_SLOT_LEFT_ARM_AUG
		if(BODY_ZONE_R_ARM)
			slot = ORGAN_SLOT_RIGHT_ARM_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/internal/cyberimp/arm/update_icon()
	. = ..()
	transform = (zone == BODY_ZONE_R_ARM) ? null : matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/internal/cyberimp/arm/examine(mob/user)
	. = ..()
	if(status == ORGAN_ROBOTIC)
		. += span_info("[src] is assembled in the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm configuration. You can use a screwdriver to reassemble it.")

/obj/item/organ/internal/cyberimp/arm/screwdriver_act(mob/living/user, obj/item/screwtool)
	. = ..()
	if(.)
		return TRUE
	screwtool.play_tool_sound(src)
	if(zone == BODY_ZONE_R_ARM)
		zone = BODY_ZONE_L_ARM
	else
		zone = BODY_ZONE_R_ARM
	SetSlotFromZone()
	to_chat(user, span_notice("You modify [src] to be installed on the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."))
	update_appearance()
