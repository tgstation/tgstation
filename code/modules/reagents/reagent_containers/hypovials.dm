/obj/item/reagent_containers/glass/bottle/vial
	name = "broken hypovial"
	desc = "You probably shouldn't be seeing this. Shout at a coder."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "hypovial"
	spillable = FALSE
	volume = 10
	possible_transfer_amounts = list(1,2,5,10)

/obj/item/reagent_containers/glass/bottle/vial/update_overlays()
    . = ..()
    if(!fill_icon_thresholds)
        return
    if(reagents.total_volume)
        var/fill_name = fill_icon_state? fill_icon_state : icon_state
        var/fill_overlay = 10
        switch(round((reagents.total_volume / volume)*100))
            if(1 to 24)
                fill_overlay = 10
            if(25 to 49)
                fill_overlay = 25
            if(50 to 74)
                fill_overlay = 50
            if(75 to 89)
                fill_overlay = 75
            if(89 to 100)
                fill_overlay = 100
        var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "[fill_name][fill_overlay]")

        filling.color = mix_color_from_reagents(reagents.reagent_list)
        . += filling

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
	desc = "A large, 120u capacity vial that fits only in the most deluxe hyposprays."
	volume = 120
	possible_transfer_amounts = list(1,2,5,10,20,30,40,50,100,120)

//Hypos that are in the CMO's kit round start
/obj/item/reagent_containers/glass/bottle/vial/large/deluxe
	name = "deluxe hypovial"
	desc = "A large, 120u capacity vial that fits only in the most deluxe hyposprays. This one is specialized for patients in critical condition."
	list_reagents = list(/datum/reagent/medicine/omnizine = 20, /datum/reagent/medicine/leporazine = 20, /datum/reagent/medicine/atropine = 20)

/obj/item/reagent_containers/glass/bottle/vial/large/salglu
	name = "large green hypovial (salglu)"
	list_reagents = list(/datum/reagent/medicine/salglu_solution = 60)

/obj/item/reagent_containers/glass/bottle/vial/large/synthflesh
	name = "large orange hypovial (synthflesh)"
	list_reagents = list(/datum/reagent/medicine/c2/synthflesh = 60)

/obj/item/reagent_containers/glass/bottle/vial/large/multiver
	name = "large black hypovial (multiver)"
	list_reagents = list(/datum/reagent/medicine/c2/multiver = 60)

/obj/item/reagent_containers/glass/bottle/vial/large/combat
	name = "large hypovial (combat)"
	amount_per_transfer_from_this = 10
	list_reagents = list(/datum/reagent/medicine/epinephrine = 30, /datum/reagent/medicine/omnizine = 30, /datum/reagent/medicine/leporazine = 15, /datum/reagent/medicine/atropine = 15)

/obj/item/reagent_containers/glass/bottle/vial/large/combat/nanite
	name = "large hypovial (combat nanites)"
	list_reagents = list(/datum/reagent/medicine/adminordrazine/quantum_heal = 80, /datum/reagent/medicine/synaptizine = 20)
