/obj/effect/proc_holder/spell/targeted/summon_pitchfork
	name = "Summon Pitchfork"
	desc = "A devil's weapon of choice.  Use this to summon/unsummon your pitchfork."
	invocation_type = "none"
	include_user = 1
	range = -1
	clothes_req = 0
	var/obj/item/weapon/twohanded/pitchfork/demonic/pitchfork
	var/pitchfork_type = /obj/item/weapon/twohanded/pitchfork/demonic/

	school = "conjuration"
	charge_max = 150
	cooldown_min = 10
	action_icon_state = "pitchfork"



/obj/effect/proc_holder/spell/targeted/summon_pitchfork/cast(list/targets, mob/user = usr)
	if (pitchfork)
		qdel(pitchfork)
	else
		for(var/mob/living/carbon/C in targets)
			if(C.drop_item())
				pitchfork = new pitchfork_type
				C.put_in_hands(pitchfork)

/obj/effect/proc_holder/spell/targeted/summon_pitchfork/Del()
	if(pitchfork)
		qdel(pitchfork)

/obj/effect/proc_holder/spell/targeted/summon_pitchfork/greater
	pitchfork_type = /obj/item/weapon/twohanded/pitchfork/demonic/greater

/obj/effect/proc_holder/spell/targeted/summon_pitchfork/ascended
	pitchfork_type = /obj/item/weapon/twohanded/pitchfork/demonic/ascended


/obj/effect/proc_holder/spell/targeted/summon_contract
	name = "Summon infernal contract"
	desc = "Skip making a contract by hand, just do it by magic."
	invocation_type = "whisper"
	invocation = "Just sign on the dotted line."
	include_user = 0
	range = 5
	clothes_req = 0

	school = "conjuration"
	charge_max = 150
	cooldown_min = 10
	action_icon_state = "spell_default" //TODO: set icon

/obj/effect/proc_holder/spell/targeted/summon_contract/cast(list/targets, mob/user = usr)
	var/contractTypeName = input(user, "What type of contract?") in list ("Power", "Wealth", "Prestige", "Magic", "Revive", "Knowledge")
	var/contractType = CONTRACT_POWER
	switch(contractTypeName)
		if("Power")
			contractType = CONTRACT_POWER
		if("Wealth")
			contractType = CONTRACT_WEALTH
		if("Prestige")
			contractType = CONTRACT_PRESTIGE
		if("Magic")
			contractType = CONTRACT_MAGIC
		if("Revive")
			contractType = CONTRACT_REVIVE
		if("Knowledge")
			contractType = CONTRACT_KNOWLEDGE
	for(var/mob/living/carbon/C in targets)
		if(C.mind && user.mind)
			if(user.drop_item())
				var/obj/item/weapon/paper/contract/infernal/contract = new(user.loc, C.mind, contractType, user.mind)
				if(contractType == CONTRACT_REVIVE)
					user.put_in_hands(contract)
				else
					C.put_in_hands(contract)
		else
			user << "<span class='notice'>[C] seems to not be sentient.  You cannot summon a contract for them.</span>"


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
	jaunt_duration = 300
	action_icon_state = "jaunt" //TODO: better icon


/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/demon/cast(list/targets,mob/user = usr)
	if(!in_jaunt)
		playsound(get_turf(user), 'sound/magic/Ethereal_Enter.ogg', 50, 1, -1)
		for(var/mob/living/target in targets)
			target.notransform = 1
			sleep(30)
			mobloc = get_turf(target.loc)
			holder = new /obj/effect/dummy/spell_jaunt( mobloc )
			animation = new /atom/movable/overlay( mobloc )
			enter_jaunt(target)
			in_jaunt = 1
	else
		for(var/mob/living/target in targets)
			var/continuing = 0
			for(var/mob/living/C in orange(2, get_turf(target.loc)))
				if (C.mind && C.mind.soulOwner == C.mind)
					continuing = 1
					break
			if(continuing)
				in_jaunt = 0
				var/turf/mobloc = get_turf(target.loc)
				var/obj/effect/dummy/spell_jaunt/holder = new /obj/effect/dummy/spell_jaunt( mobloc )
				var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
				exit_jaunt(target, mobloc, holder, animation, user)
			else
				target << "<<span class='warning'>You can only re-appear near a potential signer."
				revert_cast()
				return ..()
	return ..()
