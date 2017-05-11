//Revenants: based off of wraiths from Goon
//"Ghosts" that are invisible and move like ghosts, cannot take damage while invisible
//Don't hear deadchat and are NOT normal ghosts
//Admin-spawn or random event

#define INVISIBILITY_REVENANT 50

/mob/living/simple_animal/revenant
	name = "revenant"
	desc = "A malevolent spirit."
	icon = 'icons/mob/mob.dmi'
	icon_state = "revenant_idle"
	var/icon_idle = "revenant_idle"
	var/icon_reveal = "revenant_revealed"
	var/icon_stun = "revenant_stun"
	var/icon_drain = "revenant_draining"
	var/stasis = 0
	incorporeal_move = 3
	invisibility = INVISIBILITY_REVENANT
	health = INFINITY //Revenants don't use health, they use essence instead
	maxHealth = INFINITY
	layer = GHOST_LAYER
	healable = FALSE
	sight = SEE_SELF

	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	response_help   = "passes through"
	response_disarm = "swings through"
	response_harm   = "punches through"
	unsuitable_atmos_damage = 0
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0) //I don't know how you'd apply those, but revenants no-sell them anyway.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	harm_intent_damage = 0
	friendly = "touches"
	status_flags = 0
	wander = FALSE
	density = FALSE
	movement_type = FLYING
	anchored = TRUE
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	speed = 1
	unique_name = TRUE
	hud_possible = list(ANTAG_HUD)

	var/essence = 75 //The resource, and health, of revenants.
	var/essence_regen_cap = 75 //The regeneration cap of essence (go figure); regenerates every Life() tick up to this amount.
	var/essence_regenerating = TRUE //If the revenant regenerates essence or not
	var/essence_regen_amount = 5 //How much essence regenerates
	var/essence_accumulated = 0 //How much essence the revenant has stolen
	var/revealed = FALSE //If the revenant can take damage from normal sources.
	var/unreveal_time = 0 //How long the revenant is revealed for, is about 2 seconds times this var.
	var/unstun_time = 0 //How long the revenant is stunned for, is about 2 seconds times this var.
	var/inhibited = FALSE //If the revenant's abilities are blocked by a chaplain's power.
	var/essence_drained = 0 //How much essence the revenant will drain from the corpse it's feasting on.
	var/draining = FALSE //If the revenant is draining someone.
	var/list/drained_mobs = list() //Cannot harvest the same mob twice
	var/perfectsouls = 0 //How many perfect, regen-cap increasing souls the revenant has. //TODO, add objective for getting a perfect soul(s?)
	var/generated_objectives_and_spells = FALSE

/mob/living/simple_animal/revenant/Login()
	..()
	to_chat(src, "<span class='deadsay'><font size=3><b>You are a revenant.</b></font></span>")
	to_chat(src, "<b>Your formerly mundane spirit has been infused with alien energies and empowered into a revenant.</b>")
	to_chat(src, "<b>You are not dead, not alive, but somewhere in between. You are capable of limited interaction with both worlds.</b>")
	to_chat(src, "<b>You are invincible and invisible to everyone but other ghosts. Most abilities will reveal you, rendering you vulnerable.</b>")
	to_chat(src, "<b>To function, you are to drain the life essence from humans. This essence is a resource, as well as your health, and will power all of your abilities.</b>")
	to_chat(src, "<b><i>You do not remember anything of your past lives, nor will you remember anything about this one after your death.</i></b>")
	to_chat(src, "<b>Be sure to read the wiki page at https://tgstation13.org/wiki/Revenant to learn more.</b>")
	if(!generated_objectives_and_spells)
		generated_objectives_and_spells = TRUE
		mind.remove_all_antag()
		mind.wipe_memory()
		src << 'sound/effects/ghost.ogg'
		var/datum/objective/revenant/objective = new
		objective.owner = mind
		mind.objectives += objective
		to_chat(src, "<b>Objective #1</b>: [objective.explanation_text]")
		var/datum/objective/revenantFluff/objective2 = new
		objective2.owner = mind
		mind.objectives += objective2
		to_chat(src, "<b>Objective #2</b>: [objective2.explanation_text]")
		mind.assigned_role = "revenant"
		mind.special_role = "Revenant"
		SSticker.mode.traitors |= mind //Necessary for announcing
		AddSpell(new /obj/effect/proc_holder/spell/targeted/night_vision/revenant(null))
		AddSpell(new /obj/effect/proc_holder/spell/targeted/revenant_transmit(null))
		AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/defile(null))
		AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/overload(null))
		AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/blight(null))
		AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/revenant/malfunction(null))

