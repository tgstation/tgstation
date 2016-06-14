#define UMBRA_INVISIBILITY 50
#define UMBRA_VITAE_DRAIN_RATE 0.01 //How much vitae is drained per tick to sustain the umbra. Set this to higher values to make umbras need to harvest vitae more often.
#define UMBRA_MAX_HARVEST_COOLDOWN 3000 //In deciseconds, how long it takes for a recently-drained target's soul to be drainable again.

/*

Umbras are spirits of the dead with enough anger or determination in their souls to not fully pass on. They exist somewhere between the realms of the living and the dead.

Unfortunately, this comes at a price: umbras require the vitae of souls to keep themselves alive. Their forms are difficult to maintain, and without vitae, they will fade away.
This vitae can be drained at will from any being's corpse, although humans typically net a richer pool to drink from - in particular, sapient humans are worth the most.
Some humans have a "perfect soul" - a new soul, not corrupted by lives' worth of being passed down. These humans yield huge amounts of vitae to the umbra lucky enough to find them.
Vitae is not only used as an umbra's health, but it's also used to fuel some of their unique abilities. These abilities can be used to influence the living realm in different ways.
As a final note, umbras require vitae to live. Although it drains very slowly, it does drain, and without vitae, the umbra will die.

Umbras are not without their weaknesses. Despite being invisible to the naked eye and completely incorporeal, certain things can restrict, weaken, or outright harm them.
Lines of salt on the ground will prevent an umbra's passage, making area encircled in it completely inaccessible to even the most determined umbra.
In addition, objects and artifacts of a holy nature can force an umbra to manifest or drain its vitae.

When an umbra dies, two things can occur. If the umbra died from passive vitae drain, it will be dead forever, with no way to bring it back.
However, if the umbra is slain forcibly and still has vitae, it leaves behind phantasmal ashes. These ashes will, after a minute or so, reform into another umbra and vanish.
If possible, the new umbra will be controlled by the same player as before. If not, another player will be chosen to control it.
Regardless of whether or not this is successful, the new umbra will have the same vitae as the old one.

*/

/mob/living/simple_animal/umbra
	name = "umbra"
	real_name = "umbra"
	desc = "A translucent, cobalt-blue spirit floating several feet in the air."
	invisibility = UMBRA_INVISIBILITY
	icon = 'icons/mob/mob.dmi'
	icon_state = "umbra"
	icon_living = "umbra"
	layer = GHOST_LAYER
	alpha = 175 //To show invisibility
	health = 100
	maxHealth = 100
	healable = 0
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	healable = FALSE
	friendly = "passes through"
	speak_emote = list("murmurs")
	emote_hear = list("murmurs")
	languages = ALL
	incorporeal_move = 3
	flying = TRUE
	stop_automated_movement = TRUE
	wander = FALSE
	sight = SEE_SELF
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	see_in_dark = 8
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	var/vitae = 10 //The amount of vitae captured by the umbra
	var/vitae_cap = 100 //How much vitae a single umbra can hold
	var/breaking_apart = FALSE //If the umbra is currently dying
	var/harvesting = FALSE //If the umbra is harvesting a soul
	var/list/recently_drained = list() //Mobs that have been drained in the last five minutes by the umbra
	var/playstyle_string = "<font size=3 color='#5000A0'><b>You are an umbra,</b></font><b> a spirit with enough anger or determination not to fully pass on. Although the circumstances of your \
	death have been forgotten, you still clearly remember your name, but nothing other than that. What you do know is that you're going to make the most out of this second chance that you have \
	somehow claimed.\n\
	\n\
	Even now you feel your hold on life slipping away. You know that the souls of all creatures - humans in particular - still hold a spark of life, even after death. This spark is called \
	<i>vitae</i> and every living thing has at least a small amount of it. You think that you can harvest this vitae from the corpses of living things, but those still alive might be too \
	difficult to draw from. Anything in critical condition wouldn't be affected enough to harm by a draining, but you might be able to extract more vitae from them regardless.\n\
	\n\
	Although living things have plenty of vitae, you think that the souls of these creatures might be rendered useless if you drain too much. For this reason, you'll have to limit yourself and \
	can only draw any significant amount of vitae from a particular corpse once every few minutes. After that time, you think that the soul will have recuperated enough that you can draw from \
	it again.\n\
	\n\
	Right now, you are incorporeal and invisible to the naked eye. However, some abilities and circumstances may reveal and immobilize you, making you vulnerable to attack.</b>"

