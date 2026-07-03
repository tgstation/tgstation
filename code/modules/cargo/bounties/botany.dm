/datum/bounty/item/botany
	reward = CARGO_CRATE_VALUE * 10
	var/multiplier = 0 //adds bonus reward money; increased for higher tier or rare mutations
	var/bonus_desc //for adding extra flavor text to bounty descriptions
	var/foodtype = "meal" //same here

/datum/bounty/item/botany/New()
	..()
	description = "Шеф повар Центрального Командования хочет приготовить [foodtype], добавив \"[name]\". [bonus_desc]"
	reward += multiplier * (CARGO_CRATE_VALUE * 2)
	required_count = rand(5, 10)

/datum/bounty/item/botany/ambrosia_vulgaris
	name = "Листья амброзии вульгарис"
	wanted_types = list(/obj/item/food/grown/ambrosia/vulgaris = TRUE)
	foodtype = "рагу"

/datum/bounty/item/botany/ambrosia_gaia
	name = "Листья амброзии гайа"
	wanted_types = list(/obj/item/food/grown/ambrosia/gaia = TRUE)
	multiplier = 4
	foodtype = "рагу"

/datum/bounty/item/botany/apple_golden
	name = "Золотые яблоки"
	wanted_types = list(/obj/item/food/grown/apple/gold = TRUE)
	multiplier = 4
	foodtype = "десерт"

/datum/bounty/item/botany/banana
	name = "Бананы"
	wanted_types = list(
		/obj/item/food/grown/banana = TRUE,
		/obj/item/food/grown/banana/bluespace = FALSE,
	)
	foodtype = "банановый сплит"

/datum/bounty/item/botany/banana_bluespace
	name = "Блюспейс бананы"
	wanted_types = list(/obj/item/food/grown/banana/bluespace = TRUE)
	multiplier = 2
	foodtype = "банановый сплит"

/datum/bounty/item/botany/beans_koi
	name = "Бобы кои"
	wanted_types = list(/obj/item/food/grown/koibeans = TRUE)
	multiplier = 2

/datum/bounty/item/botany/berries_death
	name = "Смертоягоды"
	wanted_types = list(/obj/item/food/grown/berries/death = TRUE)
	multiplier = 2
	bonus_desc = "Он наставивает на том, что \"он знает что делает\"."
	foodtype = "щербет"

/datum/bounty/item/botany/berries_glow
	name = "Свето-ягоды"
	wanted_types = list(/obj/item/food/grown/berries/glow = TRUE)
	multiplier = 2
	foodtype = "щербет"

/datum/bounty/item/botany/cannabis
	name = "Листья конопли"
	wanted_types = list(
		/obj/item/food/grown/cannabis = TRUE,
		/obj/item/food/grown/cannabis/white = FALSE,
		/obj/item/food/grown/cannabis/death = FALSE,
		/obj/item/food/grown/cannabis/ultimate = FALSE,
	)
	multiplier = 4 //hush money
	bonus_desc = "Ничего не говорите об этой доставке службе безопасности."
	foodtype = "пачку \"кексов\""

/datum/bounty/item/botany/cannabis_white
	name = "Листья конопли жизни"
	wanted_types = list(/obj/item/food/grown/cannabis/white = TRUE)
	multiplier = 6
	bonus_desc = "Ничего не говорите об этой доставке службе безопасности."
	foodtype = "\"блюдо\""

/datum/bounty/item/botany/cannabis_death
	name = "Листья конопли смерти"
	wanted_types = list(/obj/item/food/grown/cannabis/death = TRUE)
	multiplier = 6
	bonus_desc = "Do not mention this shipment to security."
	foodtype = "\"блюдо\""

/datum/bounty/item/botany/cannabis_ultimate
	name = "Листья омега конопли"
	wanted_types = list(/obj/item/food/grown/cannabis/ultimate = TRUE)
	multiplier = 6
	bonus_desc = "Ни под каким предлогом ничего не говорите о доставке службе безопасности."
	foodtype = "пачку \"пирожных\""

/datum/bounty/item/botany/wheat
	name = "Зёрна пшеницы"
	wanted_types = list(/obj/item/food/grown/wheat = TRUE)

/datum/bounty/item/botany/rice
	name = "Зёрна риса"
	wanted_types = list(/obj/item/food/grown/rice = TRUE)

/datum/bounty/item/botany/chili
	name = "Перец чили"
	wanted_types = list(/obj/item/food/grown/chili = TRUE)

/datum/bounty/item/botany/ice_chili
	name = "Морозный перец"
	wanted_types = list(/obj/item/food/grown/icepepper = TRUE)
	multiplier = 2

