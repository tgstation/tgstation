/obj/item/weapon/implant/uplink
	name = "uplink implant"
	desc = "Summon things."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	origin_tech = "materials=2;magnets=4;programming=4;biotech=4;syndicate=8;bluespace=5"

/obj/item/weapon/implant/uplink/New()
	hidden_uplink = new(src)
	hidden_uplink.uses = 10
	..()

/obj/item/weapon/implant/uplink/implant(mob/source)
	var/obj/item/weapon/implant/imp_e = locate(src.type) in source
	if(imp_e && imp_e != src)
		imp_e.hidden_uplink.uses += hidden_uplink.uses
		qdel(src)
		return 1

	if(..())
		hidden_uplink.uplink_owner="[source.key]"
		return 1
	return 0

/obj/item/weapon/implant/uplink/activate()
	if(hidden_uplink)
		hidden_uplink.check_trigger(imp_in)


/obj/item/weapon/implanter/uplink
	name = "implanter (uplink)"

/obj/item/weapon/implanter/uplink/New()
	imp = new /obj/item/weapon/implant/uplink(src)
	..()