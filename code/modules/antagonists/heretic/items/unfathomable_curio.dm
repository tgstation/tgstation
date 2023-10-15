//Item for knock/moon heretic sidepath, it can block one hit of damage, acts as storage and if the heretic is examined the examiner suffers brain damage and confusion

/obj/item/unfathomable_curio
	name = "Unfathomable Curio"
	desc = "It. It looks backs. It looks past. It looks in. It sees. It shields. It opens."
	icon = 'icons/obj/antags/eldritch.dmi'
	base_icon_state = "book"
	icon_state = "book"
	worn_icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/unfathomable_curio/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/pockets/void_cloak/unfathomable_curio)


/obj/item/codex_cicatrix/examine(mob/living/carbon/human/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 40, 160)
	user.adjust_confusion(user.get_organ_loss(ORGAN_SLOT_BRAIN)/10 SECONDS)
