/**********************Areas******************************/

/area/prisonv2
	name = "Prison USSR"
	icon_state = "brig"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = TRUE
	has_gravity = TRUE
	noteleport = TRUE
	blob_allowed = FALSE
	flags_1 = NONE
	ambientsounds = list('sound/valtos/prison/amb2.ogg',
						 'sound/valtos/prison/amb3.ogg',
						 'sound/valtos/prison/amb4.ogg',
						 'sound/valtos/prison/amb5.ogg',
						 'sound/valtos/prison/amb6.ogg',
						 'sound/valtos/prison/amb7.ogg',
						 'sound/valtos/prison/amb8.ogg')

/area/prisonv2/block1
	name = "Block 1 USSR"
	icon_state = "security"

/area/prisonv2/uprava
	name = "Uprava USSR"
	icon_state = "security"

/area/prisonv2/vorota
	name = "Vorota USSR"
	icon_state = "security"

/area/prisonv2/kachalka
	name = "Kachalka USSR"
	icon_state = "yellow"

/area/prisonv2/hydro
	name = "Hydro USSR"
	icon_state = "green"

/area/prisonv2/stolovka
	name = "Stolovka USSR"
	icon_state = "kitchen"

/area/prisonv2/med
	name = "Med USSR"
	icon_state = "showroom"

/area/prisonv2/cerkov
	name = "Cerkov USSR"
	icon_state = "chapeloffice"

/area/prisonv2/bibloteka
	name = "Bibloteka USSR"
	icon_state = "library"

/area/prisonv2out
	name = "Caves USSR"
	icon_state = "yellow"
	requires_power = TRUE
	has_gravity = TRUE
	noteleport = TRUE
	blob_allowed = FALSE
	flags_1 = NONE
	ambientsounds = list('sound/valtos/prison/amb2.ogg',
						 'sound/valtos/prison/ambout1.ogg',
						 'sound/valtos/prison/ambarab.ogg',
						 'sound/valtos/prison/amb8.ogg')

/**********************Turf Walls**************************/

/turf/closed/wall/brick
	name = "brick wall"
	desc = "Изначально эти стены были белого цвета, но со временем люди стали их красить. Собой."
	icon = 'icons/valtos/prison/brick_wall.dmi'
	icon_state = "brick"
	explosion_block = 50
	slicing_duration = 20000
	canSmoothWith = list(/turf/closed/wall/brick, /obj/structure/falsewall/brick, /obj/structure/prison/window)

/turf/closed/wall/brick/TerraformTurf(path, defer_change = FALSE, ignore_air = FALSE)
	return

/obj/structure/prison/window
	name = "brick window"
	desc = "Улучшенная версия окон. Придумайте шутку сами."
	icon = 'icons/valtos/prison/brick_wall.dmi'
	icon_state = "window"
	pass_flags = LETPASSTHROW
	max_integrity = 2500
	anchored = 1
	density = 1
	opacity = 0
	layer = 2.4
	var/proj_pass_rate = 50

/obj/structure/prison/window/CanPass(atom/movable/mover, turf/target)//So bullets will fly over and stuff.
	if(locate(/obj/structure/prison/window) in get_turf(mover))
		return 1
	else if(istype(mover, /obj/item/projectile))
		if(!anchored)
			return 1
		var/obj/item/projectile/proj = mover
		if(proj.firer && Adjacent(proj.firer))
			return 1
		if(prob(proj_pass_rate))
			return 1
		return 0
	else
		return !density

/turf/closed/wall/beton
	name = "beton wall"
	desc = "Самое время потерять зубы при полете в него."
	icon = 'icons/valtos/prison/beton_wall.dmi'
	icon_state = "beton"
	explosion_block = 50
	slicing_duration = 20000
	canSmoothWith = list(/turf/closed/wall/beton)

/turf/closed/wall/beton/TerraformTurf(path, defer_change = FALSE, ignore_air = FALSE)
	return

/**********************Turf Minerals************************/

/turf/closed/mineral/bscrystal/dirty
	turf_type = /turf/open/floor/plating/asteroid/dirty
	baseturf = /turf/open/floor/plating/asteroid/dirty
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	defer_change = 1

/turf/closed/mineral/uranium/dirty
	turf_type = /turf/open/floor/plating/asteroid/dirty
	baseturf = /turf/open/floor/plating/asteroid/dirty
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	defer_change = 1

