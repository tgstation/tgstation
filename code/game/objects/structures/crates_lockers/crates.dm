/obj/structure/closet/crate
	name = "crate"
	desc = "A rectangular steel crate."
	icon = 'icons/obj/crates.dmi'
	icon_state = "crate"
	req_access = null
	can_weld_shut = FALSE
	horizontal = TRUE
	allow_objects = TRUE
	allow_dense = TRUE
	var/obj/item/weapon/paper/manifest/manifest

/obj/structure/closet/crate/New()
	..()
	update_icon()

/obj/structure/closet/crate/update_icon()
	icon_state = "[initial(icon_state)][opened ? "open" : ""]"

	overlays.Cut()
	if(manifest)
		overlays += "manifest"

/obj/structure/closet/crate/attack_hand(mob/user)
	add_fingerprint(user)
	if(manifest)
		tear_manifest(user)
		return
	if(!toggle())
		togglelock(user)

/obj/structure/closet/crate/proc/tear_manifest(mob/user)
	user << "<span class='notice'>You tear the manifest off of the crate.</span>"
	playsound(src, 'sound/items/poster_ripped.ogg', 75, 1)

	manifest.loc = loc
	if(ishuman(user))
		user.put_in_hands(manifest)
	manifest = null
	update_icon()

/obj/structure/closet/crate/internals
	desc = "A internals crate."
	name = "internals crate"
	icon_state = "o2crate"

/obj/structure/closet/crate/trashcart
	desc = "A heavy, metal trashcart with wheels."
	name = "trash cart"
	icon_state = "trashcart"

/obj/structure/closet/crate/medical
	desc = "A medical crate."
	name = "medical crate"
	icon_state = "medicalcrate"

/obj/structure/closet/crate/freezer
	desc = "A freezer."
	name = "freezer"
	icon_state = "freezer"

/obj/structure/closet/crate/radiation
	desc = "A crate with a radiation sign on it."
	name = "radiation crate"
	icon_state = "radiation"

/obj/structure/closet/crate/hydroponics
	name = "hydroponics crate"
	desc = "All you need to destroy those pesky weeds and pests."
	icon_state = "hydrocrate"

/obj/structure/closet/crate/engineering
	name = "engineering crate"
	icon_state = "engi_crate"

/obj/structure/closet/crate/engineering/electrical
	icon_state = "engi_e_crate"

/obj/structure/closet/crate/rcd
	desc = "A crate for the storage of an RCD."
	name = "\improper RCD crate"
	icon_state = "engi_crate"

/obj/structure/closet/crate/rcd/New()
	..()
	for(var/i in 1 to 4)
		new /obj/item/weapon/rcd_ammo(src)
	new /obj/item/weapon/rcd(src)
