/obj/item/melee/secblade
	name = "security shortblade"
	desc = "A utilitarian weapon, handle and blade, with little more. \
		Designed for ease of blade replacement when it inevitably breaks due to mistreatment."

	icon = 'modular_doppler/modular_weapons/icons/obj/sec_swords.dmi'
	icon_state = "sec_sword"
	lefthand_file = 'modular_doppler/modular_weapons/icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'modular_doppler/modular_weapons/icons/mob/inhands/melee_righthand.dmi'
	inhand_icon_state = "sec_sword"
	icon_angle = -20

	hitsound = 'sound/items/weapons/bladeslice.ogg'
	block_sound = 'sound/items/weapons/parry.ogg'

	obj_flags = CONDUCTS_ELECTRICITY
	sharpness = SHARP_EDGED
	w_class = WEIGHT_CLASS_BULKY
	obj_flags = UNIQUE_RENAME

	force = 18
	throwforce = 10
	block_chance = 1 // Nah, I'd win
	wound_bonus = 0
	bare_wound_bonus = 20

	attack_verb_continuous = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "rend")

	var/list/alt_continuous = list("stabs", "pierces", "impales")
	var/list/alt_simple = list("stab", "pierce", "impale")

/obj/item/melee/secblade/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, speed = 4 SECONDS, effectiveness = 100)
	alt_continuous = string_list(alt_continuous)
	alt_simple = string_list(alt_simple)
	AddComponent(/datum/component/alternative_sharpness, SHARP_POINTY, alt_continuous, alt_simple, -5)

/obj/item/melee/secblade/training
	name = "training shortblade"
	desc = "A utilitarian weapon, handle and blade, with little more. \
		This one doesn't seem completely real, incapable of bloodshed but likely still hurts quite a lot."

	icon_state = "training_sword"

	damtype = STAMINA
	wound_bonus = -50
	bare_wound_bonus = -50
