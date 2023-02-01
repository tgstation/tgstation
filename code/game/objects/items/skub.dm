/obj/item/skub
	desc = "It's skub."
	name = "skub"
	icon = 'icons/obj/weapons/items_and_weapons.dmi'
	icon_state = "skub"
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("skubs")
	attack_verb_simple = list("skub")

/obj/item/skub/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/container_item/tank_holder, "holder_skub", FALSE)

/obj/item/skub/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] has declared themself as anti-skub! The skub tears them apart!"))
	user.gib()
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE, -1)
	return MANUAL_SUICIDE
