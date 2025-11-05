/obj/item/implant/kaza_ruk
	name = "kaza ruk implant"
	desc = "Teaches you the Tiziran martial arts of Kaza Ruk in 5 short instructional videos beamed directly into your eyeballs."
	icon = 'icons/obj/scrolls.dmi'
	icon_state ="scroll2"
	/// The martial art style this implant teaches.
	var/datum/martial_art/kaza_ruk/style

/obj/item/implant/kaza_ruk/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Kaza Ruk Implant<BR>
				<b>Life:</b> 4 hours after death of host<BR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Teaches even the clumsiest host the arts of Kaza Ruk."}
	return dat

/obj/item/implant/kaza_ruk/Initialize(mapload)
	. = ..()
	style = new(src)

/obj/item/implant/kaza_ruk/Destroy()
	QDEL_NULL(style)
	return ..()

/obj/item/implant/kaza_ruk/activate()
	. = ..()
	if(isnull(imp_in.mind))
		return
	if(style.unlearn(imp_in))
		return

	style.teach(imp_in)

/obj/item/implanter/kaza_ruk
	name = "implanter (kaza ruk)"
	imp_type = /obj/item/implant/kaza_ruk

/obj/item/implantcase/kaza_ruk
	name = "implant case - 'Kaza Ruk'"
	desc = "A glass case containing an implant that can teach the user the Tiziran martial arts of Kaza Ruk."
	imp_type = /obj/item/implant/kaza_ruk
