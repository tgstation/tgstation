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

/obj/item/gland/slime
	cooldown_low = 60
	cooldown_high = 120
	uses = -1
	icon_state = "slime"

obj/item/gland/slime/activate()
	host << "<span class='notice'>You feel weird.</span>"

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