/datum/bounty/item/botany/ghost_chili
	name = "Призрачный чили"
	wanted_types = list(/obj/item/food/grown/ghost_chili = TRUE)
	multiplier = 2

/datum/bounty/item/botany/citrus_lime
	name = "Лаймы"
	wanted_types = list(/obj/item/food/grown/citrus/lime = TRUE)
	foodtype = "щербет"

/datum/bounty/item/botany/citrus_lemon
	name = "Лемоны"
	wanted_types = list(/obj/item/food/grown/citrus/lemon = TRUE)
	foodtype = "щербет"

/datum/bounty/item/botany/citrus_oranges
	name = "Апельсины"
	wanted_types = list(/obj/item/food/grown/citrus/orange = TRUE)
	bonus_desc = "Не отправляйте лемоны или лаймы." //I vanted orahnge!
	foodtype = "щербет"

/datum/bounty/item/botany/eggplant
	name = "Eggplants"
	wanted_types = list(/obj/item/food/grown/eggplant = TRUE)
	bonus_desc = "Not to be confused with egg-plants."

/datum/bounty/item/botany/eggplant_eggy
	name = "Egg-plants"
	wanted_types = list(/obj/item/food/grown/eggy = TRUE)
	bonus_desc = "Not to be confused with eggplants."
	multiplier = 2

/datum/bounty/item/botany/kudzu
	name = "Стручки кудзу"
	wanted_types = list(/obj/item/food/grown/kudzupod = TRUE)
	bonus_desc = "Хранить в сухом, тёмном помещении."
	multiplier = 4

/datum/bounty/item/botany/watermelon
	name = "Арбузы"
	wanted_types = list(/obj/item/food/grown/watermelon = TRUE)
	foodtype = "десерт"

/datum/bounty/item/botany/watermelon_holy
	name = "Святые арбузы"
	wanted_types = list(/obj/item/food/grown/holymelon = TRUE)
	multiplier = 2
	foodtype = "десерт"

/datum/bounty/item/botany/glowshroom
	name = "Светогрибы"
	wanted_types = list(
		/obj/item/food/grown/mushroom/glowshroom = TRUE,
		/obj/item/food/grown/mushroom/glowshroom/glowcap = FALSE,
		/obj/item/food/grown/mushroom/glowshroom/shadowshroom = FALSE,
	)
	foodtype = "омлет"

/datum/bounty/item/botany/glowshroom_cap
	name = "Светокэп"
	wanted_types = list(/obj/item/food/grown/mushroom/glowshroom/glowcap = TRUE)
	multiplier = 2
	foodtype = "омлет"

/datum/bounty/item/botany/glowshroom_shadow
	name = "Тенегрибы"
	wanted_types = list(/obj/item/food/grown/mushroom/glowshroom/shadowshroom = TRUE)
	multiplier = 2
	foodtype = "омлет"

/datum/bounty/item/botany/nettles_death
	name = "Крапива смерти"
	wanted_types = list(/obj/item/food/grown/nettle/death = TRUE)
	multiplier = 2
	bonus_desc = "Носите защиту, когда прикасаетесь к ней."
	foodtype = "сыр"

/datum/bounty/item/botany/pineapples
	name = "Ананасы"
	wanted_types = list(/obj/item/food/grown/pineapple = TRUE)
	bonus_desc = "Не для потребления людьми."
	foodtype = "зольник"

/datum/bounty/item/botany/tomato
	name = "Томаты"
	wanted_types = list(
		/obj/item/food/grown/tomato = TRUE,
		/obj/item/food/grown/tomato/blue = FALSE,
	)

/datum/bounty/item/botany/tomato_bluespace
	name = "Блюспейс томаты"
	wanted_types = list(/obj/item/food/grown/tomato/blue/bluespace = TRUE)
	multiplier = 4

/datum/bounty/item/botany/oatz
	name = "Овёс"
	wanted_types = list(/obj/item/food/grown/oat = TRUE)
	multiplier = 2
	foodtype = "пачку овсяных хлопьев"
	bonus_desc = "Squats and oats. We're all out of oats."

/datum/bounty/item/botany/bonfire
	name = "Зажжённый костёр"
	description = "Наши космические нагреватели сбоят и персонал отдела поставок Центрального Командования начал замерзать. Вырастите немного брёвен и разожгите костёр, чтобы согреть их."
	wanted_types = list(/obj/structure/bonfire = TRUE)

/datum/bounty/item/botany/bonfire/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/structure/bonfire/B = O
	return !!B.burning

/datum/bounty/item/botany/cucumber
	name = "Огурцы"
	wanted_types = list(/obj/item/food/grown/cucumber = TRUE)
