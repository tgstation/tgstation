/obj/machinery/blood_donation_stand
	name = "\improper Blood Donation Stand"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "blood_donation_stand"
	anchored = 1
	density = 1

/obj/machinery/blood_donation_stand/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/reagent/blood/B = H.get_blood()
		if(B && B.volume > 50)
			H << "You donate 50u of your blood. The machine spits out a cookie and an injector."
		var/obj/item/weapon/reagent_containers/hypospray/medipen/blood/M = new /obj/item/weapon/reagent_containers/hypospray/medipen/blood(src.loc)
		H.take_blood(M, 50)
		M.name += " ([B.data["blood_type"]])"
		new /obj/item/weapon/reagent_containers/food/snacks/cookie/blood(src.loc)
	..()