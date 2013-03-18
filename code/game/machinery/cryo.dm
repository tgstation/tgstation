/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "cell-off"
	density = 1
	anchored = 1.0
	layer = 5
	var/on = 0
	var/temperature_archived
	var/mob/living/carbon/occupant = null
	var/obj/item/weapon/reagent_containers/beaker = null
	var/next_trans = 0
	var/current_heat_capacity = 50


/obj/machinery/atmospherics/unary/cryo_cell/New()
	..()
	initialize_directions = dir


/obj/machinery/atmospherics/unary/cryo_cell/initialize()
	if(node) return
	var/node_connect = dir
	for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break


/obj/machinery/atmospherics/unary/cryo_cell/process()
	..()
	if(!node)
		return
	if(!on)
		updateDialog()
		return

	if(air_contents)
		temperature_archived = air_contents.temperature
		heat_gas_contents()
		expel_gas()

		if(occupant)
			if(occupant.stat != 2)
				process_occupant()

	if(abs(temperature_archived-air_contents.temperature) > 1)
		network.update = 1

	updateDialog()
	return 1


/obj/machinery/atmospherics/unary/cryo_cell/allow_drop()
	return 0


/obj/machinery/atmospherics/unary/cryo_cell/relaymove(mob/user)
	if(user.stat)
		return
	go_out()
	return


/obj/machinery/atmospherics/unary/cryo_cell/attack_hand(mob/user)
	interact(user)


/obj/machinery/atmospherics/unary/cryo_cell/interact(mob/user)
	var/dat = "<h3>Cryo Cell Status</h3>"

	dat += "<div class='statusDisplay'>"

	if(!occupant)
		dat += "Cell Unoccupied"
	else
		dat += "[occupant.name] => "
		switch(occupant.stat) // obvious, see what their status is
			if(0)
				dat += "<span class='good'>Conscious</span>"
			if(1)
				dat += "<span class='average'>Unconscious</span>"
			else
				dat += "<span class='bad'>DEAD</span>"

		dat += "<br />"

		dat +=  "<div class='line'><div class='statusLabel'>Health:</div><div class='progressBar'><div style='width: [round(occupant.health)]%;' class='progressFill good'></div></div><div class='statusValue'>[round(occupant.health)]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Brute Damage:</div><div class='progressBar'><div style='width: [round(occupant.getBruteLoss())]%;' class='progressFill bad'></div></div><div class='statusValue'>[round(occupant.getBruteLoss())]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Resp. Damage:</div><div class='progressBar'><div style='width: [round(occupant.getOxyLoss())]%;' class='progressFill bad'></div></div><div class='statusValue'>[round(occupant.getOxyLoss())]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Toxin Content:</div><div class='progressBar'><div style='width: [round(occupant.getToxLoss())]%;' class='progressFill bad'></div></div><div class='statusValue'>[round(occupant.getToxLoss())]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>\> Burn Severity:</div><div class='progressBar'><div style='width: [round(occupant.getFireLoss())]%;' class='progressFill bad'></div></div><div class='statusValue'>[round(occupant.getFireLoss())]%</div></div>"
		dat +=  "<div class='line'><div class='statusLabel'>Body Temperature:</div><div class='statusValue'>[round(occupant.bodytemperature)]</div></div>"

	var/temp_text = ""
	if(air_contents.temperature > T0C)
		temp_text = "<span class='bad'>[air_contents.temperature]</span>"
	else if(air_contents.temperature > 225)
		temp_text = "<span class='average'>[air_contents.temperature]</span>"
	else
		temp_text = "<span class='good'>[air_contents.temperature]</span>"

	dat += "<hr>"
	dat +=  "<div class='line'><div class='statusLabel'>Cell Temperature:</div><div class='statusValue'>[temp_text]</div></div>"

	dat += "</div>" // close statusDisplay div

	dat += "<BR><B>Cryo Status:</B> [ on ? "<A href='?src=\ref[src];start=1'>Off</A> <span class='linkOn'>On</span>" : "<span class='linkOn'>Off</span> <A href='?src=\ref[src];start=1'>On</A>"]<BR><BR>"

	dat += "<B>Beaker:</B> "
	if(beaker)
		if(beaker:reagents && beaker:reagents.reagent_list.len)
			for(var/datum/reagent/R in beaker:reagents.reagent_list)
				dat += "<br><span class='highlight'>[R.volume] units of [R.name]</span>"
		else
			dat += "<br><span class='highlight'>Beaker empty</span>"
		dat += "<br><A href='?src=\ref[src];eject=1'>Eject</A>"
	else
		dat += "<br><span class='highlight'><i>No beaker loaded</i></span>"
		dat += "<br><span class='linkOff'>Eject</span>"

	user.set_machine(src)
	var/datum/browser/popup = new(user, "cryo", "Cryo Cell Control System", 520, 410) // Set up the popup browser window
	popup.add_stylesheet("sleeper", 'html/browser/cryo.css')
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.set_content(dat)
	popup.open()


/obj/machinery/atmospherics/unary/cryo_cell/Topic(href, href_list)
	if((get_dist(src, usr) <= 1) || istype(usr, /mob/living/silicon/ai))
		if(href_list["start"])
			on = !on
			update_icon()
		if(href_list["eject"])
			if(beaker)
				var/obj/item/weapon/reagent_containers/glass/B = beaker
				B.loc = get_step(loc, SOUTH)
				beaker = null

		updateUsrDialog()
		add_fingerprint(usr)