//Life, Stat, Hud Updates, and Say
/mob/living/simple_animal/revenant/Life()
	if(stasis)
		return
	if(revealed && essence <= 0)
		death()
	if(unreveal_time && world.time >= unreveal_time)
		unreveal_time = 0
		revealed = FALSE
		incorporeal_move = 3
		invisibility = INVISIBILITY_REVENANT
		to_chat(src, "<span class='revenboldnotice'>You are once more concealed.</span>")
	if(unstun_time && world.time >= unstun_time)
		unstun_time = 0
		notransform = FALSE
		to_chat(src, "<span class='revenboldnotice'>You can move again!</span>")
	if(essence_regenerating && !inhibited && essence < essence_regen_cap) //While inhibited, essence will not regenerate
		essence = min(essence_regen_cap, essence+essence_regen_amount)
		update_action_buttons_icon() //because we update something required by our spells in life, we need to update our buttons
	update_spooky_icon()
	update_health_hud()
	..()

/mob/living/simple_animal/revenant/Stat()
	..()
	if(statpanel("Status"))
		stat(null, "Current essence: [essence]/[essence_regen_cap]E")
		stat(null, "Stolen essence: [essence_accumulated]E")
		stat(null, "Stolen perfect souls: [perfectsouls]")

/mob/living/simple_animal/revenant/update_health_hud()
	if(hud_used)
		var/essencecolor = "#8F48C6"
		if(essence > essence_regen_cap)
			essencecolor = "#9A5ACB" //oh boy you've got a lot of essence
		else if(!essence)
			essencecolor = "#1D2953" //oh jeez you're dying
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[essencecolor]'>[essence]E</font></div>"

/mob/living/simple_animal/revenant/med_hud_set_health()
	return //we use no hud

/mob/living/simple_animal/revenant/med_hud_set_status()
	return //we use no hud

/mob/living/simple_animal/revenant/say(message)
	if(!message)
		return
	log_say("[key_name(src)] : [message]")
	var/rendered = "<span class='revennotice'><b>[src]</b> says, \"[message]\"</span>"
	for(var/mob/M in GLOB.mob_list)
		if(isrevenant(M))
			to_chat(M, rendered)
		else if(isobserver(M))
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [rendered]")
	return


//Immunities
/mob/living/simple_animal/revenant/Process_Spacemove(movement_dir = 0)
	return 1

/mob/living/simple_animal/revenant/ex_act(severity, target)
	return 1 //Immune to the effects of explosions.

/mob/living/simple_animal/revenant/blob_act(obj/structure/blob/B)
	return //blah blah blobs aren't in tune with the spirit world, or something.

/mob/living/simple_animal/revenant/singularity_act()
	return //don't walk into the singularity expecting to find corpses, okay?

/mob/living/simple_animal/revenant/narsie_act()
	return //most humans will now be either bones or harvesters, but we're still un-alive.

/mob/living/simple_animal/revenant/ratvar_act()
	return //clocks get out reee

//damage, gibbing, and dying
/mob/living/simple_animal/revenant/attackby(obj/item/W, mob/living/user, params)
	. = ..()
	if(istype(W, /obj/item/weapon/nullrod))
		visible_message("<span class='warning'>[src] violently flinches!</span>", \
						"<span class='revendanger'>As \the [W] passes through you, you feel your essence draining away!</span>")
		adjustBruteLoss(25) //hella effective
		inhibited = TRUE
		update_action_buttons_icon()
		addtimer(CALLBACK(src, .proc/reset_inhibit), 30)

/mob/living/simple_animal/revenant/proc/reset_inhibit()
	inhibited = FALSE
	update_action_buttons_icon()

/mob/living/simple_animal/revenant/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	if(!forced && !revealed)
		return FALSE
	. = amount
	essence = max(0, essence-amount)
	if(updating_health)
		update_health_hud()
	if(!essence)
		death()

/mob/living/simple_animal/revenant/dust()
	death()

/mob/living/simple_animal/revenant/gib()
	death()

/mob/living/simple_animal/revenant/death()
	if(!revealed || stasis) //Revenants cannot die if they aren't revealed //or are already dead
		return 0
	to_chat(src, "<span class='revendanger'>NO! No... it's too late, you can feel your essence [pick("breaking apart", "drifting away")]...</span>")
	notransform = TRUE
	revealed = TRUE
	invisibility = 0
	playsound(src, 'sound/effects/screech.ogg', 100, 1)
	visible_message("<span class='warning'>[src] lets out a waning screech as violet mist swirls around its dissolving body!</span>")
	icon_state = "revenant_draining"
	for(var/i = alpha, i > 0, i -= 10)
		stoplag()
		alpha = i
	visible_message("<span class='danger'>[src]'s body breaks apart into a fine pile of blue dust.</span>")
	var/reforming_essence = essence_regen_cap //retain the gained essence capacity
	var/obj/item/weapon/ectoplasm/revenant/R = new(get_turf(src))
	R.essence = max(reforming_essence - 15 * perfectsouls, 75) //minus any perfect souls
	R.client_to_revive = client //If the essence reforms, the old revenant is put back in the body
	R.revenant = src
	invisibility = INVISIBILITY_ABSTRACT 
	revealed = 0
	stasis = 1
	ghostize(0)//Don't re-enter invisible corpse
	return


