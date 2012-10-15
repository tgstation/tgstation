/obj/item/weapon/reagent_containers/blood
	name = "BloodPack"
	desc = "Contains blood used for transfusion."
	icon = 'icons/obj/bloodpack.dmi'
	volume = 100

	var/blood_type = null

	New()
		..()
		if(blood_type != null)
			name = "BloodPack [blood_type]"
			reagents.add_reagent("blood", 100, list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=blood_type,"resistances"=null,"trace_chem"=null))

/obj/item/weapon/reagent_containers/blood/APlus
	blood_type = "A+"

/obj/item/weapon/reagent_containers/blood/AMinus
	blood_type = "A-"

/obj/item/weapon/reagent_containers/blood/BPlus
	blood_type = "B+"

/obj/item/weapon/reagent_containers/blood/BMinus
	blood_type = "B-"

/obj/item/weapon/reagent_containers/blood/OPlus
	blood_type = "O+"

/obj/item/weapon/reagent_containers/blood/OMinus
	blood_type = "O-"

/obj/item/weapon/reagent_containers/blood/empty
	name = "Empty BloodPack"
	desc = "Seems pretty useless... Maybe if there were a way to fill it?"
	icon_state = "empty"