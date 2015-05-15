/obj/item/gland/
	name = "Fleshy mass"
	desc = "Eww"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gland"
	var/cooldown_low = 30
	var/cooldown_high = 30
	var/cooldown_current = 0
	var/cooldown = 0
	var/uses // -1 For inifinite
	var/active = 0
	var/mob/living/carbon/human/host

/obj/item/gland/proc/HostCheck()
	if(ishuman(host) && host == src.loc)
		if(host.stat != DEAD)
			return 1
	return 0

/obj/item/gland/proc/Start()
	active = 1
	SSobj.processing |= src

/obj/item/gland/proc/Inject(var/mob/living/carbon/human/target)
	host = target
	target.internal_organs += src
	src.loc = target

/obj/item/gland/process()
	if(!active)
		SSobj.processing.Remove(src)
		return
	cooldown++
	if(cooldown >= cooldown_current)
		//This gives a chance to transplant the gland active into someone else if you're fast
		if(!HostCheck())
			active = 0
			return
		activate()
		uses--
		cooldown = 0
		cooldown_current = rand(cooldown_low,cooldown_high)
	if(uses == 0)
	 active = 0

/obj/item/gland/proc/activate()
	return

/obj/item/gland/heals
	cooldown_low = 20
	cooldown_high = 40
	uses = -1
	icon_state = "health"

obj/item/gland/heals/activate()
	host << "<span class='notice'>You feel weird.</span>"
	host.adjustBruteLoss(-20)
	host.adjustOxyLoss(-20)
	host.adjustFireLoss(-20)

/obj/item/gland/mindshock
	cooldown_low = 30
	cooldown_high = 30
	uses = -1
	icon_state = "mindshock"

/obj/item/gland/mindshock/activate()
	host << "<span class='notice'>You feel weird.</span>"

	var/turf/T = get_turf(host)
	for(var/mob/living/carbon/human/H in orange(4,T))
		if(H == host)
			continue
		H << "<span class='alien'> You hear a buzz in your head </span>"
		H.confused += 20

/obj/item/gland/pop
	cooldown_low = 120
	cooldown_high = 180
	uses = 5
	icon_state = "species"

/obj/item/gland/pop/activate()
	host << "<span class='notice'>You feel weird.</span>"
	var/species = pick(list(/datum/species/lizard,/datum/species/slime,/datum/species/plant/pod,/datum/species/fly))
	hardset_dna(host, null, null, null, null, species)
	host.regenerate_icons()
	return

/obj/item/gland/ventcrawling
	cooldown_low = 180
	cooldown_high = 240
	uses = 1
	icon_state = "vent"

/obj/item/gland/ventcrawling/activate()
	host << "<span class='notice'>You feel weird.</span>"
	host << "<span class='notice'>You feel very stretchy.</span>"
	host.ventcrawler = 2
	return


/obj/item/gland/viral
	cooldown_low = 180
	cooldown_high = 240
	uses = 1
	icon_state = "viral"

/obj/item/gland/viral/activate()
	var/virus_type = pick(/datum/disease/beesease, /datum/disease/brainrot, /datum/disease/magnitis)
	var/datum/disease/D = new virus_type()
	D.carrier = 1
	host.viruses += D
	D.affected_mob = host
	D.holder = host
	host.med_hud_set_status()


/obj/item/gland/emp //TODO : Replace with something more interesting
	cooldown_low = 90
	cooldown_high = 160
	uses = 5
	icon_state = "emp"

/obj/item/gland/emp/activate()
	empulse(get_turf(host), 2, 5, 1)


/obj/item/gland/spiderman
	cooldown_low = 90
	cooldown_high = 160
	uses = 10
	icon_state = "spider"

/obj/item/gland/spiderman/activate()
	if(uses == initial(uses))
		host.faction += "spiders"
	new /obj/effect/spider/spiderling(host.loc)

/obj/item/gland/egg
	cooldown_low = 60
	cooldown_high = 90
	uses = -1
	icon_state = "egg"

/obj/item/gland/egg/activate()
	var/obj/item/weapon/reagent_containers/food/snacks/egg/egg = new(host.loc)
	egg.reagents.add_reagent("sacid",20)
	egg.desc += " It smells bad."


/obj/item/gland/bloody
	cooldown_low = 200
	cooldown_high = 400
	uses = -1

/obj/item/gland/bloody/activate()
	host.adjustBruteLoss(15)

	host.visible_message("<span class='danger'>[host] skin erupts with blood!</span>",\
	"<span class='userdanger'>Your skin erupts with blood! It hurts!</span>")

	for(var/turf/T in oview(3,host)) //Make this respect walls and such
		T.add_blood_floor(host)
	for(var/mob/living/carbon/human/H in oview(3,host)) //Blood decals for simple animals would be neat. aka Carp with blood on it.
		if(H.wear_suit)
			H.wear_suit.add_blood(host)
			H.update_inv_wear_suit(0)
		else if(H.w_uniform)
			H.w_uniform.add_blood(host)
			H.update_inv_w_uniform(0)

/obj/item/gland/bodysnatch
	cooldown_low = 600
	cooldown_high = 600
	uses = 1

/obj/item/gland/bodysnatch/activate()
	//spawn cocoon with clone greytide snpc inside
	var/obj/effect/cocoon/abductor/C = new (get_turf(host))
	C.Copy(host)
	C.Start()
	host.gib()
	return

/obj/effect/cocoon/abductor
	name = "Slimy cocoon"
	desc = "You can see something moving inside"
	icon = 'icons/effects/effects.dmi'
	icon_state = "cocoon_large3"
	color = rgb(10,120,10)
	density = 1
	var/hatch_time = 0

/obj/effect/cocoon/abductor/proc/Copy(var/mob/living/carbon/human/H)
	var/mob/living/carbon/human/interactive/greytide/clone = new(src)
	hardset_dna(clone,H.dna.uni_identity,H.dna.struc_enzymes,H.real_name, H.dna.blood_type, H.dna.species.type, H.dna.mutant_color)

	//There's no define for this / get all items ?
	var/list/slots = list(slot_back,slot_w_uniform,slot_wear_suit,\
	slot_wear_mask,slot_head,slot_shoes,slot_gloves,slot_ears,\
	slot_glasses,slot_belt,slot_s_store,slot_l_store,slot_r_store,slot_wear_id)

	for(var/slot in slots)
		var/obj/item/I = H.get_item_by_slot(slot)
		if(I)
			clone.equip_to_slot_if_possible(I,slot)

/obj/effect/cocoon/abductor/proc/Start()
	hatch_time = world.time + 600
	SSobj.processing |= src

/obj/effect/cocoon/abductor/process()
	if(world.time > hatch_time)
		SSobj.processing.Remove(src)
		for(var/mob/M in contents)
			src.visible_message("<span class='warning'>[src] hatches!</span>")
			M.loc = src.loc
		qdel(src)

/obj/item/gland/plasma
	cooldown_low = 1200
	cooldown_high = 2400
	uses = 1

/obj/item/gland/plasma/activate()
	host << "<span class='warning'>You feel bloated.</span>"
	sleep(150)
	host << "<span class='userdanger'>Your stomach feels about to explode!</span>"
	sleep(50)
	host.visible_message("<span class='danger'>[host] explodes in a cloud of plasma!</span>")
	var/turf/simulated/T = get_turf(host)
	if(istype(T))
		T.atmos_spawn_air(SPAWN_TOXINS|SPAWN_20C,6665)
	host.gib()
	return