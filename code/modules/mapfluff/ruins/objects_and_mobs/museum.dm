/obj/machinery/computer/terminal/museum
	name = "exhibit info terminal"
	desc = "A relatively low-tech info board. Not as low-tech as an actual sign though. Appears to be quite old."
	upperinfo = "Nanotrasen Museum Exhibit Info"
	icon_state = "plaque"
	icon_screen = "plaque_screen"
	icon_keyboard = null

/obj/effect/replica_spawner //description and name are intact, better to make a new fluff object for stuff that is not actually ingame as an object
	name = "replica creator"
	desc = "This creates a fluff object that looks exactly like the input, but like obviously a replica. Do not for the love of god use with stuff that has Initialize side effects."
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	invisibility = INVISIBILITY_ABSTRACT //nope, can't see this
	anchored = TRUE
	density = TRUE
	opacity = FALSE
	var/replica_path = /obj/structure/fluff
	var/target_path
	var/obvious_replica = TRUE

/obj/effect/replica_spawner/Initialize(mapload)
	. = ..()
	if(isnull(target_path))
		return INITIALIZE_HINT_QDEL //no use to make a replica of null
	var/atom/appearance_object = new target_path
	var/atom/new_replica = new replica_path(loc)

	new_replica.icon = appearance_object.icon
	new_replica.icon_state = appearance_object.icon_state
	new_replica.copy_overlays(appearance_object.appearance, cut_old = TRUE)
	new_replica.density = appearance_object.density //for like nondense showers and stuff

	new_replica.name = "[appearance_object.name][obvious_replica ? " replica" : ""]"
	new_replica.desc = "[appearance_object.desc][obvious_replica ? " ..except this one is a replica.": ""]"

	new_replica.pixel_y = pixel_y
	new_replica.pixel_x = pixel_x

	qdel(appearance_object)
	qdel(src)
	return INITIALIZE_HINT_QDEL

/obj/structure/fluff/dnamod
	name = "DNA Modifier"
	desc = "DNA Manipulator replica. Essentially just a box of cool lights."
	icon = 'icons/obj/service/hydroponics/equipment.dmi'
	icon_state = "dnamod"
	density = TRUE

/obj/structure/fluff/preserved_borer
	name = "preserved borer exhibit"
	desc = "A preserved cortical borer. Probably been there long enough to not last long outside the exhibit."
	icon = 'icons/obj/structures.dmi'
	icon_state = "preservedborer"
	density = TRUE

/obj/structure/fluff/balloon_nuke
	name = "nuclear balloon explosive"
	desc = "You probably shouldn't stick around to see if this is inflated."
	icon = /obj/machinery/nuclearbomb::icon
	icon_state = /obj/machinery/nuclearbomb::icon_state
	density = TRUE
	max_integrity = 5 //one tap

/obj/structure/fluff/balloon_nuke/atom_destruction()
	playsound(loc, 'sound/effects/cartoon_sfx/cartoon_pop.ogg', 75, vary = TRUE)
	..()

/obj/structure/fluff/fake_camera
	name = /obj/machinery/camera::name
	desc = /obj/machinery/camera::desc
	icon = /obj/machinery/camera::icon
	icon_state = /obj/machinery/camera::icon_state

/obj/structure/fluff/fake_scrubber
	name = /obj/machinery/atmospherics/components/unary/vent_scrubber::name
	desc = /obj/machinery/atmospherics/components/unary/vent_scrubber::desc
	icon = /obj/machinery/atmospherics/components/unary/vent_scrubber::icon
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	icon_state = "scrub_on"

/obj/structure/fluff/fake_vent
	name = /obj/machinery/atmospherics/components/unary/vent_pump::name
	desc = /obj/machinery/atmospherics/components/unary/vent_pump::desc
	icon = /obj/machinery/atmospherics/components/unary/vent_pump::icon
	layer = ABOVE_OPEN_TURF_LAYER
	plane = FLOOR_PLANE
	icon_state = "vent_out"

/turf/open/mirage
	icon = 'icons/turf/floors.dmi'
	icon_state = "mirage"
	invisibility = INVISIBILITY_ABSTRACT
	/// target turf x and y are offsets from our location instead of a direct coordinate
	var/offset = TRUE
	/// tile range that we show, 2 means that the target tile and two tiles ahead of it in our direction will show
	var/range
	var/target_turf_x = 0
	var/target_turf_y = 0
	/// if not specified, uses our Z
	var/target_turf_z

