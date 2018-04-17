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

/area/prisonv2out
	name = "Caves USSR"
	icon_state = "yellow"
	requires_power = TRUE
	has_gravity = TRUE
	noteleport = TRUE
	blob_allowed = FALSE
	flags_1 = NONE

/**********************Turf Walls**************************/

/turf/closed/wall/brick
	name = "brick wall"
	desc = "Èçíà÷àëüíî ýòè ñòåíû áûëè áåëîãî öâåòà, íî ñî âðåìåíåì ëþäè ñòàëè èõ êðàñèòü. Ñîáîé."
	icon = 'icons/turf/walls/brick_wall.dmi'
	icon_state = "brick"
	hardness = 4500
	explosion_block = 5
	slicing_duration = 20000
	canSmoothWith = list(/turf/closed/wall/brick, /obj/structure/falsewall/brick)

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
		/turf/closed/mineral/uranium/dirty = 3, /turf/closed/mineral/diamond/dirty = 3, /turf/closed/mineral/gold/dirty = 3, /turf/closed/mineral/titanium/dirty = 3,
		/turf/closed/mineral/silver/dirty = 3, /turf/closed/mineral/plasma/dirty = 3, /turf/closed/mineral/bscrystal/dirty = 3, /turf/closed/mineral/coal = 25)

/**********************Turf Floors**************************/

/turf/open/floor/plating/asteroid/dirty
	name = "dirt"
	desc = "Ìÿãåíüêàÿ."
	icon = 'icons/misc/prison.dmi'
	postdig_icon_change = TRUE
	icon_state = "dirt"
	icon_plating = "dirt"
	environment_type = "dirt"
	turf_type = /turf/open/floor/plating/asteroid/dirty
	floor_variance = 0
	initial_gas_mix = "o2=22;n2=82;TEMP=225.15"
	archdrops = list(/obj/item/ore/glass = 5)
	slowdown = 3

/turf/open/floor/trot
	name = "trotuar"
	desc = "Â ñàìûé ðàç äëÿ ïðîáåæåê."
	icon_state = "trot"
	initial_gas_mix = "o2=22;n2=82;TEMP=248.15"
	icon = 'icons/misc/beton.dmi'
	floor_tile = /obj/item/stack/tile/trot
	slowdown = -1
	broken_states = list("damaged")

/turf/open/floor/beton
	name = "beton"
	desc = "Ïàäàòü íà íåãî íå ñàìûé ëó÷øèé âàðèàíò."
	icon_state = "beton"
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"
	icon = 'icons/misc/beton.dmi'
	floor_tile = /obj/item/stack/tile/beton
	broken_states = list("damaged")
	smooth = SMOOTH_TRUE
	canSmoothWith = list(/turf/open/floor/beton)
	flags_1 = NONE

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
	desc = "Èçíà÷àëüíî ýòè ñòåíû áûëè áåëîãî öâåòà, íî ñî âðåìåíåì ëþäè ñòàëè èõ êðàñèòü. Ñîáîé."
	icon = 'icons/turf/walls/brick_wall.dmi'
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
	desc = "Ñòèëüíàÿ ðóáàøêà ê íå ìåíåå ìîäíûì øòàíàì."
	icon = 'icons/valtos/prison/uniform.dmi'
	icon_state = "nach"
	item_state = "nach"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 50)
	strip_delay = 60

/obj/item/clothing/under/prison/vertuhai
	name = "vertuhai suit"
	desc = "Ñòàíäàðòíàÿ óíèôîðìà âîåííîñëóæàùåãî."
	icon = 'icons/valtos/prison/uniform.dmi'
	icon_state = "vert"
	item_state = "vert"
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0, fire = 50, acid = 50)
	strip_delay = 60

/obj/item/clothing/under/prison/prison
	desc = "Ôîðìà óëè÷íîãî ìèìà. Ïîãîäèòå-êà... Íåò, âñå òàêè òþðåìíàÿ."
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
	desc = "Êðåïêèé è òåïëûé."
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
	desc = "Êðåïêàÿ êàñêà."
	icon = 'icons/valtos/prison/uniform.dmi'
	icon_state = "helm"
	item_state = "helm"
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 40, bomb = 60, bio = 0, rad = 0, fire = 60, acid = 60)

