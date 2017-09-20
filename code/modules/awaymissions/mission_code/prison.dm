//areas

/area/prisonv2
	name = "Prison USSR"
	icon_state = "brig"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = TRUE
	has_gravity = TRUE
	noteleport = TRUE
	blob_allowed = FALSE
	flags_1 = NONE

//turfs

/turf/closed/wall/brick
	name = "brick wall"
	desc = "Изначально эти стены были белого цвета, но со временем люди стали их красить. Собой."
	icon = 'icons/turf/walls/brick_wall.dmi'
	icon_state = "brick"
	hardness = 4500
	explosion_block = 5
	slicing_duration = 20000
	canSmoothWith = list(/turf/closed/wall/brick, /obj/structure/falsewall/brick)

/obj/structure/falsewall/brick
	name = "brick wall"
	desc = "Изначально эти стены были белого цвета, но со временем люди стали их красить. Собой."
	icon = 'icons/turf/walls/brick_wall.dmi'
	icon_state = "brick"
	walltype = /turf/closed/wall/brick
	canSmoothWith = list(/obj/structure/falsewall/brick, /turf/closed/wall/brick)

/turf/open/floor/plating/dirty
	name = "dirt"
	desc = "Мягенькая."
	icon = 'icons/turf/floors.dmi'
	icon_state = "dirt"
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	slowdown = 3

/turf/open/floor/plating/beton
	name = "beton"
	desc = "Падать на него не самый лучший вариант."
	icon_state = "beton"
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	icon = 'icons/misc/beton.dmi'

//signs

/obj/structure/sign/prison
	icon = 'icons/misc/prison.dmi'

/obj/structure/sign/prison/uprava
	name = "\improper Uprava"
	icon = 'icons/misc/prisonw.dmi'
	desc = "Здесь решаются судьбы."
	icon_state = "uprava"

/obj/structure/sign/prison/blok1
	name = "\improper Blok 1"
	desc = "Родная хата."
	icon_state = "blok1"

/obj/structure/sign/prison/tok
	name = "\improper Ne prikasaisya!"
	desc = "Не прикасайся!"
	icon_state = "tok"

/obj/structure/sign/prison/hitler
	name = "\improper Hitler"
	desc = "Какой красивый мальчик."
	icon_state = "hitler"

/obj/structure/sign/prison/net
	name = "\improper Net!"
	desc = "Нет!"
	icon_state = "net"

/obj/structure/sign/prison/kolesa
	name = "\improper Pomni o kolesah"
	desc = "Помни о колесах."
	icon_state = "kolesa"

/obj/structure/sign/prison/pobeda
	name = "\improper K novym pobedam!"
	desc = "К новым победам в труде и спорте!"
	icon_state = "pobeda"

/obj/structure/sign/prison/bolt
	name = "\improper Ne boltay!"
	desc = "Не болтай!"
	icon_state = "bolt"

/obj/structure/sign/prison/pyan
	name = "\improper Byl pyan"
	desc = "Я на производстве был пьян."
	icon_state = "pyan"

/obj/structure/sign/prison/yannp
	name = "\improper Ne ponyal!"
	desc = "У меня возник когнитивный диссонанс!"
	icon_state = "yannp"

/obj/structure/sign/prison/bolt
	name = "\improper Ne boltay!"
	desc = "Не болтай!."
	icon_state = "bolt"

//machines

/obj/machinery/vending/sovietvend
	name = "\improper Soviet Vend"
	icon = 'icons/misc/prison.dmi'
	desc = "Каждому трудящемуся по инструменту!"
	icon_state = "sovietvend"
	product_ads = "За Царя и Страну.;А ты выполнил норму сегодня?;Слава Советскому Союзу!"
	products = list(/obj/item/clothing/under/soviet = 20, /obj/item/reagent_containers/food/drinks/bottle/vodka = 40,
					/obj/item/reagent_containers/food/snacks/candy = 40, /obj/item/reagent_containers/food/snacks/tofu = 50)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 20)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/door/airlock/woodsov
	name = "wooden soviet door"
	icon = 'icons/obj/doors/airlocks/station/wood.dmi'
	var/mineral = "wood"
	req_access_txt = "150"
	assemblytype = /obj/structure/door_assembly/door_assembly_wood

