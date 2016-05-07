/obj/structure/reagent_dispensers/vat
	name = "Chemical Mixing Vat"
	desc = "A large vat for chemical storage and mixing."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "chem_vat"
	storage_amount = 1000
	clear = 1

/obj/structure/reagent_dispensers/vat/update_icon()
	..()
	overlays.Cut()
	if(reagents)
		var/colors = mix_color_from_reagents(reagents.reagent_list)
		var/image/the_overlay_shit = image('icons/obj/chemical.dmi',"[icon_state]_chem")
		the_overlay_shit.color = colors
		overlays += the_overlay_shit

/obj/structure/reagent_dispensers/vat/New()
	..()
	update_icon()

/obj/structure/reagent_dispensers/vat/attackby()
	..()
	update_icon()

/obj/structure/reagent_dispensers/vat/noreact
	name = "Chemical Storage Vat"
	desc = "A large vat for chemical storage. Doesn't allow reactions."
	storage_amount = 2000
	starting_amount = 500
	flags = NOREACT

/obj/structure/reagent_dispensers/vat/noreact/blood_aplus
	name = "Blood Storage Vat (A+)"
	starting_reagent = "blood"
	starting_params = list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"="A+","resistances"=null,"trace_chem"=null)

/obj/structure/reagent_dispensers/vat/noreact/blood_aminus
	name = "Blood Storage Vat (A-)"
	starting_reagent = "blood"
	starting_params = list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"="A-","resistances"=null,"trace_chem"=null)

/obj/structure/reagent_dispensers/vat/noreact/blood_bplus
	name = "Blood Storage Vat (B+)"
	starting_reagent = "blood"
	starting_params = list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"="B+","resistances"=null,"trace_chem"=null)

/obj/structure/reagent_dispensers/vat/noreact/blood_bminus
	name = "Blood Storage Vat (B-)"
	starting_reagent = "blood"
	starting_params = list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"="B-","resistances"=null,"trace_chem"=null)

/obj/structure/reagent_dispensers/vat/noreact/blood_oplus
	name = "Blood Storage Vat (O+)"
	starting_reagent = "blood"
	starting_params = list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"="O+","resistances"=null,"trace_chem"=null)

/obj/structure/reagent_dispensers/vat/noreact/blood_ominus
	name = "Blood Storage Vat (O-)"
	starting_reagent = "blood"
	starting_params = list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"="O-","resistances"=null,"trace_chem"=null)

/obj/structure/reagent_dispensers/vat/bathtub
	name = "bathtub"
	desc = "A large bathtub. It looks like it could hold a lot of reagents."
	icon_state = "bathtub"
	clear = 0

