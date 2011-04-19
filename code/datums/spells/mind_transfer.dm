/obj/spell/targeted/mind_transfer
	name = "Mind Transfer"
	desc = "This spell allows the user to switch bodies with a target."

	school = "transmutation"
	charge_max = 600
	clothes_req = 0
	invocation = "GIN'YU CAPAN"
	invocation_type = "whisper"
	range = 7
	var/list/protected_roles = list("Wizard","Fake Wizard","Changeling","Cultist","Space Ninja") //which roles are immune to the spell
	var/list/compatible_mobs = list("/mob/living/carbon/human","/mob/living/carbon/monkey") //which types of mobs are affected by the spell. NOTE: change at your own risk
	var/base_spell_loss_chance = 5 //base probability of the wizard losing a spell in the process
	var/spell_loss_chance_modifier = 7 //amount of probability of losing a spell added per spell (mind_transfer included)
	var/spell_loss_amount = 1 //the maximum amount of spells possible to lose during a single transfer
	var/msg_wait = 500 //how long in deciseconds it waits before telling that body doesn't feel right or mind swap robbed of a spell
	var/paralysis_amount_caster = 20 //how much the caster is paralysed for after the spell
	var/paralysis_amount_victim = 20 //how much the victim is paralysed for after the spell

/obj/spell/targeted/mind_transfer/cast(list/targets,mob/user = usr) //magnets, so mostly hardcoded
	if(!targets.len)
		user << "No mind found"
		return

	if(targets.len > 1)
		user << "Too many minds! You're not a hive damnit!"
		return

	var/mob/target = targets[1]

	if(!target.client || !target.mind)
		user << "They appear to be brain-dead."
		return

	if(target.mind.special_role in protected_roles)
		user << "Their mind is resisting your spell."
		return

	if(!target.type in compatible_mobs)
		user << "Their mind isn't compatible with yours."
		return

	if(target.stat == 2)
		user << "You didn't study necromancy back at the Space Wizard Federation academy."
		return

	var/mob/victim = target //mostly copypastaed, I have little idea how this works
	var/mob/caster = user
	//losing spells

	if(usr.spell_list.len)
		for(var/i=1,i<=spell_loss_amount,i++)
			var/spell_loss_chance = base_spell_loss_chance
			var/list/checked_spells = usr.spell_list
			checked_spells -= src //MT can't be lost //doesn't work

			for(var/j=1,j<=checked_spells.len,j++)
				if(prob(spell_loss_chance))
					if(checked_spells.len)
						usr.spell_list -= pick(checked_spells)
						spawn(msg_wait)
							victim << "The mind transfer has robbed you of a spell."
					break
				else
					spell_loss_chance += spell_loss_chance_modifier

	var/mob/dead/observer/temp_ghost = new /mob/dead/observer(target) //To properly transfer clients so no-one gets kicked off the game.

	if(caster.mind.special_verbs.len)//Removes any special verbs from the original caster.
		for(var/V in caster.mind.special_verbs)
			caster.verbs -= V
	victim.client.mob = temp_ghost
	if(victim.mind.special_verbs.len)//Removes any special verbs from the original target.
		for(var/V in victim.mind.special_verbs)
			victim.verbs -= V

	temp_ghost.spell_list = victim.spell_list
	temp_ghost.mind = victim.mind

	caster.client.mob = victim
	victim.spell_list = caster.spell_list
	victim.mind = caster.mind
	if(victim.mind.special_verbs.len)//Adds verbs for the original caster if needed.
		for(var/V in caster.mind.special_verbs)
			caster.verbs += V

	temp_ghost.client.mob = caster
	caster.spell_list = temp_ghost.spell_list
	caster.mind = temp_ghost.mind
	if(caster.mind.special_verbs.len)//Adds verbs for original target if needed.
		for(var/V in caster.mind.special_verbs)
			caster.verbs += V
	caster.mind.current = caster
	victim.mind.current = victim

	caster.paralysis += paralysis_amount_caster
	victim.paralysis += paralysis_amount_victim

	spawn(msg_wait)
		caster << "Your body doesn't feel like itself."

	del(temp_ghost)