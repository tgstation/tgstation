<<<<<<< HEAD
/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's red and gooey. Perhaps it's the chef's cooking?"
	gender = PLURAL
	density = 0
	layer = ABOVE_NORMAL_TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	var/list/viruses = list()
	blood_DNA = list()
	blood_state = BLOOD_STATE_HUMAN
	bloodiness = MAX_SHOE_BLOODINESS

/obj/effect/decal/cleanable/blood/Destroy()
	for(var/datum/disease/D in viruses)
		D.cure(0)
	viruses = null
	return ..()

/obj/effect/decal/cleanable/blood/replace_decal(obj/effect/decal/cleanable/blood/C)
	if (C.blood_DNA)
		blood_DNA |= C.blood_DNA.Copy()
	..()

/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/effect/decal/cleanable/blood/tracks
	icon_state = "tracks"
	desc = "They look like tracks left by wheels."
	gender = PLURAL
	random_icon_states = null

/obj/effect/decal/cleanable/trail_holder //not a child of blood on purpose
	name = "blood"
	icon_state = "ltrails_1"
	desc = "Your instincts say you shouldn't be following these."
	gender = PLURAL
	density = 0
	layer = ABOVE_OPEN_TURF_LAYER
	random_icon_states = null
	var/list/existing_dirs = list()
	blood_DNA = list()


/obj/effect/decal/cleanable/trail_holder/can_bloodcrawl_in()
	return 1


/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	gender = PLURAL
	density = 0
	layer = ABOVE_OPEN_TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")

/obj/effect/decal/cleanable/blood/gibs/New()
	..()
	reagents.add_reagent("liquidgibs", 5)

/obj/effect/decal/cleanable/blood/gibs/replace_decal(obj/effect/decal/cleanable/C)
	return

/obj/effect/decal/cleanable/blood/gibs/ex_act(severity, target)
	return

/obj/effect/decal/cleanable/blood/gibs/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")


/obj/effect/decal/cleanable/blood/gibs/proc/streak(list/directions)
	set waitfor = 0
	var/direction = pick(directions)
	for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
		sleep(3)
		if (i > 0)
			var/obj/effect/decal/cleanable/blood/b = new /obj/effect/decal/cleanable/blood/splatter(src.loc)
			for(var/datum/disease/D in src.viruses)
				var/datum/disease/ND = D.Copy(1)
				b.viruses += ND
				ND.holder = b
		if (step_to(src, get_step(src, direction), 0))
			break

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "It's red."
	gender = PLURAL
	icon_state = "1"
	random_icon_states = list("drip1","drip2","drip3","drip4","drip5")
	bloodiness = 0
	var/drips = 1


/obj/effect/decal/cleanable/blood/drip/can_bloodcrawl_in()
	return 1


//BLOODY FOOTPRINTS
/obj/effect/decal/cleanable/blood/footprints
	name = "footprints"
	icon = 'icons/effects/footprints.dmi'
	icon_state = "nothingwhatsoever"
	desc = "where might they lead?"
	gender = PLURAL
	random_icon_states = null
	var/entered_dirs = 0
	var/exited_dirs = 0
	blood_state = BLOOD_STATE_HUMAN //the icon state to load images from
	var/list/shoe_types = list()

