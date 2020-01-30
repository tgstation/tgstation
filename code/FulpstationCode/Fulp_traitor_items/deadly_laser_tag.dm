/obj/item/storage/box/syndicate/laser_tag_kit_red/PopulateContents()
	new /obj/item/clothing/head/helmet/redtaghelm/deadly(src)
	new /obj/item/clothing/suit/redtag/deadly_laser_tag(src)
	new /obj/item/gun/energy/laser/redtag/deadly(src)

/obj/item/storage/box/syndicate/laser_tag_kit_blue/PopulateContents()
	new /obj/item/clothing/head/helmet/bluetaghelm/deadly(src)
	new /obj/item/clothing/suit/bluetag/deadly_laser_tag(src)
	new /obj/item/gun/energy/laser/bluetag/deadly(src)

/obj/structure/closet/crate/laser_tag_partypack_blue/PopulateContents()
	new /obj/item/clothing/head/helmet/bluetaghelm/deadly(src)
	new /obj/item/clothing/head/helmet/bluetaghelm/deadly(src)
	new /obj/item/clothing/head/helmet/bluetaghelm/deadly(src)
	new /obj/item/clothing/head/helmet/bluetaghelm/deadly(src)
	new /obj/item/clothing/suit/bluetag/deadly_laser_tag(src)
	new /obj/item/clothing/suit/bluetag/deadly_laser_tag(src)
	new /obj/item/clothing/suit/bluetag/deadly_laser_tag(src)
	new /obj/item/clothing/suit/bluetag/deadly_laser_tag(src)
	new /obj/item/gun/energy/laser/bluetag/deadly(src)
	new /obj/item/gun/energy/laser/bluetag/deadly(src)
	new /obj/item/gun/energy/laser/bluetag/deadly(src)
	new /obj/item/gun/energy/laser/bluetag/deadly(src)

/obj/structure/closet/crate/laser_tag_partypack_red/PopulateContents()
	new /obj/item/clothing/head/helmet/redtaghelm/deadly(src)
	new /obj/item/clothing/head/helmet/redtaghelm/deadly(src)
	new /obj/item/clothing/head/helmet/redtaghelm/deadly(src)
	new /obj/item/clothing/head/helmet/redtaghelm/deadly(src)
	new /obj/item/clothing/suit/redtag/deadly_laser_tag(src)
	new /obj/item/clothing/suit/redtag/deadly_laser_tag(src)
	new /obj/item/clothing/suit/redtag/deadly_laser_tag(src)
	new /obj/item/clothing/suit/redtag/deadly_laser_tag(src)
	new /obj/item/gun/energy/laser/redtag/deadly(src)
	new /obj/item/gun/energy/laser/redtag/deadly(src)
	new /obj/item/gun/energy/laser/redtag/deadly(src)
	new /obj/item/gun/energy/laser/redtag/deadly(src)


//X-TREME Laser Tag Helmets

