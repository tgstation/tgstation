#define UMBRA_INVISIBILITY 50
#define UMBRA_VITAE_DRAIN_RATE 0.01 //How much vitae is drained per tick to sustain the umbra. Set this to higher values to make umbras need to harvest vitae more often.
#define UMBRA_MAX_HARVEST_COOLDOWN 3000 //In deciseconds, how long it takes for a harvested target to become eligible for draining again.
#define UMBRA_POSSESSION_THRESHOLD_WARNING 60 //In ticks, how long it takes before a possessed human starts showing signs of possession
#define UMBRA_POSSESSION_THRESHOLD_DANGER 150 //In ticks, how long it takes before a possessed human starts forcing out the umbra
#define UMBRA_POSSESSION_THRESHOLD_FORCED_OUT 155 //In ticks, how long it takes before a possessed human forces out the umbra

/*

Umbras are residual entities created by the dying who possess enough anger or determination that they never fully pass on.
Physically, they're incorporeal and invisible. Umbras are formed of a steadily-decaying electromagnetic field with a drive to sustain itself.
Umbras do this by feeding on a substance, found in the dead or dying, known as vitae.

Vitae is most closely comparable to adrenaline in that is produced by creatures at times of distress. For this reason, almost all dead creatures have vitae in one way or another.
Biologically, it's indistinguishable from normal blood, but vitae is what allows creatures to survive grievous wounds or cling to life in critical condition. It provides a large amount of energy.
It's for this reason that umbras desire it. Vitae serves as a potent energy source to a living thing, and umbras can use the energy of this vitae to sustain themselves.
Without enough vitae, the field that sustains an umbra will break down and weaken. If the umbra has no vitae at all, it will permanently dissipate.

Umbras are not without their weaknesses. Despite being invisible to the naked eye and untouchable, certain things can restrict, weaken, or outright harm them.
Piles of salt on the ground will prevent an umbra's passage, making areas encircled in it completely inaccessible to even the most determined umbra.
In addition, objects and artifacts of a holy nature can force an umbra to manifest or draw away some of the energy that it's gleaned through vitae.

When an umbra dies, two things can occur. If the umbra died from passive vitae drain, it will be dead forever, with no way to bring it back.
However, if the umbra is slain forcibly and still has vitae, the vitae possesses enough power to coalesce a part of the umbra into umbral ashes.
These "ashes" will, given around a full minute, re-form into another umbra. This umbra typically possesses the memories and consciousness of the old one, but may be a completely new mind as well.
Although these umbral ashes make umbras resilient, they can be killed permanently by scattering the ashes or destroying them, thus separating the vitae from the umbra's remains.

*/

/mob/living/simple_animal/umbra
	name = "umbra"
	real_name = "umbra"
	unique_name = TRUE
	gender = NEUTER
	desc = "A translucent, cobalt-blue apparition floating several feet in the air."
	invisibility = UMBRA_INVISIBILITY
	icon = 'icons/mob/mob.dmi'
	icon_state = "umbra"
	icon_living = "umbra"
	layer = GHOST_LAYER
	alpha = 175 //To show invisibility
	health = 100
	maxHealth = 100
	healable = FALSE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	friendly = "passes through"
	speak_emote = list("murmurs")
	emote_hear = list("murmurs")
	languages_spoken = ALL
	languages_understood = ALL
	status_flags = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	incorporeal_move = 3
	flying = TRUE
	wander = FALSE
	stop_automated_movement = TRUE
	mob_size = MOB_SIZE_TINY
	anchored = TRUE
	density = FALSE
	sight = SEE_SELF
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	see_in_dark = 8
	var/vitae = 10 //The amount of vitae captured by the umbra
	var/vitae_cap = 100 //How much vitae a single umbra can hold
	var/breaking_apart = FALSE //If the umbra is currently dying
	var/harvesting = FALSE //If the umbra is harvesting a soul
	var/list/recently_drained = list() //Mobs that have been drained in the last five minutes by the umbra
	var/list/total_drained = list() //Mobs that have been drained, period
	var/mob/living/carbon/human/possessed //The human that an umbra is inside of, if applicable
	var/time_possessing = 0 //How long an umbra has been in possession of a single target.
	var/list/lobotomized = list() //Mobs that have had their memories stolen by the umbra
	var/image/ghost_image //So ghosts can see the umbra in the dark
	var/playstyle_string = "<span class='umbra_large'><b>You are an umbra,</b></span><b> and you aren't quite sure how you're alive. You don't remember much, but you remember slipping away, \
	lsoing your hold on life. You died, but here you are... somehow. You can't be quite sure how this happened, but you're pretty sure that it won't last long. Already you feel this strange \
	form of life weakening. You need to find a way to sustain yourself, and you think you might have an idea.\n\
	\n\
	You seem to be invisible and incorporeal, so you don't think that anyone can see, feel, or otherwise perceive you right now, but there has to be some way that you managed not to just fully \
	die and instead ended up like this. You think that if you find a corpse, or perhaps someone still alive but in critical condition, you'd be able to drain whatever kept you in this state \
	from them. At first the idea sounds horrible - stealing their very life force - but as you continue to weaken it sounds more and more appealing... you think it'd be as simple as interacting \
	with them. Something in the back of your mind tells you to call this life force <i>vitae</i>.\n\
	\n\
	In any case, you can definitely feel something else. You feel partially alive, but partially dead. Perhaps somewhere in between. Nonetheless, you might be able to influence both realms. \
	You can see clearly in the dark, and you seem to have a sort of limited telepathic capabilities, plus some other things. You'll have to experiment with your new form to find out what you \
	exactly you can do."


