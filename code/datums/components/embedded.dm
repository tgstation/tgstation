/*
	This component is responsible for handling individual instances of embedded objects. The embeddable element is what allows an item to be embeddable and stores its embedding stats,
	and when it impacts and meets the requirements to stick into something, it instantiates an embedded component. Once the item falls out, the component is destroyed, while the
	element survives to embed another day.

	There are 2 different things that can be embedded presently: humans, and closed turfs (see: walls)

		- Human embedding has all the classical embedding behavior, and tracks more events and signals. The main behaviors and hooks to look for are:
			-- Every process tick, there is a chance to randomly proc pain, controlled by pain_chance. There may also be a chance for the object to fall out randomly, per fall_chance
			-- Every time the mob moves, there is a chance to proc jostling pain, controlled by jostle_chance (and only 50% as likely if the mob is walking or crawling)
			-- Various signals hooking into human topic() and the embed removal surgery in order to handle removals.

		- Turf embedding is much simpler. All we do here is draw an overlay of the item's inhand on the turf, hide the item, and create an HTML link in the turf's inspect
		that allows you to rip the item out. There's nothing dynamic about this, so far less checks.


	In addition, there are 2 cases of embedding: embedding, and sticking

		- Embedding involves harmful and dangerous embeds, whether they cause brute damage, stamina damage, or a mix. This is the default behavior for embeddings, for when something is "pointy"

		- Sticking occurs when an item should not cause any harm while embedding (imagine throwing a sticky ball of tape at someone, rather than a shuriken). An item is considered "sticky"
			when it has 0 for both pain multiplier and jostle pain multiplier. It's a bit arbitrary, but fairly straightforward.

		Stickables differ from embeds in the following ways:
			-- Text descriptors use phrasing like "X is stuck to Y" rather than "X is embedded in Y"
			-- There is no slicing sound on impact
			-- All damage checks and bloodloss are skipped for humans
			-- Pointy objects create sparks when embedding into a turf

*/


/datum/component/embedded
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/obj/item/bodypart/L
	var/obj/item/weapon

	// all of this stuff is explained in _DEFINES/combat.dm
	var/embed_chance // not like we really need it once we're already stuck in but hey
	var/fall_chance
	var/pain_chance
	var/pain_mult
	var/impact_pain_mult
	var/remove_pain_mult
	var/rip_time
	var/ignore_throwspeed_threshold
	var/jostle_chance
	var/jostle_pain_mult
	var/pain_stam_pct

	///if both our pain multiplier and jostle pain multiplier are 0, we're harmless and can omit most of the damage related stuff
	var/harmful
	var/mutable_appearance/overlay

/datum/component/embedded/Initialize(obj/item/I,
			datum/thrownthing/throwingdatum,
			embed_chance = EMBED_CHANCE,
			fall_chance = EMBEDDED_ITEM_FALLOUT,
			pain_chance = EMBEDDED_PAIN_CHANCE,
			pain_mult = EMBEDDED_PAIN_MULTIPLIER,
			remove_pain_mult = EMBEDDED_UNSAFE_REMOVAL_PAIN_MULTIPLIER,
			impact_pain_mult = EMBEDDED_IMPACT_PAIN_MULTIPLIER,
			rip_time = EMBEDDED_UNSAFE_REMOVAL_TIME,
			ignore_throwspeed_threshold = FALSE,
			jostle_chance = EMBEDDED_JOSTLE_CHANCE,
			jostle_pain_mult = EMBEDDED_JOSTLE_PAIN_MULTIPLIER,
			pain_stam_pct = EMBEDDED_PAIN_STAM_PCT)

	if((!ishuman(parent) && !isclosedturf(parent)) || !isitem(I))
		return COMPONENT_INCOMPATIBLE

	src.embed_chance = embed_chance
	src.fall_chance = fall_chance
	src.pain_chance = pain_chance
	src.pain_mult = pain_mult
	src.remove_pain_mult = remove_pain_mult
	src.rip_time = rip_time
	src.impact_pain_mult = impact_pain_mult
	src.ignore_throwspeed_threshold = ignore_throwspeed_threshold
	src.jostle_chance = jostle_chance
	src.jostle_pain_mult = jostle_pain_mult
	src.pain_stam_pct = pain_stam_pct

	src.weapon = I

	if(src.pain_mult || src.jostle_pain_mult)
		harmful = TRUE

	if(ishuman(parent))
		initHuman()
	else if(isclosedturf(parent))
		initTurf(throwingdatum)

/datum/component/embedded/RegisterWithParent()
	if(ishuman(parent))
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, .proc/jostleCheck)
		RegisterSignal(parent, COMSIG_HUMAN_EMBED_RIP, .proc/ripOutHuman)
		RegisterSignal(parent, COMSIG_HUMAN_EMBED_REMOVAL, .proc/safeRemoveHuman)
	else if(isclosedturf(parent))
		RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/examineTurf)

