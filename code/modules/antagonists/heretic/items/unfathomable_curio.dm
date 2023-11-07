//Item for knock/moon heretic sidepath, it can block 5 hits of damage, acts as storage and if the heretic is examined the examiner suffers brain damage and blindness

/obj/item/storage/belt/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "It. It looks backs. It looks past. It looks in. It sees. It hides. It opens."
	icon_state = "unfathomable_curio"
	worn_icon_state = "unfathomable_curio"
	content_overlays = FALSE
	custom_premium_price = PAYCHECK_CREW * 2
	drop_sound = 'sound/items/handling/toolbelt_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbelt_pickup.ogg'

/obj/item/storage/belt/unfathomable_curio/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 21
	atom_storage.set_holdable(list(
		/obj/item/ammo_box/strilka310/lionhunter,
		/obj/item/bodypart, // Bodyparts are often used in rituals.
		/obj/item/clothing/neck/eldritch_amulet,
		/obj/item/clothing/neck/heretic_focus,
		/obj/item/codex_cicatrix,
		/obj/item/eldritch_potion,
		/obj/item/food/grown/poppy, // Used to regain a Living Heart.
		/obj/item/food/grown/harebell, // Used to reroll targets
		/obj/item/melee/rune_carver,
		/obj/item/melee/sickly_blade,
		/obj/item/organ, // Organs are also often used in rituals.
		/obj/item/reagent_containers/cup/beaker/eldritch,
		/obj/item/stack/sheet/glass, // Glass is often used by moon heretics
	))


/obj/item/storage/belt/unfathomable_curio/Initialize(mapload)
	. = ..()
	//Vars used for the shield component
	var/heretic_shield_icon = "unfathomable_shield"
	var/max_charges = 1
	var/recharge_start_delay = 60 SECONDS
	var/charge_increment_delay = 60 SECONDS
	var/charge_recovery = 1

	AddComponent(/datum/component/shielded, max_charges = max_charges, recharge_start_delay = recharge_start_delay, charge_increment_delay = charge_increment_delay, \
	charge_recovery = charge_recovery, shield_icon = heretic_shield_icon)


/obj/item/storage/belt/unfathomable_curio/equipped(mob/user, slot, initial)
	. = ..()
	if(!(slot & slot_flags))
		return
	if(!IS_HERETIC(user))
		to_chat(user, span_warning("I wouldn't do that..."))
		user.dropItemToGround(src, TRUE)
		return



/obj/item/storage/belt/unfathomable_curio/examine(mob/living/carbon/user)
	. = ..()
	if(IS_HERETIC(user))
		return

	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 160)
	user.adjust_temp_blindness(5 SECONDS)
	. += span_notice("It. It looked. IT WRAPS ITSELF AROUND ME.")


