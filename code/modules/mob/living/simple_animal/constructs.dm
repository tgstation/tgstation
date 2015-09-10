/mob/living/simple_animal/construct
	name = "Construct"
	real_name = "Construct"
	desc = ""
	speak_emote = list("hisses")
	emote_hear = list("wails.","screeches.")
	response_help  = "thinks better of touching"
	response_disarm = "flails at"
	response_harm   = "punches"
	speak_chance = 1
	icon = 'icons/mob/mob.dmi'
	speed = 0
	a_intent = "harm"
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	healable = 0
	faction = list("cult")
	flying = 1
	unique_name = 1
	var/list/construct_spells = list()
	var/playstyle_string = "<B>You are a generic construct! Your job is to not exist.</B>"


/mob/living/simple_animal/construct/New()
	..()
	for(var/spell in construct_spells)
		mob_spell_list += new spell(src)

/mob/living/simple_animal/construct/death()
	..(1)
	new /obj/item/weapon/ectoplasm (src.loc)
	visible_message("<span class='danger'>[src] collapses in a shattered heap.</span>")
	ghostize()
	qdel(src)
	return

/mob/living/simple_animal/construct/examine(mob/user)
	var/msg = "<span cass='info'>*---------*\nThis is \icon[src] \a <EM>[src]</EM>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	user << msg

/mob/living/simple_animal/construct/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/construct/builder))
		adjustBruteLoss(-5)
		M.emote("me", 1, "mends some of \the <EM>[src]'s</EM> wounds.")
	else if(src != M)
		..()

/mob/living/simple_animal/construct/bullet_act(obj/item/projectile/Proj)
	if(!Proj)
		return
	if(Proj.damage_type == BURN || Proj.damage_type == BRUTE)
		adjustBruteLoss(Proj.damage)
	Proj.on_hit(src)
	return 0

/mob/living/simple_animal/construct/narsie_act()
	return

/////////////////Juggernaut///////////////



/mob/living/simple_animal/construct/armored
	name = "Juggernaut"
	real_name = "Juggernaut"
	desc = "A possessed suit of armor driven by the will of the restless dead."
	icon_state = "behemoth"
	icon_living = "behemoth"
	maxHealth = 250
	health = 250
	response_harm   = "harmlessly punches"
	harm_intent_damage = 0
	melee_damage_lower = 30
	melee_damage_upper = 30
	attacktext = "smashes their armored gauntlet into"
	speed = 3
	environment_smash = 2
	attack_sound = 'sound/weapons/punch3.ogg'
	status_flags = 0
	mob_size = MOB_SIZE_LARGE
	force_threshold = 11
	construct_spells = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/lesserforcewall)
	playstyle_string = "<B>You are a Juggernaut. Though slow, your shell can withstand extreme punishment, \
						create shield walls and even deflect energy weapons, and rip apart enemies and walls alike.</B>"

/mob/living/simple_animal/construct/armored/bullet_act(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam))
		var/reflectchance = 80 - round(P.damage/3)
		if(prob(reflectchance))
			if(P.damage_type == BURN || P.damage_type == BRUTE)
				adjustBruteLoss(P.damage * 0.5)
			visible_message("<span class='danger'>The [P.name] gets reflected by [src]'s shell!</span>", \
							"<span class='userdanger'>The [P.name] gets reflected by [src]'s shell!</span>")

			// Find a turf near or on the original location to bounce to
			if(P.starting)
				var/new_x = P.starting.x + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
				var/new_y = P.starting.y + pick(0, 0, -1, 1, -2, 2, -2, 2, -2, 2, -3, 3, -3, 3)
				var/turf/curloc = get_turf(src)

				// redirect the projectile
				P.original = locate(new_x, new_y, P.z)
				P.starting = curloc
				P.current = curloc
				P.firer = src
				P.yo = new_y - curloc.y
				P.xo = new_x - curloc.x

			return -1 // complete projectile permutation

	return (..(P))



////////////////////////Wraith/////////////////////////////////////////////



/mob/living/simple_animal/construct/wraith
	name = "Wraith"
	real_name = "Wraith"
	desc = "A wicked bladed shell contraption piloted by a bound spirit"
	icon_state = "floating"
	icon_living = "floating"
	maxHealth = 75
	health = 75
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashes"
	speed = 0
	see_in_dark = 7
	attack_sound = 'sound/weapons/bladeslice.ogg'
	construct_spells = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift)
	playstyle_string = "<B>You are a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</B>"



/////////////////////////////Artificer/////////////////////////

/mob/living/simple_animal/construct/builder
	name = "Artificer"
	real_name = "Artificer"
	desc = "A bulbous construct dedicated to building and maintaining The Cult of Nar-Sie's armies"
	icon_state = "artificer"
	icon_living = "artificer"
	maxHealth = 50
	health = 50
	response_harm = "viciously beats"
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "rams"
	speed = 0
	environment_smash = 2
	attack_sound = 'sound/weapons/punch2.ogg'
	construct_spells = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/wall,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/floor,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone,
							/obj/effect/proc_holder/spell/targeted/projectile/magic_missile/lesser)
	playstyle_string = "<B>You are an Artificer. You are incredibly weak and fragile, but you are able to construct fortifications, \
						use magic missile, repair allied constructs (by clicking on them), \
						</B><I>and most important of all create new constructs</I><B> \
						(Use your Artificer spell to summon a new construct shell and Summon Soulstone to create a new soulstone).</B>"

/////////////////////////////Harvester/////////////////////////

/mob/living/simple_animal/construct/harvester
	name = "Harvester"
	real_name = "Harvester"
	desc = "A harbinger of Nar-Sie's enlightenment. It'll be all over soon."
	icon_state = "harvester"
	icon_living = "harvester"
	maxHealth = 60
	health = 60
	melee_damage_lower = 1
	melee_damage_upper = 5
	attacktext = "prods"
	speed = 0
	environment_smash = 1
	see_in_dark = 7
	attack_sound = 'sound/weapons/tap.ogg'
	construct_spells = list(/obj/effect/proc_holder/spell/targeted/smoke/disable)
	playstyle_string = "<B>You are a Harvester. You are not strong, but your powers of domination will assist you in your role: \
						Bring those who still cling to this world of illusion back to the Geometer so they may know Truth.</B>"

/mob/living/simple_animal/construct/harvester/Process_Spacemove(movement_dir = 0)
	return 1