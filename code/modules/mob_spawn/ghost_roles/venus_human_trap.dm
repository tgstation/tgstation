/// Handles logic for ghost spawning code, visible object in game is handled by /obj/structure/alien/resin/flower_bud
/obj/effect/mob_spawn/ghost_role/venus_human_trap
	name = "flower bud"
	desc = "A large pulsating plant..."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "bud0"
	mob_type = /mob/living/simple_animal/hostile/venus_human_trap
	density = FALSE
	prompt_name = "venus human trap"
	you_are_text = "You are a venus human trap."
	flavour_text = "You are a venus human trap!  Protect the kudzu at all costs, and feast on those who oppose you!"
	faction = list("hostile","vines","plants")
	spawner_job_path = /datum/job/venus_human_trap
	/// Physical structure housing the spawner
	var/obj/structure/alien/resin/flower_bud/flower_bud
	/// Used to determine when to notify ghosts
	var/ready = FALSE

/obj/effect/mob_spawn/ghost_role/venus_human_trap/Destroy()
	if(flower_bud) // anti harddel checks
		if(!QDELETED(flower_bud))
			qdel(flower_bud)
		flower_bud = null
	return ..()

/obj/effect/mob_spawn/ghost_role/venus_human_trap/equip(mob/living/simple_animal/hostile/venus_human_trap/spawned_human_trap)
	if(spawned_human_trap && flower_bud)
		if(flower_bud.trait_flags & SPACEVINE_HEAT_RESISTANT)
			spawned_human_trap.unsuitable_heat_damage = 0
		if(flower_bud.trait_flags & SPACEVINE_COLD_RESISTANT)
			spawned_human_trap.unsuitable_cold_damage = 0

/// Called when the attached flower bud has borne fruit (ie. is ready)
/obj/effect/mob_spawn/ghost_role/venus_human_trap/proc/bear_fruit()
	ready = TRUE
	notify_ghosts("[src] has borne fruit!", null, enter_link = "<a href=?src=[REF(src)];activate=1>(Click to play)</a>", source = src, action = NOTIFY_ATTACK, ignore_key = POLL_IGNORE_VENUSHUMANTRAP)

/obj/effect/mob_spawn/ghost_role/venus_human_trap/Topic(href, href_list)
	. = ..()
	if(.)
		return
	if(href_list["activate"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)
			attack_ghost(ghost)

/obj/effect/mob_spawn/ghost_role/venus_human_trap/allow_spawn(mob/user, silent = FALSE)
	. = ..()
	if(!.)
		return FALSE
	if(!ready)
		if(!silent)
			to_chat(user, span_warning("\The [src] has not borne fruit yet!"))
		return FALSE
