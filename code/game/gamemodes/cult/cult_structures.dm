/////////////////////
// CULT STRUCTURES //
/////////////////////

/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'
	var/health = 100 //The total health the structure has
	var/death_message = "<span class='warning'>The structure falls apart.</span>" //The message shown when the structure is destroyed
	var/death_sound = 'sound/items/bikehorn.ogg'

/obj/structure/cult/New()
	..()
	SSobj.processing |= src

/obj/structure/cult/Destroy()
	SSobj.processing.Remove(src)
	..()

/obj/structure/cult/process()
	var/turf/T = get_turf(src)
	if(!istype(T, /turf/simulated/floor/plasteel/cult)) //Break down if not on cult tiles
		health -= 5
		if(health <= 0)
			destroy_structure()

/obj/structure/cult/proc/destroy_structure()
	visible_message(death_message)
	playsound(src, death_sound, 50, 1)
	qdel(src)

/obj/structure/cult/attackby(obj/item/I, mob/user, params)
	if(I.force)
		..()
		playsound(src, I.hitsound, 50, 1)
		health = Clamp(health - I.force, 0, initial(health))
		if(health <= 0)
			destroy_structure()
		return
	..()

/obj/structure/cult/talisman
	name = "sacrificial altar"
	desc = "An altar made of tough wood and draped with an ornamental, bloodstained cloth."
	icon_state = "talismanaltar"
	health = 150 //Sturdy
	death_message = "<span class='warning'>The altar breaks into splinters, releasing a cascade of spirits into the air!</span>"
	death_sound = 'sound/effects/altar_break.ogg'

/obj/structure/cult/forge
	name = "runed forge"
	desc = "A combination furnace and anvil. It glows with the heat of the lava flowing through its channel."
	icon_state = "forge"
	luminosity = 2
	health = 300 //Made of metal
	death_message = "<span class='warning'>The forge falls apart, its lava cooling and winking away!</span>"
	death_sound = 'sound/effects/forge_destroy.ogg'

/obj/structure/cult/pylon
	name = "energy pylon"
	desc = "A hovering red crystal that thrums with energy and light. Kept aloft by two metal prongs."
	icon_state = "pylon"
	luminosity = 5
	health = 50 //Very fragile
	death_message = "<span class='warning'>The pylon's crystal vibrates and glows fiercely before violently shattering!</span>"
	death_sound = 'sound/effects/Glassbr2.ogg'

/obj/structure/cult/pylon/destroy_structure()
	for(var/mob/living/M in range(5, src))
		if(!issilicon(M))
			M.visible_message("<span class='warning'>Deadly shards of red crystal impact [M]!</span>", \
							"<span class='userdanger'>Deadly red crystal shards fly into you!</span>")
			M.adjustBruteLoss(rand(5,10))
		else
			M.visible_message("<span class='warning'>Red crystal shards bounce off of [M]'s casing!</span>", \
							"<span class='userdanger'>Red crystal shards bounce off of your casing!</span>")
	..()

/obj/structure/cult/tome
	name = "research desk"
	desc = "A writing desk covered in strange volumes written in an unknown tongue."
	icon_state = "tomealtar"
	luminosity = 1
	health = 125 //Slightly sturdy
	death_message = "<span class='warning'>The desk breaks apart, its books falling to the floor.</span>"
	death_sound = 'sound/effects/wood_break.ogg'

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back."
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1

////////////////
// CULT TURFS //
////////////////

/turf/simulated/floor/plasteel/cult
	name = "engraved floor"
	desc = "A runed floor inlaid with shifting symbols."
	icon_state = "cult"

/turf/simulated/floor/plasteel/cult/process()
	for(var/mob/living/M in src)
		if(iscultist(M)) //Cult floors heal cultists on top of them for a small amount
			M.adjustBruteLoss(-1)
			M.adjustFireLoss(-1)

/turf/simulated/floor/plasteel/cult/New()
	..()
	SSobj.processing |= src

/turf/simulated/floor/plasteel/cult/Destroy()
	SSobj.processing.Remove(src)
	..()

/turf/simulated/wall/cult
	name = "engraved wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them."
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult"
	walltype = "cult"
	builtin_sheet = null
	canSmoothWith = null

/turf/simulated/wall/cult/break_wall()
	new /obj/effect/decal/cleanable/blood(src)
	return (new /obj/structure/cultgirder(src))

/turf/simulated/wall/cult/devastate_wall()
	new /obj/effect/decal/cleanable/blood(src)
	new /obj/effect/decal/remains/human(src)

/turf/simulated/wall/cult/narsie_act()
	return
