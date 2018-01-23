/**********************Goliath Hide**********************/
/obj/item/stack/sheet/animalhide/goliath_hide
	name = "goliath hide plates"
	desc = "Pieces of a goliath's rocky hide, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon = 'icons/obj/mining.dmi'
	icon_state = "goliath_hide"
	singular_name = "hide plate"
	max_amount = 6
	novariants = FALSE
	flags_1 = NOBLUDGEON_1
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER
	var/static/list/goliath_platable_armor_typecache = typecacheof(list(
	/obj/item/clothing/head/helmet/space/hardsuit/mining,
	/obj/item/clothing/suit/space/hardsuit/mining,
	/obj/item/clothing/head/hooded/explorer,
	/obj/item/clothing/suit/hooded/explorer))

/obj/item/stack/sheet/animalhide/goliath_hide/afterattack(atom/target, mob/user, proximity_flag)
	if(!proximity_flag)
		return
	if(is_type_in_typecache(target, goliath_platable_armor_typecache))
		var/obj/item/clothing/C = target
		if(armor.melee < 60)
			armor = armor.setRating(melee = min(armor.melee + 10, 60))
			to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
			use(1)
		else
			to_chat(user, "<span class='warning'>You can't improve [C] any further!</span>")
	else if(istype(target, /obj/mecha/working/ripley))
		var/obj/mecha/working/ripley/D = target
		if(D.hides < 3)
			D.hides++
			D.armor = D.armor.setRating(\
				melee = min(D.armor.melee + 10, 70),\
				bullet = min(D.armor.laser + 5, 50),\
				laser = min(D.armor.laser + 5, 50))
			to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
			D.update_icon()
			if(D.hides == 3)
				D.desc = "Autonomous Power Loader Unit. It's wearing a fearsome carapace entirely composed of goliath hide plates - its pilot must be an experienced monster hunter."
			else
				D.desc = "Autonomous Power Loader Unit. Its armour is enhanced with some goliath hide plates."
			use(1)
		else
			to_chat(user, "<span class='warning'>You can't improve [D] any further!</span>")
