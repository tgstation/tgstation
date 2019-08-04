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

	var/obj/item/organ/heart/slime/slimeheart = new()
	slimeheart.Insert(target, drop_if_replaced = FALSE)
	user.RemoveSpell(src)

/obj/item/organ/heart/slime
	name = "slimy heart"
	desc = "The slime has merged with this organ, instead of melting the rest of the body. Interesting!"
	icon_state = "cursedheart-off"
	icon_base = "cursedheart"//placeholder

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
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/datum/disease/transformation/melting/disease = new()
		disease.creator = firer
		disease.try_infect(H, make_copy = FALSE)
