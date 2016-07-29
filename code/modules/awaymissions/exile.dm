<<<<<<< HEAD
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


/obj/structure/closet/secure_closet/exile
	name = "exile implants"
	req_access = list(access_hos)

/obj/structure/closet/secure_closet/exile/New()
	..()
	new /obj/item/weapon/implanter/exile(src)
	new /obj/item/weapon/implantcase/exile(src)
	new /obj/item/weapon/implantcase/exile(src)
	new /obj/item/weapon/implantcase/exile(src)
	new /obj/item/weapon/implantcase/exile(src)
	new /obj/item/weapon/implantcase/exile(src)
=======
//////Exile implants will allow you to use the station gate, but not return home. This will allow security to exile badguys/for badguys to exile their kill targets////////


/obj/item/weapon/implanter/exile
	name = "implanter-exile"

/obj/item/weapon/implanter/exile/New()
	src.imp = new /obj/item/weapon/implant/exile( src )
	..()
	update()
	return


/obj/item/weapon/implant/exile
	name = "exile"
	desc = "Prevents you from returning from away missions"

	get_data()
		var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Nanotrasen Employee Exile Implant<BR>
<b>Implant Details:</b> The onboard gateway system has been modified to reject entry by individuals containing this implant<BR>"}
		return dat

/obj/item/weapon/implantcase/exile
	name = "Glass Case- 'Exile'"
	desc = "A case containing an exile implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-r"


	New()
		src.imp = new /obj/item/weapon/implant/exile( src )
		..()
		return


/obj/structure/closet/secure_closet/exile
	name = "Exile Implants"
	req_access = list(access_hos)

	New()
		..()
		sleep(2)
		new /obj/item/weapon/implanter/exile(src)
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implantcase/exile(src)
		new /obj/item/weapon/implantcase/exile(src)
		return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