/turf/closed/mineral/plasma/dirty
	turf_type = /turf/open/floor/plating/asteroid/dirty
	baseturf = /turf/open/floor/plating/asteroid/dirty
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	defer_change = 1

/turf/closed/mineral/titanium/dirty
	turf_type = /turf/open/floor/plating/asteroid/dirty
	baseturf = /turf/open/floor/plating/asteroid/dirty
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	defer_change = 1

/turf/closed/mineral/silver/dirty
	turf_type = /turf/open/floor/plating/asteroid/dirty
	baseturf = /turf/open/floor/plating/asteroid/dirty
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	defer_change = 1

/turf/closed/mineral/gold/dirty
	turf_type = /turf/open/floor/plating/asteroid/dirty
	baseturf = /turf/open/floor/plating/asteroid/dirty
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	defer_change = 1

/turf/closed/mineral/diamond/dirty
	turf_type = /turf/open/floor/plating/asteroid/dirty
	baseturf = /turf/open/floor/plating/asteroid/dirty
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	defer_change = 1

/turf/closed/mineral/coal
	mineralType = /obj/item/stack/sheet/mineral/coal
	turf_type = /turf/open/floor/plating/asteroid/dirty
	baseturf = /turf/open/floor/plating/asteroid/dirty
	spreadChance = 20
	spread = 1
	scan_state = "rock_Iron"

/turf/closed/mineral/random/prison
	turf_type = /turf/open/floor/plating/asteroid/dirty
	baseturf = /turf/open/floor/plating/asteroid/dirty
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	defer_change = 1
	mineralChance = 10
	mineralSpawnChanceList = list(
		/turf/closed/mineral/uranium/dirty = 6, /turf/closed/mineral/diamond/dirty = 6, /turf/closed/mineral/gold/dirty = 6, /turf/closed/mineral/titanium/dirty = 6,
		/turf/closed/mineral/silver/dirty = 6, /turf/closed/mineral/plasma/dirty = 6, /turf/closed/mineral/bscrystal/dirty = 6, /turf/closed/mineral/coal = 35)

/**********************Turf Floors**************************/

/turf/open/floor/plating/asteroid/dirty
	name = "dirt"
	desc = "Мягенькая."
	icon = 'icons/valtos/prison/prison.dmi'
	postdig_icon_change = TRUE
	icon_state = "dirt"
	icon_plating = "dirt"
	environment_type = "dirt"
	turf_type = /turf/open/floor/plating/asteroid/dirty
	floor_variance = 0
	initial_gas_mix = "o2=22;n2=82;TEMP=275.15"
	archdrops = list(/obj/item/ore/glass = 5)
	slowdown = 3

/turf/open/floor/trot
	name = "trotuar"
	desc = "В самый раз для пробежек."
	icon_state = "trot"
	initial_gas_mix = "o2=22;n2=82;TEMP=298.15"
	icon = 'icons/valtos/prison/beton.dmi'
	floor_tile = /obj/item/stack/tile/trot
	slowdown = 1
	broken_states = list("damaged")
	baseturf = /turf/open/floor/plating/asteroid/dirty

/turf/open/floor/trot/cell
	name = "floor"
	desc = "Холодненький."
	icon_state = "pol"
	initial_gas_mix = "o2=22;n2=82;TEMP=298.15"
	icon = 'icons/valtos/prison/beton.dmi'
	floor_tile = /obj/item/stack/tile/trot
	slowdown = 3
	broken_states = list("damaged")
	baseturf = /turf/open/floor/plating/asteroid/dirty

/turf/open/floor/woodp
	name = "wooden floor"
	desc = "Лучше, чем ничего"
	icon_state = "wood1"
	initial_gas_mix = "o2=22;n2=82;TEMP=298.15"
	icon = 'icons/valtos/prison/woodf.dmi'
	slowdown = 2
	broken_states = list("wood2","wood3","wood4","wood5","wood6")
	baseturf = /turf/open/floor/plating/asteroid/dirty

/turf/open/floor/beton
	name = "beton"
	desc = "Падать на него не самый лучший вариант."
	icon_state = "beton"
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	icon = 'icons/valtos/prison/beton.dmi'
	floor_tile = /obj/item/stack/tile/beton
	broken_states = list("damaged")
	smooth = SMOOTH_TRUE
	slowdown = 1
	canSmoothWith = list(/turf/open/floor/beton)
	flags_1 = NONE
	baseturf = /turf/open/floor/plating/asteroid/dirty

/turf/open/floor/beton/Initialize()
	..()
	update_icon()

