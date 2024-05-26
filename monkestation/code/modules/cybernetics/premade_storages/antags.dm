/obj/item/storage/briefcase/syndie_mantis
	desc = "Fully metallic briefcase. Has A.R.A.S.A.K.A. engraved on the side in Futura font."

/obj/item/storage/briefcase/syndie_mantis/PopulateContents()
	..()
	new /obj/item/autosurgeon/organ/syndicate/syndie_mantis(src)
	new /obj/item/autosurgeon/organ/syndicate/syndie_mantis/l(src)
	new /obj/item/autosurgeon/organ/cyberlink_syndicate(src)
