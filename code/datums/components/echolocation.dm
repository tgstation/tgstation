/datum/component/echolocation
	var/echo_range = 4
	var/cooldown = 0

/datum/component/echolocation/Initialize()
	. = ..()
	RegisterSignal(parent, COMSIG_ECHOLOCATION_PING, .proc/echolocate)
	var/mob/M = parent
	M.audiolocation = TRUE
	var/datum/action/innate/echo/E = new
	E.Grant(M)

/datum/component/echolocation/proc/echolocate()
	var/mob/living/carbon/human/H = parent
	var/mutable_appearance/image_output
	var/list/seen = oview(echo_range, H)
	var/list/filtered = list()
	var/list/turfs = list()
	if(!(cooldown < world.time - 30))
		return
	cooldown = world.time
	for(var/I in seen)
		var/atom/A = I
		if(!(A.type in SSoutputs.echo_blacklist) && !A.invisibility)
			if(istype(I, /obj))
				if(istype(A.loc, /turf))
					filtered += I
			if(istype(I, /mob/living))
				filtered += I
			if(istype(I, /turf/closed/wall))
				turfs += I
	for(var/F in filtered)
		var/atom/S = F
		if(SSoutputs.echo_images[S.type])
			image_output = mutable_appearance(SSoutputs.echo_images[S.type].icon, SSoutputs.echo_images[S.type].icon_state, SSoutputs.echo_images[S.type].layer, SSoutputs.echo_images[S.type].plane)
			image_output.filters = SSoutputs.echo_images[S.type].filters
			realign_icon(image_output, S)
		else
			image_output = generate_image(S)
			realign_icon(image_output, S)
			if(!(SSoutputs.uniques[S.type]))
				SSoutputs.echo_images[S.type] = image_output
		for(var/D in S.datum_outputs)
			var/datum/outputs/O = D
			if(O.echo_override)
				image_output = mutable_appearance(O.echo_override.icon, O.echo_override.icon_state, O.echo_override.layer, O.echo_override.plane)
				realign_icon(image_output, S)
		H.display_output(, image_output,, S.loc)
	for(var/T in turfs)
		image_output = generate_wall_image(T)
		image_output.loc = T
		H.display_output(, image_output,, T)

/datum/component/echolocation/proc/generate_image(atom/input)
	var/icon/I
	if(SSoutputs.uniques[input.type])
		I = getFlatIcon(input)
	else
		I = icon(input.icon, input.icon_state)
	I.MapColors(rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,255), rgb(0,0,0,-254))
	var/mutable_appearance/X
	X = mutable_appearance(I, input.icon_state, CURSE_LAYER, 50)
	X.filters += filter(type="outline", size=1, color="#FFFFFF")
	return X

/datum/component/echolocation/proc/generate_wall_image(turf/input)
	var/icon/I = icon('icons/obj/echo_override.dmi',"wall")
	var/list/dirs = list()
	for(var/direction in GLOB.cardinals)
		var/turf/T = get_step(input, direction)
		if(istype(T, /turf/closed))
			dirs += direction
	for(var/dir in dirs)
		switch(dir)
			if(NORTH)
				I.DrawBox(null,2,32,31,31)
			if(SOUTH)
				I.DrawBox(null,2,1,31,1)
			if(EAST)
				I.DrawBox(null,32,2,32,31)
			if(WEST)
				I.DrawBox(null,1,2,1,31)
	var/mutable_appearance/X = mutable_appearance(I, , CURSE_LAYER, 50)
	return X

/datum/component/echolocation/proc/realign_icon(mutable_appearance/I, atom/input)
	I.dir = input.dir
	I.loc = input.loc
	I.pixel_x = input.pixel_x
	I.pixel_y = input.pixel_y