/turf/open/floor/beton/update_icon()
	if(!..())
		return 0
	if(!broken && !burnt)
		if(smooth)
			queue_smooth(src)
	else
		make_plating()
		if(smooth)
			queue_smooth_neighbors(src)

/******************Structures***************************/

/obj/structure/falsewall/brick
	name = "brick wall"
	desc = "Изначально эти стены были белого цвета, но со временем люди стали их красить. Собой."
	icon = 'icons/valtos/prison/brick_wall.dmi'
	icon_state = "brick"
	walltype = /turf/closed/wall/brick
	canSmoothWith = list(/obj/structure/falsewall/brick, /turf/closed/wall/brick)

/obj/structure/curtain/prison/update_icon()
	if(!open)
		icon_state = "closed"
		layer = WALL_OBJ_LAYER
		density = FALSE
		open = FALSE
		opacity = 1

	else
		icon_state = "open"
		layer = WALL_OBJ_LAYER
		density = FALSE
		open = TRUE
		opacity = 0

/******************Uniforms****************************/

/obj/item/clothing/under/prison/nach
	name = "nachalnik suit"
	desc = "Стильная рубашка к не менее модным штанам."
	icon = 'icons/valtos/prison/uniform.dmi'
	icon_state = "nach"
	item_state = "nach"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 50)
	strip_delay = 60

/obj/item/clothing/under/prison/vertuhai
	name = "vertuhai suit"
	desc = "Стандартная униформа военнослужащего."
	icon = 'icons/valtos/prison/uniform.dmi'
	icon_state = "vert"
	item_state = "vert"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 50)
	strip_delay = 60

/obj/item/clothing/under/prison/prison
	desc = "Форма уличного мима. Погодите-ка... Нет, все таки тюремная."
	icon = 'icons/valtos/prison/uniform.dmi'
	icon_state = "prisoner2"
	item_state = "prisoner2"
	has_sensor = LOCKED_SENSORS
	sensor_mode = SENSOR_COORDS
	random_sensor = 0

/obj/item/clothing/under/prison/prison/Initialize()
	..()
	name = "prisoner #[rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)][rand(0,9)]"

/******************Suits*******************************/

/obj/item/clothing/suit/armor/ussr
	name = "armored trenchcoat"
	desc = "Крепкий и теплый."
	icon = 'icons/valtos/prison/uniform.dmi'
	icon_state = "vertsuit"
	item_state = "vertsuit"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS
	armor = list(melee = 30, bullet = 30, laser = 30, energy = 10, bomb = 25, bio = 0, rad = 0, fire = 70, acid = 90)
	cold_protection = CHEST|GROIN|LEGS|ARMS
	heat_protection = CHEST|GROIN|LEGS|ARMS
	strip_delay = 80

/******************Headgear****************************/

/obj/item/clothing/head/helmet/ussr
	name = "helmet"
	desc = "Крепкая каска."
	icon = 'icons/valtos/prison/uniform.dmi'
	icon_state = "helm"
	item_state = "helm"
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 40, bomb = 60, bio = 0, rad = 0, fire = 60, acid = 60)

/obj/item/clothing/head/tyubet
	name = "tybeteika"
	desc = "Тюбетейка."
	icon = 'icons/valtos/prison/uniform.dmi'
	icon_state = "phat"
	item_state = "phat"

/******************Doors*******************************/

/obj/machinery/door/airlock/prison
	name = "door"
	icon = 'icons/valtos/prison/doors.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_wood
	desc = "Обычная стальная дверь покрытая плотным слоем дерева."
	glass = FALSE
	autoclose = FALSE
	lights = FALSE
	normal_integrity = 1200
	damage_deflection = 30
	req_access_txt = "150"
	doorOpen = 'sound/machines/door_open.ogg'
	doorClose = 'sound/machines/door_close.ogg'
	boltUp = 'sound/machines/door_locked.ogg'
	boltDown = 'sound/machines/door_locked.ogg'
	doorDeni = 'sound/machines/door_locked.ogg'

/obj/machinery/door/airlock/prison/cell
	glass = TRUE
	locked = 1
	opacity = 0
	assemblytype = /obj/structure/door_assembly/door_assembly_wood

/obj/machinery/door/poddoor/shutters/prison
	name = "lattice door"
	desc = "Сверхкрепкая."
	icon = 'icons/valtos/prison/prison.dmi'
	icon_state = "closed"
	id = "cells"
	max_integrity = 1200

