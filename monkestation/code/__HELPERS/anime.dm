/proc/is_cat_enough(mob/living/user, include_all_anime = FALSE)
	. = FALSE
	if(iscat(user)) // there's nothing more cat than a cat
		return TRUE
	if(include_all_anime && HAS_TRAIT(user, TRAIT_ANIME))
		return TRUE
	if(HAS_TRAIT(user, TRAIT_CAT))
		return TRUE
	if(istype(user.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/kitty)) // combine with glue for hilarity
		return TRUE
	var/obj/item/organ/external/anime_head/anime_head = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_ANIME_HEAD)
	var/obj/item/organ/external/anime_bottom/anime_bottom = user.get_organ_slot(ORGAN_SLOT_EXTERNAL_ANIME_BOTTOM)
	if(istype(anime_head?.bodypart_overlay?.sprite_datum, /datum/sprite_accessory/anime_head/cat) && istype(anime_bottom?.bodypart_overlay?.sprite_datum, /datum/sprite_accessory/anime_bottom/cat)) // cat ears AND tail? aight then, you're very much cat
		return TRUE
