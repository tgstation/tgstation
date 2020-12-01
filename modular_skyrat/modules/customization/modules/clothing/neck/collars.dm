/datum/component/storage/concrete/pockets/small/collar
	max_items = 1

/datum/component/storage/concrete/pockets/small/collar/Initialize()
	. = ..()
	can_hold = typecacheof(list(
	/obj/item/food/cookie,
	/obj/item/food/cookie/sugar))

/datum/component/storage/concrete/pockets/small/collar/locked/Initialize()
	. = ..()
	can_hold = typecacheof(list(
	/obj/item/food/cookie,
	/obj/item/food/cookie/sugar))

/obj/item/clothing/neck/human_petcollar
	icon = 'modular_skyrat/modules/customization/icons/obj/clothing/neck.dmi'
	worn_icon = 'modular_skyrat/modules/customization/icons/mob/clothing/neck.dmi'
	name = "pet collar"
	desc = "It's for pets. Though you probably could wear it yourself, you'd doubtless be the subject of ridicule. It seems to be made out of a polychromic material."
	icon_state = "petcollar"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small/collar
	var/poly_states = 1
	var/poly_colors = list("#00BBBB")
	var/tagname = null
	var/treat_path = /obj/item/food/cookie

/obj/item/clothing/neck/human_petcollar/Initialize()
	. = ..()
	if(treat_path)
		new treat_path(src)

/obj/item/clothing/neck/human_petcollar/ComponentInitialize()
	. = ..()
	if(!poly_states)
		return
	//AddElement(/datum/element/polychromic, poly_colors, poly_states)

/obj/item/clothing/neck/human_petcollar/attack_self(mob/user)
	tagname = stripped_input(user, "Would you like to change the name on the tag?", "Input the tag's name.", "Spot", MAX_NAME_LEN)
	name = "[initial(name)] - [tagname]"

/obj/item/clothing/neck/human_petcollar/leather
	name = "leather pet collar"
	icon_state = "leathercollar"
	poly_states = 2
	poly_colors = list("#222222", "#888888")

/obj/item/clothing/neck/human_petcollar/choker
	desc = "Quite fashionable... if you're somebody who's just read their first BDSM-themed erotica novel."
	name = "choker"
	icon_state = "choker"
	poly_colors = list("#222222")