//reveal, stun, icon updates, cast checks, and essence changing
/mob/living/simple_animal/revenant/proc/reveal(time)
	if(!src)
		return
	if(time <= 0)
		return
	revealed = TRUE
	invisibility = 0
	incorporeal_move = 0
	if(!unreveal_time)
		to_chat(src, "<span class='revendanger'>You have been revealed!</span>")
		unreveal_time = world.time + time
	else
		to_chat(src, "<span class='revenwarning'>You have been revealed!</span>")
		unreveal_time = unreveal_time + time
	update_spooky_icon()

/mob/living/simple_animal/revenant/proc/stun(time)
	if(!src)
		return
	if(time <= 0)
		return
	notransform = TRUE
	if(!unstun_time)
		to_chat(src, "<span class='revendanger'>You cannot move!</span>")
		unstun_time = world.time + time
	else
		to_chat(src, "<span class='revenwarning'>You cannot move!</span>")
		unstun_time = unstun_time + time
	update_spooky_icon()

/mob/living/simple_animal/revenant/proc/update_spooky_icon()
	if(revealed)
		if(notransform)
			if(draining)
				icon_state = icon_drain
			else
				icon_state = icon_stun
		else
			icon_state = icon_reveal
	else
		icon_state = icon_idle

/mob/living/simple_animal/revenant/proc/castcheck(essence_cost)
	if(!src)
		return
	var/turf/T = get_turf(src)
	if(isclosedturf(T))
		to_chat(src, "<span class='revenwarning'>You cannot use abilities from inside of a wall.</span>")
		return FALSE
	for(var/obj/O in T)
		if(O.density && !O.CanPass(src, T, 5))
			to_chat(src, "<span class='revenwarning'>You cannot use abilities inside of a dense object.</span>")
			return FALSE
	if(inhibited)
		to_chat(src, "<span class='revenwarning'>Your powers have been suppressed by nulling energy!</span>")
		return FALSE
	if(!change_essence_amount(essence_cost, TRUE))
		to_chat(src, "<span class='revenwarning'>You lack the essence to use that ability.</span>")
		return FALSE
	return TRUE

/mob/living/simple_animal/revenant/proc/change_essence_amount(essence_amt, silent = FALSE, source = null)
	if(!src)
		return
	if(essence + essence_amt <= 0)
		return
	essence = max(0, essence+essence_amt)
	update_action_buttons_icon()
	update_health_hud()
	if(essence_amt > 0)
		essence_accumulated = max(0, essence_accumulated+essence_amt)
	if(!silent)
		if(essence_amt > 0)
			to_chat(src, "<span class='revennotice'>Gained [essence_amt]E[source ? " from [source]":""].</span>")
		else
			to_chat(src, "<span class='revenminor'>Lost [essence_amt]E[source ? " from [source]":""].</span>")
	return 1

/mob/living/simple_animal/revenant/proc/death_reset()
	revealed = FALSE
	unreveal_time = 0 
	notransform = 0
	unstun_time = 0
	inhibited = FALSE
	draining = FALSE
	incorporeal_move = 3
	invisibility = INVISIBILITY_REVENANT
	alpha=255
	stasis = 0


//reforming
/obj/item/weapon/ectoplasm/revenant
	name = "glimmering residue"
	desc = "A pile of fine blue dust. Small tendrils of violet mist swirl around it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "revenantEctoplasm"
	w_class = WEIGHT_CLASS_SMALL
	var/essence = 75 //the maximum essence of the reforming revenant
	var/reforming = TRUE
	var/inert = FALSE
	var/client/client_to_revive
	var/mob/living/simple_animal/revenant/revenant

/obj/item/weapon/ectoplasm/revenant/New()
	..()
	addtimer(CALLBACK(src, .proc/try_reform), 600)

/obj/item/weapon/ectoplasm/revenant/proc/scatter()
	qdel(src)

/obj/item/weapon/ectoplasm/revenant/proc/try_reform()
	if(reforming)
		reforming = FALSE
		reform()
	else
		inert = TRUE
		visible_message("<span class='warning'>[src] settles down and seems lifeless.</span>")

