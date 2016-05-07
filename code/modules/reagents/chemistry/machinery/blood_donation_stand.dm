/obj/machinery/blood_donation_stand
	name = "\improper Blood Donation Stand"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "blood_donation_stand"
	anchored = 1
	density = 1

/obj/machinery/blood_donation_stand/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.vessel.total_volume > 50)
			H << "You donate 50u of your blood. The machine spits out a cookie and an injector."
		else
			return
		var/obj/item/weapon/reagent_containers/hypospray/medipen/blood/M = new /obj/item/weapon/reagent_containers/hypospray/medipen/blood(src.loc)
		var/blood_string = H.dna.blood_type
		M.name += " ([blood_string])"
		H.vessel.remove_reagent("blood", 50)
		M.reagents.add_reagent("blood", 50, list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=blood_string,"resistances"=null,"trace_chem"=null))
		new /obj/item/weapon/reagent_containers/food/snacks/cookie/blood(src.loc)
	..()