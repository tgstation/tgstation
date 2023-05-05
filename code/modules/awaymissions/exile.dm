
/obj/structure/locker/secure/exile
	name = "exile implants locker"
	req_access = list(ACCESS_HOS)

/obj/structure/locker/secure/exile/PopulateContents()
	new /obj/item/implanter/exile(src)
	for(var/i in 1 to 5)
		new /obj/item/implantcase/exile(src)
