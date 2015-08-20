/obj/item/weapon/implant/explosive
	name = "explosive implant"
	desc = "And boom goes the weasel."
	icon_state = "explosive"

/obj/item/weapon/implant/explosive/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp RX-78 Employee Management Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Explodes<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact, electrically detonated explosive that detonates upon receiving a specially encoded signal or upon host death.<BR>
				<b>Special Features:</b> Explodes<BR>
				<b>Integrity:</b> Implant will occasionally be degraded by the body's immune system and thus will occasionally malfunction."}
	return dat

/obj/item/weapon/implant/explosive/trigger(emote, mob/source)
	if(emote == "deathgasp")
		activate("death")

/obj/item/weapon/implant/explosive/activate(var/cause)
	if(!cause || !imp_in)	return 0
	if(cause == "action_button" && alert(imp_in, "Are you sure you want to activate your explosive implant? This will cause you to explode and gib!", "Explosive Implant Confirmation", "Yes", "No") != "Yes")
		return 0
	explosion(src,1,2,5,7,10, flame_range = 5)
	if(imp_in)
		imp_in.gib()