/obj/item/clothing/head/tyubet
	name = "tybeteika"
	desc = "Òþáåòåéêà."
	icon = 'icons/valtos/prison/uniform.dmi'
	icon_state = "phat"
	item_state = "phat"

/******************Doors*******************************/

/obj/machinery/door/airlock/prison
	name = "door"
	icon = 'icons/valtos/prison/doors.dmi'
	assemblytype = /obj/structure/door_assembly/door_assembly_wood
	desc = "Îáû÷íàÿ ñòàëüíàÿ äâåðü ïîêðûòàÿ ïëîòíûì ñëîåì äåðåâà."
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
	desc = "Ñâåðõêðåïêàÿ."
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
	desc = "Òàáëè÷êà. Êóñü."
	icon_state = "t1"

/obj/structure/sign/prison/tablo/Initialize()
	..()
	icon_state = "t[rand(1,18)]"

/obj/structure/sign/prison/uprava
	name = "\improper Uprava"
	icon = 'icons/misc/prisonw.dmi'
	desc = "Çäåñü ðåøàþòñÿ ñóäüáû."
	icon_state = "uprava"

/obj/structure/sign/prison/blok1
	name = "\improper Blok 1"
	desc = "Ðîäíàÿ õàòà."
	icon_state = "blok1"

/obj/structure/sign/prison/tok
	name = "\improper Ne prikasaisya!"
	desc = "Íå ïðèêàñàéñÿ!"
	icon_state = "tok"

/obj/structure/sign/prison/hitler
	name = "\improper Hitler"
	desc = "Êàêîé êðàñèâûé ìàëü÷èê."
	icon_state = "hitler"

/obj/structure/sign/prison/net
	name = "\improper Net!"
	desc = "Íåò!"
	icon_state = "net"

/obj/structure/sign/prison/kolesa
	name = "\improper Pomni o kolesah"
	desc = "Ïîìíè î êîëåñàõ."
	icon_state = "kolesa"

/obj/structure/sign/prison/pobeda
	name = "\improper K novym pobedam!"
	desc = "Ê íîâûì ïîáåäàì â òðóäå è ñïîðòå!"
	icon_state = "pobeda"

/obj/structure/sign/prison/bolt
	name = "\improper Ne boltay!"
	desc = "Íå áîëòàé!"
	icon_state = "bolt"

/obj/structure/sign/prison/pyan
	name = "\improper Byl pyan"
	desc = "ß íà ïðîèçâîäñòâå áûë ïüÿí."
	icon_state = "pyan"

/obj/structure/sign/prison/yannp
	name = "\improper Ne ponyal!"
	desc = "Ó ìåíÿ âîçíèê êîãíèòèâíûé äèññîíàíñ!"
	icon_state = "yannp"

/obj/structure/sign/prison/bolt
	name = "\improper Ne boltay!"
	desc = "Íå áîëòàé!."
	icon_state = "bolt"

/********************Machinery***************************/

/obj/machinery/vending/sovietvend
	name = "\improper Soviet Vend"
	icon = 'icons/misc/prison.dmi'
	desc = "Êàæäîìó òðóäÿùåìóñÿ ïî èíñòðóìåíòó!"
	icon_state = "sovietvend"
	product_ads = "Çà Öàðÿ è Ñòðàíó.;À òû âûïîëíèë íîðìó ñåãîäíÿ?;Ñëàâà Ñîâåòñêîìó Ñîþçó!"
	products = list(/obj/item/clothing/under/soviet = 20, /obj/item/clothing/head/ushanka = 20, /obj/item/reagent_containers/food/snacks/candy = 40,
					/obj/item/reagent_containers/food/drinks/bottle/vodka = 40, /obj/item/gun/ballistic/automatic/ak = 5, /obj/item/ammo_box/magazine/ak762 = 5)
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
	desc = "Ýòà øòóêà çàñòàâëÿåò ëàìïî÷êè ïîëûõàòü àäñêèì ïëàìåíåì çà ñ÷åò ñæèãàíèÿ óãëÿ. Ñàòàíèíñêàÿ ìàøèíà."
	icon = 'icons/misc/prisond.dmi'
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
			AM.visible_message("<span class='boldwarning'>[AM] ñîðâàëñÿ!</span>", "<span class='userdanger'>Êàæåòñÿ ÿ óïàë...</span>")
			AM.forceMove(BT.loc) //Teleport to location with correct id.
			if(isliving(AM))
				var/mob/living/L = AM
				L.Knockdown(100)
				L.adjustBruteLoss(70)