/obj/machinery/door/poddoor/shutters/prison/update_icon()
	if(density)
		playsound(src, 'sound/valtos/prison/close.ogg', 20, 1)
		icon_state = "closed"
	else
		playsound(src, 'sound/valtos/prison/open.ogg', 20, 1)
		icon_state = "open"

/******************Structures Signs********************/

/obj/structure/sign/prison
	icon = 'icons/valtos/prison/prison.dmi'

/obj/structure/sign/prison/tablo
	name = "\improper Tablo"
	icon = 'icons/valtos/prison/prisonw.dmi'
	desc = "Табличка. Кусь."
	icon_state = "t1"

/obj/structure/sign/prison/tablo/Initialize()
	..()
	icon_state = "t[rand(1,18)]"

/obj/structure/sign/prison/uprava
	name = "\improper Uprava"
	icon = 'icons/valtos/prison/prisonw.dmi'
	desc = "Здесь решаются судьбы."
	icon_state = "uprava"

/obj/structure/sign/prison/blok1
	name = "\improper Block A"
	icon = 'icons/valtos/prison/prisonw.dmi'
	desc = "Родная хата."
	icon_state = "blocka"

/obj/structure/sign/prison/biblio
	name = "\improper Biblioteka"
	icon = 'icons/valtos/prison/prisonw.dmi'
	desc = "Обитель книг с голыми бабами."
	icon_state = "biblio"

/obj/structure/sign/prison/cross
	name = "\improper Church"
	icon = 'icons/valtos/prison/prisonw.dmi'
	desc = "Какой-то храм. Не сожгли благодаря кирпичным стенам."
	icon_state = "cross"

/obj/structure/sign/prison/stolov
	name = "\improper Stolovka"
	icon = 'icons/valtos/prison/prisonw.dmi'
	desc = "Говорят, что тут могут быть котлетки."
	icon_state = "stolov"

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

/********************Machinery***************************/

/obj/machinery/vending/sovietvend
	name = "\improper Soviet Vend"
	icon = 'icons/valtos/prison/prison.dmi'
	desc = "Каждому трудящемуся по инструменту!"
	icon_state = "sovietvend"
	product_ads = "За Царя и Страну.;А ты выполнил норму сегодня?;Слава Советскому Союзу!;Победим капиталистов сегодня!"
	products = list(/obj/item/clothing/under/soviet = 20, /obj/item/clothing/head/ushanka = 20, /obj/item/reagent_containers/food/snacks/candy = 40,
					/obj/item/reagent_containers/food/drinks/bottle/vodka = 40, /obj/item/gun/ballistic/automatic/ak = 3, /obj/item/ammo_box/magazine/ak762 = 10)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 20)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF

/obj/machinery/power/port_gen/pacman/coal
	name = "\improper HellMachine"
	desc = "Эта штука заставляет лампочки полыхать адским пламенем за счет сжигания угля. Сатанинская машина."
	icon = 'icons/valtos/prison/prisond.dmi'
	icon_state = "portgen0_0"
	base_icon = "portgen0"
	sheet_path = /obj/item/stack/sheet/mineral/coal
	power_gen = 15000
	time_per_sheet = 85
	density = TRUE
	anchored = TRUE

/********************Top Z-Levels***************************/

/obj/effect/bump_teleporter/prison/CollidedWith(atom/movable/AM)
	if(!ismob(AM))
		return
	if(!id_target)
		return

	for(var/obj/effect/bump_teleporter/BT in AllTeleporters)
		if(BT.id == src.id_target)
			AM.visible_message("<span class='boldwarning'>[AM] сорвался!</span>", "<span class='userdanger'>Кажется я упал...</span>")
			AM.forceMove(BT.loc) //Teleport to location with correct id.
			if(isliving(AM))
				var/mob/living/L = AM
				L.Knockdown(100)
				L.adjustBruteLoss(70)

/obj/effect/decal/tuman
	name = "tuman"
	desc = "Синий туман, похож на обман..."
	icon = 'icons/valtos/prison/prison.dmi'
	icon_state = "tuman"
	layer = 6

/********************Tiles***************************/

/obj/item/stack/tile/beton
	name = "beton floor tile"
	singular_name = "beton floor tile"
	desc = "Кусок бетона. Ммм..."
	icon = 'icons/valtos/prison/prison.dmi'
	icon_state = "tile_beton"
	turf_type = /turf/open/floor/beton