/datum/component/embedded/UnregisterFromParent()
	if(ishuman(parent))
		UnregisterSignal(parent, list(COMSIG_MOVABLE_MOVED, COMSIG_HUMAN_EMBED_RIP, COMSIG_HUMAN_EMBED_REMOVAL))
	else if(isclosedturf(parent))
		UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)

/datum/component/embedded/process()
	if(ishuman(parent))
		processHuman()

/datum/component/embedded/Destroy()
	if(overlay)
		var/atom/A = parent
		A.cut_overlay(overlay, TRUE)
		qdel(overlay)

	return ..()

////////////////////////////////////////
/////////////HUMAN PROCS////////////////
////////////////////////////////////////

/// Set up an instance of embedding for a human. This is basically an extension of Initialize() so not much to say
/datum/component/embedded/proc/initHuman()
	START_PROCESSING(SSdcs, src)
	var/mob/living/carbon/human/victim = parent
	L = pick(victim.bodyparts)
	L.embedded_objects |= weapon // on the inside... on the inside...
	weapon.forceMove(victim)

	if(harmful)
		victim.visible_message("<span class='danger'>[weapon] embeds itself in [victim]'s [L.name]!</span>","<span class='userdanger'>[weapon] embeds itself in your [L.name]!</span>")
		victim.throw_alert("embeddedobject", /obj/screen/alert/embeddedobject)
		playsound(victim,'sound/weapons/bladeslice.ogg', 40)
		weapon.add_mob_blood(victim)//it embedded itself in you, of course it's bloody!
		var/damage = weapon.w_class * impact_pain_mult
		L.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)
		SEND_SIGNAL(victim, COMSIG_ADD_MOOD_EVENT, "embedded", /datum/mood_event/embedded)
	else
		victim.visible_message("<span class='danger'>[weapon] sticks itself to [victim]'s [L.name]!</span>","<span class='userdanger'>[weapon] sticks itself to your [L.name]!</span>")


/// Called every time a human with a harmful embed moves, rolling a chance for the item to cause pain. The chance is halved if the human is crawling or walking.
/datum/component/embedded/proc/jostleCheck()
	var/mob/living/carbon/human/victim = parent

	var/chance = jostle_chance
	if(victim.m_intent == MOVE_INTENT_WALK || victim.lying)
		chance *= 0.5

	if(prob(chance))
		var/damage = weapon.w_class * jostle_pain_mult
		L.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)
		to_chat(victim, "<span class='userdanger'>[weapon] embedded in your [L.name] jostles and stings!</span>")


/// Called when then item randomly falls out of a human. This handles the damage and descriptors, then calls safe_remove()
/datum/component/embedded/proc/fallOutHuman()
	var/mob/living/carbon/human/victim = parent

	if(harmful)
		var/damage = weapon.w_class * remove_pain_mult
		L.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)
		victim.visible_message("<span class='danger'>[weapon] falls out of [victim.name]'s [L.name]!</span>","<span class='userdanger'>[weapon] falls out of your [L.name]!</span>")
	else
		victim.visible_message("<span class='danger'>[weapon] falls off of [victim.name]'s [L.name]!</span>","<span class='userdanger'>[weapon] falls off of your [L.name]!</span>")

	safeRemoveHuman()


/// Called when a human with an object embedded/stuck to them inspects themselves and clicks the appropriate link to begin ripping the item out. This handles the ripping attempt, descriptors, and dealing damage, then calls safe_remove()
/datum/component/embedded/proc/ripOutHuman()
	var/mob/living/carbon/human/victim = parent
	var/time_taken = rip_time * weapon.w_class

	victim.visible_message("<span class='warning'>[victim] attempts to remove [weapon] from [victim.p_their()] [L.name].</span>","<span class='notice'>You attempt to remove [weapon] from your [L.name]... (It will take [DisplayTimeText(time_taken)].)</span>")
	if(do_after(victim, time_taken, target = victim))
		if(!weapon || !L || weapon.loc != victim || !(weapon in L.embedded_objects))
			qdel(src)

		if(harmful)
			var/damage = weapon.w_class * remove_pain_mult
			L.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage) //It hurts to rip it out, get surgery you dingus.
			victim.emote("scream")
			victim.visible_message("<span class='notice'>[victim] successfully rips [weapon] out of [victim.p_their()] [L.name]!</span>", "<span class='notice'>You successfully remove [weapon] from your [L.name].</span>")
		else
			victim.visible_message("<span class='notice'>[victim] successfully rips [weapon] off of [victim.p_their()] [L.name]!</span>", "<span class='notice'>You successfully remove [weapon] from your [L.name].</span>")

		safeRemoveHuman(TRUE)


