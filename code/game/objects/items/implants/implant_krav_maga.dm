/obj/item/implant/krav_maga
	name = "krav maga implant"
	desc = "Teaches you the arts of Krav Maga in 5 short instructional videos beamed directly into your eyeballs."
	icon = 'icons/obj/scrolls.dmi'
	icon_state ="scroll2"
	var/datum/martial_art/krav_maga/style

/obj/item/implant/krav_maga/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Krav Maga Implant<BR>
				<b>Life:</b> 4 hours after death of host<BR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Teaches even the clumsiest host the arts of Krav Maga."}
	return dat

/obj/item/implant/krav_maga/Initialize(mapload)
	. = ..()
	style = new()
	style.allow_temp_override = FALSE

/obj/item/implant/krav_maga/Destroy()
	QDEL_NULL(style)
	return ..()

/obj/item/implant/krav_maga/activate()
	. = ..()
	if(isnull(imp_in.mind))
		return
	if(style.fully_remove(imp_in))
		return

	style.teach(imp_in, TRUE)

/obj/item/implanter/krav_maga
	name = "implanter (krav maga)"
	imp_type = /obj/item/implant/krav_maga

/obj/item/implantcase/krav_maga
	name = "implant case - 'Krav Maga'"
	desc = "A glass case containing an implant that can teach the user the arts of Krav Maga."
	imp_type = /obj/item/implant/krav_maga
