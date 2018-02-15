/obj/structure/destructible/steam_vent
	name = "steam vent"
	desc = "A slatted vent embedded in the floor - it's eminating a faint hissing sound"
	icon = 'icons/obj/atmos.dmi'
	icon_state = "steam_vent_0"
	break_message = "<span class='warning'>The vent snaps and collapses!</span>"
	max_integrity = 60
	anchored = TRUE
	density = FALSE
	layer = BELOW_OBJ_LAYER
	var/obj/effect/overlay/small_smoke/steam

/obj/structure/destructible/steam_vent/proc/toggle()
	if(!anchored)
		return
	opacity = !opacity
	icon_state = "steam_vent_[opacity]"
	if(opacity)
		playsound(src, 'sound/machines/clockcult/steam_whoosh.ogg', 50, TRUE, 7)
		steam = new(loc)
	else
		playsound(src, 'sound/machines/clockcult/integration_cog_install.ogg', 50, TRUE, 7)
		if(steam)
			qdel(steam)


/obj/structure/destructible/steam_vent/welder_act(mob/living/user, obj/item/I)
	if(opacity)
		to_chat(user, "<span class='warning'>You cannot weld [src], close the vents first!</span>")
		return TRUE
	if(!I.tool_start_check(user, amount=0))
		return TRUE
	to_chat(user, "<span class='notice'>You begin welding the vent...</span>")
	if(I.use_tool(src, user, 20, volume=50))
		if(!anchored)
			user.visible_message("[user] welds the steam vent to the floor.", "<span class='notice'>You weld the steam vent to the floor.</span>", "<span class='italics'>You hear welding.</span>")
			anchored = TRUE
		else
			user.visible_message("[user] unwelds the steam vent from the floor.", "<span class='notice'>You unweld the steam vent from the floor.</span>", "<span class='italics'>You hear welding.</span>")
			anchored = FALSE
	return TRUE

/obj/structure/destructible/steam_vent/wrench_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>You begin wrenching the [src]'s release valve...</span>")
	if(I.use_tool(src, user, 15, volume=25))
		toggle()
		return TRUE

/obj/structure/destructible/steam_vent/Crossed(atom/movable/AM)
	if(isliving(AM) && opacity)
		var/mob/living/L = AM
		L.adjust_fire_stacks(-1) //It's wet!

/obj/machinery/steam_switch
	name = "steam vent switch"
	desc = "Opens and closes steam vents."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "switch-off"
	anchored = TRUE
	use_power = NO_POWER_USE
	var/activated = FALSE
	var/list/vents = list() // the list of converyors that are controlled by this switch

/obj/machinery/steam_switch/Initialize()
	..()
	for(var/obj/structure/destructible/steam_vent/SV in range(src, 7))
		vents += SV

/obj/machinery/steam_switch/attack_hand(mob/user)
	add_fingerprint(user)
	for(var/obj/structure/destructible/steam_vent/SV in vents)
		SV.toggle()
	activated = !activated
	update_icon()

/obj/machinery/steam_switch/update_icon()
	if(activated)
		icon_state = "switch-rev"
	else
		icon_state = "switch-off"
	. = ..()