/mob/living/simple_animal/umbra/New()
	..()
	if(prob(1))
		name = "grief ghost"
		real_name = "grief ghost"
		desc = "You wonder how something that produces so much salt can be weak to it."
	AddSpell(new/obj/effect/proc_holder/spell/targeted/night_vision/umbra(null))
	AddSpell(new/obj/effect/proc_holder/spell/targeted/discordant_whisper(null))

/mob/living/simple_animal/umbra/Life()
	..()
	adjust_vitae(-UMBRA_VITAE_DRAIN_RATE, TRUE, "passive drain")
	if(!vitae)
		death()

/mob/living/simple_animal/umbra/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Vitae: [vitae]/[vitae_cap]")
		stat(null, "Vitae Cost/Tick: [UMBRA_VITAE_DRAIN_RATE]")
		var/drained_mobs = ""
		var/length = recently_drained.len
		for(var/mob/living/L in recently_drained)
			if(!L)
				recently_drained -= L
				length--
			else
				drained_mobs += "[L.real_name][length > 1 ? ", " : ""]"
			length--
		stat(null, "Recently Drained Creatures: [drained_mobs ? "[drained_mobs]" : "None"]")

/mob/living/simple_animal/umbra/ClickOn(atom/A, params)
	A.examine(src)
	if(isliving(A) && Adjacent(A))
		var/mob/living/L = A
		if(L.health > 0 && L.stat != DEAD)
			src << "<span class='warning'>[L]'s soul is too strong to drain while they aren't severely wounded!</span>"
			return
		else if(L in recently_drained)
			src << "<span class='warning'>[L]'s soul is still recuperating! You can't risk draining any more vitae!</span>"
			return
		else if(harvesting)
			src << "<span class='warning'>You're already trying to harvest a soul!</span>"
			return
		harvest_soul(L)

/mob/living/simple_animal/umbra/death()
	if(breaking_apart)
		return
	..(1)
	breaking_apart = TRUE
	notransform = TRUE
	invisibility = FALSE
	visible_message("<span class='warning'>An [name] appears from nowhere and begins to disintegrate!</span>", \
	"<span class='userdanger'>You feel your will faltering, and your form begins to break apart!</span>")
	flick("umbra_disintegrate", src)
	sleep(12)
	if(vitae)
		visible_message("<span class='warning'>[src] breaks apart into a pile of ashes!</span>", \
		"<span class='umbra_emphasis'><font size=3>You'll</font> be <font size=1>back...</font></span>")
		var/obj/item/phantasmal_ashes/P = new(get_turf(src))
		P.umbra_key = key
		P.umbra_vitae = vitae
	else
		visible_message("<span class='warning'>[src] breaks apart and fades away!</span>")
	qdel(src)

/mob/living/simple_animal/umbra/say() //Umbras can't directly speak
	return

/mob/living/simple_animal/umbra/attack_ghost(mob/dead/observer/O)
	if(key)
		return
	if(alert(O, "Become an umbra? You won't be clonable!",,"Yes", "No") == "No" || !O)
		return
	notify_ghosts("The umbra at [get_area(src)] has been taken control of by [O].", source = src, action = NOTIFY_ORBIT)
	key = O.key
	src << playstyle_string


/mob/living/simple_animal/umbra/proc/adjust_vitae(amount, silent, source)
	vitae = min(max(0, vitae + amount), vitae_cap)
	if(!silent)
		src << "<span class='umbra'>[amount > 0 ? "Gained" : "Lost"] [amount] vitae[source ? " from [source]" : ""].</span>"
	return vitae


