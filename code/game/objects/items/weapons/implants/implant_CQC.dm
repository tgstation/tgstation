/obj/item/weapon/implant/CQC
	name = "CQC implant"
	desc = "Try to remember some of the basics of CQC, Snake."
	icon = 'icons/mob/actions.dmi'
	icon_state ="cqc_0"
	activated = 1
	origin_tech = "materials=2;biotech=4;combat=7;syndicate=6"
	var/datum/martial_art/CQC/style = new

/obj/item/weapon/implant/CQC/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> CQC Implant<BR>
				<b>Life:</b> 4 hours after death of host<BR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Makes you try to remember some of the basics of CQC"}
	return dat

/obj/item/weapon/implant/CQC/activate()
	var/mob/living/carbon/human/H = imp_in
	if(!ishuman(H))
		return
	if(istype(H.martial_art, /datum/martial_art/CQC))
		style.remove(H)
	else
		H.visible_message("<span class='danger'>[H] assumes the CQC stance!</span>")
		style.teach(H,1)

/obj/item/weapon/implanter/CQC
	name = "implanter (CQC)"

/obj/item/weapon/implanter/CQC/New()
	imp = new /obj/item/weapon/implant/CQC(src)
	..()

/obj/item/weapon/implantcase/CQC
	name = "implant case - 'CQC'"
	desc = "A glass case containing an implant that can teach the user the basics of CQC."

/obj/item/weapon/implantcase/CQC/New()
	imp = new /obj/item/weapon/implant/CQC(src)
	..()
