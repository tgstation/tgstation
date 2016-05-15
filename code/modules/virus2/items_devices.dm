///////////////ANTIBODY SCANNER///////////////

/obj/item/device/antibody_scanner
	name = "Antibody Scanner"
	desc = "Used to scan living beings for antibodies in their blood."
	icon_state = "antibody"
	w_class = W_CLASS_SMALL
	item_state = "electronic"
	flags = FPRINT
	siemens_coefficient = 1


/obj/item/device/antibody_scanner/attack(mob/living/carbon/M as mob, mob/user as mob)
	if(!istype(M))
		to_chat(user, "<span class='notice'>Incompatible object, scan aborted.</span>")
		return
	var/mob/living/carbon/C = M
	if(!C.antibodies)
		to_chat(user, "<span class='notice'>Unable to detect antibodies.</span>")
		return
	var/code = antigens2string(M.antibodies)
	to_chat(user, "<span class='notice'>[src] The antibody scanner displays a cryptic set of data: [code]</span>")

///////////////VIRUS DISH///////////////

/obj/item/weapon/virusdish
	name = "Virus containment/growth dish"
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-b"
	var/datum/disease2/disease/virus2 = null
	var/growth = 0
	var/info = 0
	var/analysed = 0

/obj/item/weapon/virusdish/random
	name = "Virus Sample"

/obj/item/weapon/virusdish/random/New(loc)
	..(loc)
	virus2 = new /datum/disease2/disease
	virus2.makerandom()
	growth = rand(5, 50)

/obj/item/weapon/virusdish/attackby(var/obj/item/weapon/W as obj,var/mob/living/carbon/user as mob)
	if(istype(W,/obj/item/weapon/hand_labeler) || istype(W,/obj/item/weapon/reagent_containers/syringe))
		return
	..()
	if(prob(50))
		to_chat(user, "The dish shatters")
		if(virus2.infectionchance > 0)
			for(var/mob/living/carbon/target in view(1, get_turf(src)))
				if(airborne_can_reach(get_turf(src), get_turf(target)))
					if(get_infection_chance(target))
						infect_virus2(target,src.virus2, notes="([src] attacked by [key_name(user)])")
		qdel (src)

/obj/item/weapon/virusdish/examine(mob/user)
	..()
	if(src.info)
		to_chat(user, "<span class='info'>It has the following information about its contents</span>")
		to_chat(user, src.info)

///////////////GNA DISK///////////////

/obj/item/weapon/diseasedisk
	name = "Blank GNA disk"
	icon = 'icons/obj/cloning.dmi'
	icon_state = "datadisk0"
	var/datum/disease2/effectholder/effect = null
	var/stage = 1

/obj/item/weapon/diseasedisk/premade/New()
	name = "Blank GNA disk (stage: [5-stage])"
	effect = new /datum/disease2/effectholder
	effect.effect = new /datum/disease2/effect/invisible
	effect.stage = stage