/obj/effect/decal/tuman
	name = "tuman"
	desc = "Ñèíèé òóìàí, ïîõîæ íà îáìàí..."
	icon = 'icons/misc/prison.dmi'
	icon_state = "tuman"
	layer = 6

/********************Tiles***************************/

/obj/item/stack/tile/beton
	name = "beton floor tile"
	singular_name = "beton floor tile"
	desc = "Êóñîê áåòîíà. Ììì..."
	icon = 'icons/misc/prison.dmi'
	icon_state = "tile_beton"
	turf_type = /turf/open/floor/beton

/obj/item/stack/tile/trot
	name = "trot floor tile"
	singular_name = "trot floor tile"
	desc = "Êóñîê òðîòóàðíîé ïëèòêè. Çà÷åì?"
	icon = 'icons/misc/prison.dmi'
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
	desc = "Ñòóë. Ïðîñòîé ñòóë èç äåðåâà."
	icon = 'icons/valtos/prison/decor.dmi'
	icon_state = "chair"
	item_chair = null

/obj/structure/prison/fence
	name = "fence"
	desc = "Ñëîæíûé çàáîð. ÑËÎÆÍÛÉ!"
	icon = 'icons/valtos/prison/decor.dmi'
	icon_state = "fence"
	pass_flags = LETPASSTHROW
	var/proj_pass_rate = 80
	max_integrity = 1000
	damage_deflection = 10
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
	desc = "Èäåàëüíûé ïóòü íà ñâîáîäó. Íî íå ñåé÷àñ."
	icon = 'icons/valtos/prison/decor.dmi'
	icon_state = "trubas"
	density = 0
	opacity = 0
	layer = 6
	alpha = 205

/obj/structure/table/prison
	desc = "Ñàìûé îáû÷íûé ñòîë èç äåðåâà, íè÷åãî èíòåðåñíîãî."
	icon = 'icons/valtos/prison/decor.dmi'
	icon_state = "table"
	smooth = SMOOTH_FALSE
	deconstruction_ready = 0
	max_integrity = 1000

/obj/structure/closet/pcloset
	name = "old cabinet"
	desc = "Äîâîëüíî ñòàðûé."
	icon_state = "cabinet"
	resistance_flags = FLAMMABLE
	max_integrity = 70

/obj/effect/decal/prison/pipe
	name = "pipe"
	desc = "Òåïëåíüêàÿ."
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
	desc = "Íàø ëþáèìûé ñîâåòñêèé òåëåâèçîð."
	icon_state = "TV"
	density = 1

/obj/structure/bed/prison/bed
	name = "bed"
	icon = 'icons/valtos/prison/decor.dmi'
	desc = "Òóò ìîæíî îòäîõíóòü, íî íå âñåãäà."
	icon_state = "bed"

/********************Lights***************************/

/obj/machinery/light/streetlight
	name = "street light"
	icon = 'icons/misc/prisonh.dmi'
	base_state = "light"
	icon_state = "light1"
	brightness = 10
	layer = 5
	density = 1
	light_type = /obj/item/light/bulb
	fitting = "bulb"

/********************Guns***************************/

/obj/item/gun/ballistic/automatic/ak
	name = "\improper AK-47"
	desc = "Ëåãåíäàðíûé àâòîìàò Êàëàøíèêîâà. Èñïîëüçóåò ïàòðîíû êàëèáðà 7.62"
	icon = 'icons/misc/prison.dmi'
	icon_state = "kalash"
	origin_tech = "combat=4;materials=2;syndicate=4"
	mag_type = /obj/item/ammo_box/magazine/ak762
	burst_size = 3

/obj/item/ammo_box/magazine/ak762
	name = "AK-47 magazine (7.62)"
	icon = 'icons/misc/prison.dmi'
	icon_state = "akmag"
	ammo_type = /obj/item/ammo_casing/a762
	caliber = "a762"
	max_ammo = 30

