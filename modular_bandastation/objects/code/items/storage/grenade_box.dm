/obj/item/storage/box/smoke_grenade
	name = "box of smoke grenade"
	desc = "Do not shake."
	icon_state = "security"
	illustration = "grenade"

/obj/item/storage/box/smoke_grenade/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/grenade/smokebomb(src)
