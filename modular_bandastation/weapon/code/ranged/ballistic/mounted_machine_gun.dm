/obj/item/mounted_machine_gun_folded
	name = "folded M2T9 mounted machine gun"
	desc = "Сложенный и разряженный станковый пулемет, готовый к развертыванию и использованию."
	icon = 'modular_bandastation/weapon/icons/ranged/turret_objects.dmi'
	icon_state = "folded_hmg"
	max_integrity = 250
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK

/obj/item/mounted_machine_gun_folded/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, 5 SECONDS, /obj/machinery/deployable_turret/mounted_machine_gun)

/obj/machinery/deployable_turret/mounted_machine_gun
	name = "M2T9 Mounted Machine Gun"
	desc = "Крупнокалиберный станковый пулемет, способный вести огонь на подавление."
	icon = 'modular_bandastation/weapon/icons/ranged/turret.dmi'
	icon_state = "mmg"
	base_icon_state = "mmg"
	max_integrity = 250
	projectile_type = /obj/projectile/bullet/p50/mmg
	anchored = TRUE
	number_of_shots = 4
	cooldown_duration = 1 SECONDS
	rate_of_fire = 2
	firesound = 'modular_bandastation/weapon/sound/ranged/50cal_fire.ogg'
	overheatsound = 'sound/effects/wounds/sizzle2.ogg'
	can_be_undeployed = TRUE
	spawned_on_undeploy = /obj/item/mounted_machine_gun_folded
	SET_BASE_PIXEL(-8, -8)
	always_anchored = TRUE

/obj/item/mounted_machine_gun_folded/full_auto/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, 5 SECONDS, /obj/machinery/deployable_turret/mounted_machine_gun/full_auto)

/obj/machinery/deployable_turret/mounted_machine_gun/full_auto
	number_of_shots = 1
	cooldown_duration = 1 SECONDS
	rate_of_fire = 1
	spawned_on_undeploy = /obj/item/mounted_machine_gun_folded/full_auto

/obj/machinery/deployable_turret/mounted_machine_gun/full_auto/stationary
	can_be_undeployed = FALSE

/obj/machinery/deployable_turret/mounted_machine_gun/full_auto/checkfire(atom/targeted_atom, mob/user)
	target = targeted_atom
	if(target == user || target == get_turf(src))
		return
	target_turf = get_turf(target)
	fire_helper(user)

// KORD

/obj/item/mounted_machine_gun_folded/volna
	name = "folded 'Volna-15' mounted machine gun"
	desc = "Сложенный и разряженный станковый пулемет СССП калибра 12.7x108мм, готовый к развертыванию и использованию."
	icon = 'modular_bandastation/weapon/icons/ranged/turret_objects.dmi'
	icon_state = "folded_hmg_volna"
	worn_icon_state = "folded_hmg"
	lefthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/ranged/inhands/ballistic/righthand.dmi'
	inhand_icon_state = "volna"

/obj/item/mounted_machine_gun_folded/volna/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, 5 SECONDS, /obj/machinery/deployable_turret/mounted_machine_gun/volna)

/obj/machinery/deployable_turret/mounted_machine_gun/volna
	name = "'Volna-15' Mounted Machine Gun"
	desc = "Крупнокалиберный станковый пулемет СССП калибра 12.7x108мм, способный вести огонь на подавление."
	icon_state = "volna"
	base_icon_state = "volna"
	projectile_type = /obj/projectile/bullet/c127x108mm
	number_of_shots = 4
	cooldown_duration = 1 SECONDS
	rate_of_fire = 2
	firesound = 'modular_bandastation/weapon/sound/ranged/dshk.ogg'
	spawned_on_undeploy = /obj/item/mounted_machine_gun_folded/volna

/obj/item/mounted_machine_gun_folded/volna/full_auto/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, 5 SECONDS, /obj/machinery/deployable_turret/mounted_machine_gun/volna/full_auto)

/obj/machinery/deployable_turret/mounted_machine_gun/volna/full_auto
	number_of_shots = 1
	cooldown_duration = 1 SECONDS
	rate_of_fire = 1
	spawned_on_undeploy = /obj/item/mounted_machine_gun_folded/volna/full_auto

/obj/machinery/deployable_turret/mounted_machine_gun/volna/full_auto/stationary
	can_be_undeployed = FALSE

/obj/machinery/deployable_turret/mounted_machine_gun/volna/full_auto/checkfire(atom/targeted_atom, mob/user)
	target = targeted_atom
	if(target == user || target == get_turf(src))
		return
	target_turf = get_turf(target)
	fire_helper(user)

/obj/machinery/deployable_turret/hmg
	name = "CM90 heavy laser machine gun"
	desc = "Тяжелый лазерный пулемет часто используемый силами Нанотрейзен, известен своей способностью оставлять у получателей больше дыр, чем обычно."
	projectile_type = /obj/projectile/beam/laser/flare
	number_of_shots = 4
	cooldown_duration = 1 SECONDS
	rate_of_fire = 2
