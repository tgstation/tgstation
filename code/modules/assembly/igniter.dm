#define EXPOSED_VOLUME 1000
#define ROOM_TEMP 293
#define MIN_FREEZE_TEMP 50
#define MAX_FREEZE_TEMP 1000000

/obj/item/assembly/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustible substances."
	icon_state = "igniter"
	custom_materials = list(/datum/material/iron=500, /datum/material/glass=50)
	var/datum/effect_system/spark_spread/sparks
	heat = 1000
	drop_sound = 'sound/items/handling/component_drop.ogg'
	pickup_sound = 'sound/items/handling/component_pickup.ogg'

/obj/item/assembly/igniter/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is trying to ignite [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	user.ignite_mob()
	return FIRELOSS

/obj/item/assembly/igniter/Initialize(mapload)
	. = ..()
	sparks = new
	sparks.set_up(2, 0, src)
	sparks.attach(src)

/obj/item/assembly/igniter/Destroy()
	if(sparks)
		qdel(sparks)
	sparks = null
	. = ..()

/obj/item/assembly/igniter/activate()
	if(!..())
		return FALSE//Cooldown check
	var/turf/location = get_turf(loc)
	if(location)
		location.hotspot_expose(heat, EXPOSED_VOLUME)
	sparks.start()
	return TRUE

/obj/item/assembly/igniter/attack_self(mob/user)
	activate()
	add_fingerprint(user)

/obj/item/assembly/igniter/ignition_effect(atom/A, mob/user)
	. = span_notice("[user] fiddles with [src], and manages to light [A].")
	activate()
	add_fingerprint(user)

//For the Condenser, which functions like the igniter but makes things colder.
/obj/item/assembly/igniter/condenser
	name = "condenser"
	desc = "A small electronic device able to chill their surroundings."
	icon_state = "freezer"
	custom_materials = list(/datum/material/iron=250, /datum/material/glass=300)
	heat = 200

/obj/item/assembly/igniter/condenser/activate()
	. = ..()
	if(!.)
		return //Cooldown check
	var/turf/location = get_turf(loc)
	if(location)
		var/datum/gas_mixture/enviro = location.return_air()
		enviro.temperature = clamp(min(ROOM_TEMP, enviro.temperature*0.85),MIN_FREEZE_TEMP,MAX_FREEZE_TEMP)
	sparks.start()

#undef EXPOSED_VOLUME
#undef ROOM_TEMP
#undef MIN_FREEZE_TEMP
#undef MAX_FREEZE_TEMP
