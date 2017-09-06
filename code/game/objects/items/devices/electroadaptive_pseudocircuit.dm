//Used by engineering cyborgs in place of generic circuits.
/obj/item/device/electroadaptive_pseudocircuit
	name = "electroadaptive pseudocircuit"
	desc = "An all-in-one circuit imprinter, designer, synthesizer, outfitter, creator, and chef. It can be used in place of any generic circuit board during construction."
	icon = 'icons/obj/module.dmi'
	icon_state = "boris"
	w_class = WEIGHT_CLASS_TINY
	materials = list(MAT_METAL = 50, MAT_GLASS = 300)
	origin_tech = "engineering=4"
	var/recharging = FALSE

/obj/item/device/electroadaptive_pseudocircuit/examine(mob/user)
	..()
	if(iscyborg(user))
		to_chat(user, "<span class='notice'>Serves as a substitute for <b>fire/air alarm</b>, <b>firelock</b>, and <b>APC</b> electronics.</span>")
		to_chat(user, "<span class='notice'>It can also be used on an APC with no power cell to <b>fabricate a low-capacity cell</b> at a high power cost.</span>")

/obj/item/device/electroadaptive_pseudocircuit/proc/adapt_circuit(mob/living/silicon/robot/R, circuit_cost = 0)
	if(QDELETED(R) || !istype(R))
		return
	if(!R.cell)
		to_chat(R, "<span class='warning'>You need a power cell installed for that.</span>")
		return
	if(!R.cell.use(circuit_cost))
		to_chat(R, "<span class='warning'>You don't have the power for that (you need [DisplayPower(circuit_cost)].)</span>")
		return
	if(recharging)
		to_chat(R, "<span class='warning'>[src] needs some time to recharge first.</span>")
		return
	playsound(R, 'sound/items/rped.ogg', 50, TRUE)
	recharging = TRUE
	icon_state = "[initial(icon_state)]_recharging"
	var/recharge_time = min(600, circuit_cost * 5)  //40W of cost for one fabrication = 20 seconds of recharge time; this is to prevent spamming
	addtimer(CALLBACK(src, .proc/recharge), recharge_time)
	return TRUE //The actual circuit magic itself is done on a per-object basis

/obj/item/device/electroadaptive_pseudocircuit/proc/recharge()
	playsound(src, 'sound/machines/chime.ogg', 25, TRUE)
	recharging = FALSE
	icon_state = initial(icon_state)