/*****************Mineral Sheets**********************/

/obj/item/stack/sheet/mineral/coal
	name = "coal"
	icon = 'icons/misc/prison.dmi'
	desc = "×åðíûé êàê òîò çåê."
	singular_name = "coal"
	icon_state = "coal"
	throw_speed = 3
	throw_range = 5
	origin_tech = "materials=1"
	materials = list(MAT_DIAMOND=MINERAL_MATERIAL_AMOUNT)

/*********************ID system*************************/

/obj/item/card/id/keys
	name = "keys"
	icon = 'icons/misc/prison.dmi'
	icon_state = "keys"
	desc = "Êëþ÷è îò âñåõ äâåðåé"

/obj/item/card/id/keys/Initialize()
	access = get_all_syndicate_access()
	..()

/*********************Sovietlathe************************/

/obj/machinery/autolathe/soviet
	name = "sovietlathe"
	circuit = /obj/item/circuitboard/machine/autolathe/soviet
	categories = list(
							"Tools",
							"Electronics",
							"T-Comm",
							"Security",
							"Machinery",
							"Medical",
							"Misc",
							"Dinnerware",
							"Imported"
							)

/obj/item/circuitboard/machine/autolathe/soviet
	name = "Sovietlathe (Machine Board)"
	build_path = /obj/machinery/autolathe/soviet

/*********************Radio Shit*************************/

/obj/item/device/radio/headset/radioprison
	name = "soviet radio"
	icon = 'icons/misc/prison.dmi'
	desc = "Íîâåéøàÿ ðàçðàáîòêà ñîâåòñêèõ ó÷åíûõ - ðàöèÿ!"
	canhear_range = 3
	frequency = 1469
	slot_flags = SLOT_EARS
	icon_state = "radio"
	flags_2 = BANG_PROTECT_2

/**********************Spawners**************************/

/obj/effect/mob_spawn/human/prison
	desc = "Êàæåòñÿ òóò êòî-òî çàòàèëñÿ ïîä øêîíêîé..."
	icon = 'icons/misc/prison.dmi'
	icon_state = "spwn"
	roundstart = FALSE
	death = FALSE
	var/list/imena = list("Ïåòðåíêî", "Ãàâðèëîâ", "Ñìèðíîâ", "Ãìûçåíêî", "Þëèÿ", "Ñàôðîíîâ", "Ïàâëîâ", "Ïåðäþê", "Çîëîòàðåâ", "Ìèõàëû÷", "Ïîïîâ", "Ëøòøôóì Àùüô")


/obj/effect/mob_spawn/human/prison/doctor
	name = "doctor spawner"
	flavour_text = "Âû âå÷íûé ïàòîëîãîàíàòîì òþðüìû Ðîìàøêà. Ïîñòàðàéòåñü ñëåäèòü çà òåëàìè, æèâûå îíè èëè íåò, è íå çàáûâàéòå ãîòîâèòü ìÿñî äëÿ êîòëåò.<b> Óáèâàòü è ñáåãàòü áåç îñîáîé ïðè÷èíû çàïðåùåíî, èíà÷å Âàñ çàáàíÿò. Ïðàâèëà òóò ðàáîòàþò â ïîëíóþ ñèëó.</b>"
	outfit = /datum/outfit/prison/doctor
	assignedrole = "Doctor USSR"

/obj/effect/mob_spawn/human/prison/chaplain
	name = "prorok spawner"
	flavour_text = "Âû áûâøèé çàêëþ÷åííûé òþðüìû Ðîìàøêà ïîäàâøèéñÿ â ñâÿùåííîñëóæåíèå. Ïîìîãàéòå ÷åì ìîæåòå âñåì íóæäàþùèìñÿ.<b> Óáèâàòü è ñáåãàòü áåç îñîáîé ïðè÷èíû çàïðåùåíî, èíà÷å Âàñ çàáàíÿò. Ïðàâèëà òóò ðàáîòàþò â ïîëíóþ ñèëó.</b>"
	outfit = /datum/outfit/prison/chaplain
	assignedrole = "Prorok USSR"

