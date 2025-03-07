/obj/item/clothing/head/utility/welding/disco
	name = "Диско сварочная маска"
	desc = "Изобретение какого-то безумца"
	icon_state = "welding"
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	inhand_icon_state = "welding"
	lefthand_file = 'icons/mob/inhands/clothing/masks_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/masks_righthand.dmi'
	custom_materials = list(/datum/material/iron=HALF_SHEET_MATERIAL_AMOUNT*1.75, /datum/material/glass=SMALL_MATERIAL_AMOUNT * 4)
	flash_protect = FLASH_PROTECTION_WELDER
	tint = 2
	armor_type = /datum/armor/utility_welding
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	actions_types = list(/datum/action/item_action/toggle)
	visor_flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDESNOUT
	visor_flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	resistance_flags = FIRE_PROOF
	clothing_flags = SNUG_FIT | STACKABLE_HELMET_EXEMPT

/obj/item/clothing/head/utility/welding/disco/equipped(mob/living/user, slot, initial)
	.=..()
	if(slot == ITEM_SLOT_HEAD)
		RegisterSignal(user,COMSIG_MOB_FLASH_PROTECTED, PROC_REF(flash))

/obj/item/clothing/head/utility/welding/disco/dropped(mob/living/user, slot)
	.=..()
	UnregisterSignal(user,COMSIG_MOB_FLASH_PROTECTED)

/obj/item/clothing/head/utility/welding/disco/proc/flash(intensity = 1,length = 1)
	SIGNAL_HANDLER

	spawn_atom_to_turf(/obj/effect/temp_visual/hierophant/telegraph/edge, src, 1, FALSE)
	var/list/hearers = get_hearers_in_view(view_radius = DEFAULT_MESSAGE_RANGE, source=src)
	for (var/mob/hearer in hearers)
		if(isliving(hearer))
			if(hearer != src.loc)
				var/mob/living/H = hearer
				INVOKE_ASYNC(H,TYPE_PROC_REF(/mob,emote),"flip")
				INVOKE_ASYNC(H,TYPE_PROC_REF(/mob,emote),"spin")
				H.flash_act(intensity=1,length=1 SECONDS)
