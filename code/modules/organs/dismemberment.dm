//All stuff related to dismemberment goes here. |- Ricotez

/obj/item/weapon/
	var/can_dismember 			= 0		//Set to 1 if this weapon can dismember arms and legs.
	var/can_behead 				= 0		//Set to 1 if this weapon can dismember heads.
	var/dismember_threshold 	= 0		//Set to the damage the limb needs to have before this weapon can dismember it. As of writing, the max damage for a limb is 75.
	var/behead_threshold 		= 0		//Set to the damage the head needs to have before this weapon can dismember it. As of writing, the max damage for a head is 200.
	var/dismember_prob 			= 0		//Set the probability that this weapon dismembers if the conditions are met.
	var/behead_prob				= 0		//Set the probability that this weapon beheads if the conditions are met.
	var/dismember_nobleed		= 0		//Set whether the weapon instantly cauterizes a limb upon dismemberment. eg. eswords are so hot they seal the wound up.


/obj/proc/handle_dismemberment(var/datum/organ/limb/limbdata)
	return

//This proc is called in attacked_by() which you can find in item_attack.dm, and it assumes that the weapon already made contact with the body part.
//All this proc does is determine if the weapon can dismember the target limb, and then dismember it with the given probability.
/obj/item/weapon/handle_dismemberment(var/datum/organ/limb/limbdata)
	visible_message("This is a test message. handle_dismemberment has been called.", "This is a test message. handle_dismemberment has been called.")
	var/obj/item/organ/limb/L = limbdata.organitem
	//In this big check we determine if this weapon has met the conditions to cut off this limb.
	if((can_behead && L.name == "head" && limbdata.exists() && (L.brute_dam + L.burn_dam >= behead_threshold) && prob(behead_prob)) || (can_dismember && can_be_dismembered(limbdata.name) && limbdata.exists() && (L.brute_dam + L.burn_dam >= dismember_threshold) && prob(dismember_prob)))
		if(dismember_nobleed)
			return limbdata.dismember(ORGAN_NOBLEED)
		else
			return limbdata.dismember(ORGAN_DESTROYED)
	return null

//THIS PROC DOES NOT INCLUDE HEADS BECAUSE BEHEADING IS DEALT WITH SEPARATELY!
//Not all weapons that can dismember can also behead.
/obj/proc/can_be_dismembered(var/limbname)
	return (limbname == "l_arm" || limbname == "r_arm" || limbname == "l_leg" || limbname == "r_leg")