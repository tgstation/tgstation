
///basic bow, used for medieval sim
/obj/item/gun/ballistic/bow/longbow
	name = "longbow"
	desc = "While pretty finely crafted, surely you can find something better to use in the current year."
	icon_state = "bow"
	inhand_icon_state = "bow"
	base_icon_state = "bow"
	accepted_arrow_type = /obj/item/ammo_casing/caseless/arrow

/obj/item/gun/ballistic/bow/divine
	name = "divine bow"
	desc = "Holy armament to pierce the souls of sinners."
	accepted_arrow_type = /obj/item/ammo_casing/caseless/arrow/holy

/obj/item/gun/ballistic/bow/divine/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You disrupt the magic of %THEEFFECT with %THEWEAPON.", \
		success_forcesay = "BEGONE FOUL MAGIKS!!", \
		tip_text = "Clear rune", \
		on_clear_callback = CALLBACK(src, PROC_REF(on_cult_rune_removed)), \
		effects_we_clear = list(/obj/effect/rune, /obj/effect/heretic_rune) \
	)
	AddElement(/datum/element/bane, target_type = /mob/living/simple_animal/revenant, damage_multiplier = 0, added_damage = 25, requires_combat_mode = FALSE)
