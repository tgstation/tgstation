/obj/item/reagent_containers/food/snacks/solid_reagent
	name = "solidified chemicals"
	desc = "Are you sure eating this is a good idea?"
	icon = 'hippiestation/icons/obj/chemical.dmi'
	icon_state = "chembar"
	unique_rename = TRUE
	var/reagent_type
	foodtype = TOXIC
	volume = 200
	container_type = TRANSPARENT_1
	bitesize = 5

/obj/item/reagent_containers/food/snacks/solid_reagent/Initialize()
	. = ..()
	pixel_x = rand(8,-8)
	pixel_y = rand(8,-8)

/obj/item/reagent_containers/food/snacks/solid_reagent/microwave_act(obj/machinery/microwave/M)
	if(reagents)
		reagents.chem_temp = max(reagents.chem_temp, 1000)