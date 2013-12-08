/*
 * Based on Goon's artistic toolbox
 */

/obj/item/weapon/hisgrace

	var/obj/machinery/gibber/his_grace
	var/hunger=0
	var/glomp=0
	var/eating=0
	var/mob/living/carbon/champion=null
	var/bite = 'sound/weapons/bite.ogg'
	var/make_traitor=1 // 1=only the first person, 2+=anyone who picks up will be made a traitor
	var/make_psyco=1 // makes you mute-deaf on pick up, shows fluff messages when equipped. 1=show fluff, 2=first person, 3+=anyone who picks up gets mute-deaf
	var/list/psyco_fluff=list("...feed...me...", "...kill...kill everything...", "...blood...", "...fresh...meat...",
		 "...me...against...the world...", "..there is...no evil...only...suffering...", "...no evil...",
		 "...only...suffering...", "...kill...", "...kill...them...all...")


/obj/item/weapon/hisgrace/New()
	..()

	var/obj/item/weapon/storage/toolbox/mechanical/temp = new //don't want to inherit storage properties from toolbox
	var/list/types = list("icon","icon_state","item_state","flags","force","throwforce","throw_range","throw_speed","w_class","origin_tech","attack_verb")
	var/list/temp_vars = temp.vars
	for(var/i=1, i<temp_vars.len, i++)
		var/a = "[temp_vars[i]]"
		if(a in types)
			src.vars[a]=temp_vars[a]

	name="strange toolbox"
	desc="There is something strange about this toolbox, but you are not sure what it is..."

	his_grace = new()
	his_grace.name = name
	his_grace.use_power = 0
	his_grace.allow_abiotic = 1
	his_grace.require_aggressive_grab = 1
	his_grace.eject_meat = 0
	his_grace.gibbing_sound='sound/items/eatfood.ogg'
	his_grace.gib_message=null
	his_grace.gibtime=5


/obj/item/weapon/hisgrace/attackby(obj/item/weapon/grab/G as obj, mob/living/user as mob)
	if(istype(G, /obj/item/weapon/grab))
		var/is_human=ishuman(G.affecting)
		if(his_grace.attackby(G,user,src))
			spawn(his_grace.gibtime)
				his_grace.start_gibbing(user, src.loc)
				if(is_human) hunger=0
				else hunger = max(0, hunger-50) //monkeys aren't as good as humans
	else if(istype(G, /obj/item/weapon/reagent_containers/food/snacks/meat))
		user << "<span class='danger'>You feed [G] to [src].</span>"
		playsound(src.loc, his_grace.gibbing_sound, 50, 1)
		hunger = hunger - 30
		del(G)
	else
		user << "<span class='userdanger'>You try to put [G] in [src], but [src] bites you instead!</span>"
		playsound(src.loc, bite, 50, 1)
		user.take_organ_damage(5)
		hunger--


/obj/item/weapon/hisgrace/pickup(mob/M as mob)
	..(M)
	if(!champion)
		champion = M
		if(make_traitor)
			make_traitor()
		if(make_psyco)
			make_psyco()
		if(!(src in processing_objects))
			processing_objects.Add(src)
		champion << "<span class='notice'>You feel a sudden surge of power when you pick up [src]!</span>"

/obj/item/weapon/hisgrace/proc/make_traitor()
	if(is_special_character(champion) || !champion.mind) return
	ticker.mode.traitors += champion.mind
	champion.mind.special_role = "Champion of His Grace"

	var/datum/objective/steal/o = new
	o.target_name = name
	o.steal_target = /obj/item/weapon/hisgrace
	o.explanation_text = "Steal [src]."
	o.owner = champion.mind
	champion.mind.objectives += o

	var/datum/objective/escape/e = new
	e.owner = champion.mind
	champion.mind.objectives += e

	var/i=0
	for(var/datum/objective/OBJ in champion.mind.objectives)
		i++
		champion << "<B>Objective #[i]</B>: [OBJ.explanation_text]"

	if(make_traitor==1)
		make_traitor--

/obj/item/weapon/hisgrace/proc/make_psyco()
	if(!(DEAF & champion.sdisabilities))
		champion.sdisabilities |= DEAF
	if(!(MUTE & champion.sdisabilities))
		champion.sdisabilities |= MUTE
	if(make_psyco==2)
		make_psyco--

/*
 * His Grace is active only when equipped. He becomes hungrier and hungrier, starting to nibble and bite
 * whoever is holding Him. At the peak of His hunger, he will glomp the holder three times before eating them.
 */
/obj/item/weapon/hisgrace/process()
	if(!champion)
		glomp=0
		eating=0
		processing_objects.Remove(src)
		return
	if(loc!=champion && loc!=champion.loc)
		champion = null
		processing_objects.Remove(src)
	if(make_psyco && prob(2))
		champion << "<span class='warning'>"+pick(psyco_fluff)+"</span>"
	if(hunger<0)
		hunger=0
		return
	if(hunger<100)
		glomp = 0
		eating= 0
	switch(hunger)
		if(0 to 39)
			if(prob(8)) growl()
		if(40 to 69)
			if(prob(10)) nibble()
		if(70 to 84)
			if(prob(15)) bite()
		if(85 to 99)
			if(prob(25)) bite()
		if(100 to INFINITY)
			if(prob(40)) glomp()
			if(glomp>=3) eat()
			return
	hunger++
	return


/obj/item/weapon/hisgrace/proc/growl(var/mob/living/carbon/user=champion)
	if(!user) return
	user.visible_message("<span class='danger'>[src] growls.</span>")

/obj/item/weapon/hisgrace/proc/nibble(var/mob/living/carbon/user=champion)
	if(!user) return
	user <<"<span class='userdanger'>[src] nibbles you!</span>"
	user.take_organ_damage(1)
	hunger = hunger-1

/obj/item/weapon/hisgrace/proc/bite(var/mob/living/carbon/user=champion)
	if(!user) return
	user.visible_message("<span class='danger'>[src] bites [user]!</span>","<span class='userdanger'>[src] bites you!</span>")
	playsound(src.loc, bite, 50, 1)
	user.take_organ_damage(2)
	hunger = hunger-2

/obj/item/weapon/hisgrace/proc/glomp(var/mob/living/carbon/user=champion)
	if(eating) return
	if(!user) return
	user.u_equip(src)
	user.Weaken(10)
	user.take_organ_damage(20)
	playsound(src.loc, bite, 50, 1)
	user.visible_message("<span class='danger'>[src] glomps [user]!</span>","<span class='userdanger'>[src] glomps you!</span>")
	glomp++

/obj/item/weapon/hisgrace/proc/eat(var/mob/living/carbon/user=champion)
	if(eating)
		return
	eating = 1

	spawn(30)
		if(!user)
			eating=0
			return
		user.visible_message("<span class='danger'>[src] eats [user] whole!</span>", "<span class='userdanger'>[src] eats you whole!</span>")
		his_grace.put_in_gibber(user, src)
		spawn(his_grace.gibtime)
			his_grace.occupant.attack_log += "\[[time_stamp()]\] Was eaten by <b>[his_grace]</b>"
			log_attack("\[[time_stamp()]\] <b>[his_grace]</b> ate <b>[his_grace.occupant]/[his_grace.occupant.ckey]</b>")
			his_grace.start_gibbing(null, src)
			hunger = 0
			glomp  = 0
			eating = 0
			return