/obj/item/weapon/ectoplasm/revenant/attack_self(mob/user)
	if(!reforming || inert)
		return ..()
	user.visible_message("<span class='notice'>[user] scatters [src] in all directions.</span>", \
						 "<span class='notice'>You scatter [src] across the area. The particles slowly fade away.</span>")
	user.drop_item()
	scatter()

/obj/item/weapon/ectoplasm/revenant/throw_impact(atom/hit_atom)
	..()
	if(inert)
		return
	visible_message("<span class='notice'>[src] breaks into particles upon impact, which fade away to nothingness.</span>")
	scatter()

/obj/item/weapon/ectoplasm/revenant/examine(mob/user)
	..()
	if(inert)
		to_chat(user, "<span class='revennotice'>It seems inert.</span>")
	else if(reforming)
		to_chat(user, "<span class='revenwarning'>It is shifting and distorted. It would be wise to destroy this.</span>")

/obj/item/weapon/ectoplasm/revenant/proc/reform()
	if(QDELETED(src) || QDELETED(revenant) || inert)
		return
	var/key_of_revenant
	message_admins("Revenant ectoplasm was left undestroyed for 1 minute and is reforming into a new revenant.")
	loc = get_turf(src) //In case it's in a backpack or someone's hand
	revenant.forceMove(loc)
	if(client_to_revive)
		for(var/mob/M in GLOB.dead_mob_list)
			if(M.client == client_to_revive) //Only recreates the mob if the mob the client is in is dead
				revenant.client = client_to_revive
				key_of_revenant = client_to_revive.key
	if(!key_of_revenant)
		message_admins("The new revenant's old client either could not be found or is in a new, living mob - grabbing a random candidate instead...")
		var/list/candidates = pollCandidatesForMob("Do you want to be [revenant.name] (reforming)?", "revenant", null, ROLE_REVENANT, 50, revenant)
		if(!candidates.len)
			qdel(revenant)
			message_admins("No candidates were found for the new revenant. Oh well!")
			inert = TRUE
			visible_message("<span class='revenwarning'>[src] settles down and seems lifeless.</span>")
			return
		var/client/C = pick(candidates)
		revenant.client = C
		key_of_revenant = C.key
		if(!key_of_revenant)
			qdel(revenant)
			message_admins("No ckey was found for the new revenant. Oh well!")
			inert = TRUE
			visible_message("<span class='revenwarning'>[src] settles down and seems lifeless.</span>")
			return

	message_admins("[key_of_revenant] has been [client_to_revive ? "re":""]made into a revenant by reforming ectoplasm.")
	log_game("[key_of_revenant] was [client_to_revive ? "re":""]made as a revenant by reforming ectoplasm.")
	visible_message("<span class='revenboldnotice'>[src] suddenly rises into the air before fading away.</span>")

	revenant.essence = essence
	revenant.essence_regen_cap = essence
	revenant.death_reset()
	revenant.key = key_of_revenant
	revenant = null
	qdel(src)

/obj/item/weapon/ectoplasm/revenant/Destroy()
	if(!QDELETED(revenant))
		qdel(revenant)
	..()

//objectives
/datum/objective/revenant
	dangerrating = 10
	var/targetAmount = 100

/datum/objective/revenant/New()
	targetAmount = rand(350,600)
	explanation_text = "Absorb [targetAmount] points of essence from humans."
	..()

/datum/objective/revenant/check_completion()
	if(!isrevenant(owner.current))
		return FALSE
	var/mob/living/simple_animal/revenant/R = owner.current
	if(!R || R.stat == DEAD)
		return FALSE
	var/essence_stolen = R.essence_accumulated
	if(essence_stolen < targetAmount)
		return FALSE
	return TRUE

/datum/objective/revenantFluff
	dangerrating = 0

/datum/objective/revenantFluff/New()
	var/list/explanationTexts = list("Assist and exacerbate existing threats at critical moments.", \
									 "Avoid killing in plain sight.", \
									 "Cause as much chaos and anger as you can without being killed.", \
									 "Damage and render as much of the station rusted and unusable as possible.", \
									 "Disable and cause malfunctions in as many machines as possible.", \
									 "Ensure that any holy weapons are rendered unusable.", \
									 "Hinder the crew while attempting to avoid being noticed.", \
									 "Make the crew as miserable as possible.", \
									 "Make the clown as miserable as possible.", \
									 "Make the captain as miserable as possible.", \
									 "Prevent the use of energy weapons where possible.")
	explanation_text = pick(explanationTexts)
	..()

/datum/objective/revenantFluff/check_completion()
	return TRUE
