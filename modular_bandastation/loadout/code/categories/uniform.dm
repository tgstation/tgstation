/datum/loadout_category/uniforms
	category_name = "Униформы"
	category_ui_icon = FA_ICON_SHIRT
	type_to_generate = /datum/loadout_item/uniforms

/datum/loadout_item/uniforms
	abstract_type = /datum/loadout_item/uniforms

/datum/loadout_item/uniforms/insert_path_into_outfit(datum/outfit/outfit, mob/living/carbon/human/equipper, visuals_only = FALSE)
	if(outfit.uniform)
		LAZYADD(outfit.backpack_contents, outfit.uniform)
	outfit.uniform = item_path

// MARK: Tier 0
/datum/loadout_item/uniforms/dutch_suit
	name = "Датч"
	item_path = /obj/item/clothing/under/costume/dutch

/datum/loadout_item/uniforms/martial_artist_gi
	name = "Бойцовский ги"
	item_path = /obj/item/clothing/under/costume/gi

/datum/loadout_item/uniforms/seifuku
	name = "Школьница"
	item_path = /obj/item/clothing/under/costume/seifuku

/datum/loadout_item/uniforms/soviet_uniform
	name = "Советская"
	item_path = /obj/item/clothing/under/costume/soviet

/datum/loadout_item/uniforms/kilt
	name = "Килт"
	item_path = /obj/item/clothing/under/costume/kilt

/datum/loadout_item/uniforms/yellow_performer_outfit
	name = "Мику (жёлтый)"
	item_path = /obj/item/clothing/under/costume/singer/yellow

/datum/loadout_item/uniforms/blue_performer_outfit
	name = "Мику (синий)"
	item_path = /obj/item/clothing/under/costume/singer/blue

/datum/loadout_item/uniforms/russian_officer_uniform
	name = "Русский офицер"
	item_path = /obj/item/clothing/under/costume/russian_officer

/datum/loadout_item/uniforms/buttondown_shirt_slacks
	name = "Рубашка на пуговицах (Брюки)"
	item_path = /obj/item/clothing/under/costume/buttondown/slacks

/datum/loadout_item/uniforms/buttondown_shirt_shorts
	name = "Рубашка на пуговицах (Шорты)"
	item_path = /obj/item/clothing/under/costume/buttondown/shorts

/datum/loadout_item/uniforms/buttondown_shirt_skirt
	name = "Рубашка на пуговицах (Юбка)"
	item_path = /obj/item/clothing/under/costume/buttondown/skirt

/datum/loadout_item/uniforms/yuri_initiate_jumpsuit
	name = "Комбинезон Юрия-инициата"
	item_path = /obj/item/clothing/under/costume/yuri

/datum/loadout_item/uniforms/assistantformal
	name = "Формальная униформа ассистента"
	item_path = /obj/item/clothing/under/misc/assistantformal

/datum/loadout_item/uniforms/syndicate_souvenir
	name = "Сувенирная футболка Синдиката"
	item_path = /obj/item/clothing/under/misc/syndicate_souvenir

/datum/loadout_item/uniforms/slacks
	name = "Широкие брюки"
	item_path = /obj/item/clothing/under/pants/slacks

/datum/loadout_item/uniforms/jeans
	name = "Джинсы"
	item_path = /obj/item/clothing/under/pants/jeans

/datum/loadout_item/uniforms/track_pants
	name = "Спортивки"
	item_path = /obj/item/clothing/under/pants/track

/datum/loadout_item/uniforms/camo_pants
	name = "Штаны (Камуфляж)"
	item_path = /obj/item/clothing/under/pants/camo

/datum/loadout_item/uniforms/whitesuit
	name = "Костюм (Белый)"
	item_path = /obj/item/clothing/under/suit/white

/datum/loadout_item/uniforms/whitesuitskirt
	name = "Костюм (Белый с юбкой)"
	item_path = /obj/item/clothing/under/suit/white/skirt

/datum/loadout_item/uniforms/blacksuit
	name = "Костюм (Чёрный)"
	item_path = /obj/item/clothing/under/suit/black

/datum/loadout_item/uniforms/blacksuitskirt
	name = "Костюм (Чёрный с юбкой)"
	item_path = /obj/item/clothing/under/suit/black/skirt

/datum/loadout_item/uniforms/beigesuit
	name = "Костюм (Бежевый)"
	item_path = /obj/item/clothing/under/suit/beige

/datum/loadout_item/uniforms/navysuit
	name = "Костюм (Тёмно-синий)"
	item_path = /obj/item/clothing/under/suit/navy

/datum/loadout_item/uniforms/burgundysuit
	name = "Костюм (Бордовый)"
	item_path = /obj/item/clothing/under/suit/burgundy

