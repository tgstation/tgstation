/obj/item/clothing/gloves/captain
	desc = "Regal blue gloves, with a nice gold trim. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	item_state = "egloves"
	item_color = "captain"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	strip_delay = 60

/obj/item/clothing/gloves/combat
	name = "combat gloves"
	desc = "These tactical gloves are fireproof and shock resistant."
	icon_state = "black"
	item_state = "bgloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	strip_delay = 80
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT

/obj/item/clothing/gloves/latex
	name = "latex gloves"
	desc = "Sterile latex gloves."
	icon_state = "latex"
	item_state = "lgloves"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	item_color="white"
	transfer_prints = TRUE

	cmo
		item_color = "medical"		//Exists for washing machines. Is not different from latex gloves in any way.

/obj/item/clothing/gloves/botanic_leather
	name = "botanist's leather gloves"
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin.  They're also quite warm."
	icon_state = "leather"
	item_state = "ggloves"
	permeability_coefficient = 0.9
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT

/obj/item/clothing/gloves/fingerless
	name = "fingerless gloves"
	desc = "Plain black gloves without fingertips for the hard working."
	icon_state = "fingerless"
	item_state = "fingerless"
	item_color = null	//So they don't wash.
	transfer_prints = TRUE
	strip_delay = 40
	put_on_delay = 20

/obj/item/clothing/gloves/yellow/stun
	//these look exactly like normal yellow gloves
	action_button_name = "Press Hidden Trigger"
	action_button_is_hands_free = 1
	var/obj/item/weapon/stock_parts/cell/super/cell = new()
	var/datum/effect/effect/system/spark_spread/spark_system = new()
	var/on = 0

/obj/item/clothing/gloves/yellow/stun/attack_self(mob/user)
	playsound(loc, "sparks", 75, 1, -1)
	on = !on
	user << "<span class='notice'>You push the hidden trigger inside \the [src]. [on ? "It feels tingly." : "The tingling sensation subsides."]</span>"

/obj/item/clothing/gloves/yellow/stun/Touch(atom/A)
	if(!on)
		return
	var/mob/living/carbon/human/user = loc
	if(istype(A, /obj/item/weapon/stock_parts/cell))
		var/obj/item/weapon/stock_parts/cell/tcell = A
		if(tcell.charge && (cell.maxcharge != cell.charge))
			playsound(loc, "sparks", 75, 1, -1)
			spark_system.set_up(2, 0, A.loc)
			spark_system.start()
			user << "<span class='notice'>You feel a powerful vibration as you touch \the [tcell].</span>"
			if(do_after(user,50))
				var/useamt = min((cell.maxcharge-cell.charge), tcell.charge)
				if(tcell.use(useamt))
					cell.give(useamt)
				user << "<span class='notice'>The vibration suddenly subsides.</span>"
			else
				user << "<span class='notice'>As you move away from \the [tcell], the vibration slowly subsides.</span>"
			playsound(loc, "sparks", 75, 1, -1)
			spark_system.start()
		return 1
	if(istype(A, /mob/living/carbon))
		if(cell.use(5000)) //4 uses before recharging, with 10-20 dmg + stun
			var/mob/living/carbon/M = A
			playsound(loc, "sparks", 75, 1, -1)
			spark_system.set_up(5, 0, A.loc)
			spark_system.start()
			M.electrocute_act(cell.get_electrocute_damage(), src, safety = 1) //no gloves will protect you
			return 1
	return
