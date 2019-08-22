//MELTING ABILITIES//

/obj/effect/proc_holder/spell/targeted/mark
	name = "Mark Champion"
	desc = "Selects a single human in our range as our champion. They will carry the disease but not be affected by it, and will spread it to others around him. Upon death, they will revive as a greater minion."

	action_background_icon_state = "bg_melting"
	action_icon_state = "mark"

	charge_max = 600
	clothes_req = FALSE
	range = 1
	cooldown_min = 200 //100 deciseconds reduction per rank

/obj/effect/proc_holder/spell/targeted/mark/cast(list/targets, mob/living/user = usr, distanceoverride, silent = FALSE)
	if(!targets.len)
		if(!silent)
			to_chat(user, "<span class='warning'>No champion found!</span>")
		return

	if(targets.len > 1)
		if(!silent)
			to_chat(user, "<span class='warning'>You can only champion one person!</span>")
		return

	var/mob/living/carbon/human/target = targets[1]

	if(!(target in oview(range)) && !distanceoverride)//If they are not in overview after selection. Do note that !() is necessary for in to work because ! takes precedence over it.
		if(!silent)
			to_chat(user, "<span class='warning'>They are too far away!</span>")
		return

	if(!ishuman(target))
		if(!silent)
			to_chat(user, "<span class='warning'>This creature is not compatible with our conversion!</span>")
		return

	if(target.stat == DEAD)
		if(!silent)
			to_chat(user, "<span class='notice'>While this would revive the body as a minion, you should start with a champion who is alive!</span>")
		return

	if(!target.key || !target.mind)
		if(!silent)
			to_chat(user, "<span class='warning'>You don't particularly want your champion to be catatonic!</span>")
		return

	var/datum/disease/transformation/melting/delivereddisease
	for(var/datum/disease/transformation/melting/founddisease in target.diseases)
		delivereddisease = founddisease
		break
	if(!delivereddisease)
		delivereddisease = new /datum/disease/transformation/melting()
		delivereddisease.creator = user
	var/obj/item/organ/heart/slime/slimeheart = new(get_turf(target), delivereddisease)
	slimeheart.Insert(target, drop_if_replaced = FALSE)
	user.RemoveSpell(src)

/obj/item/organ/heart/slime
	name = "slimy heart"
	desc = "The slime has merged with this organ, instead of melting the rest of the body. Interesting!"
	icon_state = "cursedheart-off"
	icon_base = "cursedheart"//placeholder
	var/datum/disease/transformation/melting/melting_transform

/obj/item/organ/heart/slime/Initialize(mapload, disease)
	. = ..()
	melting_transform = disease

/obj/item/organ/heart/slime/Insert(mob/living/carbon/M, special = 0)
	..()
	if(owner)
		owner.mind.add_antag_datum(/datum/antagonist/meltedchampion)

/obj/item/organ/heart/slime/Remove(mob/living/carbon/M, special = 0)
	owner.mind.remove_antag_datum(/datum/antagonist/meltedchampion)
	..()
	if(!special)
		visible_message("<span class='warning'>[src] melts away into nothing!</span>")
		qdel(src)

/obj/item/organ/heart/slime/on_life()
	..()
	var/coldmultiplier = -1 //makes the damage negative if not cold, thus healing
	var/critmultiplier = 1 //doubles healing/damage if in crit
	if(owner.bodytemperature < BODYTEMP_COLD_DAMAGE_LIMIT)
		coldmultiplier = 1
	if(owner.stat == DEAD)
		melting_transform.do_disease_transformation(owner)
	else if(owner.stat == UNCONSCIOUS)
		critmultiplier = 2
	owner.apply_damages(brute = 1 * critmultiplier * coldmultiplier, burn = 1 * critmultiplier * coldmultiplier)

/datum/action/innate/colorchange
	name = "Change Colors"
	desc = "Swap colors to your liking! You only have one minute to do this before your color locks in, so decide fast!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "colors"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_melting"

/datum/action/innate/colorchange/Activate()
	var/mob/living/simple_animal/hostile/melting/melting = owner
	var/picked_color = input(melting, "Choose your new color", "Color","#"+melting.slimebody_color) as color|null
	if(!melting.colors)
		alert("You were too late on picking a color, sorry!")
	else
		melting.setup_icons(picked_color)
	QDEL_NULL(src)

/obj/effect/proc_holder/spell/aimed/slime
	name = "Slime Toss"
	desc = "Fires a heavy hitting slime projectile, stuns and infects the target with the slime disease. Converts critical humans into minions."

	action_background_icon_state = "bg_melting"
	action_icon_state = "slimeball"

	charge_max = 500
	range = 20
	projectile_type = /obj/item/projectile/slime
	base_icon_state = "slimeball0"
	action_icon_state = "slimeball1"
	sound = 'sound/effects/slime_ready.ogg'
	active_msg = "You ready a slime toss!"
	deactive_msg = "You decide against tossing slime."
	antimagic_allowed = TRUE
	clothes_req = FALSE

/obj/item/projectile/slime
	name = "slime ball"
	icon_state = "slime"
	damage = 40
	damage_type = TOX
	nodamage = FALSE
	armour_penetration = 100
	hitsound = 'sound/weapons/slime_impact.ogg'

/obj/item/projectile/slime/on_hit(mob/living/carbon/target)
	. = ..()
	var/mob/living/simple_animal/hostile/melting/melting = firer
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/H = target
	var/turf/T = get_turf(H)
	T.add_vomit_floor(src, VOMIT_TOXIC, melting.slimebody_color)
	var/datum/disease/transformation/melting/disease = new()
	disease.creator = melting
	disease.try_infect(H, make_copy = FALSE)

/datum/action/innate/communicate
	name = "Communicate"
	desc = "Allows you to send a message to your champion!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "communicate"
	icon_icon = 'icons/mob/actions/actions_minor_antag.dmi'
	background_icon_state = "bg_melting"
	var/champion = FALSE

/datum/action/innate/communicate/Activate()
	var/message = input("Send a message!", "Communicate")
	var/datum/antagonist/A
	if(champion)
		for(var/datum/antagonist/melting/melting_antagonist in GLOB.antagonists)
			if(melting_antagonist.owner)
				A = melting_antagonist
				break
	else
		for(var/datum/antagonist/meltedchampion/champion_antagonist in GLOB.antagonists)
			if(champion_antagonist.owner)
				A = champion_antagonist
				break
	if(!A)
		to_chat(owner, "<span class='warning'>There's nobody on the other end...?</span>")
		return
	to_chat(owner, "<span class='[champion ? "warning" : "notice"]'><b>[owner]</b>:[message]")
	to_chat(A.owner, "<span class='[champion ? "warning" : "notice"]'><b>[owner]</b>:[message]")
	for(var/mob/dead in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead, owner)
		to_chat(dead, "[link] <span class='[champion ? "warning" : "notice"]'><b>[owner]</b>:[message]")

/datum/action/innate/communicate/champion
	desc = "Allows you to send a message to your master!"
	champion = TRUE
