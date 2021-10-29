/obj/item/storage/box/syndie_kit/cultkisr
	name = "cult construct kit"
	desc = "A sleek, sturdy box with an ominous, dark energy inside. Yikes."

/obj/item/storage/box/syndie_kit/cultkitsr/PopulateContents()
	new /obj/item/storage/belt/soulstone/full/purified(src)
	new /obj/item/sbeacondrop/constructshell(src)
	new /obj/item/sbeacondrop/constructshell(src)

/obj/item/sbeacondrop/constructshell
	desc = "A label on it reads: <i>Warning: Activating this device will send a Nar'sian construct shell to your location</i>."
	droptype = /obj/structure/constructshell

/obj/item/storage/belt/soulstone/full/purified/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/soulstone/anybody/purified(src)
