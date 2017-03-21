var/obj/machinery/plumbing_tank/master_plumber //Cool name, right?

//The master reservoir connected to all plumbing on the station. Synthesizes power into reagents.
/obj/machinery/plumbing_tank
	name = "master plumbing tank"
	desc = "A massive piece of industrial machinery covered in dials and gauges, used to control plumbing across the station."
	icon = 'icons/obj/machines/mining_machines.dmi' //Temporary sprite
	icon_state = "stacker"
	obj_integrity = 500
	max_integrity = 500
	armor = list(melee = 60, bullet = -25, laser = 100, energy = 100, bomb = 80, bio = 100, rad = 100, fire = 100, acid = 100) //This thing is heavy-duty!
	density = TRUE
	anchored = TRUE
	opacity = TRUE
	idle_power_usage = 10
	active_power_usage = 100
	var/list/starting_reagents = list("water" = 1000)
	var/operating_mode = PLUMBING_TANK_IDLE
	var/obj/item/weapon/reagent_containers/buffer //Used as a guideline. The master tank will try to match the proportion of reagents in this.

/obj/machinery/plumbing_tank/Initialize()
	buffer = new/obj/item/weapon/reagent_containers/glass/bottle(src)
	create_reagents(10000)
	reagents.add_reagent_list(starting_reagents)
	buffer.reagents.add_reagent_list(reagent_proportions_to_volume(reagents.get_reagent_proportions(), buffer.volume))
	//Breaking down this line step-by-step!
	//1. First we get the reagent proportions of the master tank. If we have 1234 water and 400 hydrogen and account for the empty space, this will be list("water" = 0.1234, "hydrogen" = 0.04).
	//2. Next, we make a list (check holder.dm for both of these procs, by the way) of these proportions adjusted to the volume of our buffer.
	//  If our bottle holds 30 units, this will be list("water" = 3.702, "hydrogen" = 1.2).
	//3. Finally, add all those reagents to our buffer. Done!
	//Keep in mind that we're accounting for empty space here. If there's 1 unit of water in a 1,000 unit tank, and it doesn't account for space, the water's proportion is 1, not 0.001!
	if(!master_plumber)
		master_plumber = src
	..()

/obj/machinery/plumbing_tank/Destroy()
	if(master_plumber == src)
		master_plumber = null
	return ..()

/obj/machinery/plumbing_tank/process()
	switch(operating_mode)
		if(PLUMBING_TANK_IDLE)
			use_power = 1
		if(PLUMBING_TANK_SYNTHESIZE)
			use_power = 2
			reagents.add_reagent_list(buffer.reagents.get_reagent_proportions())
		if(PLUMBING_TANK_DRAIN)
			use_power = 2
			for(var/reagent in reagents.reagent_list)
				var/datum/reagent/R = reagent
				reagents.remove_reagent(R.id, 1)

/obj/machinery/plumbing_tank/interact(mob/user)
	var/dat
	switch(obj_integrity / max_integrity)
		if(0)
			dat += "<i>The display lies dark, and the tank in ruins. Oops.</i>"
		if(0 to 0.2)
			dat += "<i>The entire tank shudders and heaves as it struggles to stay intact. A flurry of sparks spews from a cut wire.</i>"
		if(0.2 to 0.4)
			dat += "<i>[src] is dented, and badly. It could use some repairs.</i>"
		if(0.4 to 0.6)
			dat += "<i>[src]'s bolts are a little loose, and one of the gauges is cracked.</i>"
		if(0.6 to 0.8)
			dat += "<i>The tank's surface is a little scratched, and there's a good-sized dent near the top.</i>"
		if(0.8 to 0.99)
			dat += "<i>[src] seems to have suffered some minor damages, but nothing terrible.</i>"
		if(0.99 to 1)
			dat += "<i>[src] is running as well as can be expected.</i>"
	dat += "<br><br>"
	switch(use_power)
		if(0)
			dat += "<i>The power light is unlit.</i>"
		if(1)
			dat += "<font color='#00FF00'>The power light is blinking green.</font>"
		if(2)
			dat += "<font color='#00FF00'>The power light is glowing green.</font>"
	if(powered())
		dat += "<br><br><b>CNTS ([reagents.total_volume / reagents.maximum_volume]):</b><br>"
		for(var/V in reagents.reagent_list)
			var/datum/reagent/R = V
			dat += "	reag. [R.id] vol. [R.volume]<br>"
		dat += "<br>"
		switch(operating_mode)
			if(PLUMBING_TANK_IDLE)
				dat += "<font color='#003FFF'>An LED labeled \"OPMD\" is glowing a steady blue.</font>"
			if(PLUMBING_TANK_SYNTHESIZE)
				dat += "<font color='#00FF00'>An LED labeled \"OPMD\" is flickering green[reagents.total_volume == reagents.maximum_volume ? "" : ", and you hear flowing liquid"].</font>"
			if(PLUMBING_TANK_DRAIN)
				dat += "<font color='#FF0000'>An LED labeled \"OPMD\" is blinking red, and you hear [reagents.total_volume ? "the sound of draining liquid" : "sucking sounds"].</font>"
	dat += "<br><br>"
	dat += "<a href='?src=\ref[src];switch_modes=1'>Set the OPMD dial to a new setting</a>"
	var/datum/browser/popup = new(user, "plumbing_tank", name, 600, 400)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/plumbing_tank/Topic(href, href_list)
	if(..())
		return
	if(!iscarbon(usr) || !usr.canUseTopic(src) || !src || QDELETED(src) || stat)
		return
	var/mob/living/carbon/user = usr
	if(href_list["switch_modes"])
		var/new_mode = alert(user, "There are three options for the dial.", "OPMD Dial", "IDLE", "SYNT", "DRAI")
		var/mode_fluff = ""
		if(!user.canUseTopic(src) || !src || QDELETED(src) || stat)
			return
		switch(new_mode)
			if("IDLE")
				operating_mode = PLUMBING_TANK_IDLE
			if("SYNT")
				operating_mode = PLUMBING_TANK_SYNTHESIZE
				mode_fluff = ", and you hear flowing liquid"
			if("DRAI")
				operating_mode = PLUMBING_TANK_DRAIN
				mode_fluff = ", and you hear a drain sputter"
		user.visible_message("<span class='notice'>[user] turns a dial on [src].</span>", "<span class='notice'>You switch the dial to [new_mode][!user.ear_deaf ? mode_fluff : ""].")
		playsound(src, 'sound/machines/click.ogg', 50, 1)

/obj/machinery/plumbing_tank/proc/request_liquid(obj/requester, reagent_volume, reagent_id)
	if(reagent_id)
		if(!reagents.get_reagent_amount(reagent_id) < reagent_volume)
			return
		reagents.remove_reagent(reagent_id, reagent_volume)
		if(requester.reagents)
			requester.reagents.add_reagent(reagent_id, reagent_volume)
		return TRUE
	else
		if(reagents.total_volume < reagent_volume)
			return
		for(var/V in reagents.reagent_list)
			var/datum/reagent/R = V
			reagents.remove_reagent(R.id, reagent_volume / reagents.reagent_list.len)
			if(requester.reagents)
				requester.reagents.add_reagent(R.id, reagent_volume / reagents.reagent_list.len)
		return TRUE
