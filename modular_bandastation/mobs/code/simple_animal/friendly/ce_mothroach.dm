/mob/living/basic/mothroach/ce_mothroach
	name = "chiefroach"
	desc = "Мольтаракан в каске Главного инженера. Выглядит крайне важным."
	icon = 'modular_bandastation/mobs/icons/animal.dmi'
	icon_state = "ce_mothroach"
	icon_living = "ce_mothroach"
	icon_dead = "ce_mothroach_dead"
	held_state = "mothroach"
	held_lh = 'icons/mob/inhands/animal_item_lefthand.dmi'
	held_rh = 'icons/mob/inhands/animal_item_righthand.dmi'
	head_icon = 'modular_bandastation/mobs/icons/inhead/head.dmi'
	butcher_results = list(/obj/item/food/meat/slab/mothroach = 3, /obj/item/stack/sheet/animalhide/mothroach = 1)
	gold_core_spawnable = FRIENDLY_SPAWN
