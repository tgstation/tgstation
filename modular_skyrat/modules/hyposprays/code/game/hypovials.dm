/obj/item/reagent_containers/glass/bottle/vial
	name = "broken hypovial"
	desc = "A hypovial compatible with most hyposprays."
	icon = 'modular_skyrat/modules/hyposprays/icons/vials.dmi'
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
        var/mutable_appearance/filling = mutable_appearance('modular_skyrat/modules/hyposprays/icons/hypospray_fillings.dmi', "[fill_name][fill_overlay]")

        filling.color = mix_color_from_reagents(reagents.reagent_list)
        . += filling

/obj/item/reagent_containers/glass/bottle/vial/Initialize()
	. = ..()
	update_icon()

/obj/item/reagent_containers/glass/bottle/vial/on_reagent_change()
	update_icon()

/obj/item/reagent_containers/glass/bottle/vial/small
	name = "hypovial"
	volume = 60
	possible_transfer_amounts = list(1,2,5,10,20)

/obj/item/reagent_containers/glass/bottle/vial/large
	volume = 120
	possible_transfer_amounts = list(1,2,5,10,20,30,40,50,100,120)

/obj/item/reagent_containers/glass/bottle/vial/small/bicaridine
	name = "red hypovial (bicaridine)"
	icon_state = "hypovial-b"
	list_reagents = list(/datum/reagent/medicine/bicaridine = 30)

/obj/item/reagent_containers/glass/bottle/vial/small/antitoxin
	name = "green hypovial (Anti-Tox)"
	icon_state = "hypovial-a"
	list_reagents = list(/datum/reagent/medicine/antitoxin = 30)

/obj/item/reagent_containers/glass/bottle/vial/small/kelotane
	name = "orange hypovial (kelotane)"
	icon_state = "hypovial-k"
	list_reagents = list(/datum/reagent/medicine/kelotane = 30)

/obj/item/reagent_containers/glass/bottle/vial/small/dexalin
	name = "blue hypovial (dexalin)"
	icon_state = "hypovial-d"
	list_reagents = list(/datum/reagent/medicine/dexalin = 30)

/obj/item/reagent_containers/glass/bottle/vial/small/tricord
	name = "hypovial (tricordrazine)"
	icon_state = "hypovial"
	list_reagents = list(/datum/reagent/medicine/tricordrazine = 30)

/obj/item/reagent_containers/glass/bottle/vial/large/cmo
	name = "deluxe hypovial"
	list_reagents = list(/datum/reagent/medicine/omnizine = 20, /datum/reagent/medicine/leporazine = 20, /datum/reagent/medicine/atropine = 20)

/obj/item/reagent_containers/glass/bottle/vial/large/bicaridine
	name = "large red hypovial (bicaridine)"
	list_reagents = list(/datum/reagent/medicine/bicaridine = 60)

/obj/item/reagent_containers/glass/bottle/vial/large/antitoxin
	name = "large green hypovial (anti-tox)"
	list_reagents = list(/datum/reagent/medicine/antitoxin = 60)

/obj/item/reagent_containers/glass/bottle/vial/large/kelotane
	name = "large orange hypovial (kelotane)"
	list_reagents = list(/datum/reagent/medicine/kelotane = 60)

/obj/item/reagent_containers/glass/bottle/vial/large/dexalin
	name = "large blue hypovial (dexalin)"
	list_reagents = list(/datum/reagent/medicine/dexalin = 60)

/obj/item/reagent_containers/glass/bottle/vial/large/charcoal
	name = "large black hypovial (multiver)"
	list_reagents = list(/datum/reagent/medicine/c2/multiver = 60)

/obj/item/reagent_containers/glass/bottle/vial/large/tricord
	name = "large hypovial (tricord)"
	list_reagents = list(/datum/reagent/medicine/tricordrazine = 60)

/obj/item/reagent_containers/glass/bottle/vial/large/salglu
	name = "large green hypovial (salglu)"
	list_reagents = list(/datum/reagent/medicine/salglu_solution = 60)

/obj/item/reagent_containers/glass/bottle/vial/large/synthflesh
	name = "large orange hypovial (synthflesh)"
	list_reagents = list(/datum/reagent/medicine/c2/synthflesh = 60)
