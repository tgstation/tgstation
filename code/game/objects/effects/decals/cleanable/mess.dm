/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Кто-то должен это убрать."
	icon = 'icons/obj/debris.dmi'
	icon_state = "shards"
	beauty = -50

/obj/effect/decal/cleanable/ash
	name = "ashes"
	desc = "Пепел к пеплу, пыль к пыли и в космос."
	icon = 'icons/obj/debris.dmi'
	icon_state = "ash"
	plane = GAME_PLANE
	layer = CLEANABLE_OBJECT_LAYER
	mergeable_decal = FALSE
	beauty = -50
	decal_reagent = /datum/reagent/ash
	reagent_amount = 30

/obj/effect/decal/cleanable/ash/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

/obj/effect/decal/cleanable/ash/NeverShouldHaveComeHere(turf/here_turf)
	return !istype(here_turf, /obj/structure/bodycontainer/crematorium) && ..()

/obj/effect/decal/cleanable/ash/large
	name = "large pile of ashes"
	icon_state = "big_ash"
	beauty = -100
	decal_reagent = /datum/reagent/ash
	reagent_amount = 60

/obj/effect/decal/cleanable/glass
	name = "tiny shards"
	desc = "Обратно в песок."
	icon = 'icons/obj/debris.dmi'
	icon_state = "tiny"
	beauty = -100

/obj/effect/decal/cleanable/glass/Initialize(mapload)
	. = ..()
	setDir(pick(GLOB.cardinals))

/obj/effect/decal/cleanable/glass/ex_act()
	qdel(src)
	return TRUE

/obj/effect/decal/cleanable/glass/plasma
	icon_state = "plasmatiny"

/obj/effect/decal/cleanable/glass/titanium
	icon_state = "titaniumtiny"

/obj/effect/decal/cleanable/glass/plastitanium
	icon_state = "plastitaniumtiny"

//Screws that are dropped on the Z level below when deconstructing a reinforced floor plate.
/obj/effect/decal/cleanable/glass/plastitanium/screws //I don't know how to sprite scattered screws, this can work until a spriter gets their hands on it.
	name = "pile of screws"
	desc = "Выглядит так, будто они упали с потолка."

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Кто-то должен это убрать."
	icon = 'icons/effects/dirt_misc.dmi'
	icon_state = "dirt-flat-0"
	base_icon_state = "dirt"
	smoothing_flags = NONE
	smoothing_groups = SMOOTH_GROUP_CLEANABLE_DIRT
	canSmoothWith = SMOOTH_GROUP_CLEANABLE_DIRT + SMOOTH_GROUP_WALLS
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	beauty = -75
	/// Set to FALSE if your dirt has no smoothing sprites
	var/is_tileable = TRUE

/obj/effect/decal/cleanable/dirt/Initialize(mapload)
	. = ..()
	icon_state = pick("dirt-flat-0","dirt-flat-1","dirt-flat-2","dirt-flat-3")
	var/obj/structure/broken_flooring/broken_flooring = locate(/obj/structure/broken_flooring) in loc
	if(!isnull(broken_flooring))
		return
	var/turf/T = get_turf(src)
	if(T.tiled_turf && is_tileable)
		icon = 'icons/effects/dirt.dmi'
		icon_state = "dirt-0"
		smoothing_flags = SMOOTH_BITMASK
		QUEUE_SMOOTH(src)
	if(smoothing_flags & USES_SMOOTHING)
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/effect/decal/cleanable/dirt/Destroy()
	if(smoothing_flags & USES_SMOOTHING)
		QUEUE_SMOOTH_NEIGHBORS(src)
	return ..()

/obj/effect/decal/cleanable/dirt/dust
	name = "dust"
	desc = "Пол покрыт тонким слоем пыли."
	icon_state = "dust"
	base_icon_state = "dust"
	is_tileable = FALSE

/obj/effect/decal/cleanable/dirt/dust/Initialize(mapload)
	. = ..()
	icon_state = base_icon_state

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Боже. Надеюсь, это не на обед."
	icon_state = "greenglow"
	light_power = 3
	light_range = 2
	light_color = LIGHT_COLOR_GREEN
	beauty = -300

/obj/effect/decal/cleanable/greenglow/ex_act()
	return FALSE

/obj/effect/decal/cleanable/greenglow/filled
	decal_reagent = /datum/reagent/uranium
	reagent_amount = 5

/obj/effect/decal/cleanable/greenglow/filled/Initialize(mapload)
	decal_reagent = pick(/datum/reagent/uranium, /datum/reagent/uranium/radium)
	. = ..()

/obj/effect/decal/cleanable/greenglow/ecto
	name = "ectoplasmic puddle"
	desc = "Вы знаете, кому звонить."
	light_power = 2