/obj/item/stack/tile/trot
	name = "trot floor tile"
	singular_name = "trot floor tile"
	desc = "Кусок тротуарной плитки. Зачем?"
	icon = 'icons/valtos/prison/prison.dmi'
	icon_state = "tile_trot"
	turf_type = /turf/open/floor/trot

/********************Plants***************************/

/obj/machinery/prisonplant
	name = "potted plant"
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-01"
	layer = 5
	anchored = 1

/obj/machinery/prisonplant/Initialize()
	..()
	icon_state = "plant-[rand(0,2)][rand(0,5)]"

/********************Misc-Deco****************************/

/obj/structure/chair/prison/wood
	name = "chair"
	desc = "Стул. Простой стул из дерева."
	icon = 'icons/valtos/prison/decor.dmi'
	icon_state = "chair"
	item_chair = null

/obj/structure/prison/fence
	name = "fence"
	desc = "Сложный забор. СЛОЖНЫЙ!"
	icon = 'icons/valtos/prison/decor.dmi'
	icon_state = "fence"
	pass_flags = LETPASSTHROW
	var/proj_pass_rate = 80
	layer = 5
	anchored = 1
	density = 1
	opacity = 0

/obj/structure/prison/fence/CanPass(atom/movable/mover, turf/target)
	if(locate(/obj/structure/prison/fence) in get_turf(mover))
		return 1
	else if(istype(mover, /obj/item/projectile))
		if(!anchored)
			return 1
		var/obj/item/projectile/proj = mover
		if(proj.firer && Adjacent(proj.firer))
			return 1
		if(prob(proj_pass_rate))
			return 1
		return 0
	else
		return !density

/obj/structure/prison/pipe
	name = "pipe"
	desc = "Идеальный путь на свободу. Но не сейчас."
	icon = 'icons/valtos/prison/decor.dmi'
	icon_state = "trubas"
	density = 0
	opacity = 0
	layer = 6
	alpha = 205

/obj/structure/table/prison
	desc = "Самый обычный стол из дерева, ничего интересного."
	icon = 'icons/valtos/prison/decor.dmi'
	icon_state = "table"
	smooth = SMOOTH_FALSE
	deconstruction_ready = 0
	max_integrity = 1000

/obj/structure/closet/pcloset
	name = "old cabinet"
	desc = "Довольно старый."
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70

/obj/effect/decal/prison/pipe
	name = "pipe"
	desc = "Тепленькая."
	icon = 'icons/valtos/prison/decor.dmi'
	icon_state = "pipe1"
	layer = 2.5
	pixel_y = 12

/obj/effect/decal/prison/pipe/pipea
	icon_state = "pipe2"

/obj/effect/decal/prison/pipe/pipeb
	icon_state = "pipe3"

/obj/effect/decal/prison/pipe/pipec
	icon_state = "pipe4"

/obj/effect/decal/prison/pipe/piped
	icon_state = "pipe5"

/obj/structure/prison/tv
	name = "tv"
	icon = 'icons/valtos/prison/prison.dmi'
	desc = "Наш любимый советский телевизор."
	icon_state = "TV"
	density = 1

/obj/structure/bed/prison/bed
	name = "bed"
	icon = 'icons/valtos/prison/decor.dmi'
	desc = "Тут можно отдохнуть, но не всегда."
	icon_state = "bed"

/********************Lights***************************/

/obj/machinery/light/streetlight
	name = "street light"
	icon = 'icons/valtos/prison/prisonh.dmi'
	base_state = "light"
	icon_state = "light1"
	max_integrity = 10000
	brightness = 10
	layer = 5
	density = 1
	light_type = /obj/item/light/bulb
	fitting = "bulb"
	pixel_y = 8

/obj/machinery/light/reinforced
	name = "durable light"
	desc = "Специально созданные лампы для защиты от содомитов."
	active_power_usage = 5
	max_integrity = 10000
	brightness = 10
	layer = 5

/********************Guns***************************/

/obj/item/gun/ballistic/automatic/ak
	name = "\improper AK-47"
	desc = "Легендарный автомат Калашникова. Использует патроны калибра 7.62"
	icon = 'icons/valtos/prison/prison.dmi'
	icon_state = "kalash"
	origin_tech = "combat=4;materials=2;syndicate=4"
	slot_flags = SLOT_BACK|SLOT_BELT
	mag_type = /obj/item/ammo_box/magazine/ak762
	fire_sound = 'sound/valtos/prison/ak74_shot.ogg'
	burst_size = 3
	w_class = 4
	can_suppress = 1
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'

