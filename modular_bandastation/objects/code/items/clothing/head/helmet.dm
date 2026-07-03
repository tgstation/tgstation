/obj/item/clothing/head/helmet/biker_helmet
	name = "biker helmet"
	desc = "Крутой шлем."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'
	icon_state = "bike_helmet"
	base_icon_state = "bike_helmet"
	inhand_icon_state = "bike_helmet"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	actions_types = list(/datum/action/item_action/toggle_helmet)
	flags_cover = HEADCOVERSEYES|EARS_COVERED
	dog_fashion = null
	var/on = TRUE

/obj/item/clothing/head/helmet/biker_helmet/replica
	desc = "Крутой шлем. На вид хлипкий..."

/obj/item/clothing/head/helmet/biker_helmet/ui_action_click(mob/user, toggle_helmet)
	helm_toggle(user)

/obj/item/clothing/head/helmet/biker_helmet/update_icon_state()
	icon_state = "[base_icon_state][on ? null : "_up" ]"
	if (on)
		flags_cover &= ~HEADCOVERSEYES
	else
		flags_cover |= HEADCOVERSEYES
	return ..()

/obj/item/clothing/head/helmet/biker_helmet/proc/helm_toggle(mob/user)
	on = !on
	update_icon_state()
	update_appearance()

/obj/item/clothing/head/helmet/space/hardsuit/security
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'
	icon_state = "hardsuit0-sec"

// MARK: ERT
/obj/item/clothing/head/helmet/plate/crusader/ert
	name = "ERT crusader's hood"
	desc = "Усовершенствованный капюшон для крестовых походов против ереси, состоящий из освященного нанометалла и ткани. Обеспечивает очень хорошую защиту от еретиков и нечисти."
	resistance_flags = FIRE_PROOF

/obj/item/clothing/head/helmet/ntci_helmet
	name = "tactical helmet"
	desc = "Облегчённый военный шлем с проверенным временем дизайном. Использование современных технологий обеспечивает защиту от осколков и винтовочных калибров."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'
	icon_state = "ntci_helmet"
	base_icon_state = "ntci_helmet"
	armor_type = /datum/armor/pmc
	clothing_flags = STACKABLE_HELMET_EXEMPT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	hair_mask = /datum/hair_mask/standard_hat_middle
	flags_inv = null
	dog_fashion = null
	sound_vary = TRUE
	equip_sound = 'sound/items/handling/helmet/helmet_equip1.ogg'
	pickup_sound = 'sound/items/handling/helmet/helmet_pickup1.ogg'
	drop_sound = 'sound/items/handling/helmet/helmet_drop1.ogg'

/obj/item/clothing/head/helmet/ntci_helmet/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/seclite_attachable, light_icon_state = "flight")

// MARK: USSP
/obj/item/clothing/head/helmet/marine/ussp_officer_kaska
	name = "komandir kaska"
	desc = "Солдатская пласталевая каска бойцов армии СССП, но с чёткими опознавательными знаками командира отряда. \
		Защищает так, как должна по ГОСТу, главное верить и не задавать вопросов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	icon_state = "ussp_command"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'
	base_icon_state = "ussp_command"

/obj/item/clothing/head/helmet/marine/security/ussp_kaska
	name = "heavy kaska"
	desc = "Солдатская пласталевая каска бойцов армии СССП, но чуть тяжелее чем другие. \
		Защищает так, как должна по ГОСТу, но возможно чуть лучше так как общита дополнительным слоем стали, главное верить."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	icon_state = "ussp_security"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'
	base_icon_state = "ussp_security"

/obj/item/clothing/head/helmet/marine/security/ussp_kaska/medic
	desc = "Солдатская пласталевая каска бойцов армии СССП, но с чёткими опознавательными знаками медика. \
		Защищает так, как должна по ГОСТу, но защиту от военных преступлений не предоставляет."
	icon_state = "ussp_medic"
	base_icon_state = "ussp_medic"

/obj/item/clothing/head/helmet/toggleable/riot/ussp_riot
	name = "OMON helmet"
	desc = "Тяжелый шлем с забралом для групп быстрого реагирования \"ОМОН\", состоит из многослойного арамида и пластали. \
		Отлично защищает от колюще-режущих и ударных повреждений."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	icon_state = "ussp_riot"
	base_icon_state = "ussp_riot"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'

/obj/item/clothing/head/helmet/toggleable/riot/ussp_heavy
	name = "'Altyn' helmet"
	desc = "Тяжелый шлем \"Алтын\" с забралом советского производства, состоит из усиленных сплавов титана и пластали. \
		Отлично защищает от любых повреждений, особенно от пуль. Вам кажется, что будет очень стильно если его покрасить в черный с тремя белыми полосками."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	icon_state = "ussp_altyn"
	base_icon_state = "ussp_altyn"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'
	armor_type = /datum/armor/armor_heavy
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/helmet/space/ussp_expedition
	name = "'Voskhod' EVA suit helmet"
	desc = "Гермошлем экспедиционного скафандра \"Восход\", создан для использования в космических экспедицях СССП. \
		Имеет небольшое бронепокрытие для обеспечения защиты в потенциально враждебных сценариях."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/helmet.dmi'
	icon_state = "voskhod_helmet"
	armor_type = /datum/armor/head_helmet

// MARK: TSF
/obj/item/clothing/head/helmet/marine/security/tsf_heavy
	name = "'Juggernaut' helmet"
	desc = "Тяжелый бронированный шлем ТСФ, состоит из усиленных сплавов титана и пластали. \
		Отлично защищает от любых повреждений, особенно от пуль. Для самых серьезных защитников Федерации."
	heat_protection = HEAD
	max_heat_protection_temperature = SPACE_HELM_MAX_TEMP_PROTECT
	armor_type = /datum/armor/armor_heavy
	clothing_traits = list(TRAIT_HEAD_INJURY_BLOCKED)
