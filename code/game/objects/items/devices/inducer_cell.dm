/obj/item/inducer_cell
	name = "\improper Cybersun Flash Inducer Cell"
	desc = "A single-use device that recharges all power cells carried by a person - even those in a weapon or device. Do not drop when in use."
	icon = 'icons/obj/devices/syndie_gadget.dmi'
	icon_state = "inducer_cell_off"
	inhand_icon_state = "flashtool"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	//Has this already been used?
	var/burntout = FALSE
	//How many times this charges your items.
	var/cycle_amount = 4
	//Amount of time this takes between charges.
	var/cycle_time = 0.5 SECONDS
	//How many times this will charge your gear and emit sparks
	var/pulse_amount = 4
	//Upper and lower bounds for how much of a cell is charged per pulse. This is a percentage.
	var/charge_upper = 30
	var/charge_lower = 20
	//With default settings, this will charge between 80% and 110% of every chargable item on you. Unless you drop it or something.
	//Speaking of, this is how much damage this does when used as a grenade/dropped
	var/zap_damage = 33
	//AoE range of zap nade usage (in tiles from centre)
	var/zap_range = 1
	//And how much stun time it inflicts
	var/stun_time = 1.5 SECONDS

/obj/item/inducer_cell/interact(mob/user)
	if(!burntout)
		do_sparks(number = 1, source = src)
		playsound(src, SFX_SPARKS, 65, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
		icon_state = "inducer_cell"
		inductive_charge()
	return ..()

/obj/item/inducer_cell/proc/inductive_charge(mob/user)
	if(!locate(user) in loc) //muh machine's gone, delete myself because im disarmed
		punishment()
		qdel(src)
		return
	src.Shake(4, 4, cycle_time)
	pulse_amount--
	if(pulse_amount > 0)
		addtimer(CALLBACK(src, PROC_REF(inductive_charge)), cycle_time)
	var/list/chargables = list()
	for(var/obj/item/stock_parts/power_store/cells in user.get_all_contents())
		if(cells.charge < cells.maxcharge)
			chargables += cells
	if(chargables.len)
		var/obj/item/stock_parts/power_store/charging = pick(chargables)
		charging.charge += min(charging.maxcharge - charging.charge, charging.maxcharge/(rand(charge_lower, charge_upper)))

/obj/item/inducer_cell/proc/punishment()
	for(var/mob/living/living_mob in range(zap_range, src))
		to_chat(living_mob, span_warning("You are struck by an arc of electricity!"))
		src.Beam(living_mob, icon_state = "lightning[rand(1,12)]", time = 0.5 SECONDS)
		living_mob.electrocute_act(zap_damage, src, 1, SHOCK_NOGLOVES, stun_time, stun_time, stun_time)
	do_sparks(number = 4, source = src)
