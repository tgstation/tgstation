/obj/item/melee/katana_tsf
	name = "Дыхание Ночи"
	desc = "Неоновая энергетическая катана синего цвета, сделанная в лучших традициях современных мастеров-мечников Транс-Солнечной Федерации."
	icon = 'modular_bandastation/weapon/icons/melee/sword.dmi'
	icon_state = "katana_tsf"
	inhand_icon_state = "katana_tsf"
	icon_angle = 35
	lefthand_file = 'modular_bandastation/weapon/icons/melee/inhands/lefthand.dmi'
	righthand_file = 'modular_bandastation/weapon/icons/melee/inhands/righthand.dmi'
	worn_icon = 'modular_bandastation/weapon/icons/melee/sword_onmob.dmi'
	worn_icon_state = "katana_tsf"
	light_system = OVERLAY_LIGHT
	light_range = 2
	light_color = LIGHT_COLOR_LIGHT_CYAN
	slot_flags = ITEM_SLOT_BELT
	force = 25
	armour_penetration = 70
	block_chance = 60
	throwforce = 30
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hitsound = 'modular_bandastation/weapon/sound/melee/tsf_katana_hit.ogg'
	pickup_sound = 'modular_bandastation/weapon/sound/melee/tsf_katana_unsheath.ogg'
	drop_sound = 'modular_bandastation/weapon/sound/melee/tsf_katana_sheath.ogg'
	block_sound = 'modular_bandastation/weapon/sound/melee/tsf_katana_block.ogg'
	attack_verb_continuous = list("attacks", "slashes", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP_EDGED

/obj/item/melee/katana_tsf/afterattack(atom/target, mob/user, list/modifiers)
	if(isliving(target) && (prob(50)))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/void_chill, 3)

/obj/item/melee/katana_tsf/examine(mob/user)
	. = ..()
	. += span_notice("Вы можете <b>изучить подробнее</b>, чтобы узнать немного больше об этом оружии.")

/obj/item/melee/katana_tsf/examine_more(mob/user)
	. = ..()

	. += "Является уникальной в своём роде, благодаря добавлению в качестве материала блюспэйс-кристаллов. \
		Небольшие их вкрапления находятся в гарде и рукоятке, основная же, заряженная часть - непосредственно составляет само лезвие. \
		Основа сделана из закаленной стали прямиком с Адомая, являющаяся самой крепкой в Галактике. \
		Энергия кристаллов настолько сжалась внутри клинка, что вы чувствуете очень пронзительный холод, едва только прикоснувшись к этому лезвию. \
		Судя по всему, он позволяет замораживать своих обидчиков по нанесению серии ударов, при этом проходя через их броню, как нож сквозь масло. \
		Легкость рукоятки, сделанной из плазменного полимера, позволяет наносить удары с завидной быстротой. \
		Этот клинок - настоящее воплощение холодного нрава его владельца. \
		Надпись на рукояти гласит - \"Перед вами один из двух образцов гениальных творений мастера Фигерса - сделанных по заказу Мистера К.\""

	return .