/datum/loadout_item/uniforms/dress_plaid
	name = "Клетчатая юбка"
	item_path = /obj/item/clothing/under/dress/skirt/plaid

/datum/loadout_item/uniforms/dress_turtleskirt
	name = "Юбка-водолазка"
	item_path = /obj/item/clothing/under/dress/skirt/turtleskirt

/datum/loadout_item/uniforms/dress_tango
	name = "Платье танго"
	item_path = /obj/item/clothing/under/dress/tango

/datum/loadout_item/uniforms/dress_striped
	name = "Полосатое платье"
	item_path = /obj/item/clothing/under/dress/striped

/datum/loadout_item/uniforms/dress_sailor
	name = "Платье моряка"
	item_path = /obj/item/clothing/under/dress/sailor

/datum/loadout_item/uniforms/dress_head_of_personnel
	name = "Костюм (Бирюзовый с юбкой)"
	item_path = /obj/item/clothing/under/costume/head_of_personnel/skirt

/datum/loadout_item/uniforms/dress_captain
	name = "Костюм (Зелёный с юбкой)"
	item_path = /obj/item/clothing/under/costume/captain/skirt

/datum/loadout_item/uniforms/dress_sundress
	name = "Летнее платье"
	item_path = /obj/item/clothing/under/dress/sundress

/datum/loadout_item/uniforms/kimono
	name = "Кимоно (Чёрное)"
	item_path = /obj/item/clothing/under/costume/kimono

/datum/loadout_item/uniforms/kimono_red
	name = "Кимоно (Красное)"
	item_path = /obj/item/clothing/under/costume/kimono/red

/datum/loadout_item/uniforms/kimono_purple
	name = "Кимоно (Пурпурное)"
	item_path = /obj/item/clothing/under/costume/kimono/purple

/datum/loadout_item/uniforms/osi
	name = "Комбинезон O.S.I"
	item_path = /obj/item/clothing/under/costume/osi

/datum/loadout_item/uniforms/ethereal_tunic
	name = "Эфириальная туника"
	item_path = /obj/item/clothing/under/ethereal_tunic

/datum/loadout_item/uniforms/yukata
	name = "Юката (Чёрная)"
	item_path = /obj/item/clothing/under/costume/yukata

/datum/loadout_item/uniforms/yukata_green
	name = "Юката (Зелёная)"
	item_path = /obj/item/clothing/under/costume/yukata/green

/datum/loadout_item/uniforms/yukata_white
	name = "Юката (Белая)"
	item_path = /obj/item/clothing/under/costume/yukata/white

/datum/loadout_item/uniforms/overalls
	name = "Полукомбинезон"
	item_path = /obj/item/clothing/under/misc/overalls

/datum/loadout_item/uniforms/dress_purple_bartender
	name = "Юбка бармена"
	item_path = /obj/item/clothing/under/rank/civilian/purple_bartender

// MARK: Tier 1
/datum/loadout_item/uniforms/etamin_suit
	name = "Костюм Etamin Industries"
	item_path = /obj/item/clothing/under/rank/etamin_ind/suit
	donator_level = DONATOR_TIER_1

/datum/loadout_item/uniforms/etamin_skirt
	name = "Юбка Etamin Industries"
	item_path = /obj/item/clothing/under/rank/etamin_ind/skirt
	donator_level = DONATOR_TIER_1

// MARK: Tier 2
/datum/loadout_item/uniforms/etamin_skirt_alt
	name = "Юбка \"Солнце\" Etamin Industries"
	item_path = /obj/item/clothing/under/rank/etamin_ind/skirt_alt
	donator_level = DONATOR_TIER_2

// MARK: Tier 3
/datum/loadout_item/uniforms/maid_costume
	name = "Костюм горничной"
	item_path = /obj/item/clothing/under/costume/maid
	donator_level = DONATOR_TIER_3

/datum/loadout_item/uniforms/katarina_suit
	name = "Костюм Катарины"
	item_path = /obj/item/clothing/under/costume/katarina_suit
	donator_level = DONATOR_TIER_3

/datum/loadout_item/uniforms/etamin_formal
	name = "Деловой костюм Etamin Industries"
	item_path = /obj/item/clothing/under/rank/etamin_ind/formal
	donator_level = DONATOR_TIER_3

/datum/loadout_item/uniforms/etamin_combat
	name = "Тактический костюм Etamin Industries"
	item_path = /obj/item/clothing/under/rank/etamin_ind/combat
	donator_level = DONATOR_TIER_3

// MARK: Tier 4
/datum/loadout_item/uniforms/katarina_cybersuit
	name = "Кибер-костюм Катарины"
	item_path = /obj/item/clothing/under/costume/katarina_cybersuit
	donator_level = DONATOR_TIER_4
