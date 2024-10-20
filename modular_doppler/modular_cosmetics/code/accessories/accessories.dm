
// Accessory for Akula species, it makes them wet and happy! :)
/obj/item/clothing/accessory/vaporizer
	name = "\improper Stardress hydro-vaporizer"
	desc = "An expensive device manufactured for the civilian work-force of the Azulean military power. \
	Relying on an internal battery, the coil mechanism synthesizes a hydrogen oxygen mixture, \
	which can then be used to moisturize the wearer's skin. \n\n\
	<i>A label on its back warns about the potential dangers of electro-magnetic pulses.</i> \
	<b>ctrl-click</b> in-hand to hide the device while worn."
	icon_state = "wetmaker"
	base_icon_state = "wetmaker"
	icon = 'modular_doppler/modular_cosmetics/icons/obj/accessories/accessories.dmi'
	worn_icon = 'modular_doppler/modular_cosmetics/icons/mob/accessories/accessories.dmi'
	obj_flags = UNIQUE_RENAME
	attachment_slot = NONE

/obj/item/clothing/accessory/vaporizer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wetsuit)

/obj/item/clothing/accessory/vaporizer/item_ctrl_click(mob/user)
	. = ..()
	if(!ishuman(user))
		return CLICK_ACTION_BLOCKING
	var/mob/living/carbon/human/wearer = user
	if(wearer.get_active_held_item() != src)
		to_chat(wearer, span_warning("You must hold the [src] in your hand to do this!"))
		return CLICK_ACTION_BLOCKING
	if(icon_state == "[base_icon_state]")
		icon_state = "[base_icon_state]_hidden"
		worn_icon_state = "[base_icon_state]_hidden"
		balloon_alert(wearer, "hidden")
	else
		icon_state = "[base_icon_state]"
		worn_icon_state = "[base_icon_state]"
		balloon_alert(wearer, "shown")
	update_icon() // update that mf
	return CLICK_ACTION_SUCCESS

/obj/item/clothing/accessory/vaporizer/emp_act(severity)
	. = ..()
	var/obj/item/clothing/under/attached_to = loc
	var/mob/living/carbon/human/wearer = attached_to.loc
	if(!istype(wearer) || !istype(attached_to))
		return
	var/turf/open/tile = get_turf(wearer)
	if(istype(tile))
		tile.atmos_spawn_air("[GAS_WATER_VAPOR]=50;[TURF_TEMPERATURE(1000)]")
	wearer.balloon_alert(wearer, "overloaded!")
	wearer.visible_message("<span class='danger'>[wearer] [wearer.p_their()] [src] overloads, exploding in a cloud of hot steam!</span>")
	wearer.set_jitter_if_lower(10 SECONDS)
	playsound(wearer, 'sound/effects/spray.ogg', 80)
	detach(attached_to) // safely remove wetsuit status effect
	qdel(src)

/datum/design/vaporizer
	name = "Hydro-Vaporizer"
	id = "vaporizer"
	build_type = AUTOLATHE | PROTOLATHE | AWAY_LATHE
	materials = list(/datum/material/gold = SMALL_MATERIAL_AMOUNT*2.5, /datum/material/silver =SMALL_MATERIAL_AMOUNT*5)
	build_path = /obj/item/clothing/accessory/vaporizer
	category = list(
		RND_CATEGORY_INITIAL,
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL,
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL | DEPARTMENT_BITFLAG_SCIENCE | DEPARTMENT_BITFLAG_SERVICE