//Creation, destruction, life, and death
/mob/living/simple_animal/umbra/New()
	..()
	ghost_image = image(icon, src, icon_state)
	ghost_darkness_images |= ghost_image
	updateallghostimages()
	if(prob(1))
		name = "grief ghost"
		real_name = "grief ghost"
		desc = "You wonder how something that produces so much salt can be weak to it."
	AddSpell(new/obj/effect/proc_holder/spell/targeted/night_vision/umbra(null))
	AddSpell(new/obj/effect/proc_holder/spell/targeted/discordant_whisper(null))
	AddSpell(new/obj/effect/proc_holder/spell/targeted/possess(null))
	AddSpell(new/obj/effect/proc_holder/spell/targeted/thoughtsteal(null))

/mob/living/simple_animal/umbra/Life()
	..()
	if(!possessed)
		adjust_vitae(-UMBRA_VITAE_DRAIN_RATE, TRUE, "passive drain")
		time_possessing = 0
	else
		if(possessed.reagents && possessed.reagents.has_reagent("sodiumchloride"))
			unpossess(TRUE)
			visible_message("<span class='warning'>[src] appears from nowhere, twitching and flickering!</span>", "<span class='userdanger'>AAAH! SALT!</span>")
			immobilize(30)
			reveal(50)
			return
		if(possessed.stat == DEAD)
			unpossess()
			return
		adjust_vitae(UMBRA_VITAE_DRAIN_RATE, TRUE, "passive gain")
		time_possessing++
		switch(time_possessing)
			if(0 to UMBRA_POSSESSION_THRESHOLD_WARNING)
				if(prob(1))
					possessed << "<span class='warning'>You feel [pick("watched", "not wholly yourself", "an intense craving for salt", "singularly odd", \
					"a horrible dread in your heart")].</span>"
			if(UMBRA_POSSESSION_THRESHOLD_WARNING to UMBRA_POSSESSION_THRESHOLD_DANGER)
				if(prob(2))
					possessed << "<span class='warning'>[pick("Another mind briefly touches yours, then fades", "Your vision briefly flares violet", "You feel a brief pain in your chest", \
					"A murmur from within your mind, too quiet to understand", "You become uneasy for no explainable reason")].</span>"
				if(prob(5))
					possessed.emote("twitch")
			if(UMBRA_POSSESSION_THRESHOLD_DANGER to UMBRA_POSSESSION_THRESHOLD_FORCED_OUT)
				possessed << "<span class='userdanger'>GET OUT GET OUT GET OUT</span>"
				possessed.confused = max(3, possessed.confused)
				possessed.emote(pick("moan", "groan", "shiver", "twitch", "cry"))
				flash_color(possessed, flash_color = "#5000A0", flash_time = 10)
			if(UMBRA_POSSESSION_THRESHOLD_FORCED_OUT to INFINITY)
				src << "<span class='userdanger'>You can't stay any longer - you retreat from [possessed]'s body!</span>"
				unpossess(TRUE)
				return
		if(time_possessing == UMBRA_POSSESSION_THRESHOLD_WARNING)
			src << "<span class='warning'>[possessed] is starting to catch on to your presence. Be wary.</span>"
		else if(time_possessing == UMBRA_POSSESSION_THRESHOLD_DANGER)
			src << "<span class='userdanger'>[possessed] has noticed your presence and is forcing you out!</span>"
			possessed << "<span class='userdanger'>There's something in your head! You start trying to force it out--</span>"
		else if(time_possessing == UMBRA_POSSESSION_THRESHOLD_FORCED_OUT)
			src << "<span class='userdanger'>You can't stay any longer! You flee from [possessed]...</span>"
			unpossess()
	adjustBruteLoss(-1) //Vitae slowly heals the umbra as well
	adjustFireLoss(-1)
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
		if(possessed)
			stat(null, "Time in [possessed]: [time_possessing]/[UMBRA_POSSESSION_THRESHOLD_FORCED_OUT]")