/obj/machinery/power/port_gen/pacman/coal
	name = "\improper HellMachine"
	desc = "Эта штука заставляет лампочки полыхать адским пламенем за счет сжигания угля. Сатанинская машина."
	icon = 'icons/misc/prisond.dmi'
	icon_state = "portgen0_0"
	base_icon = "portgen0"
	sheet_path = /obj/item/stack/sheet/mineral/coal
	power_gen = 15000
	time_per_sheet = 185
	density = TRUE
	anchored = TRUE

/*
 * Coal
 */

/obj/item/stack/sheet/mineral/coal
	name = "coal"
	icon = 'icons/misc/prison.dmi'
	desc = "Черный как тот зек."
	singular_name = "coal"
	icon_state = "coal"
	throw_speed = 3
	throw_range = 5
	origin_tech = "materials=1"
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)

/obj/item/stack/sheet/mineral/coal/five
	amount = 5

//misc

/turf/closed/mineral/coal
	mineralType = /obj/item/stack/sheet/mineral/coal
	spreadChance = 20
	spread = 1
	scan_state = "rock_Iron"

/turf/closed/mineral/random/high_chance/prison
	turf_type = /turf/open/floor/plating/dirty
	baseturf = /turf/open/floor/plating/dirty
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	defer_change = 1
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/volcanic = 3, /turf/closed/mineral/diamond/volcanic = 3, /turf/closed/mineral/gold/volcanic = 3, /turf/closed/mineral/titanium/volcanic = 3,
		/turf/closed/mineral/silver/volcanic = 3, /turf/closed/mineral/plasma/volcanic = 3, /turf/closed/mineral/bscrystal/volcanic = 3, /turf/closed/mineral/coal = 15)

/obj/item/card/id/keys
	name = "keys"
	icon = 'icons/misc/prison.dmi'
	icon_state = "keys"
	desc = "Ключи от всех дверей"
	access = list(ACCESS_SYNDICATE)

/obj/item/projectile/magic/upal
	name = "upal"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "x2"
	invisibility = INVISIBILITY_ABSTRACT

/obj/item/projectile/magic/upal/on_hit(target)
	. = ..()
	if(ismob(target))
		var/mob/M = target
		M.death(0)

//spawners

/obj/effect/mob_spawn/human/prison
	desc = "Кажется тут кто-то затаился под шконкой..."
	icon = 'icons/misc/prison.dmi'
	icon_state = "spwn"
	roundstart = FALSE
	death = FALSE

/obj/effect/mob_spawn/human/prison/doctor
	name = "doctor spawner"
	flavour_text = "Вы вечный патологоанатом тюрьмы Ромашка. Постарайтесь следить за телами, живые они или нет, и не забывайте готовить мясо для котлет.<b> И да, смерти в этой тюрьме не приветствуются, Вы верующий человек и бог с Вами.</b>"
	outfit = /datum/outfit/prison/doctor
	assignedrole = "Doctor USSR"

/datum/outfit/prison/doctor
	name = "Doctor USSR"
	head = /obj/item/clothing/head/ushanka
	uniform = /obj/item/clothing/under/lobster
	suit = /obj/item/clothing/suit/toggle/labcoat
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol

/obj/effect/mob_spawn/human/prison/vertuhai/special(mob/living/L)
	var/list/imenad = list("Петренко", "Гаврилов", "Смирнов", "Гмызенко", "Юлия", "Сафронов", "Павлов", "Пердюк", "Попов")
	L.real_name = "Доктор [pick(imenad)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/vertuhai
	name = "vertuhai spawner"
	flavour_text = "Вы вечный смотритель тюрьмы Ромашка. Постарайтесь не убивать зеков без приказа свыше и не забывайте кушать котлеты.<b> И да, смерти в этой тюрьме не приветствуются, Вы верующий человек и бог с Вами.</b>"
	outfit = /datum/outfit/prison/vertuhai
	assignedrole = "Vertuhai USSR"

