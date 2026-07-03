// MARK: Armor //

// CentCom
/obj/item/clothing/suit/armor/centcom_formal/field
	name = "field officer's tunic"
	desc = "Строгое и надежное армированное пальто для тяжелой работы непосредственно на объектах Компании. Не пропитывается кровью."
	icon_state = "centcom_field_officer"
	inhand_icon_state = "centcom_field"

/obj/item/clothing/suit/armor/centcom_formal/officer
	name = "fleet officer's greatcoat"
	desc = "Удобный мундир для повседневного ношения."
	icon_state = "centcom_officer"

// Blueshield
/datum/atom_skin/blueshield_armor
	abstract_type = /datum/atom_skin/blueshield_armor
	change_inhand_icon_state = TRUE
	change_base_icon_state = TRUE

/datum/atom_skin/blueshield_armor/slim
	preview_name = "Slim"
	new_icon_state = "blueshield_armor"

/datum/atom_skin/blueshield_armor/marine
	preview_name = "Marine"
	new_icon_state = "blueshield_marine"

/datum/atom_skin/blueshield_armor/bulky
	preview_name = "Bulky"
	new_icon_state = "vest_black"

/obj/item/clothing/suit/armor/vest/blueshield
	name = "blueshield's armor"
	desc = "A tight-fitting kevlar-lined vest with a blue badge on the chest of it."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	icon_state = "blueshield_armor"
	body_parts_covered = CHEST

/obj/item/clothing/suit/armor/vest/blueshield/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/reskinable_item, /datum/atom_skin/blueshield_armor)

/obj/item/clothing/suit/armor/vest/blueshield_jacket
	name = "blueshield's jacket"
	desc = "An expensive kevlar-lined jacket with a golden badge on the chest and \"NT\" emblazoned on the back. It weighs surprisingly little, despite how heavy it looks."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	icon_state = "blueshield"
	body_parts_covered = CHEST|ARMS

/obj/item/clothing/suit/armor/vest/blueshield_jacket/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

// Security
/obj/item/clothing/suit/armor/vest/bomber
	name = "security bomber"
	desc = "Стильная черная куртка-бомбер, украшенная красной полосой слева. Выглядит сурово."
	icon_state = "bombersec"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/bomber/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/toggle_icon)

/obj/item/clothing/suit/armor/vest/coat
	name = "security coat"
	desc = "Пальто, усиленный специальным сплавом для защиты и стиля."
	icon_state = "secgreatcoat"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/caftan
	name = "security caftan"
	desc = "Это длинный и довольно удобный наряд, плотно сидящий на плечах. Выглядит так, как будто он создан в трудные времена."
	icon_state = "seccaftan"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

// MARK: TSF
/obj/item/clothing/suit/armor/centcom_formal/tsf_commander
	name = "federate commander greatcoat"
	desc = "Мундир командующего офицера КМП ТСФ."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	icon_state = "tsf_command"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	inhand_icon_state = null

/obj/item/clothing/suit/armor/vest/tsf_overcoat
	name = "federate overcoat"
	desc = "Стильное пальто с отличительными знаками ТСФ.\
	Неофициально считается деловой одеждой представителей Федерации."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "tsf_overcoat"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	armor_type = /datum/armor/tsf_overcoat
	dog_fashion = null

/datum/armor/tsf_overcoat
	melee = 5
	bullet = 0
	laser = 10
	energy = 0
	bomb = 0
	fire = 5
	acid = 0
	wound = 0

/obj/item/clothing/suit/armor/swat/tsf_heavy
	name = "'Juggernaut' armor"
	desc = "Тяжелая броня ТСФ, состоящая из множества слоев разных усиленных бронеплит и нано-кевлара. Отлично защищает от любых повреждений, особенно от пуль. Броня для самых серьезных защитников Федерации."
	armor_type = /datum/armor/armor_heavy

// MARK: USSP
/obj/item/clothing/suit/armor/centcom_formal/ussp_commander
	name = "soviet general greatcoat"
	desc = "Парадная шинель генерала КА СССП."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/suits.dmi'
	icon_state = "ussp_command"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/suits.dmi'
	inhand_icon_state = null

