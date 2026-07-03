/obj/item/storage/box/deathimp
	name = "death alarm implant kit"
	desc = "Коробка с имплантами оповещения о смерти."
	illustration = "implant"

/obj/item/storage/box/deathimp/PopulateContents()
	new /obj/item/implanter/death_alarm(src)
	for(var/i in 1 to 6)
		new /obj/item/implantcase/death_alarm(src)
