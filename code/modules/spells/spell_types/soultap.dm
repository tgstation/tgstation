
/obj/effect/proc_holder/spell/self/tap
	name = "Soul Tap"
	desc = "Fuel your spells using your own soul! Nope, nothing can go wrong with this."
	school = "necromancy" //i could see why this wouldn't be necromancy but messing with souls or whatever
	charge_max = 10
	invocation = "AT ANY COST"
	invocation_type = "shout"
	level_max = 0 //cannot be improved either, mostly because there isn't much to improve beyond how much health you lose and that is already generous for what it does
	cooldown_min = 10

	action_icon = 'icons/mob/actions/actions_spells.dmi'
	action_icon_state = "skeleton"

/obj/effect/proc_holder/spell/self/tap/cast(mob/living/user = usr)
	if(!user.mind.hasSoul) //lol
		to_chat(user, "<span class='caution'>You do not possess a soul to tap into!</span>")
	to_chat(user, "<span class='danger'>A gripping, cold emptiness flows through your body for a moment.</span>")
	user.maxHealth -= 10
	user.health = min(user.health - 10, user.maxHealth)
	if(user.maxHealth <= 0)
		to_chat(user, "<span class='userdanger'>You feel empty and cold as your weakened soul is completely consumed by the tap!</span>")
		user.mind.hasSoul = FALSE
	for(var/obj/effect/proc_holder/spell/spell in user.mind.spell_list)
		spell.charge_counter = spell.charge_max
