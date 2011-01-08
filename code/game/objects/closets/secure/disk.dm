/obj/secure_closet/disk_security/New()
	..()
	sleep(2)
	new /obj/item/weapon/disk/circuit_disk/security( src )
	new /obj/item/weapon/disk/circuit_disk/secure_data( src )
	new /obj/item/weapon/disk/circuit_disk/prisoner( src )
	new /obj/item/weapon/disk/circuit_disk/protectStation( src )
	new /obj/item/weapon/disk/circuit_disk/paladin( src )
	return

/obj/secure_closet/disk_medical/New()
	..()
	sleep(2)
	new /obj/item/weapon/disk/circuit_disk/med_data( src )
	new /obj/item/weapon/disk/circuit_disk/pandemic( src )
	new /obj/item/weapon/disk/circuit_disk/scan_consolenew( src )
	new /obj/item/weapon/disk/circuit_disk/cloning( src )
	new /obj/item/weapon/disk/circuit_disk/quarantine( src )
	new /obj/item/weapon/disk/circuit_disk/oxygen( src )

	return

/obj/secure_closet/disk_command/New()
	..()
	sleep(2)
	new /obj/item/weapon/disk/circuit_disk/aiupload( src )
	new /obj/item/weapon/disk/circuit_disk/communications( src )
	new /obj/item/weapon/disk/circuit_disk/card( src )
	new /obj/item/weapon/disk/circuit_disk/safeguard( src )
	new /obj/item/weapon/disk/circuit_disk/oneHuman( src )
	new /obj/item/weapon/disk/circuit_disk/freeform( src )
	new /obj/item/weapon/disk/circuit_disk/purge( src )
	new /obj/item/weapon/disk/circuit_disk/freeformcore( src )
	return

/obj/secure_closet/disk_engineering/New()
	..()
	sleep(2)
	new /obj/item/weapon/disk/circuit_disk/atmospherealerts( src )
	new /obj/item/weapon/disk/circuit_disk/air_management( src )
	new /obj/item/weapon/disk/circuit_disk/general_alert( src )
	new /obj/item/weapon/disk/circuit_disk/powermonitor( src )
	new /obj/item/weapon/disk/circuit_disk/prototypeEngineOffline( src )
	return

/obj/secure_closet/disk_research/New()
	..()
	sleep(2)
	new /obj/item/weapon/disk/circuit_disk/aicore( src )
	new /obj/item/weapon/disk/circuit_disk/aiupload( src )
	new /obj/item/weapon/disk/circuit_disk/teleporter( src )
	new /obj/item/weapon/disk/circuit_disk/robotics( src )
	new /obj/item/weapon/disk/circuit_disk/teleporterOffline( src )
	return