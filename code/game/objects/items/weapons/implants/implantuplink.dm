/obj/item/weapon/implant/uplink
	name = "uplink implant"
	desc = "Sneeki breeki."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	origin_tech = "materials=4;magnets=4;programming=4;biotech=4;syndicate=5;bluespace=5"

/obj/item/weapon/implant/uplink/New()
	hidden_uplink = new(src)
	hidden_uplink.telecrystals = 10
	..()

/obj/item/weapon/implant/uplink/implant(mob/user)
	var/obj/item/weapon/implant/imp_e = locate(src.type) in user
	if(imp_e && imp_e != src)
		imp_e.hidden_uplink.telecrystals += hidden_uplink.telecrystals
		qdel(src)
		return 1

	if(..())
		hidden_uplink.owner = "[user.key]"
		return 1
	return 0

/obj/item/weapon/implant/uplink/activate()
	if(hidden_uplink)
		hidden_uplink.interact(usr)

/obj/item/weapon/implanter/uplink
	name = "implanter (uplink)"

/obj/item/weapon/implanter/uplink/New()
	imp = new /obj/item/weapon/implant/uplink(src)
	..()
