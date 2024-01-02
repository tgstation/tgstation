//alpha wolf- smaller chance to spawn, practically a miniboss. Has the ability to do a short, untelegraphed lunge with a stun. Be careful!
/mob/living/simple_animal/hostile/asteroid/wolf/alpha
	name = "alpha wolf"
	desc = "An old wolf with matted, dirty fur and a missing eye, trophies of many won battles and successful hunts. Seems like they're the leader of the pack around here. Watch out for the lunge!"
	icon = 'voidcrew/icons/mob/icemoon/icemoon_monsters.dmi'
	icon_state = "alphawolf"
	icon_living = "alphawolf"
	icon_dead = "alphawolf_dead"
	speed = 15
	move_to_delay = 15
	vision_range = 4
	aggro_vision_range = 12
	maxHealth = 100
	health = 100
	melee_damage_lower = 10
	melee_damage_upper = 10
	dodging = TRUE
	dodge_prob = 75
	//charger = TRUE
	//charge_distance = 7
	//knockdown_time = 1 SECONDS
	//charge_frequency = 20 SECONDS
	//butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2, /obj/item/stack/sheet/sinew/wolf = 4, /obj/item/stack/sheet/sinew/wolf = 4, /obj/item/stack/sheet/bone = 5)
	loot = list()
	crusher_loot = /obj/item/crusher_trophy/fang

/mob/living/simple_animal/hostile/asteroid/wolf/alpha/gib()
	move_force = MOVE_FORCE_DEFAULT
	move_resist = MOVE_RESIST_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	if(prob(75))
		new /obj/item/crusher_trophy/fang(loc)
		visible_message("<span class='warning'>You find an intact fang that looks salvagable.</span>")
	..()

/obj/item/crusher_trophy/fang
	name = "battle-stained fang"
	desc = "A wolf fang, displaying the wear and tear associated with a long and colorful life. Could be attached to a kinetic crusher or used to make a trophy."
	icon = 'icons/obj/lavaland/elite_trophies.dmi'
	icon_state = "fang"
	denied_type = /obj/item/crusher_trophy/fang
	var/bleed_stacks_per_hit = 5

/obj/item/crusher_trophy/fang/effect_desc()
	return "waveform collapse to build up a small stack of bleeding, causing a burst of damage if applied repeatedly."

/obj/item/crusher_trophy/fang/on_mark_detonation(mob/living/M, mob/living/user)
	if(istype(M) && (M.mob_biotypes & MOB_ORGANIC))
		var/datum/status_effect/stacking/saw_bleed/bloodletting/B = M.has_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting)
		if(!B)
			M.apply_status_effect(/datum/status_effect/stacking/saw_bleed/bloodletting, bleed_stacks_per_hit)
		else
			B.add_stacks(bleed_stacks_per_hit)

/mob/living/simple_animal/hostile/asteroid/wolf/random/Initialize()
	. = ..()
	if(prob(15))
		new /mob/living/simple_animal/hostile/asteroid/wolf/alpha(loc)
		return INITIALIZE_HINT_QDEL

/mob/living/simple_animal/hostile/asteroid/wolf/wasteland
	faction = list(FACTION_WASTELAND)

/mob/living/simple_animal/hostile/asteroid/wolf/alpha/wasteland
	faction = list(FACTION_WASTELAND)

/mob/living/simple_animal/hostile/asteroid/wolf/wasteland/random/Initialize()
	. = ..()
	if(prob(15))
		new /mob/living/simple_animal/hostile/asteroid/wolf/alpha/wasteland(loc)
		return INITIALIZE_HINT_QDEL

