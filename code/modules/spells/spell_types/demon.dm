/obj/effect/proc_holder/spell/targeted/summon_pitchfork
	name = "Summon Pitchfork"
	desc = "A devil's weapon of choice.  Use this to summon/unsummon your pitchfork."
	invocation_type = "none"
	include_user = 1
	range = -1
	clothes_req = 0
	var/summoned = 0
	var/obj/item/weapon/twohanded/pitchfork/pitchfork

	school = "conjuration"
	charge_max = 150
	cooldown_min = 10
	action_icon_state = "bolt_action" //TODO: set icon



/obj/effect/proc_holder/spell/targeted/summon_pitchfork/cast(list/targets, mob/user = usr)
	if (summoned)
		qdel(pitchfork)
	else
		for(var/mob/living/carbon/C in targets)
			C.drop_item()
			pitchfork = new
			C.put_in_hands(pitchfork)
	summoned = !summoned

/obj/effect/proc_holder/spell/dumbfire/fireball/demonic
	name = "Hellfire"
	desc = "This spell launches hellfire at the target."

	school = "evocation"
	charge_max = 30
	clothes_req = 0
	invocation = "Your very soul will catch fire!"
	invocation_type = "shout"
	range = 2

	proj_icon_state = "fireball"
	proj_name = "a fireball"
	proj_type = "/obj/effect/proc_holder/spell/turf/fireball/demon"

	proj_lifespan = 200
	proj_step_delay = 1

	action_icon_state = "fireball"
	sound = "sound/magic/Fireball.ogg"

/obj/effect/proc_holder/spell/turf/fireball/demon/cast(turf/T,mob/user = usr)
	explosion(T, -1, -1, 1, 4, 0, flame_range = 5)


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/demon
	name = "Infernal appearance"
	desc = "Allows you to disappear and re-appear in a flash of fire."

	school = "transmutation"
	charge_max = 10
	clothes_req = 0
	invocation = "none"
	invocation_type = "none"
	range = -1
	jaunt_duration = 300 //in deciseconds
	action_icon_state = "jaunt" //TODO: better icon


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/demon/cast(list/targets,mob/user = usr) //magnets, so mostly hardcoded
	if(!in_jaunt)
		..()
	else
		in_jaunt = 0
		for(var/mob/living/target in targets)
			var/turf/mobloc = get_turf(target.loc)
			var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt( mobloc )
			var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
			user << "Bleep."
			exit_jaunt(target, mobloc, holder, animation, user)