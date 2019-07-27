//This doesn't function like a "trap" in of itself, but obscures vision when active.
/obj/structure/destructible/clockwork/trap/steam_vent
	name = "steam vent"
	desc = "Some wired slats embedded in the floor. They feel warm to the touch."
	icon_state = "steam_vent_0"
	clockwork_desc = "When active, these vents will billow out clouds of excess steam from Reebe, obscuring vision."
	break_message = "<span class='warning'>The vent snaps and collapses!</span>"
	max_integrity = 100
	density = FALSE

/obj/structure/destructible/clockwork/trap/steam_vent/activate()
	opacity = !opacity
	icon_state = "steam_vent_[opacity]"
	if(opacity)
		playsound(src, 'sound/machines/clockcult/steam_whoosh.ogg', 50, TRUE)

	else
		playsound(src, 'sound/machines/clockcult/integration_cog_install.ogg', 50, TRUE)

/obj/structure/destructible/clockwork/trap/steam_vent/Crossed(atom/movable/AM)
	if(isliving(AM) && opacity)
		var/mob/living/L = AM
		L.adjust_fire_stacks(-1) //It's wet!