/obj/item/gun/ballistic/automatic/ak/update_icon()
	..()
	cut_overlays()
	if(!select)
		add_overlay("[initial(icon_state)]semi")
	if(select == 1)
		add_overlay("[initial(icon_state)]burst")
	icon_state = "[initial(icon_state)][chambered ? "" : "-e"][suppressed ? "-suppressed" : ""]"

/obj/item/ammo_box/magazine/ak762
	name = "AK-47 magazine (7.62)"
	icon = 'icons/valtos/prison/prison.dmi'
	icon_state = "akmag"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 30

/*****************Mineral Sheets**********************/

/obj/item/stack/sheet/mineral/coal
	name = "coal"
	icon = 'icons/valtos/prison/prison.dmi'
	desc = "Черный как тот зек."
	singular_name = "coal"
	icon_state = "coal"
	throw_speed = 3
	throw_range = 5
	origin_tech = "materials=1"
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)

/*********************ID system*************************/

///obj/item/door_remote/soviet
//	name = "DOOR CONTROL 3000"
//	desc = "Позволяет контроллировать замки дверей."
//	icon_state = "gangtool-red"
//	region_access = list(ACCESS_SYNDICATE, ACCESS_SYNDICATE)

/obj/item/card/id/keys
	name = "keys"
	icon = 'icons/valtos/prison/prison.dmi'
	icon_state = "keys"
	desc = "Ключи от всех дверей"

/obj/item/card/id/keys/Initialize()
	access = get_all_syndicate_access()
	..()

/*********************Radio Shit*************************/

/obj/item/device/radio/headset/radioprison
	name = "soviet radio"
	icon = 'icons/valtos/prison/prison.dmi'
	desc = "Новейшая разработка советских ученых - рация!"
	canhear_range = 3
	frequency = 1469
	slot_flags = SLOT_EARS
	icon_state = "radio"
	flags_2 = BANG_PROTECT_2

/obj/item/device/radio/headset/radioprison/talk_into()
	. = ..()
	playsound(get_turf(src), 'sound/valtos/prison/radio.ogg', 50, 0)

/**********************Spawners**************************/

/obj/effect/mob_spawn/human/prison
	desc = "Кажется тут кто-то затаился под шконкой..."
	icon = 'icons/valtos/prison/prison.dmi'
	icon_state = "spwn"
	roundstart = FALSE
	death = FALSE
	density = 0
	var/list/imena = list("Петренко", "Гаврилов", "Смирнов", "Гмызенко", "Юлия", "Сафронов", "Павлов", "Пердюк", "Золотарев", "Михалыч", "Попов", "Лштшфум Ащьф")


/obj/effect/mob_spawn/human/prison/doctor
	name = "doctor spawner"
	flavour_text = "Вы вечный патологоанатом тюрьмы Ромашка. Постарайтесь следить за телами, живые они или нет, и не забывайте готовить мясо для котлет.<b> И да, смерти в этой тюрьме не приветствуются, Вы верующий человек и бог с Вами.</b>"
	outfit = /datum/outfit/prison/doctor
	assignedrole = "Doctor USSR"

/obj/effect/mob_spawn/human/prison/chaplain
	name = "prorok spawner"
	flavour_text = "Вы бывший заключенный тюрьмы Ромашка подавшийся в священнослужение. Помогайте чем можете всем нуждающимся.<b> И да, смерти в этой тюрьме не приветствуются, Вы верующий человек и бог с Вами.</b>"
	outfit = /datum/outfit/prison/chaplain
	assignedrole = "Prorok USSR"

/obj/effect/mob_spawn/human/prison/vertuhai
	name = "vertuhai spawner"
	flavour_text = "Вы вечный смотритель тюрьмы Ромашка. Постарайтесь не убивать зеков без приказа свыше и не забывайте кушать котлеты.<b> И да, смерти в этой тюрьме не приветствуются, Вы верующий человек и бог с Вами.</b>"
	outfit = /datum/outfit/prison/vertuhai
	assignedrole = "Vertuhai USSR"

/obj/effect/mob_spawn/human/prison/mehanik
	name = "mehanik spawner"
	flavour_text = "Вы вечный механик тюрьмы Ромашка. Постарайтесь не взорвать двигатель, починить, что не сломано и не забывайте спрашивать у зеков, когда котлеты будут там.<b> И да, смерти в этой тюрьме не приветствуются, Вы верующий человек и бог с Вами.</b>"
	outfit = /datum/outfit/prison/mehanik
	assignedrole = "Mehanik USSR"

