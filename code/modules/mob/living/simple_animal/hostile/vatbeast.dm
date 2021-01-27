///Vatbeasts are creatures from vatgrowing and are literaly a beast in a vat, yup. They are designed to be a powerful mount roughly equal to a gorilla in power.
/mob/living/simple_animal/hostile/vatbeast
	name = "vatbeast"
	desc = "A strange molluscoidal creature carrying a busted growing vat.\nYou wonder if this burden is a voluntary undertaking in order to achieve comfort and protection, or simply because the creature is fused to its metal shell?"
	icon = 'icons/mob/vatgrowing.dmi'
	icon_state = "vat_beast"
	icon_living = "vat_beast"
	icon_dead = "vat_beast_dead"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	mob_size = MOB_SIZE_LARGE
	gender = NEUTER
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	speak_emote = list("roars")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	health = 250
	maxHealth = 250
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 1, CLONE = 2, STAMINA = 0, OXY = 1)
	melee_damage_lower = 25
	melee_damage_upper = 25
	obj_damage = 40
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	attack_sound = 'sound/weapons/punch3.ogg'
	attack_verb_continuous = "slaps"
	attack_verb_simple = "slap"
	food_type = list(/obj/item/food/fries, /obj/item/food/cheesyfries, /obj/item/food/cornchips, /obj/item/food/carrotfries)
	tame_chance = 30

	var/obj/effect/proc_holder/tentacle_slap/tentacle_slap

/mob/living/simple_animal/hostile/vatbeast/Initialize()
	. = ..()
	tentacle_slap = new(src)
	AddAbility(tentacle_slap)
	add_cell_sample()

/mob/living/simple_animal/hostile/vatbeast/Destroy()
	. = ..()
	QDEL_NULL(tentacle_slap)

/mob/living/simple_animal/hostile/vatbeast/tamed()
	. = ..()
	can_buckle = TRUE
	buckle_lying = 0
	AddElement(/datum/element/ridable, /datum/component/riding/creature/vatbeast)
	faction = list("neutral")

/mob/living/simple_animal/hostile/vatbeast/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_VATBEAST, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

///Ability that allows the owner to slap other mobs a short distance away
/obj/effect/proc_holder/tentacle_slap
	name = "Tentacle slap"
	desc = "Slap a creature with your tentacles."
	active = FALSE
	action_icon = 'icons/mob/actions/actions_animal.dmi'
	action_icon_state = "tentacle_slap"
	action_background_icon_state = "bg_revenant"
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'
	var/cooldown = 12 SECONDS
	var/current_cooldown = 0

/obj/effect/proc_holder/tentacle_slap/Click(location, control, params)
	. = ..()
	if(!isliving(usr))
		return TRUE
	fire(usr)

/obj/effect/proc_holder/tentacle_slap/fire(mob/living/carbon/user)
	if(current_cooldown > world.time)
		to_chat(user, "<span class='notice'>This ability is still on cooldown.</span>")
		return
	if(active)
		remove_ranged_ability("<span class='notice'>You stop preparing to tentacle slap.</span>")
	else
		add_ranged_ability(user, "<span class='notice'>You prepare your pimp-tentacle. <B>Left-click to slap a target!</B></span>", TRUE)

/obj/effect/proc_holder/tentacle_slap/InterceptClickOn(mob/living/caller, params, atom/target)
	. = ..()
	if(.)
		return

	if(owner.stat)
		remove_ranged_ability()
		return

	if(!caller.Adjacent(target))
		return

	if(!isliving(target))
		return

	var/mob/living/living_target = target

	owner.visible_message("<span class='warning>[owner] slaps [living_target] with its tentacle!</span>", "<span class='notice'>You slap [living_target] with your tentacle.</span>")
	playsound(owner, 'sound/effects/assslap.ogg', 90)
	var/atom/throw_target = get_edge_target_turf(target, ranged_ability_user.dir)
	living_target.throw_at(throw_target, 6, 4, owner)
	living_target.apply_damage(30)
	current_cooldown = world.time + cooldown
	remove_ranged_ability()
	return TRUE