/obj/item/clothing/head/helmet/redtaghelm/deadly
	armor = list("melee" = 15, "bullet" = 10, "laser" = 60,"energy" = 60, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	var/hit_reflect_chance = 50

/obj/item/clothing/head/helmet/redtaghelm/deadly/IsReflect(def_zone)
	if(!(def_zone in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_EYES))) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/head/helmet/bluetaghelm/deadly
	armor = list("melee" = 15, "bullet" = 10, "laser" = 60,"energy" = 60, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	var/hit_reflect_chance = 50

/obj/item/clothing/head/helmet/bluetaghelm/deadly/IsReflect(def_zone)
	if(!(def_zone in list(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_EYES))) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE

//X-TREME Laser Tag Vests

/obj/item/clothing/suit/bluetag/deadly_laser_tag
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	heat_protection = CHEST|GROIN|ARMS
	armor = list("melee" = 15, "bullet" = 10, "laser" = 60, "energy" = 60, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	var/hit_reflect_chance = 50

/obj/item/clothing/suit/bluetag/deadly_laser_tag/IsReflect(def_zone)
	if(!(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE

/obj/item/clothing/suit/redtag/deadly_laser_tag
	body_parts_covered = CHEST|GROIN|ARMS
	cold_protection = CHEST|GROIN|ARMS
	heat_protection = CHEST|GROIN|ARMS
	armor = list("melee" = 15, "bullet" = 10, "laser" = 60, "energy" = 60, "bomb" = 20, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 100)
	var/hit_reflect_chance = 50

/obj/item/clothing/suit/redtag/deadly_laser_tag/IsReflect(def_zone)
	if(!(def_zone in list(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))) //If not shot where ablative is covering you, you don't get the reflection bonus!
		return FALSE
	if (prob(hit_reflect_chance))
		return TRUE

//X-TREME Laser Tag... Lasers

/obj/item/gun/energy/laser/bluetag/deadly
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag, /obj/item/ammo_casing/energy/laser/bluetag/stun, /obj/item/ammo_casing/energy/laser/bluetag/kill)
	modifystate = 1
	var/obj/item/card/id/ID_imprint
	var/parental_lock = FALSE

/obj/item/gun/energy/laser/redtag/deadly
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag, /obj/item/ammo_casing/energy/laser/redtag/stun, /obj/item/ammo_casing/energy/laser/redtag/kill)
	modifystate = 1
	var/obj/item/card/id/ID_imprint
	var/parental_lock = FALSE

//Laser procs

/obj/item/gun/energy/laser/redtag/deadly/attackby(obj/item/W, mob/user, params)
	. = ..()
	var/obj/item/card/id/I
	if (istype(W, /obj/item/card/id))
		I = W
	else if (istype(W, /obj/item/pda))
		var/obj/item/pda/P = W
		I = P.id

	if(!I)
		return

	if(!ID_imprint)
		to_chat(user, "<span class='notice'>Parental lock ID imprinted. Swipe again with imprinted ID to toggle the parental lock feature.</span>")
		ID_imprint = I
		return

	playsound(loc, SEC_BODY_CAM_SOUND, get_clamped_volume(), TRUE, -1)

	if(parental_lock)
		parental_lock = FALSE
		to_chat(user, "<span class='notice'>Parental lock deactivated. Swipe again with imprinted ID to toggle the parental lock feature.</span>")
		modifystate = 1

	else
		parental_lock = TRUE
		to_chat(user, "<span class='notice'>Parental lock activated. Swipe again with imprinted ID to toggle the parental lock feature.</span>")
		activate_parental_lock(user)
		modifystate = 0

/obj/item/gun/energy/laser/redtag/deadly/multitool_act(user, I)
	if(!parental_lock)
		to_chat(user, "<span class='notice'>You reset the parental lock ID; [src] can now imprint a new ID.</span>")
		playsound(loc, SEC_BODY_CAM_SOUND, get_clamped_volume(), TRUE, -1)

/obj/item/gun/energy/laser/redtag/deadly/emag_act(mob/user)
	if(ID_imprint)
		ID_imprint = null
		to_chat(user, "<span class='warning'>You forcibly reset the [src]'s parental lock ID; it can now imprint a new ID.</span>")

/obj/item/gun/energy/laser/redtag/deadly/attack_self(mob/living/user as mob)
	if(parental_lock)
		return
	. = ..()

/obj/item/gun/energy/laser/redtag/deadly/proc/activate_parental_lock(mob/user)
	select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if (shot.select_name)
		to_chat(user, "<span class='notice'>[src] is now set to [shot.select_name].</span>")
	chambered = null
	recharge_newshot(TRUE)
	update_icon(TRUE)
	return

//Blue gun procs

/obj/item/gun/energy/laser/bluetag/deadly/attackby(obj/item/W, mob/user, params)
	. = ..()

	var/obj/item/card/id/I
	if (istype(W, /obj/item/card/id))
		I = W
	else if (istype(W, /obj/item/pda))
		var/obj/item/pda/P = W
		I = P.id

	if(!I)
		return

	playsound(loc, SEC_BODY_CAM_SOUND, get_clamped_volume(), TRUE, -1)

	if(!ID_imprint)
		to_chat(user, "<span class='notice'>Parental lock ID imprinted. Swipe again with imprinted ID to toggle the parental lock feature.</span>")
		ID_imprint = I
		return

	if(parental_lock)
		parental_lock = FALSE
		to_chat(user, "<span class='notice'>Parental lock deactivated. Swipe again with imprinted ID to toggle the parental lock feature.</span>")
		modifystate = 1

	else
		parental_lock = TRUE
		to_chat(user, "<span class='notice'>Parental lock activated. Swipe again with imprinted ID to toggle the parental lock feature.</span>")
		activate_parental_lock(user)
		modifystate = 0

/obj/item/gun/energy/laser/bluetag/deadly/multitool_act(user, I)
	if(!parental_lock)
		to_chat(user, "<span class='notice'>You reset the parental lock ID; [src] can now imprint a new ID.</span>")
		playsound(loc, SEC_BODY_CAM_SOUND, get_clamped_volume(), TRUE, -1)

/obj/item/gun/energy/laser/bluetag/deadly/emag_act(mob/user)
	if(ID_imprint)
		ID_imprint = null
		to_chat(user, "<span class='warning'>You forcibly reset the [src]'s parental lock ID; it can now imprint a new ID.</span>")


/obj/item/gun/energy/laser/bluetag/deadly/attack_self(mob/living/user as mob)
	if(parental_lock)
		return
	. = ..()

/obj/item/gun/energy/laser/bluetag/deadly/proc/activate_parental_lock(mob/user)
	select = 1
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	fire_sound = shot.fire_sound
	fire_delay = shot.delay
	if (shot.select_name)
		to_chat(user, "<span class='notice'>[src] is now set to [shot.select_name].</span>")
	chambered = null
	recharge_newshot(TRUE)
	update_icon(TRUE)
	return

//BLUE LASER AMMO CASINGS

/obj/item/ammo_casing/energy/laser/bluetag/stun
	projectile_type = /obj/projectile/beam/lasertag/bluetag/stun
	select_name = "disable"

/obj/item/ammo_casing/energy/laser/bluetag/hitscan/stun
	projectile_type = /obj/projectile/beam/lasertag/bluetag/hitscan/stun
	select_name = "disable"

/obj/item/ammo_casing/energy/laser/bluetag/kill
	projectile_type = /obj/projectile/beam/lasertag/bluetag/kill
	select_name = "kill"
	harmful = TRUE

/obj/item/ammo_casing/energy/laser/bluetag/hitscan/kill
	projectile_type = /obj/projectile/beam/lasertag/bluetag/hitscan/kill
	select_name = "kill"
	harmful = TRUE

//RED LASER AMMO CASINGS

/obj/item/ammo_casing/energy/laser/redtag/stun
	projectile_type = /obj/projectile/beam/lasertag/redtag/stun
	select_name = "disable"

/obj/item/ammo_casing/energy/laser/redtag/hitscan/stun
	projectile_type = /obj/projectile/beam/lasertag/redtag/hitscan/stun
	select_name = "disable"

/obj/item/ammo_casing/energy/laser/redtag/kill
	projectile_type = /obj/projectile/beam/lasertag/redtag/kill
	select_name = "kill"
	harmful = TRUE

/obj/item/ammo_casing/energy/laser/redtag/hitscan/kill
	projectile_type = /obj/projectile/beam/lasertag/redtag/hitscan/kill
	select_name = "kill"
	harmful = TRUE


//STUN PROJECTILES
//RED

/obj/projectile/beam/lasertag/redtag/stun
	damage = 30
	damage_type = STAMINA
	hitsound = 'sound/weapons/tap.ogg'

/obj/projectile/beam/lasertag/redtag/hitscan/stun
	damage = 30
	damage_type = STAMINA
	hitsound = 'sound/weapons/tap.ogg'

//BLUE

/obj/projectile/beam/lasertag/bluetag/stun
	damage = 30
	damage_type = STAMINA
	hitsound = 'sound/weapons/tap.ogg'

/obj/projectile/beam/lasertag/bluetag/hitscan/stun
	damage = 30
	damage_type = STAMINA
	hitsound = 'sound/weapons/tap.ogg'

//KILL PROJECTILES
//RED

/obj/projectile/beam/lasertag/redtag/kill
	damage = 20
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'

/obj/projectile/beam/lasertag/redtag/hitscan/kill
	damage = 20
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'

//BLUE

/obj/projectile/beam/lasertag/bluetag/kill
	damage = 20
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'

/obj/projectile/beam/lasertag/bluetag/hitscan/kill
	damage = 20
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'