/obj/effect/mob_spawn/human/prison/nachalnik
	name = "nachalnik spawner"
	flavour_text = "Вы вечный надзиратель тюрьмы Ромашка. Постарайтесь привести её в порядок и не забывайте напоминать зекам о том, что котлеты только завтра.<b> И да, смерти в этой тюрьме не приветствуются, Вы верующий человек и бог с Вами.</b>"
	icon_state = "spwn"
	outfit = /datum/outfit/prison/nachalnik
	assignedrole = "Nachalnik USSR"

/obj/effect/mob_spawn/human/prison/prisoner
	name = "shkonka spawner"
	desc = "Кажется тут кто-то затаился под шконкой..."
	flavour_text = "Вы вечный заключенный тюрьмы Ромашка. Отсиживайте свой тюремный срок как следует, слушайтесь начальника и не забывайте о том, что котлеты только завтра. Кстати, сидишь ты тут за "
	outfit = /datum/outfit/prison/prisoner
	assignedrole = "Prisoner USSR"

/**********************Outfits**************************/

/datum/outfit/prison/doctor
	name = "Doctor USSR"
	head = /obj/item/clothing/head/ushanka
	ears = /obj/item/device/radio/headset/radioprison
	uniform = /obj/item/clothing/under/prison/vertuhai
	suit = /obj/item/clothing/suit/toggle/labcoat
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	l_pocket = /obj/item/card/id/keys
	belt = /obj/item/storage/belt/military
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(/obj/item/device/flashlight/lantern = 1, /obj/item/crowbar/red = 1, /obj/item/melee/classic_baton = 1)
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/prison/vertuhai
	name = "Vertuhai USSR"
	head = /obj/item/clothing/head/ushanka
	ears = /obj/item/device/radio/headset/radioprison
	uniform = /obj/item/clothing/under/prison/vertuhai
	suit = /obj/item/clothing/suit/armor/ussr
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_pocket = /obj/item/restraints/handcuffs
	l_pocket = /obj/item/card/id/keys
	belt = /obj/item/storage/belt/military
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(/obj/item/device/flashlight/lantern = 1, /obj/item/crowbar/red = 1, /obj/item/melee/classic_baton = 1)
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/prison/mehanik
	name = "Mehanik USSR"
	head = /obj/item/clothing/head/ushanka
	ears = /obj/item/device/radio/headset/radioprison
	uniform = /obj/item/clothing/under/prison/vertuhai
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	l_pocket = /obj/item/card/id/keys
	belt = /obj/item/storage/belt/utility/full/engi
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(/obj/item/device/flashlight/lantern = 1, /obj/item/crowbar/red = 1, /obj/item/melee/classic_baton = 1)
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/prison/nachalnik
	name = "Nachalnik USSR"
	head = /obj/item/clothing/head/ushanka
	ears = /obj/item/device/radio/headset/radioprison
	uniform = /obj/item/clothing/under/prison/nach
	suit = /obj/item/clothing/suit/armor/ussr
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	l_pocket = /obj/item/card/id/keys
	belt = /obj/item/storage/belt/military
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(/obj/item/device/flashlight/lantern = 1, /obj/item/crowbar/red = 1, /obj/item/paper/fluff/awaymissions/prisonv2/nachruk = 1)
	implants = list(/obj/item/implant/weapons_auth)

/datum/outfit/prison/chaplain
	name = "Prorok USSR"
	uniform = /obj/item/clothing/under/rank/chaplain
	back = /obj/item/storage/backpack/satchel/leather
	shoes = /obj/item/clothing/shoes/sandal

/datum/outfit/prison/prisoner
	name = "Prisoner USSR"
	head = /obj/item/clothing/head/tyubet
	uniform = /obj/item/clothing/under/prison/prison
	shoes = /obj/item/clothing/shoes/sandal

/**********************Spawn-flavoures**************************/

/obj/effect/mob_spawn/human/prison/doctor/special(mob/living/L)
	L.real_name = "Доктор [pick(imena)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/chaplain/special(mob/living/L)
	L.real_name = "Пророк [pick(imena)]"
	L.name = L.real_name
	if(L.mind)
		L.mind.isholy = TRUE

