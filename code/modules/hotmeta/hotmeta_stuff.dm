/// ~ Ruin Keys ~

/obj/item/keycard/hotmeta
	name = "omninous key"
	desc = "This feels like it belongs to a door."
	icon = 'icons/obj/fluff/hotmeta_keys.dmi'
	puzzle_id = "omninous"

/obj/item/keycard/hotmeta/lizard
	name = "green key"
	icon_state = "lizard_key"
	puzzle_id = "lizard"

/obj/item/keycard/hotmeta/drake
	name = "red key"
	icon_state = "drake_key"
	puzzle_id = "drake"

/obj/item/keycard/hotmeta/hierophant
	name = "purple key"
	icon_state = "hiero_key"
	puzzle_id = "hiero"

/obj/item/keycard/hotmeta/legion
	name = "blue key"
	icon_state = "legion_key"
	puzzle_id = "legion"

/obj/machinery/door/puzzle/keycard/hotmeta
	name = "wooden door"
	desc = "A dusty, scratched door with a thick lock attached."
	icon = 'icons/obj/doors/puzzledoor/wood.dmi'
	puzzle_id = "omninous"
	open_message = "The door opens with a loud creak."

/obj/machinery/door/puzzle/keycard/hotmeta/lizard
	puzzle_id = "lizard"
	color = "#044116"
	desc = "A dusty, scratched door with a thick green lock attached."

/obj/machinery/door/puzzle/keycard/hotmeta/drake
	puzzle_id = "drake"
	color = "#830c0c"
	desc = "A dusty, scratched door with a thick red lock attached."

/obj/machinery/door/puzzle/keycard/hotmeta/hierophant
	puzzle_id = "hiero"
	color = "#770a65"
	desc = "A dusty, scratched door with a thick purple lock attached."

/obj/machinery/door/puzzle/keycard/hotmeta/legion
	puzzle_id = "legion"
	color = "#2b0496"
	desc = "A dusty, scratched door with a thick blue lock attached."

// ~ Ruin Mega fauna ~ //

/mob/living/simple_animal/hostile/megafauna/hierophant/hotmeta
	loot = list(/obj/item/hierophant_club, /obj/item/keycard/hotmeta/hierophant)
	icon = 'icons/mob/simple/lavaland/hotmeta_hierophant.dmi'

/mob/living/simple_animal/hostile/megafauna/hierophant/hotmeta/Initialize(mapload)
	. = ..()
	spawned_beacon_ref = WEAKREF(new /obj/effect/hierophant(loc))
	AddComponent(/datum/component/boss_music, 'sound/music/boss/hiero_old.ogg', 154 SECONDS)

/mob/living/simple_animal/hostile/megafauna/hierophant/hotmeta/Destroy()
	QDEL_NULL(spawned_beacon_ref)
	return ..()

/mob/living/simple_animal/hostile/megafauna/dragon/hotmeta
	loot = list(/obj/structure/closet/crate/necropolis/dragon, /obj/item/keycard/hotmeta/drake)

/mob/living/simple_animal/hostile/megafauna/dragon/hotmeta/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/boss_music, 'sound/music/boss/triumph.ogg', 138 SECONDS)

/mob/living/simple_animal/hostile/megafauna/legion/hotmeta
	loot = list(/obj/item/keycard/hotmeta/legion)

/mob/living/simple_animal/hostile/megafauna/legion/hotmeta/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/boss_music, 'sound/music/boss/revenge.ogg', 293 SECONDS)

// ~ Spinfusor ~ //
/obj/projectile/bullet/spinfusor
	name ="spinfusor disk"
	icon = 'icons/obj/hotmeta_gun.dmi'
	icon_state= "spinner"
	damage = 30
	dismemberment = 25

/obj/item/projectile/bullet/spinfusor/on_hit(atom/target, blocked = FALSE) //explosion to emulate the spinfusor's AOE
	..()
	explosion(target, -1, -1, 2, 0, -1)
	return 1

/obj/item/ammo_casing/caseless/spinfusor
	name = "spinfusor disk"
	desc = "A magnetic disk designed specifically for the Stormhammer magnetic cannon. Warning: extremely volatile!"
	projectile_type = /obj/projectile/bullet/spinfusor
	caliber = "spinfusor"
	icon = 'icons/obj/hotmeta_gun.dmi'
	icon_state = "disk"
	throwforce = 15 //still deadly when thrown
	throw_speed = 3

/obj/item/ammo_casing/caseless/spinfusor/throw_impact(atom/target) //disks detonate when thrown
	if(!..()) // not caught in mid-air
		visible_message("<span class='notice'>[src] detonates!</span>")
		playsound(src.loc, "sparks", 50, 1)
		explosion(target, -1, -1, 1, 1, -1)
		qdel(src)
		return 1

/obj/item/ammo_box/magazine/internal/spinfusor
	name = "spinfusor internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/spinfusor
	caliber = "spinfusor"
	max_ammo = 1

/obj/item/gun/ballistic/automatic/spinfusor
	name = "Stormhammer Magnetic Cannon"
	desc = "An innovative weapon utilizing mag-lev technology to spin up a magnetic fusor and launch it at extreme velocities."
	icon = 'icons/obj/hotmeta_gun.dmi'
	icon_state = "spinfusor"
	item_state = "spinfusor"
	mag_type = /obj/item/ammo_box/magazine/internal/spinfusor
	fire_sound = 'sound/weapons/rocketlaunch.ogg'
	w_class = WEIGHT_CLASS_BULKY
	can_suppress = 0
	burst_size = 1
	fire_delay = 20
	select = 0
	actions_types = list()
	casing_ejector = 0

/obj/item/gun/ballistic/automatic/spinfusor/attackby(obj/item/A, mob/user, params)
	var/num_loaded = magazine.attackby(A, user, params, 1)
	if(num_loaded)
		to_chat(user, "<span class='notice'>You load [num_loaded] disk\s into \the [src].</span>")
		update_icon()
		chamber_round()

/obj/item/gun/ballistic/automatic/spinfusor/attack_self(mob/living/user)
	return //caseless rounds are too glitchy to unload properly. Best to make it so that you cannot remove disks from the spinfusor

/obj/item/gun/ballistic/automatic/spinfusor/update_icon()
	..()
	icon_state = "spinfusor[magazine ? "-[get_ammo(1)]" : ""]"

/obj/item/ammo_box/aspinfusor
	name = "ammo box (spinfusor disks)"
	icon = 'icons/obj/hotmeta_gun.dmi'
	icon_state = "spinfusorbox"
	ammo_type = /obj/item/ammo_casing/caseless/spinfusor
	max_ammo = 8

// ~ Hotmeta Spefific Turfs ~ //

/turf/open/floor/iron/solarpanel/lava_atmos
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
