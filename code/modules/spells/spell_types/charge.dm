/obj/effect/proc_holder/spell/targeted/charge
	name = "Charge"
	desc = "This spell can be used to recharge a variety of things in your hands, from magical artifacts to electrical components. A creative wizard can even use it to grant magical power to a fellow magic user."

	school = "transmutation"
	charge_max = 600
	clothes_req = 0
	invocation = "DIRI CEL"
	invocation_type = "whisper"
	range = -1
	cooldown_min = 400 //50 deciseconds reduction per rank
	include_user = 1


/obj/effect/proc_holder/spell/targeted/charge/cast(list/targets,mob/user = usr)
	for(var/mob/living/L in targets)
		var/list/hand_items = list(L.get_active_held_item(),L.get_inactive_held_item())
		var/charged_item = null
		var/burnt_out = 0

		if(L.pulling && isliving(L.pulling))
			var/mob/living/M =	L.pulling
			if(M.mob_spell_list.len != 0 || (M.mind && M.mind.spell_list.len != 0))
				for(var/obj/effect/proc_holder/spell/S in M.mob_spell_list)
					S.charge_counter = S.charge_max
				if(M.mind)
					for(var/obj/effect/proc_holder/spell/S in M.mind.spell_list)
						S.charge_counter = S.charge_max
				to_chat(M, "<span class='notice'>You feel raw magic flowing through you. It feels good!</span>")
			else
				to_chat(M, "<span class='notice'>You feel very strange for a moment, but then it passes.</span>")
				burnt_out = 1
			charged_item = M
			break
		for(var/obj/item in hand_items)
			if(istype(item, /obj/item/weapon/spellbook))
				if(istype(item, /obj/item/weapon/spellbook/oneuse))
					var/obj/item/weapon/spellbook/oneuse/I = item
					if(prob(80))
						L.visible_message("<span class='warning'>[I] catches fire!</span>")
						qdel(I)
					else
						I.used = 0
						charged_item = I
						break
				else
					to_chat(L, "<span class='danger'>Glowing red letters appear on the front cover...</span>")
					to_chat(L, "<span class='warning'>[pick("NICE TRY BUT NO!","CLEVER BUT NOT CLEVER ENOUGH!", "SUCH FLAGRANT CHEESING IS WHY WE ACCEPTED YOUR APPLICATION!", "CUTE! VERY CUTE!", "YOU DIDN'T THINK IT'D BE THAT EASY, DID YOU?")]</span>")
					burnt_out = 1
			else if(istype(item, /obj/item/weapon/gun/magic))
				var/obj/item/weapon/gun/magic/I = item
				if(prob(80) && !I.can_charge)
					I.max_charges--
				if(I.max_charges <= 0)
					I.max_charges = 0
					burnt_out = 1
				I.charges = I.max_charges
				if(istype(item,/obj/item/weapon/gun/magic/wand) && I.max_charges != 0)
					var/obj/item/weapon/gun/magic/W = item
					W.icon_state = initial(W.icon_state)
				I.recharge_newshot()
				charged_item = I
				break
			else if(istype(item, /obj/item/weapon/stock_parts/cell/))
				var/obj/item/weapon/stock_parts/cell/C = item
				if(!C.self_recharge)
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
					if(istype(I, /obj/item/weapon/stock_parts/cell/))
						var/obj/item/weapon/stock_parts/cell/C = I
						if(!C.self_recharge)
							if(prob(80))
								C.maxcharge -= 200
							if(C.maxcharge <= 1) //Div by 0 protection
								C.maxcharge = 1
								burnt_out = 1
						C.charge = C.maxcharge
						if(istype(C.loc,/obj/item/weapon/gun))
							var/obj/item/weapon/gun/G = C.loc
							G.process_chamber()
						item.update_icon()
						charged_item = item
						break
		if(!charged_item)
			to_chat(L, "<span class='notice'>You feel magical power surging through your hands, but the feeling rapidly fades...</span>")
		else if(burnt_out)
			to_chat(L, "<span class='caution'>[charged_item] doesn't seem to be reacting to the spell...</span>")
		else
			playsound(get_turf(L), 'sound/magic/charge.ogg', 50, 1)
			to_chat(L, "<span class='notice'>[charged_item] suddenly feels very warm!</span>")
