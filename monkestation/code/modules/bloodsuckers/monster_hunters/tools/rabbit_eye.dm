/obj/item/rabbit_eye
	name = "Rabbit Eye"
	desc = "An item that resonates with trick weapons."
	icon_state = "rabbit_eye"
	icon = 'monkestation/icons/bloodsuckers/weapons.dmi'
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/item/rabbit_eye/proc/upgrade(obj/item/melee/trick_weapon/weapon, mob/user)
	if(weapon.upgrade_level >= 3)
		user.balloon_alert(user, "already fully upgraded!")
		return
	if(weapon.enabled)
		user.balloon_alert(user, "weapon must be in base form!")
		return
	SEND_SIGNAL(weapon, WEAPON_UPGRADE)
	weapon.name = "[weapon.base_name] +[weapon.upgrade_level]"
	balloon_alert(user, "[src] crumbles away...")
	playsound(src, 'monkestation/sound/bloodsuckers/weaponsmithing.ogg', vol = 50)
	qdel(src)
