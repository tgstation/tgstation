/obj/item/clothing/head/utility/welding/disco
	name = "Диско сварочная маска"
	desc = "Изобретение какого-то безумца"
	icon = 'newstuff/nikitauou/icons/clothing.dmi'
	worn_icon = 'newstuff/nikitauou/icons/worn.dmi'
	icon_state = "discomask"
	inhand_icon_state = "discomask"
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH | PEPPERPROOF
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

	if(!loc.get_filter("disco_rays"))
		loc.add_filter(name = "disco_rays", priority = 3, params = list(
			type = "rays",x=0,y=0, size = 28, density = 16, color = "white", flags = FILTER_UNDERLAY, offset = 0
		))
		animate(loc.get_filter("disco_rays"), offset = 10, time = 3 SECONDS, loop = -1)
		addtimer(CALLBACK(loc, TYPE_PROC_REF(/datum, remove_filter), "disco_rays"), 1.5 SECONDS)

	var/list/hearers = get_hearers_in_view(view_radius = DEFAULT_MESSAGE_RANGE, source=src)
	for (var/mob/hearer in hearers)
		if(ishuman(hearer))
			if(hearer != src.loc)
				var/mob/living/carbon/human/H = hearer
				if(!istype(H.head, src.type))
					if(H.flash_act(intensity=1,length=1 SECONDS))
						INVOKE_ASYNC(H,TYPE_PROC_REF(/mob,emote),"flip")
						INVOKE_ASYNC(H,TYPE_PROC_REF(/mob,emote),"spin")

