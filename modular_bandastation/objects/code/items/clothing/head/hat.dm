// MARK: Head //

// Roboticist
/obj/item/clothing/head/cowboy/roboticist
	name = "roboticist's cowboy hat"
	desc = "Ковбойская шляпа с малиновой лентой, сочетающая стиль и функциональность. Отличный выбор для тех, кто хочет выделиться на космической станции. На бирке указано: 'Flameholdeir Industries'. Вам точно не хватает револьвера!"
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/cowboy.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/cowboy.dmi'
	icon_state = "cowboy_robostics"
	worn_icon_state = "cowboy_robostics"

// Science
/obj/item/clothing/head/cowboy/science
	name = "science's cowboy hat"
	desc = "Ковбойская шляпа с фиолетовой лентой, сочетающая стиль и функциональность. Отличный выбор для тех, кто хочет выделиться на космической станции."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/cowboy.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/cowboy.dmi'
	icon_state = "cowboy_science"
	worn_icon_state = "cowboy_science"

// CentCom
/obj/item/clothing/head/beret/cent_intern
	name = "fleet junior-officer's beret"
	desc = "Носится младшим офицерским составом."
	icon = 'icons/map_icons/clothing/head/beret.dmi'
	icon_state = "/obj/item/clothing/head/beret/cent_intern"
	post_init_icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#323253#acacac"
	armor_type = /datum/armor/cent_intern
	dog_fashion = null
	flags_1 = NONE

/datum/armor/cent_intern
	melee = 30
	bullet = 25
	laser = 25
	energy = 35
	bomb = 25
	fire = 20
	acid = 50
	wound = 10

/obj/item/clothing/head/beret/ert
	name = "SRT operative beret"
	desc = "Берет оперативника ОСР."
	icon = 'icons/map_icons/clothing/head/beret.dmi'
	icon_state = "/obj/item/clothing/head/beret/ert"
	post_init_icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#43523d#a2abb0"
	armor_type = /datum/armor/cent_intern
	dog_fashion = null
	flags_1 = NONE

/obj/item/clothing/head/beret/ert/amber
	name = "amber ERT commander beret"
	desc = "Берет командира отряда быстрого реагирования кода «ЭМБЕР»"
	icon_state = "/obj/item/clothing/head/beret/ert/amber"
	greyscale_colors = "#526382#eeeeee"

/obj/item/clothing/head/beret/ert/red
	name = "red ERT commander beret"
	desc = "Берет командира отряда быстрого реагирования кода «РЭД»."
	icon_state = "/obj/item/clothing/head/beret/ert/red"
	greyscale_colors = "#526382#cc9900"

/obj/item/clothing/head/beret/ert/gamma
	name = "gamma ERT commander beret"
	desc = "Берет командира отряда быстрого реагирования кода «ГАММА»."
	icon_state = "/obj/item/clothing/head/beret/ert/gamma"
	greyscale_colors = "#212121#cc9900"

/obj/item/clothing/head/beret/ert/janitor
	name = "janitor ERT operative beret"
	desc = "Берет оперативника-уборщика отряда быстрого реагирования. Символ неумолимой стойкости перед любыми угрозами для чистоты."
	icon_state = "/obj/item/clothing/head/beret/ert/janitor"
	greyscale_colors = "#7e1980#cc9900"

/obj/item/clothing/head/beret/cent_diplomat
	name = "fleet officer's white beret"
	desc = "Изящный белый берет. На подкладке вышита надпись: \"НЕ ПОДЛЕЖИТ СТИРКЕ!\""
	icon = 'icons/map_icons/clothing/head/beret.dmi'
	icon_state = "/obj/item/clothing/head/beret/cent_diplomat"
	post_init_icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#eeeeee#FFCE5B"
	armor_type = /datum/armor/cent_intern
	dog_fashion = null
	flags_1 = NONE

/datum/armor/cent_diplomat
	melee = 50
	bullet = 40
	laser = 40
	energy = 60
	bomb = 40
	fire = 60
	acid = 60
	wound = 12

/obj/item/clothing/head/helmet/space/beret/soo
	name = "special ops officer's beret"
	desc = "Продвинутая версия стандартного офицерского берета. Выдерживает попадание аннигиляторной пушки. Проверять не стоит."
	greyscale_colors = "#b72b2f#acacac"

/obj/item/clothing/head/caphat/beret_black
	name = "black captain beret"
	desc = "Хорошо быть королём."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hats.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/cap.dmi'
	icon_state = "cap_beret_black"

/obj/item/clothing/head/ratge
	name = "ratge head"
	desc = "Ну ты и крыса!"
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hats.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/hats.dmi'
	icon_state = "ratgehead"
	inhand_icon_state = "ratgehead"
	lefthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_left_hand.dmi'
	righthand_file = 'modular_bandastation/objects/icons/mob/inhands/clothing_right_hand.dmi'
	flags_inv = HIDEMASK | HIDEEARS | HIDEEYES | HIDEFACE | HIDEHAIR
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/head/chefhat/red
	name = "chef's red hat"
	desc = "Красный поварской колпак, для тех, кто хочет показать что он тут настоящий босс кухни."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hats.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/cap.dmi'
	icon_state = "chef_red"

