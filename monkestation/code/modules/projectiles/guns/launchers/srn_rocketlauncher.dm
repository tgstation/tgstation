/obj/item/gun/ballistic/SRN_rocketlauncher
	desc = "A rocket designed with the power of bluespace to send a singularity or tesla back to the shadow realm"
	name = "Spatial Rift Nullifier"
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	icon_state = "srnlauncher"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/guns_righthand.dmi'
	item_state = "srnlauncher"
	mag_type = /obj/item/ammo_box/magazine/internal/SRN_rocket
	fire_sound = 'sound/weapons/rocketlaunch.ogg'
	fire_sound_volume = 80
	w_class = WEIGHT_CLASS_BULKY
	can_suppress = FALSE
	pin = /obj/item/firing_pin
	fire_delay = 0
	fire_rate = 1.5
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

/obj/item/gun/ballistic/SRN_rocketlauncher/chamber_round()
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
	projectile_type = /obj/item/projectile/bullet/SRN_rocket



/// SRN Rocket Projectile
/obj/item/projectile/bullet/SRN_rocket
	name = "SRN rocket"
	icon = 'monkestation/icons/obj/guns/projectiles.dmi'
	icon_state = "srn_rocket"
	hitsound = "sound/effects/meteorimpact.ogg"
	damage = 10
	ricochets_max = 0 //it's a MISSILE

/obj/item/projectile/bullet/SRN_rocket/on_hit(atom/target, blocked = FALSE)
	..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		playsound(src.loc, "pierce", 100, 1)
		M.oxyloss = 5
		M.hallucination = 15
		to_chat(M, "<span class='alert'>You are struck by a spatial nullifier! Thankfully it didn't affect you... much.</span>")
		M.emote("scream")
	else
		playsound(src.loc, "sparks", 100, 1)
	return BULLET_ACT_HIT

/obj/item/projectile/bullet/SRN_rocket/Impact(atom/A)
	. = ..()
	if(istype(A, /obj/anomaly))
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

	if(istype(A, /obj/eldritch)) //This should allow both Rat'Var and Nar'Sie to be nullified
		var/mob/living/user = firer
		user.client.give_award(/datum/award/achievement/misc/god_buster, user) //Good luck hitting it
		user.emote("scream")

		for(var/mob/player as anything in GLOB.player_list)
			SEND_SOUND(player, sound('sound/magic/charge.ogg', volume = player.client.prefs.channel_volume["[CHANNEL_SOUND_EFFECTS]"]))
			to_chat(player, "<span class='boldannounce'>You feel reality distort for a moment...</span>")
			shake_camera(player, 15, 5)

		new/obj/spatial_rift(A.loc)
		qdel(A)
	return
