/mob/living/silicon/robot
	///are we a clockwork borg or not
	var/clockwork = FALSE
	///our internal clockwork slab, created on picking a clockwork module
	var/obj/item/clockwork/clockwork_slab/internal_clock_slab

/mob/living/silicon/robot/proc/set_clockwork(clockwork_state, rebuild = TRUE)
	clockwork = clockwork_state
	if(rebuild)
		model.rebuild_modules()
	update_icons()
	if(clockwork)
		set_light_color(LIGHT_COLOR_CLOCKWORK)
		scrambledcodes = TRUE //it would be kind of lame if you could just loackdown all the clock borgs
		if(!internal_clock_slab)
			internal_clock_slab = new /obj/item/clockwork/clockwork_slab(src)
	else if(!clockwork)
		qdel(internal_clock_slab)

/obj/item/robot_suit
	///will we be a clockwork borg by default
	var/be_clockwork = FALSE

/obj/item/robot_suit/prebuilt/clockwork
	name = "Clockwork Cyborg Endoskeleton"
	desc = "Is that a steam exhaust port?"
	color = rgb(190, 135, 0)
	be_clockwork = TRUE
