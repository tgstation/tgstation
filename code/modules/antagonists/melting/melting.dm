#define MORPH_COOLDOWN 50

/mob/living/simple_animal/hostile/melting
	name = "melting"
	real_name = "melting"
	desc = "A revolting, pulsating pile of LOVE!"
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	icon = 'icons/mob/melting.dmi'
	icon_state = "melting_base"
	icon_living = "melting_base"
	speed = 2
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxHealth = 150
	health = 150
	healable = 0
	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	see_in_dark = 8
	gender = NEUTER
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	vision_range = 1 // Only attack when target is close
	wander = FALSE
	attacktext = "glomps"
	attack_sound = 'sound/effects/blobattack.ogg'
	del_on_death = TRUE
	//spells, then grant them

/mob/living/simple_animal/hostile/melting/Initialize()
	. = ..()
	name = "[pick(GLOB.melting_first_names)] [pick(GLOB.melting_last_names)]"
	color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	add_overlay("melting_shine")
	//mark = new
	//mark.AddSpell(src)

/mob/living/simple_animal/hostile/melting/Destroy()
	//removespellQDEL_NULL(mark)
	return ..()

/mob/living/simple_animal/hostile/melted
	name = "melted"
	desc = "A sickening goo creature."
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	icon = 'icons/mob/melting.dmi'
	icon_state = "melting_base"
	icon_living = "melting_base"
	speed = 2
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxHealth = 150
	health = 150
	healable = 0
	obj_damage = 50
	melee_damage_lower = 20
	melee_damage_upper = 20
	see_in_dark = 8
	gender = NEUTER
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	vision_range = 1 // Only attack when target is close
	wander = FALSE
	attacktext = "glomps"
	attack_sound = 'sound/effects/blobattack.ogg'
	del_on_death = TRUE

/mob/living/simple_animal/hostile/melted/Initialize()
	. = ..()
	var/static/regex/meltword_endings = new("ing$|less$|ful$|y$") //there are problems with the strings that need fixing.

	var/newmeltword = meltword_endings.Replace(pick(GLOB.melting_first_names), "ed")
	name = newmeltword

/mob/living/simple_animal/hostile/melted/champion
	name = "champion"

//MELTING ABILITIES//

/obj/effect/proc_holder/spell/targeted/mark
	name = "Mark Champion"
	desc = "Selects a single human in our range as our champion. They will carry the disease but not be affected by it, and will spread it to others around him. Upon death, they will revive as a greater minion."

	action_background_icon_state = "bg_hive"
	action_icon_state = "mindswap"

	school = "transmutation"
	charge_max = 600
	clothes_req = FALSE
	invocation = "GIN'YU CAPAN"
	invocation_type = "whisper"
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
	slimeheart.Insert(target)

/obj/effect/proc_holder/spell/aimed/slime
	name = "Slime Toss"
	desc = "Fires a heavy hitting slime projectile, stuns and infects the target with the slime disease. Converts critical humans into minions."

	action_background_icon_state = "bg_hive"
	action_icon_state = "mindswap" //change

	charge_max = 500
	range = 20
	projectile_type = /obj/item/projectile/slime
	base_icon_state = "fireball"
	action_icon_state = "fireball0"
	sound = 'sound/magic/fireball.ogg' //change
	active_msg = "You ready a slime toss!"
	deactive_msg = "You decide against tossing slime."
	antimagic_allowed = TRUE
	clothes_req = FALSE

/obj/item/projectile/slime
	name = "slime ball"
	icon_state = "arcane_barrage"
	damage = 5
	damage_type = TOX
	nodamage = FALSE
	armour_penetration = 100
	flag = "magic"
	hitsound = 'sound/weapons/barragespellhit.ogg'

/obj/item/projectile/slime/on_hit(mob/living/carbon/target)
	. = ..()
	//if(ishuman(target))

//SPECIAL ORGANS//

/obj/item/organ/heart/slime
	name = "slimy heart"
	desc = "The slime has merged with this organ, instead of melting the rest of the body. Interesting!"
	icon_state = "cursedheart-off"
	icon_base = "cursedheart"//placeholder
