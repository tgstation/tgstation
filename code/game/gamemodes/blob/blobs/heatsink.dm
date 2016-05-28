/obj/effect/blob/heatsink
	name = "heatsink blob"
	icon_state = "blank_blob"
	desc = "A fleshy mass capable of asborbing laser fire."
	health = 5
	maxhealth = 5
	atmosblock = 1

/obj/effect/blob/heatsink/update_icon()
	overlays.Cut()
	color = null
	var/image/I = new('icons/mob/blob.dmi', "blob")
	if(overmind)
		I.color = overmind.blob_reagent_datum.color
	src.overlays += I
	var/image/C = new('icons/mob/blob.dmi', "blob_heatskin_overlay")
	src.overlays += C


/obj/effect/blob/heatsink/bullet_act(var/obj/item/projectile/Proj)
	if(Proj.damage_type == "burn")
		return 0
	else
		..()