/turf/open/mirage/Initialize(mapload)
	. = ..()
	if(isnull(range))
		range = world.view
	var/used_z = target_turf_z || z //if target z is not defined, use ours
	var/turf/target = locate(offset ? target_turf_x + x : target_turf_x, offset ? target_turf_y + y : target_turf_y, used_z)
	AddElement(/datum/element/mirage_border, target, dir, range)

/obj/effect/mapping_helpers/ztrait_injector/museum
	traits_to_add = list(ZTRAIT_NOPARALLAX = TRUE, ZTRAIT_NOXRAY = TRUE, ZTRAIT_NOPHASE = TRUE, ZTRAIT_BASETURF = /turf/open/indestructible/plating, ZTRAIT_SECRET = TRUE)

/obj/effect/smooths_with_walls
	name = "effect that smooths with walls"
	desc = "to supplement /turf/open/mirage."
	icon = 'icons/hud/screen_gen.dmi'
	icon_state = "x2"
	invisibility = INVISIBILITY_ABSTRACT
	anchored = TRUE
	density = TRUE
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS

/obj/item/paper/fluff/museum/noend
	name = "scrambled note"
	default_raw_text = {"this place,
	<br>god whose idea was to build a museum in the void in the middle of god knows where there is no reason we should have done this
	<br>and those mannequins why do they stare back where the fuck did you get these from
	<br>how would we even get visitors here
	<br>sometimes i can catch them moving
	<br>
	<br>we should have never come here"}

/obj/item/paper/fluff/museum/chefs_ultimatum
	name = "old note"
	default_raw_text = {"I messed it up big times.
	<br>I broke the button and now I'm stuck.
	<br>Anyway, I don't have the key on me. I flushed it down.
	<br>Hell knows where it's now, shit's like all linked together here."}

/obj/item/paper/fluff/museum/numbers_on_walls
	name = "reprimanding note"
	default_raw_text = "Please refraim from writing the pass all over the place. I know you've the memory of a goldfish, but, like, just put it on a piece of paper, no?"

/obj/effect/mob_spawn/corpse/human/skeleton/museum_chef
	name = "Dead Museum Cafeteria Chef"
	mob_name = "Nameless Chef"
	outfit = /datum/outfit/museum_chef

/datum/outfit/museum_chef
	name = "Dead Museum Cafeteria Chef"
	uniform = /obj/item/clothing/under/color/green
	suit = /obj/item/clothing/suit/toggle/chef
	head = /obj/item/clothing/head/utility/chefhat
	shoes = /obj/item/clothing/shoes/laceup
	mask = /obj/item/clothing/mask/fakemoustache/italian

/obj/machinery/vending/hotdog/museum
	all_products_free = TRUE

/obj/machinery/vending/hotdog/museum/screwdriver_act(mob/living/user, obj/item/attack_item)
	return NONE

/obj/machinery/vending/hotdog/museum/crowbar_act(mob/living/user, obj/item/attack_item)
	return NONE

#define CAFE_KEYCARD_TOILETS "museum_cafe_key_toilets"

///Do not place these beyond the cafeteria shutters, or you might lock people out of reaching it.
/obj/structure/toilet/museum

/obj/structure/toilet/museum/Initialize(mapload)
	. = ..()
	if(mapload)
		SSqueuelinks.add_to_queue(src, CAFE_KEYCARD_TOILETS)

/obj/item/keycard/cafeteria
	name = "museum cafeteria keycard"
	color = COLOR_OLIVE
	puzzle_id = "museum_cafeteria"
	desc = "The key to the cafeteria, as the name implies."

/obj/item/keycard/cafeteria/Initialize(mapload)
	. = ..()
	if(mapload)
		SSqueuelinks.add_to_queue(src, CAFE_KEYCARD_TOILETS)
		return INITIALIZE_HINT_LATELOAD

/obj/item/keycard/cafeteria/LateInitialize()
	if(SSqueuelinks.queues[CAFE_KEYCARD_TOILETS])
		SSqueuelinks.pop_link(CAFE_KEYCARD_TOILETS)

/obj/item/keycard/cafeteria/MatchedLinks(id, partners)
	if(id != CAFE_KEYCARD_TOILETS)
		return ..()
	var/obj/structure/toilet/destination = pick(partners)
	forceMove(destination)
	destination.w_items += w_class
	LAZYADD(destination.cistern_items, src)

#undef CAFE_KEYCARD_TOILETS