/obj/item/clothing/head/towel
	name = "towel cap"
	desc = "Полотенце замотанное в импровизированную шапку. Можно надеть на голову."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hats.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/cap.dmi'
	icon_state = "towel_head"

// Security
/obj/item/clothing/head/cowboy/security
	name = "security cowboy hat"
	desc = "Ковбойская шляпа с красной лентой, сочетающая стиль и функциональность. Вариация для службы безопасности, имеющая тонкий армированный слой."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/cowboy.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/cowboy.dmi'
	icon_state = "cowboy_sec"
	worn_icon_state = "cowboy_sec"
	armor_type = /datum/armor/cosmetic_sec

/obj/item/clothing/head/sec_beanie
	name = "security beanie"
	desc = "Мягкая и бронированная берендейка, которая меняет свой порядок."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hats.dmi'
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/hats.dmi'
	icon_state = "secbeanie"
	worn_icon_state = "secbeanie"
	armor_type = /datum/armor/cosmetic_sec

// MARK: TSF
/obj/item/clothing/head/beret/tsf_commander
	name = "TSF commander beret"
	desc = "Берет командующего офицера КМП ТСФ."
	icon_state = "/obj/item/clothing/head/beret/tsf_commander"
	post_init_icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#212121#cc9900"
	dog_fashion = null
	flags_1 = NONE

/obj/item/clothing/head/beret/tsf_marine
	name = "TSF marine beret"
	desc = "Берет бойца КМП ТСФ."
	icon_state = "/obj/item/clothing/head/beret/tsf_marine"
	post_init_icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#526382#eeeeee"
	dog_fashion = null
	flags_1 = NONE

/obj/item/clothing/head/beret/tsf_marine_officer
	name = "TSF marine officer beret"
	desc = "Берет бойца КМП ТСФ."
	icon_state = "/obj/item/clothing/head/beret/tsf_marine_officer"
	post_init_icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#526382#cc9900"
	dog_fashion = null
	flags_1 = NONE

/obj/item/clothing/head/beret/tsf_marsoc
	name = "TSF MARSOC beret"
	desc = "Берет бойца КСОМП ТСФ."
	icon_state = "/obj/item/clothing/head/beret/tsf_marsoc"
	post_init_icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#212121#eeeeee"
	dog_fashion = null
	flags_1 = NONE

/obj/item/clothing/head/beret/tsf_marsoc_officer
	name = "TSF MARSOC officer beret"
	desc = "Берет офицера КСОМП ТСФ."
	icon_state = "/obj/item/clothing/head/beret/tsf_marsoc_officer"
	post_init_icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#212121#cc9900"
	dog_fashion = null
	flags_1 = NONE

/obj/item/clothing/head/beret/tsf_infiltrator
	name = "TSF infiltrator operative beret"
	desc = "Берет бойца-диверсанта ТСФ."
	icon_state = "/obj/item/clothing/head/beret/tsf_infiltrator"
	post_init_icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#43523d#a2abb0"
	dog_fashion = null
	flags_1 = NONE

/obj/item/clothing/head/beret/tsf_diplomat
	name = "TSF official's beret"
	desc = "Берет официальных лиц ТСФ."
	icon_state = "/obj/item/clothing/head/beret/tsf_diplomat"
	post_init_icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#102036#eeeeee"
	dog_fashion = null
	flags_1 = NONE

/obj/item/clothing/head/hats/fedora/tsf
	name = "TSF fedora"
	desc = "Темно-синяя федора."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hats.dmi'
	icon_state = "tsf_fedora"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/hats.dmi'

/obj/item/clothing/head/hats/tsf_cap
	name = "TSF cap"
	desc = "Мягкая кепка с опознавательными знаками ТСФ."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hats.dmi'
	icon_state = "tsf_cap"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/hats.dmi'

// MARK: USSP
/obj/item/clothing/head/hats/ussp
	name = "soviet pilotka"
	desc = "Пилотка бойцов КА СССП."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hats.dmi'
	icon_state = "ussp_pilotka"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/hats.dmi'

/obj/item/clothing/head/hats/ussp_officer
	name = "soviet officer hat"
	desc = "Фуражка офицера КА СССП."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hats.dmi'
	icon_state = "ussp_hat_officer"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/hats.dmi'

/obj/item/clothing/head/hats/ussp_command
	name = "soviet general hat"
	desc = "Фуражка высшего командного состава КА СССП."
	icon = 'modular_bandastation/objects/icons/obj/clothing/head/hats.dmi'
	icon_state = "ussp_hat_komandir"
	worn_icon = 'modular_bandastation/objects/icons/mob/clothing/head/hats.dmi'

