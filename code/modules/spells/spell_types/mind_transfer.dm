/obj/effect/proc_holder/spell/targeted/mind_transfer
	name = "Mind Transfer"
	desc = "This spell allows the user to switch bodies with a target."

	school = "transmutation"
	charge_max = 600
	clothes_req = 0
	invocation = "GIN'YU CAPAN"
	invocation_type = "whisper"
	range = 1
	cooldown_min = 200 //100 deciseconds reduction per rank
	var/list/protected_roles = list("Wizard","Changeling","Cultist") //which roles are immune to the spell
	var/paralysis_amount_caster = 20 //how much the caster is paralysed for after the spell
	var/paralysis_amount_victim = 20 //how much the victim is paralysed for after the spell

	action_icon_state = "mindswap"

/*
Urist: I don't feel like figuring out how you store object spells so I'm leaving this for you to do.
Make sure spells that are removed from spell_list are actually removed and deleted when mind transfering.
Also, you never added distance checking after target is selected. I've went ahead and did that.
*/
/obj/effect/proc_holder/spell/targeted/mind_transfer/cast(list/targets, mob/user = usr, distanceoverride)
	if(!targets.len)
		user << "<span class='warning'>No mind found!</span>"
		return

	if(targets.len > 1)
		user << "<span class='warning'>Too many minds! You're not a hive damnit!</span>"//Whaa...aat?
		return

	var/mob/living/target = targets[1]

	var/t_He = target.p_they(TRUE)
	var/t_is = target.p_are()

	if(!(target in oview(range)) && !distanceoverride)//If they are not in overview after selection. Do note that !() is necessary for in to work because ! takes precedence over it.
		user << "<span class='warning'>[t_He] [t_is] too far away!</span>"
		return

	if(ismegafauna(target))
		user << "<span class='warning'>This creature is too powerful to control!</span>"
		return

	if(target.stat == DEAD)
		user << "<span class='warning'>You don't particularly want to be dead!</span>"
		return

	if(!target.key || !target.mind)
		user << "<span class='warning'>[t_He] appear[target.p_s()] to be catatonic! Not even magic can affect [target.p_their()] vacant mind.</span>"
		return

	if(user.suiciding)
		user << "<span class='warning'>You're killing yourself! You can't concentrate enough to do this!</span>"
		return

	if((target.mind.special_role in protected_roles) || cmptext(copytext(target.key,1,2),"@"))
		user << "<span class='warning'>[target.p_their(TRUE)] mind is resisting your spell!</span>"
		return

	var/mob/living/victim = target//The target of the spell whos body will be transferred to.
	var/mob/caster = user//The wizard/whomever doing the body transferring.

	//MIND TRANSFER BEGIN
	if(caster.mind.special_verbs.len)//If the caster had any special verbs, remove them from the mob verb list.
		for(var/V in caster.mind.special_verbs)//Since the caster is using an object spell system, this is mostly moot.
			caster.verbs -= V//But a safety nontheless.

	if(victim.mind.special_verbs.len)//Now remove all of the victim's verbs.
		for(var/V in victim.mind.special_verbs)
			victim.verbs -= V

	var/mob/dead/observer/ghost = victim.ghostize(0)
	caster.mind.transfer_to(victim)

	if(victim.mind.special_verbs.len)//To add all the special verbs for the original caster.
		for(var/V in caster.mind.special_verbs)//Not too important but could come into play.
			caster.verbs += V

	ghost.mind.transfer_to(caster)
	if(ghost.key)
		caster.key = ghost.key	//have to transfer the key since the mind was not active
	qdel(ghost)

	if(caster.mind.special_verbs.len)//If they had any special verbs, we add them here.
		for(var/V in caster.mind.special_verbs)
			caster.verbs += V
	//MIND TRANSFER END

	//Here we paralyze both mobs and knock them out for a time.
	caster.Paralyse(paralysis_amount_caster)
	victim.Paralyse(paralysis_amount_victim)
	caster << sound('sound/magic/MandSwap.ogg')
	victim << sound('sound/magic/MandSwap.ogg')// only the caster and victim hear the sounds, that way no one knows for sure if the swap happened