/mob/living/simple_animal/umbra/death()
	if(breaking_apart)
		return
	..(1)
	unpossess(TRUE)
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
		var/obj/item/umbral_ashes/P = new(get_turf(src))
		P.umbra_key = key
		P.umbra_vitae = vitae
	else
		visible_message("<span class='warning'>[src] breaks apart and fades away!</span>")
	qdel(src)

/mob/living/simple_animal/umbra/proc/reveal(time, silent) //Makes the umbra visible for the designated amount of deciseconds
	if(!time)
		return
	if(!silent)
		src << "<span class='warning'>You've become visible!</span>"
	alpha = 255
	invisibility = FALSE
	spawn(time)
		alpha = initial(alpha)
		if(!silent)
			src << "<span class='umbra'>You've become invisible again!</span>"
		invisibility = UMBRA_INVISIBILITY

/mob/living/simple_animal/umbra/proc/immobilize(time, silent) //Immobilizes the umbra for the designated amount of deciseconds
	if(!time)
		return
	if(!silent)
		src << "<span class='warning'>You can't move!</span>"
	notransform = TRUE
	spawn(time)
		if(!silent)
			src << "<span class='umbra'>You can move again!</span>"
		if(!possessed) //To ensure that umbras don't escape their quarry
			notransform = FALSE


//Actions and interaction
/mob/living/simple_animal/umbra/say() //Umbras can't directly speak
	src << "<span class='warning'>You lack the power to speak out loud! Use Discordant Whisper instead.</span>"
	return

/mob/living/simple_animal/umbra/attack_ghost(mob/dead/observer/O)
	if(key)
		return
	if(alert(O, "Become an umbra? You won't be clonable!",,"Yes", "No") == "No" || !O)
		return
	occupy(O)
	notify_ghosts("The umbra at [get_area(src)] has been taken control of by [O].", source = src, action = NOTIFY_ORBIT)
	src << playstyle_string

/mob/living/simple_animal/umbra/ClickOn(atom/A, params)
	A.examine(src)
	if(isliving(A) && Adjacent(A))
		var/mob/living/L = A
		if(L.health > 0 && L.stat != DEAD)
			src << "<span class='warning'>[L] has no vitae to drain!</span>"
			return
		else if(L in recently_drained)
			src << "<span class='warning'>[L]'s body is still recuperating! You can't risk draining any more vitae!</span>"
			return
		else if(harvesting)
			src << "<span class='warning'>You're already trying to harvest vitae!</span>"
			return
		harvest_vitae(L)

