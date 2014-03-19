/*
	pAI ClickOn()

	This code allows pAI's to interact with the world around them,
	functionaly working in a similar way to a cyborg it allows a pAI to not only
	interact with the world - but actively help it's owner.
	It's an AI that is bound to a human, that must obay given directives!
	Awesome!
	Just so long as they are willing to cough up for the software upgrade, that is.
*/


/mob/living/silicon/pai/ClickOn(var/atom/A, var/params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(client.buildmode) // comes after object.Click to allow buildmode gui objects to be clicked
		build_click(src, client.buildmode, params, A)
		return

	//if we are not using wiress, return
	if(!src.Wireless)
		return

	//we don't require any range checking
	A.attack_ai(src)

/mob/living/silicon/pai/UnarmedAttack(atom/A)
	A.attack_ai(src)
/mob/living/silicon/pai/RangedAttack(atom/A)
	A.attack_ai(src)