/// This proc handles the final step and actual removal of an embedded/stuck item from a human, whether or not it was actually removed safely.
/// Pass TRUE for to_hands if we want it to go to the victim's hands when they pull it out
/datum/component/embedded/proc/safeRemoveHuman(to_hands)
	var/mob/living/carbon/human/victim = parent
	L.embedded_objects -= weapon

	if(!victim)
		weapon.forceMove(get_turf(weapon))
		qdel(src)

	if(to_hands)
		victim.put_in_hands(weapon)
	else
		weapon.forceMove(get_turf(victim))

	if(!victim.has_embedded_objects())
		victim.clear_alert("embeddedobject")
		SEND_SIGNAL(victim, COMSIG_CLEAR_MOOD_EVENT, "embedded")
	qdel(src)


/// Items embedded/stuck to humans both check whether they randomly fall out (if applicable), as well as if the target mob and limb still exists.
/// Items harmfully embedded in humans have an additional check for random pain (if applicable)
/datum/component/embedded/proc/processHuman()
	var/mob/living/carbon/human/victim = parent

	if(!victim || !L) // in case the victim and/or their limbs exploded (say, due to a sticky bomb)
		weapon.forceMove(get_turf(weapon))
		qdel(src)

	if(victim.stat == DEAD)
		return

	if(harmful  && prob(pain_chance))
		var/damage = weapon.w_class * pain_mult
		L.receive_damage(brute=(1-pain_stam_pct) * damage, stamina=pain_stam_pct * damage)
		to_chat(victim, "<span class='userdanger'>[weapon] embedded in your [L.name] hurts!</span>")

	if(prob(fall_chance))
		fallOutHuman()


////////////////////////////////////////
//////////////TURF PROCS////////////////
////////////////////////////////////////

/// Turfs are much lower maintenance, since we don't care if they're in pain, but since they don't bleed or scream, we draw an overlay to show their status.
/// The only difference pointy/sticky items make here is text descriptors and pointy objects making a spark shower on impact.
/datum/component/embedded/proc/initTurf(datum/thrownthing/throwingdatum)
	var/turf/closed/hit = parent

	// we can't store the item IN the turf (cause turfs are just kinda... there), so we fake it by making the item invisible and bailing if it moves due to a blast
	weapon.forceMove(hit)
	weapon.invisibility = INVISIBILITY_ABSTRACT
	RegisterSignal(weapon, COMSIG_MOVABLE_MOVED, .proc/itemMoved)

	var/pixelX = rand(-2, 2)
	var/pixelY = rand(-1, 3) // bias this upwards since in-hands are usually on the lower end of the sprite

	switch(throwingdatum.init_dir)
		if(NORTH)
			pixelY -= 2
		if(SOUTH)
			pixelY += 2
		if(WEST)
			pixelX += 2
		if(EAST)
			pixelX -= 2

	if(throwingdatum.init_dir in list(NORTH,  WEST, NORTHWEST, SOUTHWEST))
		overlay = mutable_appearance(icon=weapon.righthand_file,icon_state=weapon.item_state)
	else
		overlay = mutable_appearance(icon=weapon.lefthand_file,icon_state=weapon.item_state)

	var/matrix/M = matrix()
	M.Translate(pixelX, pixelY)
	overlay.transform = M
	hit.add_overlay(overlay, TRUE)

	if(harmful)
		hit.visible_message("<span class='danger'>[weapon] embeds itself in [hit]!</span>")
		playsound(hit,'sound/weapons/bladeslice.ogg', 70)

		var/datum/effect_system/spark_spread/sparks = new
		sparks.set_up(1, 1, parent)
		sparks.attach(parent)
		sparks.start()
	else
		hit.visible_message("<span class='danger'>[weapon] sticks itself to [hit]!</span>")


/datum/component/embedded/proc/examineTurf(datum/source, mob/user, list/examine_list)
	if(harmful)
		examine_list += "\t <a href='?src=[REF(src)];embedded_object=[REF(weapon)]' class='warning'>There is \a [weapon] embedded in [parent]!</a>"
	else
		examine_list += "\t <a href='?src=[REF(src)];embedded_object=[REF(weapon)]' class='warning'>There is \a [weapon] stuck to [parent]!</a>"


/// Someone is ripping out the item from the turf by hand
/datum/component/embedded/Topic(datum/source, href_list)
	var/mob/living/us = usr
	if(in_range(us, parent) && locate(href_list["embedded_object"]) == weapon)
		if(harmful)
			us.visible_message("<span class='notice'>[us] begins unwedging [weapon] from [parent].</span>", "<span class='notice'>You begin unwedging [weapon] from [parent]...</span>")
		else
			us.visible_message("<span class='notice'>[us] begins unsticking [weapon] from [parent].</span>", "<span class='notice'>You begin unsticking [weapon] from [parent]...</span>")

		if(do_after(us, 30, target = parent))
			us.put_in_hands(weapon)
			qdel(src)


/// This proc handles if something knocked the invisible item loose from the turf somehow (probably an explosion). Just make it visible and say it fell loose, then get outta here.
/datum/component/embedded/proc/itemMoved()
	weapon.invisibility = initial(weapon.invisibility)
	weapon.visible_message("<span class='notice'>[weapon] falls loose from [parent].</span>")
	qdel(src)
