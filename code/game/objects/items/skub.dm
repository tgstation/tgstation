/obj/item/skub
	desc = "It's skub."
	name = "skub"
	icon = 'icons/obj/maintenance_loot.dmi'
	icon_state = "skub"
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("skubs")
	attack_verb_simple = list("skub")

/obj/item/skub/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/container_item/tank_holder, "holder_skub", FALSE)

/obj/item/skub/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] has declared themself as anti-skub! The skub tears them apart!"))
	user.gib(DROP_ALL_REMAINS)
	PLAYSOUND(src, 'sound/items/eatfood.ogg').volume(50).vary_frequency(TRUE).range(-1 + SOUND_RANGE).play()
	return MANUAL_SUICIDE
