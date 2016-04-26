// Mirror object
// Part of the optics system
//
// reflects laser beams
// 16 directional states 0/22.5/45/67.5deg to allow for 0/45deg beam angles


// ideas:
// frame/stand icon w/ mirror directional overlay
// two sets of overlay icons for 0/45 and 22.5/67.5 deg angles

// can rotate cw/acw - need screwdriver to loosen/tighten mirror
// use wrench to anchor/unanchor frame
// if touched, gets dirty - fingerprints, which reduce reflectivity
// if dirty and hit with high-power beam, mirror may shatter
// some kind of dust accumulation with HasProximity? Could check for mob w/o labcoat etc.
// can clean with acetone+wipes

/obj/optical/mirror
	icon = 'optical.dmi'
	icon_state = "mirrorA"
	dir = 1
	desc = "A large, optical-grade mirror firmly mounted on a stand."
	flags = FPRINT
	anchored = 0
	var/rotatable = 0	// true if mirror can be rotated
	var/angle = 0		// normal of mirror, 0-15. 0=N, 1=NNE, 2=NE, 3=ENE, 4=E etc


	New()
		..()
		set_angle()



	//set the angle from icon_state and dir
	proc/set_angle()
		switch(dir)
			if(1)
				angle = 0
			if(5)
				angle = 2
			if(4)
				angle = 4
			if(6)
				angle = 6
			if(2)
				angle = 8
			if(10)
				angle = 10
			if(8)
				angle = 12
			if(9)
				angle = 14

		if(icon_state == "mirrorB")	// 22.5deg turned states
			angle++
		return

	// set the dir and icon_state from the angle
	proc/set_dir()
		if(angle%2 == 1)
			icon_state = "mirrorB"
		else
			icon_state = "mirrorA"
		switch(round(angle/2)*2)
			if(0)
				dir = 1
			if(2)
				dir = 5
			if(4)
				dir = 4
			if(6)
				dir = 6
			if(8)
				dir = 2
			if(10)
				dir = 10
			if(12)
				dir = 8
			if(14)
				dir = 9
		return