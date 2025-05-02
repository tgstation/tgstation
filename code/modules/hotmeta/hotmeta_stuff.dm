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

// ~ Hotmeta Spefific Lockers ~ //

// ~ Hos ~ //
/obj/structure/closet/secure_closet/hos/hotmeta
	name = "head of security's locker"
	icon_state = "hos"
	req_access = list(ACCESS_HOS)

/obj/structure/closet/secure_closet/hos/hotmeta/populateContents()
	..()

	new /obj/item/computer_disk/command/hos(src)
	new /obj/item/radio/headset/heads/hos(src)
	new /obj/item/radio/headset/heads/hos/alt(src)
	new /obj/item/clothing/shoes/russian(src)
	new /obj/item/clothing/under/syndicate/rus_army(src)
	new /obj/item/clothing/suit/armor/vest/russian(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/head/beret/sec(src)
	new /obj/item/melee/baton(src)
	new /obj/item/storage/lockbox/medal/sec(src)
	new /obj/item/megaphone/sec(src)
	new /obj/item/holosign_creator/security(src)
	new /obj/item/storage/lockbox/loyalty(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/shield/riot/tele(src)
	new /obj/item/storage/belt/security/full(src)
	new /obj/item/circuitboard/machine/techfab/department/security(src)
	new /obj/item/storage/photo_album/hos(src)

/obj/structure/closet/secure_closet/hos/hotmeta/populate_contents_immediate()
	. = ..()

	// Traitor steal objectives
	new /obj/item/gun/energy/e_gun/hos/hotmeta(src)
	new /obj/item/pinpointer/nuke(src)

// ~ Security Officer ~ //
/obj/structure/closet/secure_closet/security/hotmeta
	name = "security officer's locker"
	icon_state = "sec"
	req_access = list(ACCESS_BRIG)

/obj/structure/closet/secure_closet/security/hotmeta/PopulateContents()
	..()
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/radio/headset/headset_sec/alt(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/clothing/shoes/russian(src)
	new /obj/item/clothing/under/syndicate/rus_army(src)
	new /obj/item/clothing/suit/armor/vest/russian(src)
	new /obj/item/clothing/head/helmet/rus_helmet(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/melee/baton(src)
	new /obj/item/gun/ballistic/automatic/battle_rifle(src)
	new /obj/item/ammo_box/magazine/m38/hotshot(src)
	new /obj/item/ammo_box/magazine/m38/iceblox(src)

// ~ Warden ~ //
/obj/structure/closet/secure_closet/warden/hotmeta
	name = "warden's locker"
	icon_state = "warden"
	req_access = list(ACCESS_ARMORY)

/obj/structure/closet/secure_closet/warden/hotmeta/PopulateContents()
	..()
	new /obj/item/dog_bone(src)
	new /obj/item/radio/headset/headset_sec(src)
	new /obj/item/holosign_creator/security(src)
	new /obj/item/storage/box/zipties(src)
	new /obj/item/storage/box/flashbangs(src)
	new /obj/item/flashlight/seclite(src)
	new /obj/item/door_remote/head_of_security(src)
	new /obj/item/clothing/glasses/hud/security/sunglasses(src)
	new /obj/item/clothing/shoes/russian(src)
	new /obj/item/clothing/under/syndicate/rus_army(src)
	new /obj/item/clothing/suit/armor/vest/russian(src)
	new /obj/item/clothing/head/helmet/rus_helmet(src)
	new /obj/item/clothing/gloves/krav_maga/combatglovesplus(src)
// ~ Hotmeta Spefific guns ~ //

/obj/item/gun/energy/e_gun/hos/hotmeta
	name = "\improper X-420 MultiPhase Energy Gun"
	desc = "This is an expensive, modern recreation of an antique laser gun. This gun has several unique firemodes, but lacks the ability to recharge over time."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/hos, /obj/item/ammo_casing/energy/laser/hos, /obj/item/ammo_casing/energy/ion/hos, /obj/item/ammo_casing/energy/electrode/hos)

/obj/item/ammo_casing/energy/electrode/hos
	projectile_type = /obj/projectile/energy/electrode
	select_name = "taser"
	e_cost = LASER_SHOTS(4, STANDARD_CELL_CHARGE)

// ~ Hotmeta Spefific Turfs ~ //

/turf/open/floor/iron/solarpanel/lava_atmos
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
