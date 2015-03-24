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
	var/base_icon = 'icons/effects/blood.dmi'
	var/list/viruses = list()
	blood_DNA = list()
	var/basecolor="#A10808" // Color when wet.
	var/list/datum/disease2/disease/virus2 = list()
	var/amount = 5

/obj/effect/decal/cleanable/blood/cultify()
	return

/obj/effect/decal/cleanable/blood/Destroy()
	blood_list -= src
	for(var/datum/disease/D in viruses)
		D.cure(0)
		D.holder = null

	if(ticker.mode && ticker.mode.name == "cult")
		var/datum/game_mode/cult/mode_ticker = ticker.mode
		var/turf/T = get_turf(src)
		if(T)
			if(locate(T) in mode_ticker.bloody_floors)
				mode_ticker.bloody_floors -= T
				mode_ticker.blood_check()
	..()

/obj/effect/decal/cleanable/blood/resetVariables()
	Destroy()
	viruses = list()
	virus2 = list()
	blood_DNA = list()
	..("viruses","virus2", "blood_DNA", "random_icon_states", args)

/obj/effect/decal/cleanable/blood/New()
	..()
	blood_list += src
	update_icon()

	if(ticker && ticker.mode && ticker.mode.name == "cult")
		var/datum/game_mode/cult/mode_ticker = ticker.mode
		if((mode_ticker.objectives[mode_ticker.current_objective] == "bloodspill") && !mode_ticker.narsie_condition_cleared)
			var/turf/T = get_turf(src)
			if(T && (T.z == map.zMainStation))
				if(locate("\ref[T]") in mode_ticker.bloody_floors)
				else
					mode_ticker.bloody_floors += T
					mode_ticker.bloody_floors[T] = T
					mode_ticker.blood_check()

	if(istype(src, /obj/effect/decal/cleanable/blood/gibs))
		return
	if(istype(src, /obj/effect/decal/cleanable/blood/tracks))
		return // We handle our own drying.
	if(src.type == /obj/effect/decal/cleanable/blood)
		if(src.loc && isturf(src.loc))
			for(var/obj/effect/decal/cleanable/blood/B in src.loc)
				if(B != src)
					if (B.blood_DNA)
						blood_DNA |= B.blood_DNA.Copy()
					returnToPool(B)

/obj/effect/decal/cleanable/blood/update_icon()
	if(basecolor == "rainbow") basecolor = "#[pick(list("FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	color = basecolor

	var/icon/blood = icon(base_icon,icon_state,dir)
	blood.Blend(basecolor,ICON_MULTIPLY)

	icon = blood

/obj/effect/decal/cleanable/blood/Crossed(mob/living/carbon/human/perp)
	if (!istype(perp))
		return
	if(amount < 1)
		return

	if(perp.shoes)
		perp.shoes:track_blood = max(amount,perp.shoes:track_blood)                //Adding blood to shoes
		if(!perp.shoes.blood_overlay)
			perp.shoes.generate_blood_overlay()
		if(!perp.shoes.blood_DNA)
			perp.shoes.blood_DNA = list()
		perp.shoes.overlays -= perp.shoes.blood_overlay
		perp.shoes.blood_overlay.color = basecolor
		perp.shoes.overlays += perp.shoes.blood_overlay
		if(blood_DNA)
			perp.shoes.blood_DNA |= blood_DNA.Copy()
		perp.shoes.blood_color=basecolor
		perp.update_inv_shoes(1)
	else
		perp.track_blood = max(amount,perp.track_blood)                                //Or feet
		if(!perp.feet_blood_DNA)
			perp.feet_blood_DNA = list()
		perp.feet_blood_DNA |= blood_DNA.Copy()
		perp.feet_blood_color=basecolor

	amount--

/obj/effect/decal/cleanable/blood/proc/dry()
	name = "dried [src.name]"
	desc = "It's dry and crusty. Someone is not doing their job."
	color = adjust_brightness(color, -50)
	amount = 0

/obj/effect/decal/cleanable/blood/attack_hand(mob/living/carbon/human/user)
	..()
	if (amount && istype(user))
		add_fingerprint(user)
		if (user.gloves)
			return
		var/taken = rand(1,amount)
		amount -= taken
		user << "<span class='notice'>You get some of \the [src] on your hands.</span>"
		if (!user.blood_DNA)
			user.blood_DNA = list()
		user.blood_DNA |= blood_DNA.Copy()
		user.bloody_hands += taken
		user.hand_blood_color = basecolor
		user.update_inv_gloves(1)
		user.verbs += /mob/living/carbon/human/proc/bloody_doodle

/obj/effect/decal/cleanable/blood/splatter
	random_icon_states = list("mgibbl1", "mgibbl2", "mgibbl3", "mgibbl4", "mgibbl5")
	amount = 2

/obj/effect/decal/cleanable/blood/drip
	name = "drips of blood"
	desc = "It's red."
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
	user << "It reads: <font color='[basecolor]'>\"[message]\"<font>"

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





/obj/effect/decal/cleanable/blood/gibs/proc/streak(var/list/directions)
	spawn (0)
		var/direction = pick(directions)
		for (var/i = 0, i < pick(1, 200; 2, 150; 3, 50; 4), i++)
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

			if (step_to(src, get_step(src, direction), 0))
				break


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

	var/list/datum/disease2/disease/virus2 = list()
	var/dry=0 // Keeps the lag down
