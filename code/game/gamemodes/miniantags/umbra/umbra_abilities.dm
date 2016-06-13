//Unlike revenants, abilities used by umbras generally don't cost any vitae.

/obj/effect/proc_holder/spell/targeted/night_vision/umbra //Toggle Nightvision: Self-explanatory
	panel = "Umbral Evocation"
	message = "<span class='umbra'>You toggle your night vision.</span>"
	charge_max = 0
	action_icon_state = "umbral_sight"
	action_background_icon_state = "bg_umbra"



/obj/effect/proc_holder/spell/targeted/discordant_whisper //Discordant Whisper: Sends a single, silent message to a creature that the umbra can see. Doesn't work on dead targets.
	name = "Discordant Whisper"
	desc = "Telepathically sends a single message to a target within range. Nobody else can perceive this message, and it works on unconscious and deafened targets."
	panel = "Umbral Evocation"
	range = 7
	charge_max = 50
	clothes_req = FALSE
	include_user = FALSE
	action_icon_state = "discordant_whisper"
	action_background_icon_state = "bg_umbra"

/obj/effect/proc_holder/spell/targeted/discordant_whisper/cast(list/targets, mob/living/simple_animal/umbra/user)
	if(!isumbra(user))
		revert_cast()
		return
	var/mob/living/target = targets[1]
	if(target.stat == DEAD)
		user << "<span class='warning'>You can't send thoughts to the dead!</span>"
		revert_cast()
		return
	var/message = stripped_input(user, "Enter a message to transmit to [target].", "Discordant Whisper")
	if(!message || !target)
		revert_cast()
		return
	log_say("UmbraWhisper: [key_name(user)] -> [key_name(target)]: [message]")
	user << "<span class='umbra_bold'>You whisper to [target]:</span> <span class='umbra'>\"[message]\"</span>"
	target << "<span class='umbra_emphasis'>You hear an otherworldly voice...</span> <span class='umbra'>\"[message]\"</span>"
	for(var/mob/dead/observer/O in dead_mob_list)
		var/f1 = FOLLOW_LINK(O, user)
		var/f2 = FOLLOW_LINK(O, target)
		O << "[f1] <span class='umbra_bold'>[user] (Umbra Whisper):</span> <span class='umbra'>\"[message]\"</span> to [f2] <span class='name'>[target]</span>"



/obj/effect/proc_holder/spell/self/manifest //Manifest: Reveals the umbra and frightens anyone that sees it happen, granting a bit of vitae for each witness.
	name = "Manifest"
	desc = "Displays your powers in a flashy way, frightening nearby witnesses and granting a small amount of vitae fore ach one."
	panel = "Umbral Evocation"
	charge_max = 300
	clothes_req = FALSE
	action_icon_state = "manifest"
	action_background_icon_state = "bg_umbra"

/obj/effect/proc_holder/spell/self/manifest/cast(mob/living/simple_animal/umbra/user)
	if(!isumbra(user))
		revert_cast()
		return
	var/obj/effect/spooky = new(get_turf(user))
	spooky.density = TRUE
	spooky.opacity = TRUE
	spooky.anchored = TRUE
	var/yielded_vitae = 0
	for(var/mob/living/L in range(3, spooky))
		if(L == user)
			continue
		flash_color(L, flash_color = "#FF0000", flash_time = 50)
		yielded_vitae += rand(1, 5)
	switch(user.manifest_theme)
		if("Void")
			spooky.name = "emptiness"
			spooky.desc = "A humanoid form, utterly devoid of light but staring with horrible intelligence."
			spooky.icon = 'icons/effects/effects.dmi'
			spooky.icon_state = "blank"
			playsound(spooky, 'sound/effects/tendril_destroyed.ogg', 100, 0)
			for(var/mob/living/L in range(3, spooky))
				L << pick('sound/hallucinations/growl2.ogg', 'sound/hallucinations/over_here2.ogg', 'sound/hallucinations/im_here1.ogg')
		if("Clown")
			spooky.name = "spooky clown"
			spooky.desc = "And people wonder why you're afraid of clowns."
			spooky.icon = 'icons/mob/animal.dmi'
			spooky.icon_state = "scary_clown"
			playsound(spooky, 'sound/spookoween/scary_clown_appear.ogg', 100, 0)
			for(var/mob/living/L in range(3, spooky))
				L << pick('sound/spookoween/scary_horn.ogg', 'sound/spookoween/scary_horn2.ogg', 'sound/spookoween/scary_horn3.ogg')
	user.Reveal(5) //Really quick reveal
	user.Stun(5) //Same with the stun
	if(yielded_vitae)
		user.adjust_vitae(yielded_vitae, FALSE, "witnesses to your manifestation")
	spawn(50)
		qdel(spooky)
