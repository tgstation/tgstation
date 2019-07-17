//////////////EXTERNAL LENS//////////////

/obj/item/external_lens
	name = "external lens"
	icon_state = "external"
	desc = "These lens modify the laser frequency and trajectory giving them special effects."
	icon = 'icons/obj/guns/energy.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/stored_ammo_type = /obj/item/ammo_casing/energy/laser
	var/restricted_type = /obj/item/gun/energy/laser //which type of laser gun it can be assigned to
	var/overlay = "laser"

/obj/item/external_lens/Initialize()
	. = ..()
	add_overlay(overlay)

/obj/item/external_lens/afterattack(atom/movable/AM, mob/user, flag)
	. = ..()
	if(user && AM.type == restricted_type)
		AM.AddComponent(/datum/component/extralasers, stored_ammo_type, type)
		playsound(src, 'sound/weapons/pistolrack.ogg', 50, 0)
		qdel(src)

/obj/item/external_lens/ricochet
	name = "external lens: bouncing ray"
	desc = "By making the laser pass through an high density gas its able to create a small ball of hot plasma with high elasticity."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/rico
	overlay = "bouncing"

/obj/item/external_lens/shocking
	name = "external lens: shocking ray"
	desc = "Condenses energy into sparks that shock your enemies."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/shock
	overlay = "shocking"

/obj/item/external_lens/blinding
	name = "external lens: blinding ray"
	desc = "These ultra violet rays really do hurt the eyes, when you hit people with them."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/blinding
	overlay = "blinding"

/obj/item/external_lens/stealth
	name = "external lens: stealth ray"
	desc = "These rays are almost invisible to the human eye, they are less efficent in the dark."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/invisible
	overlay = "stealth"

/obj/item/external_lens/incendiary
	name = "external lens: incendiary ray"
	desc = "Heats up whatever it hits, causing them to burst into fire."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/incendiary
	overlay = "incendiary"

/obj/item/external_lens/economic
	name = "external lens: low power consuption ray"
	desc = "Trades firepower for high efficiency, to kill people with many small shots."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/lowenergy
	overlay = "economic"

/obj/item/external_lens/shield
	name = "external lens: barricade projector"
	desc = "Projects holobarricades which temporary absorb projectiles, watch out as even your target might use them as cover."
	stored_ammo_type = /obj/item/ammo_casing/energy/laser/shield
	overlay = "shield"
