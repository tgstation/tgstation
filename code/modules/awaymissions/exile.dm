//Exile implants will allow you to use the station gate, but not return home.
//This will allow security to exile badguys/for badguys to exile their kill targets

/obj/item/medical/implanter/exile
	name = "implanter-exile"

/obj/item/medical/implanter/exile/New()
	imp = new /obj/item/medical/implant/exile( src )
	..()
	update_icon()


/obj/item/medical/implant/exile
	name = "exile"
	desc = "Prevents you from returning from away missions"

/obj/item/medical/implant/exile/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Exile Implant<BR>
				<b>Implant Details:</b> The onboard gateway system has been modified to reject entry by individuals containing this implant<BR>"}
	return dat


/obj/item/medical/implantcase/exile
	name = "glass case- 'Exile'"
	desc = "A case containing an exile implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"

/obj/item/medical/implantcase/exile/New()
	imp = new /obj/item/medical/implant/exile(src)
	..()


/obj/structure/closet/secure_closet/exile
	name = "exile implants"
	req_access = list(access_hos)

/obj/structure/closet/secure_closet/exile/New()
	..()
	sleep(2)
	new /obj/item/medical/implanter/exile(src)
	new /obj/item/medical/implantcase/exile(src)
	new /obj/item/medical/implantcase/exile(src)
	new /obj/item/medical/implantcase/exile(src)
	new /obj/item/medical/implantcase/exile(src)
	new /obj/item/medical/implantcase/exile(src)