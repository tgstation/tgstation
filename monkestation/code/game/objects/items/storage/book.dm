/obj/item/storage/book/bible/mini
	//Grif
	name = "O.C. Bible"
	desc = "For when you don't want the good book to take up too much space in your life, its so small you can hide it under floors."
	icon = 'monkestation/icons/obj/items/storage.dmi'
	icon_state = "minibible"
	worn_icon_state = null
	inhand_icon_state = null
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/book/bible/mini/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, INVISIBILITY_OBSERVER, use_anchor = TRUE)
