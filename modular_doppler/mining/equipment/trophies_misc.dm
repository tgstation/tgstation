//1k points
/obj/item/crusher_trophy/skill_check
	name = "kinesics-checker"
	desc = "An upgrade for the already-clunky crusher. Uses a momentum-storage system to turn power from swings into devastating detonations. Also called the skill checker."
	icon = 'icons/obj/devices/circuitry_n_data.dmi'
	icon_state = "circuit_map"
	denied_type = /obj/item/crusher_trophy/skill_check
	bonus_value = 10

/obj/item/crusher_trophy/skill_check/effect_desc()
	return "<b>doubles your extra backstab detonation damage</b>"

/obj/item/crusher_trophy/skill_check/add_to(obj/item/kinetic_crusher/pkc, mob/living/user)
	. = ..()

	pkc.detonation_damage *=0.8
	pkc.backstab_bonus *= 2

/obj/item/crusher_trophy/skill_check/remove_from(obj/item/kinetic_crusher/pkc, mob/living/user)
	. = ..()

	pkc.detonation_damage /=0.8
	pkc.backstab_bonus /= 2


/datum/orderable_item/mining/skill_check
	purchase_path = /obj/item/crusher_trophy/skill_check
	cost_per_order = 450