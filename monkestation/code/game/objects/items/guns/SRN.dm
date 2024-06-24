/obj/item/gun/ballistic/SRN_rocketlauncher
	desc = "A rocket designed with the power of bluespace to send a singularity or tesla back to the shadow realm"
	name = "Spatial Rift Nullifier"
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	icon_state = "srnlauncher"
	inhand_icon_state = "srnlauncher"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/guns_righthand.dmi'
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/SRN_rocket
	fire_sound = 'sound/weapons/gun/general/rocket_launch.ogg'
	bolt_type = BOLT_TYPE_NO_BOLT
	fire_sound_volume = 80
	w_class = WEIGHT_CLASS_BULKY
	can_suppress = FALSE
	pin = /obj/item/firing_pin
	fire_delay = 1.5
	recoil = 1
	casing_ejector = FALSE
	weapon_weight = WEAPON_HEAVY
	bolt_type = BOLT_TYPE_LOCKING
	internal_magazine = TRUE
	cartridge_wording = "rocket"
	empty_indicator = TRUE
	empty_alarm = TRUE
	tac_reloads = FALSE

/obj/item/gun/ballistic/SRN_rocketlauncher/attack_self(mob/user)
	return //too difficult to remove the rocket with TK

/obj/item/gun/ballistic/SRN_rocketlauncher/chamber_round(keep_bullet = FALSE, spin_cylinder, replace_new_round)
	chambered = magazine.get_round(FALSE)



///SRN Internal Magazine
/obj/item/ammo_box/magazine/internal/SRN_rocket
	name = "SRN Rocket"
	ammo_type = /obj/item/ammo_casing/caseless/SRN_rocket
	caliber = "84mm"
	max_ammo = 3



/// SRN caseless ammo casing
/obj/item/ammo_casing/caseless/SRN_rocket
	name = "\improper Spatial Rift Nullifier Rocket"
	desc = "A prototype Spatial Rift Nullifier (SRN) Rocket. Fire at a rogue singularity or Tesla and pray it hits"
	caliber = "84mm"
	icon = 'monkestation/icons/obj/guns/projectiles.dmi'
	icon_state = "srn_rocket"
	projectile_type = /obj/projectile/bullet/SRN_rocket



/// SRN Rocket Projectile
/obj/projectile/bullet/SRN_rocket
	name = "SRN rocket"
	icon = 'monkestation/icons/obj/guns/projectiles.dmi'
	icon_state = "srn_rocket"
	hitsound = "sound/effects/meteorimpact.ogg"
	damage = 10
	ricochets_max = 0 //it's a MISSILE

/obj/projectile/bullet/SRN_rocket/on_hit(atom/target, blocked = 0, pierce_hit)
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		playsound(src.loc, "pierce", 100, 1)
		M.oxyloss = 5
		to_chat(M, "<span class='alert'>You are struck by a spatial nullifier! Thankfully it didn't affect you... much.</span>")
		M.emote("scream")
	else
		playsound(src.loc, "sparks", 100, 1)
	return BULLET_ACT_HIT

/obj/projectile/bullet/SRN_rocket/Impact(atom/A)
	. = ..()
	if(istype(A, /obj/singularity))
		var/mob/living/user = firer
		user.client.give_award(/datum/award/achievement/misc/singularity_buster, user)
		user.emote("scream")

		for(var/mob/player as anything in GLOB.player_list)
			SEND_SOUND(player, sound('sound/magic/charge.ogg', volume = player.client.prefs.channel_volume["[CHANNEL_SOUND_EFFECTS]"]))
			to_chat(player, "<span class='boldannounce'>You feel reality distort for a moment...</span>")
			shake_camera(player, 15, 3)

		new/obj/spatial_rift(A.loc)
		qdel(A)

	if(istype(A, /obj/energy_ball))
		var/mob/living/user = firer
		user.client.give_award(/datum/award/achievement/misc/singularity_buster, user)
		user.emote("scream")

		for(var/mob/player as anything in GLOB.player_list)
			SEND_SOUND(player, sound('sound/magic/charge.ogg', volume = player.client.prefs.channel_volume["[CHANNEL_SOUND_EFFECTS]"]))
			to_chat(player, "<span class='boldannounce'>You feel reality distort for a moment...</span>")
			shake_camera(player, 15, 3)

		new/obj/spatial_rift(A.loc)
		qdel(A)

	return


/datum/award/achievement/misc/singularity_buster
	name = "Scrungularity"
	desc = "Wow you saved the station, well at least what is left. Someone is getting a holiday bonus."
	database_id = MEDAL_SINGULARITY_BUSTER


/// Spatial Rift
/// Basically a BoH Tear, but weaker because it spawns after nullifying a tesloose or singlo and those have done enough damage
/obj/spatial_rift
	name = "a small tear in the fabric of reality, a good place to stuff problems"
	desc = "Your own comprehension of reality starts bending as you stare at this."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	anchored = TRUE
	appearance_flags = LONG_GLIDE
	pixel_x = -32
	pixel_y = -32
	obj_flags = CAN_BE_HIT | DANGEROUS_POSSESSION
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	flags_1 = SUPERMATTER_IGNORES_1

/obj/spatial_rift/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 5 SECONDS) // vanishes after 5 seconds
	AddComponent(
		/datum/component/singularity, \
		consume_callback = CALLBACK(src, PROC_REF(consume)), \
		consume_range = 1, \
		grav_pull = 8, \
		roaming = FALSE, \
		singularity_size = STAGE_FIVE, \
	)

/obj/spatial_rift/process()
	consume()

/obj/spatial_rift/proc/consume(atom/A)
	if(isturf(A))
		A.singularity_act()
		return
	var/atom/movable/AM = A
	var/turf/T = get_turf(src)
	if(!istype(AM))
		return
	if(isliving(AM))
		var/mob/living/M = AM
		investigate_log("([key_name(A)]) has been consumed by the Spatial rift at [AREACOORD(T)].", INVESTIGATE_ENGINE)
		M.ghostize(FALSE)
	else if(istype(AM, /obj/singularity))
		investigate_log("([key_name(A)]) has been consumed by the Spatial rift at [AREACOORD(T)].", INVESTIGATE_ENGINE)
		return
	AM.forceMove(src)

/obj/spatial_rift/proc/admin_investigate_setup()
	var/turf/T = get_turf(src)
	message_admins("A Spatial rift has been created at [ADMIN_VERBOSEJMP(T)].]")
	investigate_log("was created at [AREACOORD(T)].", INVESTIGATE_ENGINE)

/obj/spatial_rift/attack_tk(mob/living/user)
	if(!istype(user))
		return
	to_chat(user, "<span class='userdanger'>You don't feel like you are real anymore.</span>")
	user.dust_animation()
	user.spawn_dust()
	addtimer(CALLBACK(src, PROC_REF(consume), user), 5)
