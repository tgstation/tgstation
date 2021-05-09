/obj/item/reagent_containers/glass/bottle/vial
	name = "broken hypovial"
	desc = "You probably shouldn't be seeing this. Shout at a coder."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "hypovial"
	fill_icon_state = "hypovial"
	spillable = FALSE
	volume = 10
	possible_transfer_amounts = list(1,2,5,10)
	custom_price = 350
	var/fill_name = "hypovial"
	fill_icon_thresholds = list(0, 10, 50, 75, 100)

/obj/item/reagent_containers/glass/bottle/vial/Initialize()
	. = ..()
	update_icon()

/obj/item/reagent_containers/glass/bottle/vial/on_reagent_change()
	update_icon()

//Fit in all hypos
/obj/item/reagent_containers/glass/bottle/vial/small
	name = "hypovial"
	desc = "A small, 60u capacity vial compatible with most hyposprays."
	volume = 60
	possible_transfer_amounts = list(1,2,5,10,20)

//Fit in CMO hypo only
/obj/item/reagent_containers/glass/bottle/vial/large
	name = "large hypovial"
	icon_state = "hypoviallarge"
	fill_icon_state = "hypoviallarge"
	desc = "A large, 120u capacity vial that fits only in the most deluxe hyposprays."
	volume = 120
	possible_transfer_amounts = list(1,2,5,10,20,30,40,50,100,120)

//Hypos that are in the CMO's kit round start
/obj/item/reagent_containers/glass/bottle/vial/large/deluxe
	name = "deluxe hypovial"
	desc = "A large, 120u capacity vial that fits only in the most deluxe hyposprays. This one is specialized for patients in critical condition."
	icon_state = "hypoviallarge-cmos"
	list_reagents = list(/datum/reagent/medicine/omnizine = 20, /datum/reagent/medicine/leporazine = 20, /datum/reagent/medicine/atropine = 20)

/obj/item/reagent_containers/glass/bottle/vial/large/salglu
	name = "large green hypovial (salglu)"
	desc = "Contains a saline-glucose solution."
	icon_state = "hypoviallarge-a"
	list_reagents = list(/datum/reagent/medicine/salglu_solution = 60)

/obj/item/reagent_containers/glass/bottle/vial/large/synthflesh
	name = "large orange hypovial (synthflesh)"
	desc = "Contains synthflesh, a slightly toxic medicine capable of healing both bruises and burns."
	icon_state = "hypoviallarge-k"
	list_reagents = list(/datum/reagent/medicine/c2/synthflesh = 60)

/obj/item/reagent_containers/glass/bottle/vial/large/multiver
	name = "large black hypovial (multiver)"
	desc = "Contains multiver, a chem-purger which becomes more powerful in higher doses."
	icon_state = "hypoviallarge-t"
	list_reagents = list(/datum/reagent/medicine/c2/multiver = 60)

/obj/item/reagent_containers/glass/bottle/vial/large/omnizine
	name = "large hypovial (omnizine)"
	desc = "Contains omnizine, a powerful general medicine."
	list_reagents = list(/datum/reagent/medicine/omnizine = 30)

////////////////Combat hypos
/obj/item/reagent_containers/glass/bottle/vial/large/combat
	name = "large hypovial (combat)"
	icon_state = "hypoviallarge-t"
	desc = "A hypovial full of stabilizing medicines, perfect for your combat needs."
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/medicine/epinephrine = 30, /datum/reagent/medicine/omnizine = 30, /datum/reagent/medicine/leporazine = 15, /datum/reagent/medicine/atropine = 15)

/obj/item/reagent_containers/glass/bottle/vial/large/combat/nanite
	name = "large hypovial (combat nanites)"
	desc = "A hypovial full of state-of-the-art healing nanites."
	icon_state = "hypoviallarge-t"
	list_reagents = list(/datum/reagent/medicine/adminordrazine/quantum_heal = 80, /datum/reagent/medicine/synaptizine = 20)

////////////////Smaller vials
/obj/item/reagent_containers/glass/bottle/vial/small/epinephrine
	name = "cyan hypovial (epinephrine)"
	desc = "Contains epinephrine - used to stabilize patients."
	icon_state = "hypovial-c"
	list_reagents = list(/datum/reagent/medicine/epinephrine = 60)

/obj/item/reagent_containers/glass/bottle/vial/small/libital
	name = "pink hypovial (libital)"
	desc = "Contains libital. Diluted with granibitaluri."
	icon_state = "hypovial-pink"
	list_reagents = list(/datum/reagent/medicine/c2/libital = 24, /datum/reagent/medicine/granibitaluri = 36)

/obj/item/reagent_containers/glass/bottle/vial/small/aiuri
	name = "yellow hypovial (aiuri)"
	desc = "Contains aiuri. Diluted with granibitaluri."
	icon_state = "hypovial-y"
	list_reagents = list(/datum/reagent/medicine/c2/aiuri = 24, /datum/reagent/medicine/granibitaluri = 36)

/obj/item/reagent_containers/glass/bottle/vial/small/convermol
	name = "blue hypovial (convermol)"
	desc = "Contains convermol. Diluted with granibitaluri."
	icon_state = "hypovial-d"
	list_reagents = list(/datum/reagent/medicine/c2/convermol = 24, /datum/reagent/medicine/granibitaluri = 36)

/obj/item/reagent_containers/glass/bottle/vial/small/multiver
	name = "black hypovial (multiver)"
	desc = "Contains multiver, a chem-purger which becomes more powerful in higher doses."
	icon_state = "hypovial-t"
	list_reagents = list(/datum/reagent/medicine/c2/multiver = 30)

/obj/item/reagent_containers/glass/bottle/vial/small/sterilizine
	name = "red hypovial (sterilizer gel)"
	desc = "Hypovial loaded with a non-toxic sterilizer. Useful in preparation for surgery."
	icon_state = "hypovial-b"
	list_reagents = list(/datum/reagent/space_cleaner/sterilizine = 60)
	custom_price = 175

/obj/item/reagent_containers/glass/bottle/vial/small/synthflesh
	name = "orange hypovial (synthflesh)"
	desc = "Contains synthflesh, a slightly toxic medicine capable of healing both bruises and burns."
	icon_state = "hypovial-k"
	list_reagents = list(/datum/reagent/medicine/c2/synthflesh = 60)
	custom_price = 600

/obj/item/reagent_containers/glass/bottle/vial/small/formaldehyde
	name = "purple hypovial (formaldehyde)"
	desc = "Contains formaldehyde, a chemical that prevents organs from decaying."
	icon_state = "hypovial-p"
	list_reagents = list(/datum/reagent/toxin/formaldehyde = 30)
