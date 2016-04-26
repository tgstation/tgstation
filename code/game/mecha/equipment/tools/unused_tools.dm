


/****** Do not tick this file in without looking over this code first ******/


/obj/item/mecha_parts/mecha_equipment/defence_shocker
	name = "Exosuit Defence Shocker"
	desc = ""
	icon_state = "mecha_teleport"
	equip_cooldown = 10
	energy_drain = 100
	range = RANGED
	var/shock_damage = 15
	var/active

	can_attach(obj/mecha/M as obj)
		if(..())
			if(!istype(M, /obj/mecha/combat/honker))
				if(!M.proc_res["dynattackby"] && !M.proc_res["dynattackhand"] && !M.proc_res["dynattackalien"])
					return 1
		return 0

	attach(obj/mecha/M as obj)
		..()
		chassis.proc_res["dynattackby"] = src
		return

	proc/dynattackby(obj/item/weapon/W as obj, mob/user as mob)
		if(!action_checks(user) || !active)
			return
		user.electrocute_act(shock_damage, src)
		return chassis.dynattackby(W,user)


/*
/obj/item/mecha_parts/mecha_equipment/book_stocker

	action(var/mob/target)
		if(!istype(target))
			return
		if(target.search_contents_for(/obj/item/book/WGW))
			target.gib()
			target.client.gib()
			target.client.mom.monkeyize()
			target.client.mom.gib()
			for(var/mob/M in range(target, 1000))
				M.gib()
			explosion(target.loc,100000,100000,100000)
			usr.gib()
			world.Reboot()
			return 1

*/