/obj/machinery/atmospherics/unary/cryo_cell/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(beaker)
			user << "<span class='notice'>A beaker is already loaded into [src].</span>"
			return

		beaker = I
		user.drop_item()
		I.loc = src
		user.visible_message("<span class='notice'>[user] places [I] in [src].</span>", \
							"<span class='notice'>You place [I] in [src].</span>")
	else if(istype(I, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/G = I
		if(!ismob(G.affecting))
			return
		for(var/mob/living/carbon/slime/M in range(1, G.affecting))
			if(M.Victim == G.affecting)
				user << "[G.affecting] will not fit into [src] because they have [M] latched onto their head."
				return
		var/mob/M = G.affecting
		if(put_mob(M))
			del(G)
	updateUsrDialog()


/obj/machinery/atmospherics/unary/cryo_cell/update_icon()
	if(on)
		if(occupant)
			icon_state = "cell-occupied"
			return
		icon_state = "cell-on"
		return
	icon_state = "cell-off"


/obj/machinery/atmospherics/unary/cryo_cell/proc/process_occupant()
	if(air_contents.total_moles() < 10)
		return
	if(occupant)
		if(occupant.stat == 2)
			return
		occupant.bodytemperature += 2*(air_contents.temperature - occupant.bodytemperature) * current_heat_capacity / (current_heat_capacity + air_contents.heat_capacity())
		occupant.bodytemperature = max(occupant.bodytemperature, air_contents.temperature) // this is so ugly i'm sorry for doing it i'll fix it later i promise
		occupant.stat = 1
		if(occupant.bodytemperature < T0C)
			occupant.sleeping = max(5, (1 / occupant.bodytemperature)*2000)
			occupant.Paralyse(max(5, (1 / occupant.bodytemperature)*3000))
			if(air_contents.oxygen > 2)
				if(occupant.getOxyLoss()) occupant.adjustOxyLoss(-1)
			else
				occupant.adjustOxyLoss(-1)
			//severe damage should heal waaay slower without proper chemicals
			if(occupant.bodytemperature < 225)
				if(occupant.getToxLoss())
					occupant.adjustToxLoss(max(-1, -20 / occupant.getToxLoss()))
				var/heal_brute = occupant.getBruteLoss() ? min(1, 20 / occupant.getBruteLoss()) : 0
				var/heal_fire = occupant.getFireLoss() ? min(1, 20 / occupant.getFireLoss()) : 0
				occupant.heal_organ_damage(heal_brute,heal_fire)
		if(beaker && next_trans == 0)
			beaker.reagents.trans_to(occupant, 1, 10)
			beaker.reagents.reaction(occupant)
	next_trans++
	if(next_trans == 10)
		next_trans = 0


/obj/machinery/atmospherics/unary/cryo_cell/proc/heat_gas_contents()
	if(air_contents.total_moles() < 1)
		return
	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	if(combined_heat_capacity > 0)
		var/combined_energy = T20C * current_heat_capacity + air_heat_capacity * air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity


/obj/machinery/atmospherics/unary/cryo_cell/proc/expel_gas()
	if(air_contents.total_moles() < 1)
		return
	var/datum/gas_mixture/expel_gas = new
	var/remove_amount = air_contents.total_moles() / 100
	expel_gas = air_contents.remove(remove_amount)
	expel_gas.temperature = T20C	//Lets expel hot gas and see if that helps people not die as they are removed
	loc.assume_air(expel_gas)


/obj/machinery/atmospherics/unary/cryo_cell/proc/go_out()
	if(!occupant)
		return
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	if(occupant.loc == src)
		occupant.loc = get_step(loc, SOUTH)	//this doesn't account for walls or anything, but i don't forsee that being a problem.
	if(occupant.bodytemperature < 261 && occupant.bodytemperature > 140) //Patch by Aranclanos to stop people from taking burn damage after being ejected
		occupant.bodytemperature = 261

	occupant = null
	update_icon()


/obj/machinery/atmospherics/unary/cryo_cell/proc/put_mob(mob/living/carbon/M)
	if(!istype(M))
		usr << "<span class='notice'>[src] cannot handle this liveform.</span>"
		return
	if(occupant)
		usr << "<span class='notice'>[src] is already occupied.</span>"
		return
	if(M.abiotic())
		usr << "<span class='notice'>Subject may not have abiotic items on.</span>"
		return
	if(!node)
		usr << "<span class='notice'>The cell is not correctly connected to its pipe network!</span>"
		return

	if(M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.stop_pulling()
	M.loc = src

	if(M.health > -100 && (M.health < 0 || M.sleeping))
		M << "\blue <b>You feel a cold liquid surround you. Your skin starts to freeze up.</b>"
	occupant = M
	add_fingerprint(usr)
	update_icon()
	return 1


/obj/machinery/atmospherics/unary/cryo_cell/verb/move_eject()
	set name = "Eject occupant"
	set category = "Object"
	set src in oview(1)
	if(usr == occupant)	//If the user is inside the tube...
		if(usr.stat == DEAD)	//and he's not dead....
			return
		usr << "<span class='notice'>Release sequence activated. This will take about two minutes.</span>"
		sleep(1200)
		if(!src || !usr || !occupant || occupant != usr)	//Check if someone's released/replaced/bombed him already
			return
		go_out()	//and release him from the eternal prison.
	else
		if(usr.stat || isslime(usr) || ispAI(usr))
			return
		go_out()
	add_fingerprint(usr)


/obj/machinery/atmospherics/unary/cryo_cell/verb/move_inside()
	set name = "Enter cryo"
	set category = "Object"
	set src in oview(1)

	for(var/mob/living/carbon/slime/M in range(1,usr))
		if(M.Victim == usr)
			usr << "<span class='warning'>You're too busy getting your life sucked out of you!</span>"
			return
	if(usr.stat || stat & (NOPOWER|BROKEN))
		return
	put_mob(usr)