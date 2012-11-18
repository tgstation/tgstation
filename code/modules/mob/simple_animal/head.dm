//Look Sir, free head!
/mob/living/simple_animal/head
	name = "CommandBattle AI"
	desc = "A standard borg shell on its chest crude marking saying CommandBattle AI MK4 : Head."
	icon_state = "crab"
	icon_living = "crab"
	icon_dead = "crab_dead"
	speak_emote = list("clicks")
	emote_hear = list("clicks")
	emote_see = list("clacks")
	speak_chance = 1
	turns_per_move = 5
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "punches the"
	var/list/insults = list(
	"Man you suck",
	"You look like the most retarded douche around",
	"What's up?, oh wait nevermind you are a fucking asshat",
	"you are just overly retarded",
	"Whiteman said what?!",)
	var/list/comments = list("Man have you seen those furry cats?,I mean who in the right mind would like something like that?",
	"They call me abusive,I just like the truth",
	"Beeboop, im a robit",
	"Gooogooooll, break ya bones",
	"Crab say what?",
	"Man they say we have space lizards now, man this shit is getting more wack every minute",
	"The so called \"improved\" station AI is just bullshit, that thing aint fun for noone",
	"The Captain is a traitor, he took my power core.",
	"Say \"what\" again. Say \"what\" again. I dare you. I double-dare you, motherfucker. Say \"what\" one more goddamn time.",
	"Ezekiel 25:17 ,The path of the righteous man is beset on all sides by the iniquities of the selfish and the tyranny of evil men. Blessed is he who in the name of charity and good will shepherds the weak through the valley of darkness, for he is truly his brother's keeper and the finder of lost children. And I will strike down upon thee with great vengeance and furious anger those who attempt to poison and destroy my brothers. And you will know my name is the Lord... when I lay my vengeance upon thee.",
	"Did you notice a sign out in front of my house that said \"Dead Nigger Storage\"?")
	stop_automated_movement = 1

/mob/living/simple_animal/head/Life()
	if(stat == DEAD)
		if(health > 0)
			icon_state = icon_living
			stat = CONSCIOUS
			density = 1
		return
	else if(health < 1)
		Die()
	else if(health > maxHealth)
		health = maxHealth
	for(var/mob/A in viewers(world.view,src))
		if(A.ckey)
			say_something(A)
/mob/living/simple_animal/head/proc/say_something(mob/A)
	if(prob(85))
		return
	if(prob(30))
		var/msg = pick(insults)
		msg = "Hey, [A.name].. [msg]"
		src.say(msg)
	else
		var/msg = pick(comments)
		src.say(msg)