/obj/effect/mob_spawn/human/prison/vertuhai/special(mob/living/L)
	L.real_name = "Смотритель [pick(imena)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/mehanik/special(mob/living/L)
	L.real_name = "Механик [pick(imena)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/nachalnik/special(mob/living/L)
	L.real_name = "Начальник [pick(imena)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/prisoner/special(mob/living/L)
	var/list/klikuhi = list("Борзый", "Дохляк", "Академик", "Акула", "Базарило", "Бродяга", "Валет", "Воровайка", "Гнедой", \
	"Гребень", "Дельфин", "Дырявый", "Игловой", "Карась", "Каторжанин", "Лабух", "Мазурик", "Мокрушник", "Понтовитый", \
	"Ржавый", "Седой", "Сявка", "Темнила", "Чайка", "Чепушило", "Шакал", "Шерстяной", "Шмаровоз", "Шпилевой", "Олька", "Машка", \
	"Щипач", "Якорник", "Сладкий", "Семьянин", "Порученец", "Блатной", "Арап", "Артист", "Апельсин", "Афер", "Кабан", "Угрюмый")
	L.real_name = "[pick(klikuhi)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/prisoner/Initialize(mapload)
	. = ..()
	var/list/zacho = list("убийство", "воровство", "коррупцию", "неисполнение обязанностей", "похищение людей", "грубую некомпетентность", \
	"кражу", "организацию секты", "изнасилование", "мятеж", "мемы", "недоносительство", "педофилию")
	flavour_text += "[pick(zacho)].</b>."

/**********************Notes*********************************/

/obj/item/paper/fluff/awaymissions/prisonv2/nachruk
	name = "Activity Log"
	info = {"<center><b>Как стать прилежным начальником тюрьмы "Ромашка".</b></center><br>Это руководство поможет Вам управиться с заключенными и при этом выжить. <i>Если у Вас есть более лучшие планы и вы знаете как управлять тюрьмой, то можете проигнорировать эту заметку.</i><br><br><center><b>Я проснулся, что мне делать?</b></center><br>Первым делом соберите всех своих смотрителей в каком-нибудь месте, ваш кабинет будет идеальным местом для этого, далее, назначьте их на посты, постов тут несколько, перейдем к ним:<br><b>Блок "А"</b> - самая опасная зона среди всех, тут находятся зеки. Два здоровых мужика управятся, если не брать много на грудь.<br><b>Качалочка</b> - тут развлекаются зеки с вашего позволения. Два смотрителя достаточно.<br><b>Пост у ворот</b> - здесь выход наружу в шахту, желательно послать туда как минимум двух человек для присмотра за <b>Оружейкой</b>.<br><b>Гидропоника</b> - находится в южной части тюрьмы в подвале, найдете у забора. Также там находится проход к карцерам. Хватит одного смотрителя.<br><b>Улицы</b> - одного хватит.<br><b>Западные улицы</b> - тут находится церковь и библиотека. Учтите, что местный священник - бывший заключенный и мало ли что ему придет на ум. Одного охранника достаточно.<br><b>Все остальное по необходимости</b>.<br><br>После того как разбили всех по постам, настало время нажать важную кнопку LOCKDOWN - она поднимет ставни на важных отсеках, но блокировка на камерах останется. Ее нужно будет снимать вручную, всего в камере одновременно может находиться до двух зеков, камер 10, по 5 на каждом этаже.<br>Отлично, теперь можно набирать желающих зеков на работу, для этого зовите их к себе в кабинет, выдавайте наплечные повязки и отправляйте работать в нужный отдел. Повязки находятся в шкафу у вас в кабинете. Также рекоммендуется вести личное дело каждого рабочего, дабы не было путаницы.<<br><center><b>Кажется у нас бунт!</b></center><br>Первым делом жмите кнопку LOCKDOWN и другие панические кнопки запирающие шлюзы. Теперь не паникуйте, возьмите гранатомет из своего шкафа и коробку со светошумовыми, заправьте его и погасите восстаните, отправив всех в своих камеры. Если они продолжают сопротивление, то можете стрелять на поражение.<br><br><center><b>Все работает, что дальше?</b></center><br>У вас есть в наличии механики. Это не простые люди, они обеспечивают тюрьму светом, ремонтируют ее и продвигают науку. Вы же отправили кого-то добывать уголь? <br>Гидропоника не даст умереть вам с голоду. Там тоже должна быть рабочая сила.<br>Набирайте лояльных заключенных в персонал, только не стоит выдавать им ключи сразу, они суки хитрые.<br><br><i>На этом все, надеюсь тебе помогут мои советы, ну а я пошел в камеру. С уважением, зек "Сгущенка"</i>"}

