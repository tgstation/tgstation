/obj/mecha/makeshift
	desc = "A locker with stolen wires, struts, electronics and airlock servos crudely assembled into something that resembles the functions of a mech."
	name = "Locker Mech"
	icon = 'monkestation/icons/mecha/lockermech.dmi'
	icon_state = "lockermech"
	base_icon_state = "lockermech"
	max_integrity = 100 //its made of scraps
	lights_power = 5
	step_in = 4 //Same speed as a ripley, for now.
	armor = list(melee = 20, bullet = 10, laser = 10, energy = 0, bomb = 10, bio = 0, rad = 0, fire = 70, acid = 60) //Same armour as a locker
	internal_damage_threshold = 30 //Its got shitty durability
	max_equip = 2 //You only have two arms and the control system is shitty
	wreckage = null
	var/list/cargo = list()
	var/cargo_capacity = 5 // you can fit a few things in this locker but not much.

/obj/mecha/makeshift/Topic(href, href_list)
	..()
	if(href_list["drop_from_cargo"])
		var/obj/O = locate(sanitize(href_list["drop_from_cargo"]))
		if(O && (O in cargo))
			occupant_message("You unload [O].")
			O.forceMove(loc)
			cargo -= O
			log_message("Unloaded [O]. Cargo compartment capacity: [cargo_capacity - src.cargo.len]", LOG_MECHA)
	return


/obj/mecha/makeshift/Exit(atom/movable/O)
	if(O in cargo)
		return 0
	return ..()

/obj/mecha/makeshift/contents_explosion(severity, target)
	for(var/X in cargo)
		var/obj/O = X
		if(prob(30/severity))
			cargo -= O
			O.forceMove(loc)
	. = ..()

/obj/mecha/makeshift/get_stats_part()
	var/output = ..()
	output += "<b>Cargo Compartment Contents:</b><div style=\"margin-left: 15px;\">"
	if(cargo.len)
		for(var/obj/O in cargo)
			output += "<a href='?src=\ref[src];drop_from_cargo=\ref[O]'>Unload</a> : [O]<br>"
	else
		output += "Nothing"
	output += "</div>"
	return output

/obj/mecha/makeshift/relay_container_resist(mob/living/user, obj/O)
	to_chat(user, "You lean on the back of [O] and start pushing so it falls out of [src].")
	if(do_after(user, 1 SECONDS, target = O))//Its a fukken locker
		if(!user || user.stat != CONSCIOUS || user.loc != src || O.loc != src )
			return
		to_chat(user, "You successfully pushed [O] out of [src]!")
		O.loc = loc
		cargo -= O
	else
		if(user.loc == src) //so we don't get the message if we resisted multiple times and succeeded.
			to_chat(user, "You fail to push [O] out of [src]!")

/obj/mecha/makeshift/Destroy()
	new /obj/structure/closet(loc)
	var/obj/O
	for(O in cargo)
		O.forceMove(loc)
		cargo -= O
	..()
