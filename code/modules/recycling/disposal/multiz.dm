
/obj/structure/disposalpipe/trunk/multiz
	name = "Disposal trunk that goes up"
	icon_state = "pipe-up"
	initialize_dirs = DISP_DIR_UP

/obj/structure/disposalpipe/trunk/multiz/down
	name = "Disposal trunk that goes down"
	icon_state = "pipe-down"
	initialize_dirs = DISP_DIR_DOWN

/obj/structure/disposalpipe/trunk/multiz/transfer(obj/structure/disposalholder/H)
	if(H.dir == DOWN) //Since we're a trunk, you can still place a chute / bin over us. If theyve entered from there, treat this as a normal trunk
		return ..()
	//If we for some reason do not have a multiz dir, just like, use the default logic
	if(!multiz_dir)
		return ..()

	//Are we a trunk that goes up? Or down?
	var/turf/target = null
	if(multiz_dir == MULTIZ_PIPE_UP)
		target = SSmapping.get_turf_above(get_turf(src))
	if(multiz_dir == MULTIZ_PIPE_DOWN)
		target = SSmapping.get_turf_below(get_turf(src))
	if(!target) //Nothing located.
		return

	var/obj/structure/disposalpipe/trunk/multiz/pipe = locate(/obj/structure/disposalpipe/trunk/multiz) in target
	if(!pipe)
		return
	var/obj/structure/disposalholder/destination = new(pipe) //For future reference, the disposal holder is the thing that carries mobs
	destination.init(pipe) //This instantiates it
	destination.merge(H) //This takes the contents of H (Our disposal holder that's travelling into us) and puts them into the destination holder
	destination.active = TRUE //Active allows it to process and move
	destination.setDir(DOWN) //This tells the trunk above us NOT to loop it back down to us, or else you get an infinite loop
	destination.start_moving()

#undef MULTIZ_PIPE_UP
#undef MULTIZ_PIPE_DOWN
