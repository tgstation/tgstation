/obj/item/weapon/reagent_containers/food/snacks/meat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "meat"
	health = 180

/obj/item/weapon/reagent_containers/food/snacks/meat/New(var/loc, var/mob/flesh, var/total_slabs=3)
	..(loc)
	src.bitesize = 3
	if(!flesh)
		reagents.add_reagent("nutriment", 3)
	else
		add_reagents_from(flesh, total_slabs)


/obj/item/weapon/reagent_containers/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

/obj/item/weapon/reagent_containers/food/snacks/meat/human
	name = "-meat"
	var/subjectname = ""
	var/subjectjob = null

/obj/item/weapon/reagent_containers/food/snacks/meat/human/New(var/loc, var/mob/living/carbon/human/flesh, var/total_slabs=3)
	..(loc, flesh, total_slabs)
	name = flesh.real_name + "-meat"
	subjectname = flesh.real_name
	subjectjob = flesh.job


/obj/item/weapon/reagent_containers/food/snacks/meat/monkey
	//same as plain meat

/obj/item/weapon/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."

/obj/item/weapon/reagent_containers/food/snacks/meat/pug
	name = "Pug meat"
	desc = "Tastes like... well you know..."

/obj/item/weapon/reagent_containers/food/snacks/meat/proc/add_reagents_from(var/mob/flesh, var/total_slabs=0)
	if(!flesh || total_slabs <= 0)
		return
	var/sourcenutriment = flesh.nutrition / 15 //probably for the best that not all nutriments are transferred
	var/sourcetotalreagents = flesh.reagents.total_volume
	src.reagents.add_reagent ("nutriment", round(sourcenutriment / total_slabs)) // add nutriment
	flesh.reagents.trans_to (src, round(sourcetotalreagents / total_slabs, 1)) // add reagents
