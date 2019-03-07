/obj/structure/infection/factory
	name = "factory infection"
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_factory"
	desc = "A thick spire of tendrils."
	max_integrity = 200
	health_regen = 1
	point_return = 25
	var/list/spores = list()
	var/mob/living/simple_animal/hostile/infection/infesternaut/naut = null
	var/max_spores = 3
	var/spore_delay = 0
	var/spore_cooldown = 80 //8 seconds between spores and after spore death

/obj/structure/infection/factory/Initialize()
	START_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/infection/factory/scannerreport()
	if(naut)
		return "It is currently sustaining an infesternaut, making it fragile and unable to produce infection spores."
	return "Will produce an infection spore every few seconds."

/obj/structure/infection/factory/Destroy()
	for(var/mob/living/simple_animal/hostile/infection/infectionspore/spore in spores)
		if(spore.factory == src)
			spore.factory = null
	if(naut)
		naut.factory = null
		to_chat(naut, "<span class='userdanger'>Your factory was destroyed! You feel yourself dying!</span>")
		naut.throw_alert("nofactory", /obj/screen/alert/nofactory)
	spores = null
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/infection/factory/Life()
	. = ..()
	if(naut)
		return
	if(spores.len >= max_spores)
		return
	if(spore_delay > world.time)
		return
	flick("blob_factory_glow", src)
	spore_delay = world.time + spore_cooldown
	var/mob/living/simple_animal/hostile/infection/infectionspore/IS = new/mob/living/simple_animal/hostile/infection/infectionspore(src.loc, src)
	if(overmind) //if we don't have an overmind, we don't need to do anything but make a spore
		IS.overmind = overmind
		IS.update_icons()
		overmind.infection_mobs.Add(IS)