/obj/item/clothing/suit/armor/vest/ussp
	name = "soviet overcoat"
	desc = "Стандартная шинель производства Союза."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_overcoat"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	dog_fashion = null

/obj/item/clothing/suit/armor/vest/ussp/officer
	name = "soviet officer overcoat"
	desc = "Офицерская шинель производства Союза."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_overcoat_officer"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/marine/ussp_officer
	name = "tactical soviet armor vest"
	desc = "Стандартная тактическая броня для бойцов армии СССП, но с чёткими опознавательными знаками командира отряда. \
		Состоит из пласталевых плит и многослойного арамида. Защищает так, как должна по ГОСТу, главное верить и не задавать вопросов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_command"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/marine/security/ussp_security
	name = "large tactical soviet armor vest"
	desc = "Стандартная тактическая броня для бойцов армии СССП, с дополнительными наколенниками. \
		Состоит из пласталевых плит и многослойного арамида. Защищает так, как должна по ГОСТу, главное верить и не задавать вопросов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_security"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/marine/engineer/ussp_engineer
	name = "tactical soviet utility armor vest"
	desc = "Стандартная тактическая броня для бойцов армии СССП, но с дополнительными инженерными подсумками и бронированием. \
		Состоит из пласталевых плит и многослойного арамида. Защищает так, как должна по ГОСТу, но возможно чуть лучше так как имеет дополнительный слой стали, главное верить."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_engineer"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/vest/marine/medic/ussp_medic
	name = "tactical soviet medic's armor vest"
	desc = "Стандартная тактическая броня для бойцов армии СССП, но с чёткими опознавательными знаками медика отряда. \
		Состоит из пласталевых плит и многослойного арамида. Защищает так, как должна по ГОСТу, но защиту от военных преступлений не предоставляет."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_medic"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/riot/ussp_riot
	name = "OMON armor"
	desc = "Стандартная тактическая противоударная броня бойцов групп быстрого реагирования \"ОМОН\" для подавления беспорядков. \
		Отлично защищает от колюще-режущих и ударных повреждений. "
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_riot"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'

/obj/item/clothing/suit/armor/swat/ussp_heavy
	name = "heavy soviet armor"
	desc = "Тяжелая броня советского производства, состоит из усиленных титано-керамических плит и множества слоев нанокевлара. \
		Отлично защищает от любых повреждений, особенно от пуль. Броня для настоящих суровых советских Джаггернаутов."
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	icon_state = "ussp_heavy"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	armor_type = /datum/armor/armor_heavy

// MARK: ERT
/obj/item/clothing/suit/armor/swat/ert
	name = "MK.II SWAT Suit"
	desc = "Усовершенствованная версия тактического костюма SWAT. Обеспечивает надежную защиту и помогает пользователю противостоять толчкам в тесном пространстве, не замедляя его движений."
	slowdown = 0

/obj/item/clothing/suit/chaplainsuit/armor/crusader/ert
	name = "ERT crusader's armour"
	desc = "Усовершенствованная броня для крестовых походов против ереси, состоящая из освященного нанометалла и ткани. Обеспечивает очень хорошую защиту от еретиков, не замедляя движения пользователя."
	slowdown = 0
	allowed = null
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/chaplainsuit/armor/crusader/ert/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/apron/ert
	name = "ERT armoured apron"
	desc = "Фартук из специального легкого кевлара и ткани созданный для уборщиков ОБР. Обеспечивает надежную защиту от врагов чистоты."
	armor_type = /datum/armor/armor_swat
	allowed = null
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/apron/ert/Initialize(mapload)
	. = ..()
	allowed = GLOB.security_vest_allowed

/obj/item/clothing/suit/armor/vest/ntci_chestplate
	name = "chestplate armor"
	desc = "Бронежилет сочетающий в себе удобство, лёгкость и хорошую бронезащиту груди и спины. Модульность позволяет собрать его под себя и упрощает замену бронеплит."
	icon_state = "ntci_chestplate_armor"
	icon = 'modular_bandastation/objects/icons/obj/clothing/suits/armor.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/suits/armor.dmi'
	armor_type = /datum/armor/vest_marine
	clothing_flags = THICKMATERIAL
	body_parts_covered = CHEST|GROIN
	resistance_flags = FIRE_PROOF | ACID_PROOF
