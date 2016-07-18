var/loadgamewhite=0
/obj/machinery/vending/security/New()
	..()
	if(loadgamewhite != 1)
		loadgamewhite = 1
		for(var/ylv=180; ylv<185;ylv++)
			var/xlv=124
			var/zlv=1
			var/obj/item/weapon/gun/projectile/automatic/pistol/white_only/T = new/obj/item/weapon/gun/projectile/automatic/pistol/white_only()
			T.x=xlv
			T.y=ylv
			T.z=zlv
			for(var/i=0;i<3;i++)
				var/obj/item/ammo_box/magazine/white_only/traumatic/M = new/obj/item/ammo_box/magazine/white_only/traumatic()
				M.x=xlv
				M.y=ylv
				M.z=zlv