/datum/outfit/prison/vertuhai
	name = "Vertuhai USSR"
	head = /obj/item/clothing/head/ushanka
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol

/obj/effect/mob_spawn/human/prison/vertuhai/special(mob/living/L)
	var/list/imenav = list("Петренко", "Гаврилов", "Смирнов", "Гмызенко", "Юлия", "Сафронов", "Павлов", "Пердюк", "Золотарев", "Михалыч")
	L.real_name = "Смотритель [pick(imenav)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/mehanik
	name = "mehanik spawner"
	flavour_text = "Вы вечный механик тюрьмы Ромашка. Постарайтесь не взорвать двигатель, починить, что не сломано и не забывайте спрашивать у зеков, когда котлеты будут там.<b> И да, смерти в этой тюрьме не приветствуются, Вы верующий человек и бог с Вами.</b>"
	outfit = /datum/outfit/prison/mehanik
	assignedrole = "Mehanik USSR"

/datum/outfit/prison/mehanik
	name = "Mehanik USSR"
	head = /obj/item/clothing/head/ushanka
	uniform = /obj/item/clothing/under/rank/engineer
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol

/obj/effect/mob_spawn/human/prison/mehanik/special(mob/living/L)
	var/list/imenam = list("Петренко", "Гаврилов", "Смирнов", "Гмызенко", "Юлия", "Сафронов", "Павлов", "Пердюк", "Михалыч")
	L.real_name = "Механик [pick(imenam)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/nachalnik
	name = "nachalnik spawner"
	flavour_text = "Вы вечный надзиратель тюрьмы Ромашка. Постарайтесь привести её в порядок и не забывайте напоминать зекам о том, что котлеты только завтра.<b> И да, смерти в этой тюрьме не приветствуются, Вы верующий человек и бог с Вами.</b>"
	icon_state = "spwn"
	outfit = /datum/outfit/prison/nachalnik
	assignedrole = "Nachalnik USSR"

/datum/outfit/prison/nachalnik
	name = "Nachalnik USSR"
	head = /obj/item/clothing/head/ushanka
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol

/obj/effect/mob_spawn/human/prison/nachalnik/special(mob/living/L)
	var/list/imenan = list("Петренко", "Гаврилов", "Смирнов", "Гмызенко", "Юлия", "Сафронов", "Павлов", "Пердюк", "Михалыч")
	L.real_name = "Начальник [pick(imenan)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/prisoner
	name = "shkonka spawner"
	desc = "Кажется тут кто-то затаился под шконкой..."
	flavour_text = "Вы вечный заключенный тюрьмы Ромашка. Отсиживайте свой тюремный срок как следует, слушайтесь начальника и не забывайте о том, что котлеты только завтра. Кстати, сидишь ты тут за "
	outfit = /datum/outfit/prison/prisoner
	assignedrole = "Prisoner USSR"

/obj/effect/mob_spawn/human/prison/prisoner/special(mob/living/L)
	var/list/imena = list("Борзый", "Дохляк", "Академик", "Акула", "Базарило", "Бродяга", "Валет", "Воровайка", "Гнедой", \
	"Гребень", "Дельфин", "Дырявый", "Игловой", "Карась", "Каторжанин", "Лабух", "Мазурик", "Мокрушник", "Понтовитый", \
	"Ржавый", "Седой", "Сявка", "Темнила", "Чайка", "Чепушило", "Шакал", "Шерстяной", "Шмаровоз", "Шпилевой", "Олька", "Машка", \
	"Щипач", "Якорник", "Сладкий", "Семьянин", "Порученец", "Блатной", "Арап", "Артист", "Апельсин", "Афер")
	L.real_name = "[pick(imena)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/prisoner/Initialize(mapload)
	. = ..()
	var/list/zacho = list("убийство", "воровство", "коррупцию", "неисполнение обязанностей", "похищение людей", "грубую некомпетентность", \
	"кражу", "поклонение запрещенному божеству", "межвидовые отношения", "мятеж")
	flavour_text += "[pick(zacho)].</b>."

/datum/outfit/prison/prisoner
	name = "Prisoner USSR"
	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange