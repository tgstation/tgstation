/obj/item/organ/internal
	origin_tech = "biotech=2"
	force = 1
	w_class = 2
	throwforce = 0
	var/zone ="error"
	var/slot = "error"
	var/vital = 0
	var/organ_action_name = null

	var/dysfunctional = 0	//Inflamed appendix, kidney or liver failure, etc.
	var/base_icon_state
	var/damstring = "damaged"
	var/diseasetype
	var/curedbyremoval = 0

/obj/item/organ/internal/Remove()
	if(organ_action_name)
		action_button_name = null
	update_icon()

	if(curedbyremoval)
		for(var/datum/disease/A in owner.viruses)
			if(istype(A, diseasetype))
				A.cure()
				dysfunctional = 1
	else if(diseasetype)	//Basically if you remove a healthy organ you will have the same symptoms as if it was dysfunctional
		for(var/datum/disease/A in owner.viruses)
			if(istype(A, diseasetype))
				return
		owner.AddDisease(new diseasetype)
	..()

/obj/item/organ/internal/on_insertion(special = 0)
	if(organ_action_name)
		action_button_name = organ_action_name
	update_icon()

	if(dysfunctional)
		for(var/datum/disease/A in owner.viruses)
			if(istype(A, diseasetype))
				return
		owner.AddDisease(new diseasetype)
	else	//Healthy organ transplant cures liver and kidney failure
		for(var/datum/disease/A in owner.viruses)
			if(istype(A, diseasetype))
				A.cure()
	return

/obj/item/organ/internal/update_icon()
	if(base_icon_state)	//We don't need to do this for organs that don't update
		if(dysfunctional)
			icon_state = "[base_icon_state]_dam"
			name = "[damstring] [hardpoint]"	//[hardpoint] is a bit kludge-y but I don't want to have each organ to have four of the exact same string
		else
			icon_state = "[base_icon_state]"
			name = "[hardpoint]"

/obj/item/organ/internal/proc/on_find(mob/living/finder)
	return

/obj/item/organ/internal/proc/on_life()
	return

/obj/item/organ/internal/proc/prepare_eat()
	var/obj/item/weapon/reagent_containers/food/snacks/S = new
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.origin_tech = origin_tech
	S.w_class = w_class
	S.reagents.add_reagent("nutriment", 5)

	return S

/obj/item/organ/internal/Destroy()
	if(owner)
		organdatum.dismember(ORGAN_REMOVED, 1)
	..()

/obj/item/organ/internal/attack(mob/living/carbon/M, mob/user)
	if(M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(organtype == ORGAN_ORGANIC)
			var/obj/item/weapon/reagent_containers/food/snacks/S = prepare_eat()
			if(S)
				H.drop_item()
				H.put_in_active_hand(S)
				S.attack(H, H)
				qdel(src)
	else
		..()

//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm



/obj/item/organ/internal/heart
	name = "heart"
	hardpoint = "heart"
	icon_state = "heart-on"
	desc = "Some days, your heart is just not in it."
	origin_tech = "biotech=3"
	var/beating = 1

/obj/item/organ/internal/heart/update_icon()
	if(beating)
		icon_state = "heart-on"
	else
		icon_state = "heart-off"

/obj/item/organ/internal/heart/examine(mob/user)
	if(beating)
		user << "It's still beating."
	else
		user << "It stopped beating."

/obj/item/organ/internal/heart/on_insertion()
	beating = 1
	update_icon()
	return

/obj/item/organ/internal/heart/Remove(special = 0)
	..()
	spawn(120)
		beating = 0
		update_icon()

/obj/item/organ/internal/heart/prepare_eat()
	var/obj/S = ..()
	S.icon_state = "heart-off"
	return S



/obj/item/organ/internal/appendix
	name = "appendix"
	hardpoint = "appendix"
	icon_state = "appendix"
	desc = "The greyshirt of organs."

	base_icon_state = "appendix"
	damstring = "inflamed"
	diseasetype = /datum/disease/appendicitis
	curedbyremoval = 1

/obj/item/organ/internal/appendix/prepare_eat()
	var/obj/S = ..()
	if(dysfunctional)
		S.reagents.add_reagent("????", 5)
	return S

// New internal organs
// Thanks Randy



/obj/item/organ/internal/liver
	name = "liver"
	hardpoint = "liver"
	icon_state = "liver"
	base_icon_state = "liver"
	desc = "Liver let die."
	diseasetype = /datum/disease/cirrhosis



/obj/item/organ/internal/kidneys
	name = "kidneys"
	hardpoint = "kidneys"
	icon_state = "kidneys"
	base_icon_state = "kidneys"
	desc = "I couldn't think of a witty pun here."
	diseasetype = /datum/disease/kidney_failure



/obj/item/organ/internal/lungs
	name = "lungs"
	hardpoint = "lungs"
	base_icon_state = "lungs"
	desc = "I couldn't think of a witty pun here."
	diseasetype = /datum/disease/emphysema	//Smoker's lung
	curedbyremoval = 1


/*
/obj/item/organ/internal/stomach
	name = "stomach"
	hardpoint = "stomach"
	base_icon_state = "stomach"
	desc = "I couldn't think of a witty pun here."
*/