/obj/effect/mob_spawn/human/prison/vertuhai
	name = "vertuhai spawner"
	flavour_text = "Âû âå÷íûé ñìîòðèòåëü òþðüìû Ðîìàøêà. Ïîñòàðàéòåñü íå óáèâàòü çåêîâ áåç ïðèêàçà ñâûøå è íå çàáûâàéòå êóøàòü êîòëåòû.<b> Óáèâàòü è ñáåãàòü áåç îñîáîé ïðè÷èíû çàïðåùåíî, èíà÷å Âàñ çàáàíÿò. Ïðàâèëà òóò ðàáîòàþò â ïîëíóþ ñèëó.</b>"
	outfit = /datum/outfit/prison/vertuhai
	assignedrole = "Vertuhai USSR"

/obj/effect/mob_spawn/human/prison/mehanik
	name = "mehanik spawner"
	flavour_text = "Âû âå÷íûé ìåõàíèê òþðüìû Ðîìàøêà. Ïîñòàðàéòåñü íå âçîðâàòü äâèãàòåëü, ïî÷èíèòü, ÷òî íå ñëîìàíî è íå çàáûâàéòå ñïðàøèâàòü ó çåêîâ, êîãäà êîòëåòû áóäóò òàì.<b> Óáèâàòü è ñáåãàòü áåç îñîáîé ïðè÷èíû çàïðåùåíî, èíà÷å Âàñ çàáàíÿò. Ïðàâèëà òóò ðàáîòàþò â ïîëíóþ ñèëó.</b>"
	outfit = /datum/outfit/prison/mehanik
	assignedrole = "Mehanik USSR"

/obj/effect/mob_spawn/human/prison/nachalnik
	name = "nachalnik spawner"
	flavour_text = "Âû âå÷íûé íàäçèðàòåëü òþðüìû Ðîìàøêà. Ïîñòàðàéòåñü ïðèâåñòè å¸ â ïîðÿäîê è íå çàáûâàéòå íàïîìèíàòü çåêàì î òîì, ÷òî êîòëåòû òîëüêî çàâòðà.<b> Óáèâàòü è ñáåãàòü áåç îñîáîé ïðè÷èíû çàïðåùåíî, èíà÷å Âàñ çàáàíÿò. Ïðàâèëà òóò ðàáîòàþò â ïîëíóþ ñèëó.</b>"
	icon_state = "spwn"
	outfit = /datum/outfit/prison/nachalnik
	assignedrole = "Nachalnik USSR"

/obj/effect/mob_spawn/human/prison/prisoner
	name = "shkonka spawner"
	desc = "Êàæåòñÿ òóò êòî-òî çàòàèëñÿ ïîä øêîíêîé..."
	flavour_text = "Âû âå÷íûé çàêëþ÷åííûé òþðüìû Ðîìàøêà. Îòñèæèâàéòå ñâîé òþðåìíûé ñðîê êàê ñëåäóåò, ñëóøàéòåñü íà÷àëüíèêà è íå çàáûâàéòå î òîì, ÷òî êîòëåòû òîëüêî çàâòðà.<b> Óáèâàòü è ñáåãàòü áåç îñîáîé ïðè÷èíû çàïðåùåíî, èíà÷å Âàñ çàáàíÿò. Ïðàâèëà òóò ðàáîòàþò â ïîëíóþ ñèëó.</b> Êñòàòè, ñèäèøü òû òóò çà "
	outfit = /datum/outfit/prison/prisoner
	assignedrole = "Prisoner USSR"

/**********************Outfits**************************/

/datum/outfit/prison/doctor
	name = "Doctor USSR"
	head = /obj/item/clothing/head/ushanka
	ears = /obj/item/device/radio/headset/radioprison
	uniform = /obj/item/clothing/under/soviet
	suit = /obj/item/clothing/suit/toggle/labcoat
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	l_pocket = /obj/item/card/id/keys
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(/obj/item/device/flashlight/lantern = 1, /obj/item/crowbar/red = 1, /obj/item/melee/classic_baton = 1)
	implants = list(/obj/item/implant/weapons_auth, /obj/item/implant/exile)