/obj/effect/decal/cleanable/greenglow/radioactive
	name = "radioactive goo"
	desc = "Святые угодники, немедленно прекратите смотреть на это и уйдите подальше! Это радиоактивно!"
	light_power = 5
	light_range = 3
	light_color = LIGHT_COLOR_NUCLEAR

/obj/effect/decal/cleanable/greenglow/radioactive/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	AddComponent(
		/datum/component/radioactive_emitter, \
		cooldown_time = 5 SECONDS, \
		range = 4, \
		threshold = RAD_MEDIUM_INSULATION, \
	)

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Кто-то должен это убрать."
	gender = NEUTER
	plane = GAME_PLANE
	layer = WALL_OBJ_LAYER
	icon = 'icons/effects/web.dmi'
	icon_state = "cobweb1"
	resistance_flags = FLAMMABLE
	beauty = -100
	clean_type = CLEAN_TYPE_HARD_DECAL
	is_mopped = FALSE

/obj/effect/decal/cleanable/cobweb/cobweb2
	icon_state = "cobweb2"

/obj/effect/decal/cleanable/molten_object
	name = "gooey grey mass"
	desc = "Это похоже на расплавленное... что-то."
	gender = NEUTER
	icon = 'icons/effects/effects.dmi'
	icon_state = "molten"
	plane = GAME_PLANE
	layer = CLEANABLE_OBJECT_LAYER
	mergeable_decal = FALSE
	beauty = -150
	clean_type = CLEAN_TYPE_HARD_DECAL

/obj/effect/decal/cleanable/molten_object/large
	name = "big gooey grey mass"
	icon_state = "big_molten"
	beauty = -300

//Vomit (sorry)
/obj/effect/decal/cleanable/vomit
	name = "vomit"
	desc = "Господи, как неприятно."
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")
	beauty = -150

/obj/effect/decal/cleanable/vomit/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || !ishuman(user))
		return
	var/mob/living/carbon/human/as_human = user
	var/obj/item/organ/tongue/user_tongue = user.get_organ_slot(ORGAN_SLOT_TONGUE)
	if(!istype(user_tongue, /obj/item/organ/tongue/fly))
		return
	playsound(get_turf(src), 'sound/items/drink.ogg', 50, TRUE) //slurp
	as_human.visible_message(span_alert("[as_human] extends a small proboscis into the vomit pool, sucking it with a slurping sound."))
	lazy_init_reagents()?.trans_to(as_human, reagents.total_volume, transferred_by = user, methods = INGEST)
	qdel(src)

/obj/effect/decal/cleanable/vomit/toxic // this has a more toned-down color palette, which may be why it's used as the default in so many spots
	icon_state = "vomittox_1"
	random_icon_states = list("vomittox_1", "vomittox_2", "vomittox_3", "vomittox_4")

/obj/effect/decal/cleanable/vomit/purple // ourple
	icon_state = "vomitpurp_1"
	random_icon_states = list("vomitpurp_1", "vomitpurp_2", "vomitpurp_3", "vomitpurp_4")

/obj/effect/decal/cleanable/vomit/nanites
	name = "nanite-infested vomit"
	desc = "Господи, вы видите, как там что-то движется."
	icon_state = "vomitnanite_1"
	random_icon_states = list("vomitnanite_1", "vomitnanite_2", "vomitnanite_3", "vomitnanite_4")

/// Tracked for voidwalkers to jump to and from
GLOBAL_LIST_EMPTY(nebula_vomits)

/obj/effect/decal/cleanable/vomit/nebula
	name = "nebula vomit"
	desc = "Господи, как... красиво."
	icon_state = "vomitnebula_1"
	random_icon_states = list("vomitnebula_1", "vomitnebula_2", "vomitnebula_3", "vomitnebula_4")
	beauty = 10

/obj/effect/decal/cleanable/vomit/nebula/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)
	GLOB.nebula_vomits += src

/obj/effect/decal/cleanable/vomit/nebula/update_overlays()
	. = ..()
	. += emissive_appearance(icon, icon_state, src, alpha = src.alpha)

/obj/effect/decal/cleanable/vomit/nebula/Destroy()
	. = ..()

	GLOB.nebula_vomits -= src

/// Nebula vomit with extra guests
/obj/effect/decal/cleanable/vomit/nebula/worms

/obj/effect/decal/cleanable/vomit/nebula/worms/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	for (var/i in 1 to rand(2, 3))
		new /mob/living/basic/hivelord_brood(loc)

/obj/effect/decal/cleanable/vomit/old
	name = "crusty dried vomit"
	desc = "Вы пытаетесь не смотреть на куски, но у вас не получается."

/obj/effect/decal/cleanable/vomit/old/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	icon_state += "-old"
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLUDGE, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 10)

