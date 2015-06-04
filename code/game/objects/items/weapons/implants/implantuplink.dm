/obj/item/weapon/implant/uplink
	name = "uplink implant"
	desc = "Summon things."
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"

/obj/item/weapon/implant/uplink/New()
	hidden_uplink = new(src)
	hidden_uplink.uses = 10
	..()

/obj/item/weapon/implant/uplink/implanted(mob/source)
	..()
	hidden_uplink.uplink_owner="[source.key]"
	return 1


/obj/item/weapon/implant/uplink/activate()
	if(hidden_uplink)
		hidden_uplink.check_trigger(imp_in)