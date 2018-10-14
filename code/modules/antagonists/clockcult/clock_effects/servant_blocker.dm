//Marks the point at which "no man's land" begins on Reebe. Servants can't pass beyond this point in any way.
/obj/effect/clockwork/servant_blocker
	name = "glowing arrow"
	desc = "A faintly glowing image of an arrow on the ground. Convenient!"
	icon_state = "servant_blocker"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	density = TRUE
	CanAtmosPass = ATMOS_PASS_NO

/obj/effect/clockwork/servant_blocker/Initialize()
	. = ..()
	air_update_turf(TRUE)

/obj/effect/clockwork/servant_blocker/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE
	return ..()

/obj/effect/clockwork/servant_blocker/CanPass(atom/movable/M, turf/target)
	var/list/target_contents = M.GetAllContents() + M
	for(var/mob/living/L in target_contents)
		if(is_servant_of_ratvar(L) && get_dir(M, src) != dir && L.stat != DEAD) //Unless we're on the side the arrow is pointing directly away from, no-go
			to_chat(L, "<span class='danger'>The space beyond here can't be accessed by you or other servants.</span>")
			return
	if(isitem(M))
		var/obj/item/I = M
		if(is_servant_of_ratvar(I.thrownby)) //nice try!
			return
	return TRUE

/obj/effect/clockwork/servant_blocker/BlockSuperconductivity()
	return TRUE

/obj/effect/clockwork/servant_blocker/singularity_act()
	return

/obj/effect/clockwork/servant_blocker/singularity_pull()
	return

/obj/effect/clockwork/servant_blocker/ex_act(severity, target)
	return

/obj/effect/clockwork/servant_blocker/safe_throw_at()
	return