/obj/effect/decal/cleanable/blood/footprints/Crossed(atom/movable/O)
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		var/obj/item/clothing/shoes/S = H.shoes
		if(S && S.bloody_shoes[blood_state])
			S.bloody_shoes[blood_state] = max(S.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
			entered_dirs|= H.dir
			shoe_types |= H.shoes.type
	update_icon()

/obj/effect/decal/cleanable/blood/footprints/Uncrossed(atom/movable/O)
	if(ishuman(O))
		var/mob/living/carbon/human/H = O
		var/obj/item/clothing/shoes/S = H.shoes
		if(S && S.bloody_shoes[blood_state])
			S.bloody_shoes[blood_state] = max(S.bloody_shoes[blood_state] - BLOOD_LOSS_PER_STEP, 0)
			exited_dirs|= H.dir
			shoe_types |= H.shoes.type
	update_icon()

/obj/effect/decal/cleanable/blood/footprints/update_icon()
	cut_overlays()

	for(var/Ddir in cardinal)
		if(entered_dirs & Ddir)
			var/image/I
			if(bloody_footprints_cache["entered-[blood_state]-[Ddir]"])
				I = bloody_footprints_cache["entered-[blood_state]-[Ddir]"]
			else
				I =  image(icon,"[blood_state]1",dir = Ddir)
				bloody_footprints_cache["entered-[blood_state]-[Ddir]"] = I
			if(I)
				add_overlay(I)
		if(exited_dirs & Ddir)
			var/image/I
			if(bloody_footprints_cache["exited-[blood_state]-[Ddir]"])
				I = bloody_footprints_cache["exited-[blood_state]-[Ddir]"]
			else
				I = image(icon,"[blood_state]2",dir = Ddir)
				bloody_footprints_cache["exited-[blood_state]-[Ddir]"] = I
			if(I)
				add_overlay(I)

	alpha = BLOODY_FOOTPRINT_BASE_ALPHA+bloodiness


/obj/effect/decal/cleanable/blood/footprints/examine(mob/user)
	. = ..()
	if(shoe_types.len)
		. += "You recognise the footprints as belonging to:\n"
		for(var/shoe in shoe_types)
			var/obj/item/clothing/shoes/S = shoe
			. += "some <B>[initial(S.name)]</B> \icon[S]\n"

	user << .

/obj/effect/decal/cleanable/blood/footprints/replace_decal(obj/effect/decal/cleanable/C)
	if(blood_state != C.blood_state) //We only replace footprints of the same type as us
		return
	..()

/obj/effect/decal/cleanable/blood/footprints/can_bloodcrawl_in()
	if((blood_state != BLOOD_STATE_OIL) && (blood_state != BLOOD_STATE_NOT_BLOODY))
		return 1
	return 0

=======
#define DRYING_TIME 5 * 60*10			//for 1 unit of depth in puddle (amount var)

var/global/list/image/splatter_cache=list()
var/global/list/blood_list = list()

/obj/effect/decal/cleanable/blood
	name = "blood"
	desc = "It's thick and gooey. Perhaps it's the chef's cooking?"
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "mfloor1"
	random_icon_states = list("mfloor1", "mfloor2", "mfloor3", "mfloor4", "mfloor5", "mfloor6", "mfloor7")
	plane = PLANE_NOIR_BLOOD
	appearance_flags = TILE_BOUND
	var/base_icon = 'icons/effects/blood.dmi'

	basecolor="#A10808" // Color when wet.
	amount = 5
	counts_as_blood = 1
	transfers_dna = 1
	absorbs_types=list(/obj/effect/decal/cleanable/blood,/obj/effect/decal/cleanable/blood/drip,/obj/effect/decal/cleanable/blood/writing)

/obj/effect/decal/cleanable/blood/Destroy()
	..()
	blood_DNA = null
	virus2 = null

/obj/effect/decal/cleanable/blood/cultify()
	return

/obj/effect/decal/cleanable/blood/update_icon()
	if(basecolor == "rainbow") basecolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	color = basecolor
	if(basecolor == "#FF0000"||basecolor == "#A10808") // no dirty dumb vox scum allowed
		plane = PLANE_NOIR_BLOOD
	else
		plane = PLANE_TURF
	var/icon/blood = icon(base_icon,icon_state,dir)
	blood.Blend(basecolor,ICON_MULTIPLY)

	icon = blood

/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "Dried, crusty, and slightly upsetting."
	gender = PLURAL
	icon = 'icons/effects/drip.dmi'
	icon_state = "1"
	random_icon_states = list("1","2","3","4","5")
	amount = 0

	base_icon = 'icons/effects/drip.dmi'

/obj/effect/decal/cleanable/blood/writing
	icon_state = "tracks"
	desc = "It looks like a writing in blood."
	gender = NEUTER
	random_icon_states = list("writing1","writing2","writing3","writing4","writing5")
	amount = 0
	var/message

/obj/effect/decal/cleanable/blood/writing/New()
	..()
	if(random_icon_states.len)
		for(var/obj/effect/decal/cleanable/blood/writing/W in loc)
			random_icon_states.Remove(W.icon_state)
		icon_state = pick(random_icon_states)
	else
		icon_state = "writing1"

/obj/effect/decal/cleanable/blood/writing/examine(mob/user)
	..()
	to_chat(user, "It reads: <font color='[basecolor]'>\"[message]\"<font>")

/obj/effect/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "They look bloody and gruesome."
	gender = PLURAL
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")
	var/fleshcolor = "#FFFFFF"

/obj/effect/decal/cleanable/blood/gibs/update_icon()
	if(basecolor == "#FF0000"||basecolor == "#A10808") // no dirty dumb vox scum allowed
		plane = PLANE_NOIR_BLOOD
	else
		plane = PLANE_TURF
	var/image/giblets = new(base_icon, "[icon_state]_flesh", dir)
	if(!fleshcolor || fleshcolor == "rainbow")
		fleshcolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	giblets.color = fleshcolor

	var/icon/blood = new(base_icon,"[icon_state]",dir)
	if(basecolor == "rainbow") basecolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	blood.Blend(basecolor,ICON_MULTIPLY)

	icon = blood
	overlays.len = 0
	overlays += giblets

/obj/effect/decal/cleanable/blood/gibs/up
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibup1","gibup1")

/obj/effect/decal/cleanable/blood/gibs/down
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibdown1","gibdown1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/effect/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/effect/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")

/obj/effect/decal/cleanable/blood/gibs/core/New()
	..()
	playsound(src, get_sfx("gib"),50,1)




/obj/effect/decal/cleanable/blood/viralsputum
	name = "viral sputum"
	desc = "It's black and nasty."
	basecolor="#030303"
	icon = 'icons/mob/robots.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")

/obj/effect/decal/cleanable/blood/viralsputum/Destroy()
	for(var/datum/disease/D in viruses)
		D.cure(0)
	..()





/obj/effect/decal/cleanable/blood/gibs/proc/streak(var/list/directions, spread_radius = 0)
	spawn (0)
		var/direction = pick(directions)
		for (var/i = 0 to spread_radius)
			sleep(3)
			if (i > 0)
				var/obj/effect/decal/cleanable/blood/b = getFromPool(/obj/effect/decal/cleanable/blood/splatter, src.loc)
				b.New(src.loc)
				b.basecolor = src.basecolor
				b.update_icon()
				for(var/datum/disease/D in src.viruses)
					var/datum/disease/ND = D.Copy(1)
					b.viruses += ND
					ND.holder = b

			step_to(src, get_step(src, direction), 0)


/obj/effect/decal/cleanable/mucus
	name = "mucus"
	desc = "Disgusting mucus."
	setGender(PLURAL)
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/effects/blood.dmi'
	icon_state = "mucus"
	random_icon_states = list("mucus")

	var/dry=0
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
