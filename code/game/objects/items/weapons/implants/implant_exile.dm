//Exile implants will allow you to use the station gate, but not return home.
//This will allow security to exile badguys/for badguys to exile their kill targets

/obj/item/weapon/implant/exile
	name = "exile implant"
	desc = "Prevents you from returning from away missions"
	origin_tech = "materials=2;biotech=3;magnets=2;bluespace=3"
	activated = 0

/obj/item/weapon/implant/exile/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nanotrasen Employee Exile Implant<BR>
				<b>Implant Details:</b> The onboard gateway system has been modified to reject entry by individuals containing this implant<BR>"}
	return dat


/obj/item/weapon/implanter/exile
	name = "implanter (exile)"

/obj/item/weapon/implanter/exile/New()
	imp = new /obj/item/weapon/implant/exile( src )
	..()

/obj/item/weapon/implantcase/exile
	name = "implant case - 'Exile'"
	desc = "A glass case containing an exile implant."

/obj/item/weapon/implantcase/exile/New()
	imp = new /obj/item/weapon/implant/exile(src)
	..()
