/obj/item/weapon/implant/krav_maga
	name = "krav maga implant"
	desc = "Teaches you the arts of Krav Maga in 5 short instructional videos beamed directly into your eyeballs."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"
	activated = 1
	origin_tech = "materials=2;biotech=4;combat=5;syndicate=4"
	var/datum/martial_art/krav_maga/style = new

/obj/item/weapon/implant/krav_maga/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Krav Maga Implant<BR>
				<b>Life:</b> 4 hours after death of host<BR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Teaches even the clumsiest host the arts of Krav Maga."}
	return dat

/obj/item/weapon/implant/krav_maga/activate()
	var/mob/living/carbon/human/H = imp_in
	if(!ishuman(H))
		return
	if(!H.mind)
		return
	if(istype(H.mind.martial_art, /datum/martial_art/krav_maga))
		style.remove(H)
	else
		style.teach(H,1)

/obj/item/weapon/implanter/krav_maga
	name = "implanter (krav maga)"
	imp_type = /obj/item/weapon/implant/krav_maga

/obj/item/weapon/implantcase/krav_maga
	name = "implant case - 'Krav Maga'"
	desc = "A glass case containing an implant that can teach the user the arts of Krav Maga."
	imp_type = /obj/item/weapon/implant/krav_maga

