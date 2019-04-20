/datum/component/echolocation
	var/echo_range = 4

/datum/component/echolocation/Initialize()
	. = ..()
	RegisterSignal(parent, COMSIG_ECHOLOCATION_PING, .proc/echolocate)
	var/mob/M = parent
	M.audiolocation = TRUE

/datum/component/echolocation/proc/echolocate()
	var/mob/living/carbon/human/H = parent
	to_chat(parent, "1")
	var/image/image_output
	var/list/seen = view(echo_range, H)
	var/list/filtered = list()
	for(var/turf/closed/T in seen)
		filtered += T
	for(var/obj/A in seen)
		if(istype(A.loc, /turf))
			filtered += A
	for(var/mob/living/L in seen)
		filtered += L
	for(var/A in filtered)
		var/atom/S = A
		if(!(S.type in SSoutputs.echo_blacklist) && !S.invisibility)
			to_chat(parent, "3")
			if(GLOB.echo_images[S.type])
				image_output = image(GLOB.echo_images[S.type])
				to_chat(parent, "4")
				realign_icon(image_output, S)
			else
				to_chat(parent, "5")
				image_output = generate_image(S)
				GLOB.echo_images[S.type] = image_output
			for(var/I in S.datum_outputs)
				var/datum/outputs/O = I
				if(O.echo_override)
					image_output = O.echo_override
			H.client.images |= image_output
			H.display_output(, image_output)

/datum/component/echolocation/proc/generate_image(atom/input)
	var/icon/I
	var/image/X
	if(input.type in SSoutputs.needs_flattening)
		I = getFlatIcon(input)
	else
		I = icon(input.icon, input.icon_state)
	I.MapColors(rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,255), rgb(0,0,0,-254))
	X = image(I, input.loc, input.icon_state, CAMERA_STATIC_LAYER, input.dir)
	X.filters += filter(type="outline", size=1, color="#FFFFFF")
	realign_icon(X, input)
	return X

/datum/component/echolocation/proc/realign_icon(image/I, atom/input)
	I.dir = input.dir
	I.loc = input.loc
	I.pixel_x = input.pixel_x
	I.pixel_y = input.pixel_y
	I.plane = 100