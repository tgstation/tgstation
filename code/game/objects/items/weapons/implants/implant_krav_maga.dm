/obj/item/weapon/implant/krav_maga
	name = "krav maga implant"
	desc = "Teaches you the arts of Krav Maga in 5 short instructional videos beamed directly into your eyeballs."
	icon_state = "auth"
	activated = 0
	var/datum/martial_art/krav_maga/style = new

/obj/item/weapon/implant/krav_maga/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Krav Maga Implant<BR>
				<b>Life:</b> 4 hours after death of host<BR>
				<b>Implant Details:</b> <BR>
				<b>Function:</b> Teaches even the clumsiest host the arts of Krav Maga."}
	return dat
