///prototype empowered turfs for the gigasnapper boss, they do stuff when people step on them!
/obj/effect/empowered_turf
	name = "fissure"
	icon = 'icons/mob/simple/lavaland/gigasnapper/32x32.dmi'
	icon_state = "empowered_base"
	///icon state for the emissive overlay, this is what people ACTUALLY see because empowered_base is invisible*
	///* not actually invisible, but 0,0,0,1 to make the empowered tile clickable
	/// also prefixed onto the name
	var/emissive_icon_state

/obj/effect/empowered_turf/Initialize(mapload)
	. = ..()
	name = "[emissive_icon_state] [name]"
	update_appearance()

/obj/effect/empowered_turf/update_overlays()
	. = ..()
	. += emissive_icon_state
	. += emissive_appearance(icon, emissive_icon_state, src)

/obj/effect/empowered_turf/plasma
	emissive_icon_state = "plasma"

/obj/effect/empowered_turf/bluespace
	emissive_icon_state = "bluespace"

/obj/effect/empowered_turf/necropolis
	emissive_icon_state = "necropolis"

/obj/effect/spawner/random/empowered_turf
	name = "random empowered turf"
	desc = "Spawns a random empowered turf."
	icon = 'icons/mob/simple/lavaland/gigasnapper/32x32.dmi'
	icon_state = "plasma"
	loot = list(
		/obj/effect/empowered_turf/plasma = 1,
		/obj/effect/empowered_turf/bluespace = 1,
		/obj/effect/empowered_turf/necropolis = 1,
	)
