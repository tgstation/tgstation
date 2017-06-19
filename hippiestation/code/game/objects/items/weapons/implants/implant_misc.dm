/obj/item/weapon/implant/comstimms
	name = "Combat Stimulant Implant"
	desc = "A cocktail of potent drugs will heal damage allowing you to fight for longer"
	icon_state = "adrenal"
	origin_tech = "materials=2;biotech=4;combat=3;syndicate=4"
	uses = 3

/obj/item/weapon/implant/comstimms/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Cybersun Industries Combat Implant<BR>
				<b>Life:</b> Five days.<BR>
				<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
				<HR>
				<b>Implant Details:</b> Subjects injected with implant can activate an injection of medical cocktails.<BR>
				<b>Function:</b> Has an impressive healing effect.<BR>
				<b>Integrity:</b> Implant can only be used three times before reserves are depleted."}
	return dat

/obj/item/weapon/implant/comstimms/activate()
	uses--
	to_chat(imp_in, "<span class='notice'>You feel the pain fade, and your wounds close!</span>")
	imp_in.adjustToxLoss(-30, 0) //The idea being to take a nearly dead man and make them combat ready
	imp_in.adjustBruteLoss(-10, 0)//This might look insane but remeber that adrenals were a GG no Re button most of the time, at least if you cuff this nerd you can beat them.
	imp_in.adjustFireLoss(-10, 0)
	imp_in.adjustOxyLoss(-50, 0)
	imp_in.adjustStaminaLoss(-75)
	imp_in.restoreEars()
	imp_in.cure_blind()
	imp_in.cure_nearsighted()

	imp_in.reagents.add_reagent("synaptizine", 10)
	imp_in.reagents.add_reagent("omnizine", 10)
	imp_in.reagents.add_reagent("syndicate_nanites", 10)
	imp_in.reagents.add_reagent("salbutamol", 10)//These two mean you could survive being spaced and come back healthy and ANRGY
	imp_in.reagents.add_reagent("leporazine", 10)
	if(!uses)
		qdel(src)