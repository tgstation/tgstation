// MARK: New functions
/obj/structure/sign/flag
	buildable_sign = FALSE
	custom_materials = null
	var/foldable_type = /obj/item/sign/flag

/obj/structure/sign/flag/wrench_act(mob/living/user, obj/item/wrench/I)
	return

/obj/structure/sign/flag/welder_act(mob/living/user, obj/item/I)
	return

/obj/structure/sign/flag/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(foldable_type)
		context[SCREENTIP_CONTEXT_RMB] = "Сложить"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/structure/sign/flag/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	return fold(user) ? SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN : .

/obj/structure/sign/flag/proc/fold(mob/user)
	if(!foldable_type)
		return FALSE
	if(!user.can_perform_action(src, FORBID_TELEKINESIS_REACH | NEED_HANDS | NEED_DEXTERITY))
		return FALSE
	user.visible_message(span_notice("[user] складывает [declent_ru(NOMINATIVE)]."), span_notice("Вы складываете [declent_ru(NOMINATIVE)]."))
	var/obj/item/flag_item = new foldable_type(loc)
	TransferComponents(flag_item)
	user.put_in_hands(flag_item)
	qdel(src)
	return TRUE

// MARK: The old ones with new sprites
/obj/structure/sign/flag/nanotrasen
	icon = 'modular_bandastation/objects/icons/obj/structures/flags.dmi'
	foldable_type = /obj/item/sign/flag/nanotrasen

/obj/structure/sign/flag/ssc
	icon = 'modular_bandastation/objects/icons/obj/structures/flags.dmi'
	foldable_type = /obj/item/sign/flag/ssc

/obj/structure/sign/flag/terragov
	icon = 'modular_bandastation/objects/icons/obj/structures/flags.dmi'
	foldable_type = /obj/item/sign/flag/terragov

/obj/structure/sign/flag/tizira
	icon = 'modular_bandastation/objects/icons/obj/structures/flags.dmi'
	foldable_type = /obj/item/sign/flag/tizira

/obj/structure/sign/flag/mothic
	icon = 'modular_bandastation/objects/icons/obj/structures/flags.dmi'
	foldable_type = /obj/item/sign/flag/mothic

/obj/structure/sign/flag/mars
	icon = 'modular_bandastation/objects/icons/obj/structures/flags.dmi'
	foldable_type = /obj/item/sign/flag/mars

// MARK: New flags
/obj/structure/sign/flag/syndicate
	name = "flag of the Syndicate"
	desc = "Флаг Синдиката. Ранее использовался как способ заявить о противостоянии Нанотрейзен, а теперь стал межгалактическим символом с той же, но гораздо более искаженной целью, поскольку все больше заинтересованных групп перешли на сторону повстанцев ради собственной выгоды."
	icon = 'modular_bandastation/objects/icons/obj/structures/flags.dmi'
	icon_state = "flag_syndi"
	foldable_type = /obj/item/sign/flag/syndicate

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/flag/syndicate, 32)

/obj/structure/sign/flag/ussp
	name = "flag of the Union of Soviet Socialist Planets"
	desc = "Официальный государственный флаг Союза Советских Социалистических Планет."
	icon = 'modular_bandastation/objects/icons/obj/structures/flags.dmi'
	icon_state = "flag_ussp"
	foldable_type = /obj/item/sign/flag/ussp

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/sign/flag/ussp, 32)

// MARK: Items
/obj/item/sign/flag
	name = "folded flag of the IT Division"
	desc = "Сложенный флаг IT-подразделения компании Нанотрейзен."
	icon = 'modular_bandastation/objects/icons/obj/structures/flags.dmi'
	icon_state = "folded_coder"
	sign_path = /obj/structure/sign/flag
	is_editable = FALSE

/// Since all of the signs rotate themselves on initialisation, this made folded flags look ugly (and more importantly rotated).
/// And thus, it gets removed to make them aesthetically pleasing once again.
/obj/item/sign/flag/Initialize(mapload)
	. = ..()
	transform = matrix()

/obj/item/sign/flag/welder_act(mob/living/user, obj/item/I)
	return

/obj/item/sign/flag/nanotrasen
	name = "folded flag of the Nanotrasen"
	desc = "Сложенный флаг компании Нанотрейзен."
	icon_state = "folded_nt"
	sign_path = /obj/structure/sign/flag/nanotrasen

/obj/item/sign/flag/ssc
	name = "folded flag of the Spinward Stellar Coalition"
	desc = "Сложенный флаг Независимой Коалиции Сектора Спинвард."
	icon_state = "folded_ssc"
	sign_path = /obj/structure/sign/flag/ssc

/obj/item/sign/flag/terragov
	name = "folded flag of Trans-Solar Federation"
	desc = "Сложенный флаг Транс-Солнечной Федерации."
	icon_state = "folded_terragov"
	sign_path = /obj/structure/sign/flag/terragov

/obj/item/sign/flag/tizira
	name = "folded flag of the Tiziran Empire"
	desc = "Сложенный флаг Великой империи Тизира."
	icon_state = "folded_tizira"
	sign_path = /obj/structure/sign/flag/tizira

/obj/item/sign/flag/mothic
	name = "folded flag of the Grand Nomad Fleet"
	desc = "Сложенный флаг Гранд-Номадского флота Мотылька."
	icon_state = "folded_mothic"
	sign_path = /obj/structure/sign/flag/mothic

/obj/item/sign/flag/mars
	name = "folded flag of the Martian Republic"
	desc = "Сложенный флаг Марса."
	icon_state = "folded_mars"
	sign_path = /obj/structure/sign/flag/mars

/// MARK: New flag items
/obj/item/sign/flag/syndicate
	name = "folded flag of the Syndicate"
	desc = "Сложенный флаг Синдиката."
	icon_state = "folded_syndi"
	sign_path = /obj/structure/sign/flag/syndicate

/obj/item/sign/flag/ussp
	name = "folded flag of the USSP"
	desc = "Сложенный флаг Союза Советских Социалистических Планет."
	icon_state = "folded_ussp"
	sign_path = /obj/structure/sign/flag/ussp
