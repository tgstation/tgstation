/obj/item/chem/food/snacks/meat
	name = "meat"
	desc = "A slab of meat"
	icon_state = "meat"
	health = 180
	New()
		..()
		reagents.add_reagent("nutriment", 3)
		src.bitesize = 3


/obj/item/chem/food/snacks/meat/syntiflesh
	name = "synthetic meat"
	desc = "A synthetic slab of flesh."

/obj/item/chem/food/snacks/meat/human
	name = "-meat"
	var/subjectname = ""
	var/subjectjob = null


/obj/item/chem/food/snacks/meat/monkey
	//same as plain meat

/obj/item/chem/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."