/obj/item/implant/dusting
	name = "duster implant"
	desc = "An alarm which monitors host vital signs, transmitting a radio message and dusting the corpse on death."
	actions_types = list(/datum/action/item_action/dusting_implant)

/obj/item/implant/dusting/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Ultraviolet Corp XX-13 Security Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Vaporizes organic matter<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact, electrically activated heat source that turns its host to ash upon activation, or their death. <BR>
				<b>Special Features:</b> Vaporizes<BR>
				"}
	return dat

/obj/item/implant/dust/activate(cause)
	if(!cause || !imp_in || cause != "action_button")
		return FALSE
	if(alert(imp_in, "Are you sure you want to activate your dusting implant? This will turn you to ash!", "Dusting Confirmation", "Yes", "No") != "Yes")
		return FALSE
	to_chat(imp_in, "<span class='notice'>Your dusting implant activates!</span>")
	imp_in.visible_message("<span class='warning'>[imp_in] burns up in a flash!</span>")
	for(var/obj/item/I in imp_in.contents)
		if(I == src)
			continue
		 qdel(I)
	imp_in.dust()