// -------------- Sickshot -------------
/obj/item/gun/energy/sickshot
	name = "\improper MPA6 \'Sickshot\'"
	desc = "A device that can trigger convusions in specific areas to eject foreign material from a host. Must be used very close to a target. Not for Combat usage."

	icon_state = "dragnet"
	item_state = "dragnet"
	ammo_x_offset = 1
	ammo_type = list(/obj/item/ammo_casing/energy/sickshot)

/obj/item/ammo_casing/energy/sickshot
	projectile_type = /obj/item/projectile/sickshot
	e_cost = 100

//Projectile
/obj/item/projectile/sickshot
	name = "sickshot pulse"
	icon_state = "e_netting"
	damage = 0
	damage_type = STAMINA
	range = 2

/obj/item/projectile/sickshot/on_hit(var/atom/movable/target, var/blocked = 0)
	if(iscarbon(target))
		var/mob/living/carbon/H = target
		if(prob(5))
			for(var/X in H.vore_organs)
				H.release_vore_contents()
				H.visible_message("<span class='danger'>[H] contracts strangely, spewing out contents on the floor!</span>", \
 						"<span class='userdanger'>You spew out everything inside you on the floor!</span>")
		return


////////////////////////// Anti-Noms Drugs //////////////////////////
/*
/datum/reagent/medicine/ickypak
	name = "Ickypak"
	id = "ickypak"
	description = "A foul-smelling green liquid, for inducing muscle contractions to expel accidentally ingested things."
	reagent_state = LIQUID
	color = "#0E900E"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM

/datum/reagent/medicine/ickypak/on_mob_life(var/mob/living/M, method=INGEST)
	if(prob(10))
		M.visible_message("<span class='danger'>[M] retches!</span>", \
 						"<span class='userdanger'>You don't feel good...</span>")
	for(var/I in M.vore_organs)
		var/datum/belly/B = M.vore_organs[I]
		for(var/atom/movable/A in B.internal_contents)
			if(prob(55))
				playsound(M, 'sound/effects/splat.ogg', 50, 1)
				B.release_specific_contents(A)
				M.visible_message("<span class='danger'>[M] contracts strangely, spewing out something!</span>", \
 						"<span class='userdanger'>You spew out something from inside you!</span>")
	return ..()

/datum/chemical_reaction/ickypak
	name = "Ickypak"
	id = "ickypak"
	results = list("ickypak" = 2)
	required_reagents = list("chlorine" = 2 , "oil" = 1) */