/mob/living/simple_animal/umbra/proc/harvest_vitae(mob/living/L) //How umbras drain vitae from their targets
	if(!L || L.health || L in recently_drained)
		return
	harvesting = TRUE
	src << "<span class='umbra'>You search for any vitae in [L]...</span>"
	if(!do_after(src, 30, target = L))
		harvesting = FALSE
		return
	if(L.hellbound)
		src << "<span class='warning'>[L] seems to be incapable of producing vitae!</span>"
		harvesting = FALSE
		return
	if(!L.stat)
		src << "<span class='warning'>[L] is conscious again and their vitae is receding!</span>"
		L << "<span class='warning'>You're being watched.</span>"
		harvesting = FALSE
		return
	var/vitae_yield = 1 //A bit of essence even if it's a weak soul
	var/vitae_information = "<span class='umbra'>[L]'s vitae is "
	if(ishuman(L))
		vitae_information += "of the highest quality, "
		vitae_yield += rand(10, 15)
	if(L.mind)
		if(!(L.mind in ticker.mode.devils))
			vitae_information += "in copious amounts, "
		else
			vitae_information += "coming from multiple sources, "
			for(var/i in 1 to (L.mind.devilinfo.soulsOwned.len))
				vitae_yield += rand(5, 10) //You can drain all the souls that a devil has stolen!
		vitae_yield += rand(10, 15)
	if(L.stat == UNCONSCIOUS)
		vitae_information += "still being produced, "
		vitae_yield += rand(20, 25) //Significant bonus if the target is in critical condition instead of dead
	else if(L.stat == DEAD)
		vitae_information += "stagnant, "
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
	vitae_information += " Now, then...</span>"
	src << vitae_information
	if(!do_after(src, 30, target = L))
		harvesting = FALSE
		return
	if(L.hellbound)
		src << "<span class='warning'>[L] seems to have lost their vitae!</span>"
		harvesting = FALSE
		return
	if(!L.stat)
		src << "<span class='warning'>[L] is conscious again and their vitae is receding!</span>"
		L << "<span class='warning'>A chill runs across your body.</span>"
		harvesting = FALSE
		return
	immobilize(50)
	reveal(50)
	visible_message("<span class='warning'>[src] flickers into existence and reaches out towards [L]...</span>")
	L.visible_message("<span class='warning'>...who rises into the air, shuddering as purple light streams out of their body!</span>")
	animate(L, pixel_y = 5, time = 10)
	Beam(L, icon_state = "drain_life", icon = 'icons/effects/effects.dmi', time = 50)
	sleep(50)
	adjust_vitae(vitae_yield, FALSE, "[L]. They won't yield any more for the time being")
	recently_drained |= L
	total_drained |= L
	visible_message("<span class='warning'>[src] winks out of existence, releasing its hold on [L]...</span>")
	L.visible_message("<span class='warning'>...who falls unceremoniously back to the ground.</span>")
	animate(L, pixel_y = 0, time = 10)
	addtimer(src, "harvest_cooldown", rand(UMBRA_MAX_HARVEST_COOLDOWN - 600, UMBRA_MAX_HARVEST_COOLDOWN), L)
	harvesting = FALSE
	return 1

/mob/living/simple_animal/umbra/proc/harvest_cooldown(mob/living/L) //After a while, mobs that have already been drained can be harvested again
	if(!L)
		return
	src << "<span class='umbra'>You think that [L]'s body should be strong enough to produce vitae again.</span>"
	recently_drained -= L

/mob/living/simple_animal/umbra/singularity_act() //Umbras are immune to most things that are catastrophic to normal humans
	return

/mob/living/simple_animal/umbra/narsie_act()
	return

/mob/living/simple_animal/umbra/ratvar_act()
	return

/mob/living/simple_animal/umbra/blob_act(obj/effect/blob/B)
	return

/mob/living/simple_animal/umbra/ex_act(severity)
	return

/mob/living/simple_animal/umbra/emp_act(severity)
	src << "<span class='umbra_bold'>You feel the energy of an electromagnetic pulse revitalizing you!</span>" //As they're composed of an EM field, umbras are strengthened by EMPs
	adjust_vitae(50 - (severity * 10), TRUE)


//Helper procs
/mob/living/simple_animal/umbra/proc/adjust_vitae(amount, silent, source)
	vitae = min(max(0, vitae + amount), vitae_cap)
	if(!silent)
		src << "<span class='umbra'>[amount > 0 ? "Gained" : "Lost"] [amount] vitae[source ? " from [source]" : ""].</span>"
	return vitae

/mob/living/simple_animal/umbra/proc/unpossess(silent)
	if(!possessed)
		return
	if(!silent)
		src << "<span class='umbra'>You free yourself from [possessed]'s body.</span>"
	if(time_possessing >= UMBRA_POSSESSION_THRESHOLD_WARNING)
		possessed << "<span class='warning'>You feel a horrible presence depart from you...</span>"
	loc = get_turf(possessed)
	possessed = null
	time_possessing = 0
	notransform = FALSE

/mob/living/simple_animal/umbra/proc/occupy(mob/dead/observer/O)
	if(!O)
		return
	if(key)
		O << "<span class='warning'>You were too late! The umbra is occupied.</span>"
		return
	key = O.key
	mind.special_role = "Umbra"
	var/datum/objective/umbra/lobotomize/L = new
	mind.objectives += L
	src << "<b>Objective #1:</b> [L.explanation_text]"
