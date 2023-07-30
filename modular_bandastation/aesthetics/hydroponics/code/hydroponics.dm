/* Unused
/obj/machinery/plantgenes
	icon = 'modular_bandastation/aesthetics/hydroponics/icons/hydroponics.dmi'

/obj/machinery/plantgenes/update_overlays()
	. = ..()
	if(disk)
		. += "dnamod-disk"

/obj/machinery/plantgenes/add_disk(obj/item/disk/plantgene/new_disk, mob/user)
	. = ..()
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/plantgenes/update_genes()
	. = ..()
	update_icon(UPDATE_OVERLAYS)
*/

/obj/item/storage/bag/plants
	icon = 'modular_bandastation/aesthetics/hydroponics/icons/hydroponics.dmi'

/obj/structure/loom
	icon = 'modular_bandastation/aesthetics/hydroponics/icons/hydroponics.dmi'