/datum/outfit/prison/vertuhai
	name = "Vertuhai USSR"
	head = /obj/item/clothing/head/ushanka
	ears = /obj/item/device/radio/headset/radioprison
	uniform = /obj/item/clothing/under/soviet
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_pocket = /obj/item/restraints/handcuffs
	l_pocket = /obj/item/card/id/keys
	belt = /obj/item/melee/classic_baton
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(/obj/item/device/flashlight/lantern = 1, /obj/item/crowbar/red = 1, /obj/item/melee/classic_baton = 1)
	implants = list(/obj/item/implant/weapons_auth, /obj/item/implant/exile)

/datum/outfit/prison/mehanik
	name = "Mehanik USSR"
	head = /obj/item/clothing/head/ushanka
	ears = /obj/item/device/radio/headset/radioprison
	uniform = /obj/item/clothing/under/soviet
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	l_pocket = /obj/item/card/id/keys
	belt = /obj/item/storage/belt/utility/full/engi
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(/obj/item/device/flashlight/lantern = 1, /obj/item/crowbar/red = 1, /obj/item/melee/classic_baton = 1)
	implants = list(/obj/item/implant/weapons_auth, /obj/item/implant/exile)

/datum/outfit/prison/nachalnik
	name = "Nachalnik USSR"
	head = /obj/item/clothing/head/ushanka
	ears = /obj/item/device/radio/headset/radioprison
	uniform = /obj/item/clothing/under/syndicate/combat
	suit = /obj/item/clothing/suit/armor/vest/capcarapace/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	r_pocket = /obj/item/gun/ballistic/automatic/pistol
	l_pocket = /obj/item/card/id/keys
	belt = /obj/item/storage/belt/military
	back = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(/obj/item/device/flashlight/lantern = 1, /obj/item/crowbar/red = 1, /obj/item/paper/fluff/awaymissions/prisonv2/nachruk = 1)
	implants = list(/obj/item/implant/weapons_auth, /obj/item/implant/exile)

/datum/outfit/prison/prisoner
	name = "Prisoner USSR"
	uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/sneakers/orange

/**********************Spawn-flavoures**************************/

/obj/effect/mob_spawn/human/prison/doctor/special(mob/living/L)
	L.real_name = "Äîêòîð [pick(imena)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/vertuhai/special(mob/living/L)
	L.real_name = "Ñìîòðèòåëü [pick(imena)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/mehanik/special(mob/living/L)
	L.real_name = "Ìåõàíèê [pick(imena)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/nachalnik/special(mob/living/L)
	L.real_name = "Íà÷àëüíèê [pick(imena)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/prisoner/special(mob/living/L)
	var/list/klikuhi = list("Áîðçûé", "Äîõëÿê", "Àêàäåìèê", "Àêóëà", "Áàçàðèëî", "Áðîäÿãà", "Âàëåò", "Âîðîâàéêà", "Ãíåäîé", \
	"Ãðåáåíü", "Äåëüôèí", "Äûðÿâûé", "Èãëîâîé", "Êàðàñü", "Êàòîðæàíèí", "Ëàáóõ", "Ìàçóðèê", "Ìîêðóøíèê", "Ïîíòîâèòûé", \
	"Ðæàâûé", "Ñåäîé", "Ñÿâêà", "Òåìíèëà", "×àéêà", "×åïóøèëî", "Øàêàë", "Øåðñòÿíîé", "Øìàðîâîç", "Øïèëåâîé", "Îëüêà", "Ìàøêà", \
	"Ùèïà÷", "ßêîðíèê", "Ñëàäêèé", "Ñåìüÿíèí", "Ïîðó÷åíåö", "Áëàòíîé", "Àðàï", "Àðòèñò", "Àïåëüñèí", "Àôåð")
	L.real_name = "[pick(klikuhi)]"
	L.name = L.real_name

/obj/effect/mob_spawn/human/prison/prisoner/Initialize(mapload)
	. = ..()
	var/list/zacho = list("óáèéñòâî", "âîðîâñòâî", "êîððóïöèþ", "íåèñïîëíåíèå îáÿçàííîñòåé", "ïîõèùåíèå ëþäåé", "ãðóáóþ íåêîìïåòåíòíîñòü", \
	"êðàæó", "ïîêëîíåíèå çàïðåùåííîìó áîæåñòâó", "ìåæâèäîâûå îòíîøåíèÿ", "ìÿòåæ")
	flavour_text += "[pick(zacho)].</b>."