/obj/effect/decal/cleanable/vomit/old/black_bile
	name = "black bile"
	desc = "Там что-то шевелится..."
	color = COLOR_DARK

/obj/effect/decal/cleanable/chem_pile
	name = "chemical pile"
	desc = "Куча химикатов. Вы не можете точно сказать, что там внутри."
	gender = NEUTER
	plane = GAME_PLANE
	layer = CLEANABLE_OBJECT_LAYER
	icon = 'icons/obj/debris.dmi'
	icon_state = "ash"

/obj/effect/decal/cleanable/shreds
	name = "shreds"
	desc = "Разорванные в клочья остатки, судя по всему, одежды."
	icon_state = "shreds"
	gender = PLURAL
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/shreds/ex_act(severity, target)
	if(severity >= EXPLODE_DEVASTATE) //so shreds created during an explosion aren't deleted by the explosion.
		qdel(src)
		return TRUE

	return FALSE

/obj/effect/decal/cleanable/shreds/Initialize(mapload, oldname)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	if(!isnull(oldname))
		desc = "The sad remains of what used to be \a [oldname]."
	. = ..()

/obj/effect/decal/cleanable/glitter
	name = "generic glitter pile"
	desc = "Герпес среди искусства и рукоделия."
	icon = 'icons/effects/glitter.dmi'
	icon_state = "glitter"
	gender = NEUTER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/cleanable/glitter/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	add_overlay(mutable_appearance('icons/effects/glitter.dmi', "glitter_sparkle[rand(1,9)]", appearance_flags = EMISSIVE_APPEARANCE_FLAGS))

/obj/effect/decal/cleanable/plasma
	name = "stabilized plasma"
	desc = "Лужица стабилизированной плазмы."
	icon_state = "flour"
	icon = 'icons/effects/tomatodecal.dmi'
	color = "#2D2D2D"

/obj/effect/decal/cleanable/insectguts
	name = "insect guts"
	desc = "Один жук раздавлен. На его месте вырастут еще четыре."
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	color = BLOOD_COLOR_XENO

/obj/effect/decal/cleanable/confetti
	name = "confetti"
	desc = "Крошечные кусочки цветной бумаги, разбросанные повсюду на радость уборщику!"
	icon = 'icons/effects/confetti_and_decor.dmi'
	icon_state = "confetti"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT //the confetti itself might be annoying enough

/obj/effect/decal/cleanable/plastic
	name = "plastic shreds"
	desc = "Кусочки разорванного, сломаного, бесполезного пластика."
	icon = 'icons/obj/debris.dmi'
	icon_state = "shards"
	color = "#c6f4ff"

/obj/effect/decal/cleanable/wrapping
	name = "wrapping shreds"
	desc = "Оторванные кусочки картона и бумаги, оставшиеся от упаковки."
	icon = 'icons/obj/debris.dmi'
	icon_state = "paper_shreds"
	plane = GAME_PLANE
	layer = CLEANABLE_OBJECT_LAYER

/obj/effect/decal/cleanable/wrapping/pinata
	name = "pinata shreds"
	desc = "Оторванные кусочки папье-маше, оставшиеся от пиньяты."
	icon_state = "pinata_shreds"

/obj/effect/decal/cleanable/wrapping/pinata/syndie
	icon_state = "syndie_pinata_shreds"

/obj/effect/decal/cleanable/wrapping/pinata/donk
	icon_state = "donk_pinata_shreds"

/obj/effect/decal/cleanable/garbage
	name = "decomposing garbage"
	desc = "Разорванный пакет для мусора, его зловонное содержимое, похоже, частично растворилось. Фу!"
	icon = 'icons/obj/debris.dmi'
	icon_state = "garbage"
	plane = GAME_PLANE
	layer = CLEANABLE_OBJECT_LAYER
	beauty = -150
	clean_type = CLEAN_TYPE_HARD_DECAL

/obj/effect/decal/cleanable/garbage/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_SLUDGE, CELL_VIRUS_TABLE_GENERIC, rand(2,4), 15)

/obj/effect/decal/cleanable/rubble
	name = "rubble"
	desc = "Груда обломков."
	icon = 'icons/obj/debris.dmi'
	icon_state = "rubble"
	mergeable_decal = FALSE
	beauty = -10
	plane = GAME_PLANE
	layer = GIB_LAYER
	clean_type = CLEAN_TYPE_HARD_DECAL
	is_mopped = FALSE

/obj/effect/decal/cleanable/rubble/Initialize(mapload)
	. = ..()
	flick("rubble_bounce", src)
	icon_state = "rubble"
	update_appearance(UPDATE_ICON_STATE)

/obj/effect/decal/cleanable/can_bits
	name = "shredded can"
	desc = "Эта история больше не выдерживает критики."
