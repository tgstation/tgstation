/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null

	var/thermite = 0
	var/can_thermite = 1
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to
	var/drying = 0 // tracking if something is currently drying
/turf/simulated/New()
	..()

	if(istype(loc, /area/chapel))
		holy = 1
	levelupdate()

/turf/simulated/proc/AddTracks(var/typepath,var/bloodDNA,var/comingdir,var/goingdir,var/bloodcolor="#A10808")
	var/obj/effect/decal/cleanable/blood/tracks/tracks = locate(typepath) in src
	if(!tracks)
		tracks = getFromPool(typepath, src)
	tracks.AddTracks(bloodDNA,comingdir,goingdir,bloodcolor)

/turf/simulated/Entered(atom/A, atom/OL)
	if(movement_disabled && usr.ckey != movement_disabled_exception)
		to_chat(usr, "<span class='warning'>Movement is admin-disabled.</span>")//This is to identify lag problems

		return

	if (istype(A,/mob/living/carbon))
		var/mob/living/carbon/M = A
		if(M.lying)	return
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = M

			// Tracking blood
			var/list/bloodDNA = null
			var/bloodcolor=""

			// We have shoes?
			if(H.shoes)
				var/obj/item/clothing/shoes/S = H.shoes
				if(S.track_blood && S.blood_DNA)
					bloodDNA   = S.blood_DNA
					bloodcolor = S.blood_color
					S.track_blood = max(round(S.track_blood - 1, 1),0)
			else
				if(H.track_blood && H.feet_blood_DNA)
					bloodDNA   = H.feet_blood_DNA
					bloodcolor = H.feet_blood_color
					H.track_blood = max(round(H.track_blood - 1, 1),0)

			if (bloodDNA)
				if(istype(M,/mob/living/carbon/human/vox))
					src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints/vox,bloodDNA,H.dir,0,bloodcolor) // Coming
				else
					src.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,H.dir,0,bloodcolor) // Coming
				var/turf/simulated/from = get_step(H,reverse_direction(H.dir))
				if(istype(from) && from)
					if(istype(M,/mob/living/carbon/human/vox))
						from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints/vox,bloodDNA,0,H.dir,bloodcolor) // Going
					else
						from.AddTracks(/obj/effect/decal/cleanable/blood/tracks/footprints,bloodDNA,0,H.dir,bloodcolor) // Going

			bloodDNA = null

			// Floorlength braids?  Enjoy your tripping.
			if(H.h_style && !H.check_hidden_head_flags(HIDEHEADHAIR))
				var/datum/sprite_accessory/hair_style = hair_styles_list[H.h_style]
				if(hair_style && (hair_style.flags & HAIRSTYLE_CANTRIP))
					if(H.m_intent == "run" && prob(5))
						H.stop_pulling()
						step(H, H.dir)
						to_chat(H, "<span class='notice'>You tripped over your hair!</span>")
						playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
						H.Stun(4)
						H.Weaken(5)

		//Anything beyond that point will not fire if the mob isn't physically walking here
		if(!M.walking()) //Checks lying, flying and locked.to
			return ..()

		//And anything beyond that point will not fire for slimes
		if(isslime(M)) //Slimes just don't slip, end of story
			return ..()

		switch(src.wet)
			if(1) //Water
				if(M.CheckSlip() < 1) //No slipping
					return ..()
				if(M.m_intent == "run")
					sleep(1)
					M.stop_pulling()
					step(M, M.dir)
					M.visible_message("<span class='warning'>[M] slips on the wet floor!</span>", \
					"<span class='warning'>You slip on the wet floor!</span>")
					playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
					M.Stun(5)
					M.Weaken(3)

			if(2) //Lube
				M.stop_pulling()
				sleep(1)
				step(M, M.dir)
				spawn(1)
					step(M, M.dir)
				spawn(2)
					step(M, M.dir)
				spawn(3)
					step(M, M.dir)
				spawn(4)
					step(M, M.dir)
				M.take_organ_damage(2) // Was 5 -- TLE
				M.visible_message("<span class='warning'>[M] slips on the floor!</span>", \
				"<span class='warning'>You slip on the floor!</span>")
				playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
				M.Weaken(10)

			if(3) //Ice
				if(!M.CheckSlip() < 1) //No slipping
					return ..()
				if((M.m_intent == "run") && prob(30))
					sleep(1)
					M.stop_pulling()
					step(M, M.dir)
					M.visible_message("<span class='warning'>[M] slips on the icy floor!</span>", \
					"<span class='warning'>You slip on the icy floor!</span>")
					playsound(get_turf(src), 'sound/misc/slip.ogg', 50, 1, -3)
					M.Stun(4)
					M.Weaken(3)

	..()

//returns 1 if made bloody, returns 0 otherwise
/turf/simulated/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0

	for(var/obj/effect/decal/cleanable/blood/B in contents)
		if(!B.blood_DNA[M.dna.unique_enzymes])
			B.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
			B.virus2 = virus_copylist(M.virus2)
		return 1 //we bloodied the floor

	blood_splatter(src,M,1)
	return 1 //we bloodied the floor


// Only adds blood on the floor -- Skie
/turf/simulated/proc/add_blood_floor(mob/living/carbon/M as mob)
	if(istype(M, /mob/living/carbon/monkey))
		blood_splatter(src,M,1)
	else if( istype(M, /mob/living/carbon/alien ))
		var/obj/effect/decal/cleanable/blood/xeno/this = getFromPool(/obj/effect/decal/cleanable/blood/xeno, src)
		this.New(src)
		this.blood_DNA["UNKNOWN BLOOD"] = "X*"
	else if( istype(M, /mob/living/silicon/robot ))
		var/obj/effect/decal/cleanable/blood/oil/B = getFromPool(/obj/effect/decal/cleanable/blood/oil,src)
		B.New(src)
