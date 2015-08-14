/obj/item/gland/
	name = "fleshy mass"
	desc = "A nausea-inducing hunk of twisting flesh and metal."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "gland"
	var/cooldown_low = 300
	var/cooldown_high = 300
	var/next_activation = 0
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
	next_activation  = world.time + rand(cooldown_low,cooldown_high)
	SSobj.processing |= src

/obj/item/gland/proc/Inject(var/mob/living/carbon/human/target)
	host = target
	target.internal_organs += src
	src.loc = target

/obj/item/gland/process()
	if(!active)
		SSobj.processing.Remove(src)
		return
	if(next_activation <= world.time)
		//This gives a chance to transplant the gland active into someone else if you're fast
		if(!HostCheck())
			active = 0
			return
		activate()
		uses--
		next_activation  = world.time + rand(cooldown_low,cooldown_high)
	if(uses == 0)
	 active = 0

/obj/item/gland/proc/activate()
	return

/obj/item/gland/heals
	cooldown_low = 200
	cooldown_high = 400
	uses = -1
	icon_state = "health"

/obj/item/gland/heals/activate()
	host << "<span class='notice'>You feel curiously revitalized.</span>"
	host.adjustBruteLoss(-20)
	host.adjustOxyLoss(-20)
	host.adjustFireLoss(-20)

/obj/item/gland/slime
	cooldown_low = 600
	cooldown_high = 1200
	uses = -1
	icon_state = "slime"

/obj/item/gland/slime/activate()
	host << "<span class='warning'>You feel nauseous!</span>"
	if(host.is_muzzled())
		host << "<span class='warning'>The muzzle prevents you from vomiting!</span>"

	host.visible_message("<span class='danger'>[host] vomits on the floor!</span>", \
					"<span class='userdanger'>You throw up on the floor!</span>")

	host.nutrition -= 20
	host.adjustToxLoss(-3)

	var/turf/pos = get_turf(host)
	pos.add_vomit_floor(host)
	playsound(pos, 'sound/effects/splat.ogg', 50, 1)

	var/mob/living/simple_animal/slime/Slime = new/mob/living/simple_animal/slime(pos)
	Slime.Friends = list(host)
	Slime.Leader = host

/obj/item/gland/mindshock
	cooldown_low = 300
	cooldown_high = 300
	uses = -1
	icon_state = "mindshock"

/obj/item/gland/mindshock/activate()
	host << "<span class='notice'>You get a headache.</span>"

	var/turf/T = get_turf(host)
	for(var/mob/living/carbon/human/H in orange(4,T))
		if(H == host)
			continue
		H << "<span class='alien'>You hear a buzz in your head </span>"
		H.confused += 20

/obj/item/gland/pop
	cooldown_low = 900
	cooldown_high = 1800
	uses = 6
	icon_state = "species"

/obj/item/gland/pop/activate()
	host << "<span class='notice'>You feel unlike yourself.</span>"
	var/species = pick(list(/datum/species/lizard,/datum/species/slime,/datum/species/plant/pod,/datum/species/fly))
	hardset_dna(host, null, null, null, null, species)
	host.regenerate_icons()
	return

/obj/item/gland/ventcrawling
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "vent"

/obj/item/gland/ventcrawling/activate()
	host << "<span class='notice'>You feel very stretchy.</span>"
	host.ventcrawler = 2
	return


/obj/item/gland/viral
	cooldown_low = 1800
	cooldown_high = 2400
	uses = 1
	icon_state = "viral"

/obj/item/gland/viral/activate()
	host << "<span class='warning'>You feel sick.</span>"
	var/virus_type = pick(/datum/disease/beesease, /datum/disease/brainrot, /datum/disease/magnitis)
	var/datum/disease/D = new virus_type()
	D.carrier = 1
	host.viruses += D
	D.affected_mob = host
	D.holder = host
	host.med_hud_set_status()


/obj/item/gland/emp //TODO : Replace with something more interesting
	cooldown_low = 900
	cooldown_high = 1600
	uses = 10
	icon_state = "emp"

/obj/item/gland/emp/activate()
	host << "<span class='warning'>You feel a spike of pain in your head.</span>"
	empulse(get_turf(host), 2, 5, 1)

/obj/item/gland/spiderman
	cooldown_low = 450
	cooldown_high = 900
	uses = 10
	icon_state = "spider"

/obj/item/gland/spiderman/activate()
	host << "<span class='warning'>You feel something crawling in your skin.</span>"
	if(uses == initial(uses))
		host.faction += "spiders"
	new /obj/effect/spider/spiderling(host.loc)

/obj/item/gland/egg
	cooldown_low = 300
	cooldown_high = 400
	uses = -1
	icon_state = "egg"

/obj/item/gland/egg/activate()
	host << "<span class='boldannounce'>You lay an egg!</span>"
	var/obj/item/weapon/reagent_containers/food/snacks/egg/egg = new(host.loc)
	egg.reagents.add_reagent("sacid",20)
	egg.desc += " It smells bad."

/obj/item/gland/bloody
	cooldown_low = 200
	cooldown_high = 400
	uses = -1

/obj/item/gland/bloody/activate()
	host.adjustBruteLoss(15)

	host.visible_message("<span class='danger'>[host]'s skin erupts with blood!</span>",\
	"<span class='userdanger'>Blood pours from your skin!</span>")

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
	host << "<span class='warning'>You feel something moving around inside you...</span>"
	//spawn cocoon with clone greytide snpc inside
	var/obj/effect/cocoon/abductor/C = new (get_turf(host))
	C.Copy(host)
	C.Start()
	host.gib()
	return

/obj/effect/cocoon/abductor
	name = "slimy cocoon"
	desc = "Something is moving inside."
	icon = 'icons/effects/effects.dmi'
	icon_state = "cocoon_large3"
	color = rgb(10,120,10)
	density = 1
	var/hatch_time = 0

/obj/effect/cocoon/abductor/proc/Copy(mob/living/carbon/human/H)
	var/mob/living/carbon/human/interactive/greytide/clone = new(src)
	hardset_dna(clone,H.dna.uni_identity,H.dna.struc_enzymes,H.real_name, H.dna.blood_type, H.dna.species.type, H.dna.features)

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
	cooldown_low = 2400
	cooldown_high = 3000
	uses = 1

/obj/item/gland/plasma/activate()
	host << "<span class='warning'>You feel bloated.</span>"
	sleep(150)
	host << "<span class='userdanger'>A massive stomachache overcomes you.</span>"
	sleep(50)
	host.visible_message("<span class='danger'>[host] explodes in a cloud of plasma!</span>")
	var/turf/simulated/T = get_turf(host)
	if(istype(T))
		T.atmos_spawn_air(SPAWN_TOXINS|SPAWN_20C,300)
	host.gib()
	return
