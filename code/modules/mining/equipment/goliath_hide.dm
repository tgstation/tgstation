
/obj/item/stack/sheet/animalhide/goliath_hide
	name = "goliath hide plates"
	desc = "Pieces of a goliath's rocky hide, these might be able to make your suit a bit more durable to attack from the local fauna."
	icon = 'icons/obj/mining.dmi'
	icon_state = "goliath_hide"
	flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_NORMAL
	layer = MOB_LAYER

/obj/item/stack/sheet/animalhide/goliath_hide/afterattack(atom/target, mob/user, proximity_flag)
	if(proximity_flag)
		if(istype(target, /obj/item/clothing/suit/space/hardsuit/mining) || istype(target, /obj/item/clothing/head/helmet/space/hardsuit/mining) ||  istype(target, /obj/item/clothing/suit/hooded/explorer) || istype(target, /obj/item/clothing/head/hooded/explorer))
			var/obj/item/clothing/C = target
			var/list/current_armr = C.armr
			if(current_armr.["melee"] < 60)
				current_armr.["melee"] = min(current_armr.["melee"] + 10, 60)
				to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
				use(1)
			else
				to_chat(user, "<span class='warning'>You can't improve [C] any further!</span>")
				return
		if(istype(target, /obj/mecha/working/ripley))
			var/obj/mecha/working/ripley/D = target
			if(D.hides < 3)
				D.hides++
				D.armr["melee"] = min(D.armr["melee"] + 10, 70)
				D.armr["bullet"] = min(D.armr["bullet"] + 5, 50)
				D.armr["laser"] = min(D.armr["laser"] + 5, 50)
				to_chat(user, "<span class='info'>You strengthen [target], improving its resistance against melee attacks.</span>")
				D.update_icon()
				if(D.hides == 3)
					D.desc = "Autonomous Power Loader Unit. It's wearing a fearsome carapace entirely composed of goliath hide plates - its pilot must be an experienced monster hunter."
				else
					D.desc = "Autonomous Power Loader Unit. Its armr is enhanced with some goliath hide plates."
				qdel(src)
			else
				to_chat(user, "<span class='warning'>You can't improve [D] any further!</span>")
				return
