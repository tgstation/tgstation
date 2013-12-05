/obj/effect/proc_holder/spell/targeted/charge
	name = "Charge"
	desc = "This spell can be used to charge up spent magical artifacts, among other things."

	school = "transmutation"
	charge_max = 600
	clothes_req = 0
	invocation = "DIRI CEL"
	invocation_type = "whisper"
	range = -1
	cooldown_min = 400 //50 deciseconds reduction per rank
	include_user = 1


/obj/effect/proc_holder/spell/targeted/charge/cast(list/targets)
	for(var/mob/living/user in targets)
		var/list/hand_items = list(user.get_active_hand(),user.get_inactive_hand())
		var/charged_item = null
		var/burnt_out = 0
		world << "[user.l_hand] and [user.r_hand]"
		for(var/obj/item in hand_items)
			if(istype(item, /obj/item/weapon/grab))
				var/obj/item/weapon/grab/G = item
				if(G.affecting)
					var/mob/M = G.affecting
					if(M.spell_list.len != 0)
						for(var/obj/effect/proc_holder/spell/S in M.spell_list)
							S.charge_counter = S.charge_max
						M <<"\blue you feel raw magic flowing through you, it feels good!"
					else
						M <<"\blue you feel very strange for a moment, but then it passes."
						burnt_out = 1
					charged_item = M
					break
			else if(istype(item, /obj/item/weapon/gun/magic))
				var/obj/item/weapon/gun/magic/I = item
				if(prob(80))
					I.max_charges--
				if(I.max_charges <= 0)
					I.max_charges = 0
					burnt_out = 1
				I.charges = I.max_charges
				charged_item = I
				break
			else if(istype(item, /obj/item/weapon/cell/))
				var/obj/item/weapon/cell/C = item
				if(prob(80))
					C.maxcharge -= 200
				if(C.maxcharge <= 1) //Div by 0 protection
					C.maxcharge = 1
					burnt_out = 1
				C.charge = C.maxcharge
				charged_item = C
				break
			else if(item.contents)
				var/obj/I = null
				for(I in item.contents)
					if(istype(I, /obj/item/weapon/cell/))
						var/obj/item/weapon/cell/C = I
						if(prob(80))
							C.maxcharge -= 200
						if(C.maxcharge <= 1) //Div by 0 protection
							C.maxcharge = 1
							burnt_out = 1
						C.charge = C.maxcharge
						item.update_icon()
						charged_item = item
						break
		if(!charged_item)
			user << "\blue you feel magical power surging to your hands, but the feeling rapidly fades..."
		else if(burnt_out)
			user << "\red [charged_item] doesn't seem to be reacting to the spell..."
		else
			user << "\blue [charged_item] suddenly feels very warm!"