/mob/living/simple_animal/umbra/proc/harvest_soul(mob/living/L) //How umbras drain vitae from their targets
	if(!L || L.health || L in recently_drained)
		return
	harvesting = TRUE
	src << "<span class='umbra'>You search for [L]'s soul...</span>"
	if(!do_after(src, 30, target = L))
		harvesting = FALSE
		return
	if(L.hellbound)
		src << "<span class='warning'>[L] has only emptiness in place of their soul!</span>"
		harvesting = FALSE
		return
	if(!L.stat)
		src << "<span class='warning'>[L] is conscious again and shields your efforts!</span>"
		L << "<span class='warning'>You're being watched.</span>"
		harvesting = FALSE
		return
	var/vitae_yield = 1 //A bit of essence even if it's a weak soul
	var/vitae_information = "<span class='umbra'>This soul is "
	if(ishuman(L))
		vitae_information += "human, "
		vitae_yield += rand(10, 15)
	if(L.mind)
		if(!(L.mind in ticker.mode.devils))
			vitae_information += "sentient, "
		else
			vitae_information += "infernal and home to multiple souls, all of which you can drain! Moving on... it's "
			for(var/i in 1 to (L.mind.devilinfo.soulsOwned.len))
				vitae_yield += rand(5, 10) //You can drain all the souls that a devil has stolen!
		vitae_yield += rand(10, 15)
	if(L.stat == UNCONSCIOUS)
		vitae_information += "blazing with vitality, "
		vitae_yield += rand(20, 25) //Significant bonus if the target is in critical condition instead of dead
	else if(L.stat == DEAD)
		vitae_information += "dim but still usable, "
		vitae_yield += rand(1, 10)
	vitae_information += "and ready for harvest. You'll absorb around [vitae_yield] vitae - "
	switch(vitae_yield)
		if(0 to 15)
			vitae_information += "not much, but everything counts."
		if(15 to 30)
			vitae_information += "decent, but not great."
		if(30 to 45)
			vitae_information += "about what you could expect."
		if(45 to 60)
			vitae_information += "a good bit, more than you've come to expect."
		if(75 to vitae_cap)
			vitae_information += "<i>a bounty, more than you could ever dream of!</i>"
	vitae_information += " Now, for the harvest...</span>"
	src << vitae_information
	if(!do_after(src, 30, target = L))
		harvesting = FALSE
		return
	if(L.hellbound)
		src << "<span class='warning'>[L] seems to have lost their soul!</span>"
		harvesting = FALSE
		return
	if(!L.stat)
		src << "<span class='warning'>[L] is conscious again and shields your efforts!</span>"
		L << "<span class='warning'>A chill runs across your body.</span>"
		harvesting = FALSE
		return
	Stun(50)
	Reveal(50)
	visible_message("<span class='warning'>[src] flickers into existence and reaches out towards [L]...</span>")
	L.visible_message("<span class='warning'>...who rises into the air, shuddering as purple light streams towards out of their body!</span>")
	animate(L, pixel_y = pixel_y + 5, time = 10)
	Beam(L, icon_state = "drain_life", icon = 'icons/effects/effects.dmi', time = 50)
	sleep(50)
	adjust_vitae(vitae_yield, FALSE, "[L]. They won't yield any more for the time being")
	recently_drained |= L
	visible_message("<span class='warning'>[src] winks out of existence, releasing its hold on [L]...</span>")
	L.visible_message("<span class='warning'>...who falls unceremoniously back to the ground.</span>")
	animate(L, pixel_y = pixel_y - 5, time = 10)
	addtimer(src, "harvest_cooldown", rand(UMBRA_MAX_HARVEST_COOLDOWN - 600, UMBRA_MAX_HARVEST_COOLDOWN), L)
	harvesting = FALSE
	return 1

/mob/living/simple_animal/umbra/proc/harvest_cooldown(mob/living/L) //After a while, mobs that have already been drained can be harvested again
	if(!L)
		return
	src << "<span class='umbra'>You think that [L]'s soul should be strong enough to harvest again.</span>"
	recently_drained -= L


/mob/living/simple_animal/umbra/proc/Reveal(time) //Makes the umbra visible for the designated amount of deciseconds
	if(!time)
		return
	src << "<span class='warning'>You've become visible!</span>"
	alpha = 255
	invisibility = FALSE
	spawn(time)
		alpha = initial(alpha)
		src << "<span class='umbra'>You've become invisible again!</span>"
		invisibility = UMBRA_INVISIBILITY

/mob/living/simple_animal/umbra/Stun(time) //Immobilizes the umbra for the designated amount of deciseconds
	if(!time)
		return
	src << "<span class='warning'>You can't move!</span>"
	notransform = TRUE
	spawn(time)
		src << "<span class='umbra'>You can move again!</span>"
		notransform = FALSE
