var/obj/machinery/plumbing_tank/master_plumber //Cool name, right?

/proc/plumbing_has_reagents(volume)
	return master_plumber && master_plumber.reagents.total_volume >= volume

//The master reservoir connected to all plumbing on the station. Synthesizes power into reagents.
/obj/machinery/plumbing_tank
	name = "master plumbing tank"
	desc = "A massive piece of industrial machinery covered in dials and gauges, used to control plumbing across the station."
	icon = 'icons/obj/machines/plumbing.dmi' //Temporary sprite
	icon_state = "master_tank"
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
	var/broken_state = PLUMBING_TANK_FUNCTIONING
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
	if(stat)
		return
	switch(operating_mode)
		if(PLUMBING_TANK_IDLE)
			use_power = 1
		if(PLUMBING_TANK_SYNTHESIZE)
			if(!buffer)
				operating_mode = PLUMBING_TANK_IDLE
				return
			use_power = 2
			reagents.add_reagent_list(buffer.reagents.get_reagent_proportions())
		if(PLUMBING_TANK_DRAIN)
			use_power = 2
			for(var/reagent in reagents.reagent_list)
				var/datum/reagent/R = reagent
				reagents.remove_reagent(R.id, 1)

/obj/machinery/plumbing_tank/examine(mob/user)
	..()
	switch(broken_state)
		if(PLUMBING_TANK_BURST)
			user << "<span class='warning'>It's in pieces and needs more structure to support it.</span>"
		if(PLUMBING_TANK_NEEDS_WELD)
			user << "<span class='warning'>Its immediate damage has been fixed, but it's still shoddy.</span>"
		if(PLUMBING_TANK_NEEDS_WRENCH)
			user << "<span class='warning'>It's almost fixed, but its bolts are loose.</span>"

/obj/machinery/plumbing_tank/obj_break()
	if(reagents.total_volume)
		visible_message("<span class='warning'>Pressurized liquid sprays from [src] as it bursts!</span>")
		playsound(src, 'sound/effects/spray.ogg', 100, 1)
		for(var/atom/A in range(1, src))
			reagents.reaction(A, TOUCH)
	reagents.clear_reagents()
	if(buffer)
		qdel(buffer)
		buffer = null
	icon_state = "master_tank_broken"
	playsound(src, 'sound/magic/clockwork/anima_fragment_death.ogg', 50, 1)
	stat |= BROKEN
	broken_state = PLUMBING_TANK_BURST

/obj/machinery/plumbing_tank/deconstruct()
	return obj_break()

/obj/machinery/plumbing_tank/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/reagent_containers))
		if(buffer)
			to_chat(user, "<span class='warning'>[src] already has a buffer loaded.</span>")
			return
		user.visible_message("<span class='notice'>[user] places [I] into [src]'s buffer compartment.</span>", "<span class='notice'>You place [I] into the open compartment of [src]. The tank \
		sucks it upward and the panel slides shut.</span>")
		playsound(src, 'sound/items/jaws_pry.ogg', 50, 1)
		user.drop_item()
		I.forceMove(src)
		buffer = I
		return
	if(!broken_state || user.a_intent != "help")
		return ..()
	switch(broken_state)
		if(PLUMBING_TANK_BURST)
			if(!istype(I, /obj/item/stack/sheet/metal))
				return ..()
			var/obj/item/stack/sheet/metal/M = I
			if(M.get_amount() < 5)
				to_chat(user, "<span class='warning'>You need more metal - at least five sheets.</span>")
				return
			user.visible_message("<span class='notice'>[user] starts patching the holes in [src]...</span>", "<span class='notice'>You start patching up the damage to [src]...</span>")
			playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
			if(!do_after(user, 30, target = src) || M.get_amount() < 5 || broken_state != PLUMBING_TANK_BURST)
				return
			user.visible_message("<span class='notice'>[user] restores [src]'s frame!</span>", "<span class='notice'>You repair the immediate damage to [src].</span>")
			playsound(src, 'sound/machines/click.ogg', 50, 1)
			icon_state = initial(icon_state)
			update_icon()
			M.use(5)
			broken_state = PLUMBING_TANK_NEEDS_WELD
		if(PLUMBING_TANK_NEEDS_WELD)
			if(!istype(I, /obj/item/weapon/weldingtool))
				return ..()
			var/obj/item/weapon/weldingtool/WT = I
			if(!WT.isOn())
				to_chat(user, "<span class='warning'>Turn [WT] on first.</span>")
				return
			if(WT.get_fuel() < 3)
				to_chat(user, "<span class='warning'>You need more fuel.</span>")
				return
			user.visible_message("<span class='notice'>[user] starts securing the new plating to [src]...</span>", "<span class='notice'>You start welding the new plating in place...</span>")
			playsound(src, WT.usesound, 50, 1)
			if(!do_after(user, 30 * WT.toolspeed, target = src) || WT.get_fuel() < 5 || !WT.isOn() || broken_state != PLUMBING_TANK_NEEDS_WELD)
				return
			user.visible_message("<span class='notice'>[user] secures [src]'s new structure!</span>", "<span class='notice'>You reinforce the new sturctural support.</span>")
			playsound(src, 'sound/items/Welder2.ogg', 50, 1)
			WT.remove_fuel(3, user)
			broken_state = PLUMBING_TANK_NEEDS_WRENCH
		if(PLUMBING_TANK_NEEDS_WRENCH)
			if(!istype(I, /obj/item/weapon/wrench))
				return ..()
			user.visible_message("<span class='notice'>[user] finishes repairing [src]!</span>", "<span class='notice'>You fasten the bolts holding [src] together, and it rumbles to life!</span>")
			playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
			operating_mode = PLUMBING_TANK_IDLE()
			broken_state = PLUMBING_TANK_FUNCTIONING
			obj_integrity = max_integrity
			stat &= ~BROKEN
			update_icon()

/obj/machinery/plumbing_tank/interact(mob/user)
	var/list/dat = list()
	switch(obj_integrity / max_integrity)
		if(0)
			dat += "<i>The display lies dark, and the tank in ruins. Oops.</i>"
		if(0 to 0.2)
			dat += "<i>The entire tank shudders and heaves as it struggles to stay intact.</i>"
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
		dat += "<br><b>bfr:</b> [!buffer ? "<font color='#FF0000'>false</font>" : "<font color='#00FF00'>true</font>"]"
	dat += "<br>"
	if(buffer)
		dat += "<br><a href='?src=\ref[src];switch_modes=1'>Set the dial labeled \"OPMD\" to a new setting</a>"
		dat += "<br><a href='?src=\ref[src];eject_buffer=1'>Press the button labeled \"EJECT\"</a>"
	var/datum/browser/popup = new(user, "plumbing_tank", name, 600, 400)
	popup.set_content(dat.Join())
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
	if(href_list["eject_buffer"])
		if(!buffer)
			return
		visible_message("<span class='notice'>A panel on [src] slides open, and [buffer] tumbles out into a recessed tray!</span>")
		playsound(src, 'sound/items/jaws_pry.ogg', 50, 1)
		buffer.forceMove(get_turf(src))
		buffer = null

/obj/machinery/plumbing_tank/proc/request_liquid(atom/requester, reagent_volume)
	if(reagents.total_volume < reagent_volume || !requester.reagents)
		return
	for(var/V in reagents.reagent_list)
		var/datum/reagent/R = V
		reagents.remove_reagent(R.id, reagent_volume / reagents.reagent_list.len)
		requester.reagents.add_reagent(R.id, reagent_volume / reagents.reagent_list.len)
	return TRUE
