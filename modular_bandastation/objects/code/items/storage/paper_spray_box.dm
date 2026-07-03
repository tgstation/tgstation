/obj/item/storage/box/pepper_spray
	name = "box of pepper sprays"
	desc = "Everyone put masks on your face."
	icon_state = "security"
	illustration = "pepper_spray"

/obj/item/storage/box/pepper_spray/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/spray/pepper(src)
