GLOBAL_LIST_INIT(loadout_effects, generate_loadout_items(/datum/loadout_item/effects))

/datum/loadout_item/effects
	category = LOADOUT_ITEM_MISC

/datum/loadout_item/effects/post_equip_item(datum/preferences/preference_source, mob/living/carbon/human/equipper, visuals_only)
	var/obj/item/effect_granter/new_item = new item_path(equipper.loc)
	addtimer(CALLBACK(new_item, TYPE_PROC_REF(/obj/item/effect_granter, grant_effect), equipper), 3 SECONDS)

/datum/loadout_item/effects/honk_platinum
	ckeywhitelist = list("madducks")
	name = "Honk Platinum Transformation"
	item_path = /obj/item/effect_granter/honk_platinum
	requires_purchase = FALSE
