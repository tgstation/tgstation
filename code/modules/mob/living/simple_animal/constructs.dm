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
	environment_smash = 1
	see_in_dark = 7
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	healable = 0
	faction = list("cult")
	flying = 1
	unique_name = 1
	var/list/construct_spells = list()
	var/playstyle_string = "<b>You are a generic construct! Your job is to not exist.</b>"


/mob/living/simple_animal/construct/New()
	..()
	for(var/spell in construct_spells)
		AddSpell(new spell(null))

/mob/living/simple_animal/construct/death()
	..(1)
	new /obj/item/weapon/ectoplasm (src.loc)
	visible_message("<span class='danger'>[src] collapses in a shattered heap.</span>")
	ghostize()
	qdel(src)
	return

/mob/living/simple_animal/construct/examine(mob/user)
	var/msg = "<span cass='info'>*---------*\nThis is \icon[src] \a <b>[src]</b>!\n"
	if (src.health < src.maxHealth)
		msg += "<span class='warning'>"
		if (src.health >= src.maxHealth/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<b>It looks severely dented!</b>\n"
		msg += "</span>"
	msg += "*---------*</span>"

	user << msg

/mob/living/simple_animal/construct/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/construct/builder))
		if(health < maxHealth)
			adjustBruteLoss(-5)
			if(src != M)
				Beam(M,icon_state="sendbeam",icon='icons/effects/effects.dmi',time=4)
				M.visible_message("<span class='danger'>[M] repairs some of \the <b>[src]'s</b> dents.</span>", \
						   "<span class='cult'>You repair some of <b>[src]'s</b> dents, leaving <b>[src]</b> at [health]/[maxHealth] health.</span>")
			else
				M.visible_message("<span class='danger'>[M] repairs some of its own dents.</span>", \
						   "<span class='cult'>You repair some of your own dents, leaving you at [M.health]/[M.maxHealth] health.</span>")
		else
			if(src != M)
				M << "<span class='cult'>You cannot repair <b>[src]'s</b> dents, as it has none!</span>"
			else
				M << "<span class='cult'>You cannot repair your own dents, as you have none!</span>"
	else if(src != M)
		..()

/mob/living/simple_animal/construct/Process_Spacemove(movement_dir = 0)
	return 1

/mob/living/simple_animal/construct/narsie_act()
	return



/////////////////Juggernaut///////////////
/mob/living/simple_animal/construct/armored
	name = "Juggernaut"
	real_name = "Juggernaut"
	desc = "A massive, armored construct built to spearhead attacks and soak up enemy fire."
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
	playstyle_string = "<b>You are a Juggernaut. Though slow, your shell can withstand extreme punishment, \
						create shield walls, rip apart enemies and walls alike, and even deflect energy weapons.</b>"

/mob/living/simple_animal/construct/armored/bullet_act(obj/item/projectile/P)
	if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam))
		var/reflectchance = 80 - round(P.damage/3)
		if(prob(reflectchance))
			if(P.damage_type == BURN || P.damage_type == BRUTE)
				adjustBruteLoss(P.damage * 0.5)
			visible_message("<span class='danger'>The [P.name] is reflected by [src]'s armored shell!</span>", \
							"<span class='userdanger'>The [P.name] is reflected by your armored shell!</span>")

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
	desc = "A wicked, clawed shell constructed to assassinate enemies and sow chaos behind enemy lines."
	icon_state = "floating"
	icon_living = "floating"
	maxHealth = 75
	health = 75
	melee_damage_lower = 25
	melee_damage_upper = 25
	attacktext = "slashes"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	construct_spells = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift)
	playstyle_string = "<b>You are a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls.</b>"



/////////////////////////////Artificer/////////////////////////
/mob/living/simple_animal/construct/builder
	name = "Artificer"
	real_name = "Artificer"
	desc = "A bulbous construct dedicated to building and maintaining the Cult of Nar-Sie's armies."
	icon_state = "artificer"
	icon_living = "artificer"
	maxHealth = 50
	health = 50
	response_harm = "viciously beats"
	harm_intent_damage = 5
	melee_damage_lower = 5
	melee_damage_upper = 5
	attacktext = "rams"
	environment_smash = 2
	attack_sound = 'sound/weapons/punch2.ogg'
	construct_spells = list(/obj/effect/proc_holder/spell/aoe_turf/conjure/wall,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/floor,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/soulstone,
							/obj/effect/proc_holder/spell/aoe_turf/conjure/construct/lesser,
							/obj/effect/proc_holder/spell/targeted/projectile/magic_missile/lesser)
	playstyle_string = "<b>You are an Artificer. You are incredibly weak and fragile, but you are able to construct fortifications, \
						use magic missile, repair allied constructs (by clicking on them), \
						<i>and, most important of all,</i> create new constructs by producing soulstones to capture souls, \
						and shells to place those soulstones into.</b>"



/////////////////////////////Harvester/////////////////////////
/mob/living/simple_animal/construct/harvester
	name = "Harvester"
	real_name = "Harvester"
	desc = "A long, thin construct built to herald Nar-Sie's rise. It'll be all over soon."
	icon_state = "harvester"
	icon_living = "harvester"
	maxHealth = 60
	health = 60
	melee_damage_lower = 1
	melee_damage_upper = 5
	attacktext = "prods"
	attack_sound = 'sound/weapons/tap.ogg'
	construct_spells = list(/obj/effect/proc_holder/spell/targeted/smoke/disable)
	playstyle_string = "<B>You are a Harvester. You are not strong, but your powers of domination will assist you in your role: \
						Bring those who still cling to this world of illusion back to the Geometer so they may know Truth.</B>"

