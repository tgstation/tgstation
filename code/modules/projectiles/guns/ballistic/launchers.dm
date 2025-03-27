//KEEP IN MIND: These are different from gun/grenadelauncher. These are designed to shoot premade rocket and grenade projectiles, not flashbangs or chemistry casings etc.
//Put handheld rocket launchers here if someone ever decides to make something so hilarious ~Paprika

/obj/item/gun/ballistic/revolver/grenadelauncher//this is only used for underbarrel grenade launchers at the moment, but admins can still spawn it if they feel like being assholes
	desc = "A break-operated grenade launcher."
	name = "grenade launcher"
	icon_state = "dshotgun_sawn"
	inhand_icon_state = "gun"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/grenadelauncher
	fire_sound = 'sound/items/weapons/gun/general/grenade_launch.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	pin = /obj/item/firing_pin/implant/pindicate
	bolt_type = BOLT_TYPE_NO_BOLT

/obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/revolver/grenadelauncher/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/ammo_box) || isammocasing(A))
		chamber_round()

/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg
	desc = "A 6-shot grenade launcher."
	name = "multi grenade launcher"
	icon = 'icons/obj/devices/mecha_equipment.dmi'
	icon_state = "mecha_grenadelnchr"
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/cylinder/grenademulti
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg/attack_self()
	return

/obj/item/gun/ballistic/automatic/gyropistol
	name = "gyrojet pistol"
	desc = "A prototype pistol designed to fire self propelled rockets."
	icon_state = "gyropistol"
	fire_sound = 'sound/items/weapons/gun/general/grenade_launch.ogg'
	accepted_magazine_type = /obj/item/ammo_box/magazine/m75
	burst_size = 1
	fire_delay = 0
	actions_types = list()
	casing_ejector = FALSE

/obj/item/gun/ballistic/rocketlauncher
	name = "\improper Dardo-RE Rocket Launcher"
	desc = "A reusable rocket propelled grenade launcher. An arrow pointing toward the front of the launcher \
		alongside the words \"Front Toward Enemy\" are printed on the tube. Someone seems to have crossed out \
		that last word and written \"NT\" over it at some point. A sticker near the back of the launcher warn \
		to \"CHECK BACKBLAST CLEAR BEFORE FIRING\", whatever that means."
	icon = 'icons/obj/weapons/guns/wide_guns.dmi'
	icon_state = "rocketlauncher"
	inhand_icon_state = "rocketlauncher"
	worn_icon_state = "rocketlauncher"
	SET_BASE_PIXEL(-8, 0)
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/rocketlauncher
	fire_sound = 'sound/items/weapons/gun/general/rocket_launch.ogg'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	can_suppress = FALSE
	pin = /obj/item/firing_pin/implant/pindicate
	burst_size = 1
	fire_delay = 0
	casing_ejector = FALSE
	weapon_weight = WEAPON_HEAVY
	bolt_type = BOLT_TYPE_NO_BOLT
	internal_magazine = TRUE
	cartridge_wording = "rocket"
	empty_indicator = TRUE
	tac_reloads = FALSE
	/// Do we shit flames behind us when we fire?
	var/backblast = TRUE

/obj/item/gun/ballistic/rocketlauncher/Initialize(mapload)
	. = ..()
	if(backblast)
		AddElement(/datum/element/backblast)

/obj/item/gun/ballistic/rocketlauncher/unrestricted
	desc = "A reusable rocket propelled grenade launcher. An arrow pointing toward the front of the launcher \
		alongside the words \"Front Toward Enemy\" are printed on the tube. \
		A sticker near the back of the launcher warn to \"CHECK BACKBLAST CLEAR BEFORE FIRING\", whatever that means."
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/rocketlauncher/nobackblast
	name = "\improper Dardo-REF Flameless Rocket Launcher"
	desc = "A reusable rocket propelled grenade launcher. An arrow pointing toward the front of the launcher \
		alongside the words \"Front Toward Enemy\" are printed on the tube. \
		This one has been fitted with a special backblast diverter to prevent 'friendly' fire 'accidents' during use."
	backblast = FALSE

/obj/item/gun/ballistic/rocketlauncher/try_fire_gun(atom/target, mob/living/user, params)
	. = ..()
	if(!.)
		return
	magazine.get_round() //Hack to clear the mag after it's fired

/obj/item/gun/ballistic/rocketlauncher/attack_self_tk(mob/user)
	return //too difficult to remove the rocket with TK

/obj/item/gun/ballistic/rocketlauncher/update_overlays()
	. = ..()
	if(get_ammo())
		. += "rocketlauncher_loaded"

/obj/item/gun/ballistic/rocketlauncher/suicide_act(mob/living/user)
	user.visible_message(span_warning("[user] aims [src] at the ground! It looks like [user.p_theyre()] performing a sick rocket jump!"), \
		span_userdanger("You aim [src] at the ground to perform a bisnasty rocket jump..."))
	if(can_shoot())
		ADD_TRAIT(user, TRAIT_NO_TRANSFORM, REF(src))
		playsound(src, 'sound/vehicles/rocketlaunch.ogg', 80, TRUE, 5)
		animate(user, pixel_z = 300, time = 30, flags = ANIMATION_RELATIVE, easing = LINEAR_EASING)
		sleep(7 SECONDS)
		animate(user, pixel_z = -300, time = 5, flags = ANIMATION_RELATIVE, easing = LINEAR_EASING)
		sleep(0.5 SECONDS)
		REMOVE_TRAIT(user, TRAIT_NO_TRANSFORM, REF(src))
		process_fire(user, user, TRUE)
		if(!QDELETED(user)) //if they weren't gibbed by the explosion, take care of them for good.
			user.gib(DROP_ALL_REMAINS)
		return MANUAL_SUICIDE
	else
		sleep(0.5 SECONDS)
		shoot_with_empty_chamber(user)
		sleep(2 SECONDS)
		user.visible_message(span_warning("[user] looks about the room realizing [user.p_theyre()] still there. [user.p_They()] proceed to shove [src] down their throat and choke [user.p_them()]self with it!"), \
			span_userdanger("You look around after realizing you're still here, then proceed to choke yourself to death with [src]!"))
		sleep(2 SECONDS)
		return OXYLOSS

/obj/item/gun/ballistic/rocketlauncher/unrestricted/nanotrasen
	desc = "A reusable rocket propelled grenade launcher. The words \"Syndicate this way\" and an arrow have been written near the barrel. \
	A sticker near the cheek rest reads, \"ENSURE AREA BEHIND IS CLEAR BEFORE FIRING\""
	accepted_magazine_type = /obj/item/ammo_box/magazine/internal/rocketlauncher/empty
