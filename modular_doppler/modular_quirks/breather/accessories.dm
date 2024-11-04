/obj/item/clothing/accessory/breathing
	name = "breathing dogtag"
	desc = "A dogtag which labels what kind of gas a person may breathe."
	icon_state = "allergy"
	above_suit = FALSE
	attachment_slot = NONE
	var/breath_type

/obj/item/clothing/accessory/breathing/examine(mob/user)
	. = ..()
	. += "The dogtag reads: I breathe [breath_type]."

/obj/item/clothing/accessory/breathing/accessory_equipped(obj/item/clothing/under/uniform, user)
	. = ..()
	RegisterSignal(user, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/obj/item/clothing/accessory/breathing/accessory_dropped(obj/item/clothing/under/uniform, user)
	. = ..()
	UnregisterSignal(user, COMSIG_ATOM_EXAMINE)

/obj/item/clothing/accessory/breathing/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/accessory_wearer = user
	examine_list += "[accessory_wearer.p_Their()] <b>[name]</b> reads: 'I breathe [breath_type]'."


// Accessory for Akula species, it makes them wet and happy! :)
/obj/item/clothing/accessory/vaporizer
	name = "\improper Stardress hydro-vaporizer"
	desc = "An expensive device manufactured for the civilian work-force of the Azulean military power. \
	Relying on an internal battery, the coil mechanism synthesizes a hydrogen oxygen mixture, \
	which can then be used to moisturize the wearer's skin. \n\n\
	<i>A label on its back warns about the potential dangers of electro-magnetic pulses.</i> \n\
	<b>ctrl-click</b> in-hand to hide the device while worn. \n\
	Can also be worn inside of a pocket."
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

/mob/living/carbon/human/emp_act(severity) // necessary to still emp when worn as accessory
	. = ..()
	var/obj/item/clothing/under/worn_uniform = w_uniform
	if(w_uniform)
		for(var/obj/item/clothing/accessory/vaporizer/vaporizer in worn_uniform.attached_accessories)
			vaporizer.on_emp()
			break

/obj/item/clothing/accessory/vaporizer/emp_act(severity)
	. = ..()
	var/turf/open/tile = get_turf(src)
	var/list/victims = get_hearers_in_view(4, tile)
	if(istype(tile))
		tile.atmos_spawn_air("[GAS_WATER_VAPOR]=50;[TURF_TEMPERATURE(1000)]")
	tile.balloon_alert_to_viewers("overloaded!")
	tile.visible_message("<span class='danger'>[src] overloads, exploding in a cloud of hot steam!</span>")
	playsound(tile, 'sound/effects/spray.ogg', 80)
	for(var/mob/living/collateral in victims)
		collateral.set_jitter_if_lower(15 SECONDS)
		collateral.set_eye_blur_if_lower(5 SECONDS)
	qdel(src)

/obj/item/clothing/accessory/vaporizer/proc/on_emp()
	var/obj/item/clothing/under/attached_to = loc
	detach(attached_to) // safely remove wetsuit status effect
	emp_act(EMP_LIGHT)

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
