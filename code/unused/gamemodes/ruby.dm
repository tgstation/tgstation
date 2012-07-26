// RUBY MODE
// There is a weapon of some sort that spawns on the station
// It calls out to crew members in an effort to find a wielder
// The wielder is made an abomination - they're given a grotesque mask and special powers
// The Abomination wins by murdering the entire crew, then himself
// The crew wins by destroying the weapon


/datum/game_mode/ruby
	name = "ruby"
	config_tag = "ruby"

	var/datum/mind/abomination
	var/finished = 0
	var/abominationwins = 0
	var/winnerkey
	var/obj/macguffin
	var/list/killed = list()
	var/respawns = 0



/datum/game_mode/ruby/post_setup()
	var/list/possible_abominations = get_possible_abominations()

	if(possible_abominations.len>0)
		abomination = pick(possible_abominations)
	/*
	if(istype(ruby))
		abomination.special_role = "abomination"
		if(wizardstart.len == 0)
			wizard.current << "<B>\red A starting location for you could not be found, please report this bug!</B>"
		else
			var/starting_loc = pick(wizardstart)
			wizard.current.loc = starting_loc

	for (var/obj/effect/landmark/A in world)
		if (A.name == "Teleport-Scroll")
			new /obj/item/weapon/teleportation_scroll(A.loc)
			del(A)
			continue
	*/
	..()

/datum/game_mode/ruby/check_finished()
	if(!macguffin || abominationwins)
		return 1
	else
		return 0

/datum/game_mode/ruby/declare_completion()
	if(abominationwins)
		feedback_set_details("round_end_result","win - abomination win")
		world << "<B>The Abomination has murdered the station and sacrificed himself to Cjopaze!</B> (played by [winnerkey])"
	else
		feedback_set_details("round_end_result","loss - abomination killed")
		world << "<B>The Abomination has been stopped and Cjopaze's influence resisted! The station lives another day,</B>"
		if(killed.len > 0)
			world << "Those who were sacrificed shall be remembered: "
			for(var/mob/M in killed)
				if(M)
					world << "[M.real_name]"
	/*
	for(var/datum/mind/traitor in traitors)
		var/traitorwin = 1
		var/traitor_name

		if(traitor.current)
			traitor_name = "[traitor.current.real_name] (played by [traitor.key])"
		else
			traitor_name = "[traitor.key] (character destroyed)"

		world << "<B>The syndicate traitor was [traitor_name]</B>"
		var/count = 1
		for(var/datum/objective/objective in traitor.objectives)
			if(objective.check_completion())
				world << "<B>Objective #[count]</B>: [objective.explanation_text] \green <B>Success</B>"
			else
				world << "<B>Objective #[count]</B>: [objective.explanation_text] \red Failed"
				traitorwin = 0
			count++

		if(traitorwin)
			world << "<B>The traitor was successful!<B>"
		else
			world << "<B>The traitor has failed!<B>"
	*/
	..()
	return 1


/datum/game_mode/ruby/proc/spawn_macguffin()

/datum/game_mode/ruby/proc/get_possible_abominations()


/mob/proc/make_abomination()
	src.see_in_dark = 20
	src.verbs += /client/proc/planar_shift
	src.verbs += /client/proc/vile_ressurection
	src.verbs += /client/proc/defile_corpse
	src.verbs += /client/proc/summon_weapon
	src.verbs += /client/proc/sacrifice_self
	src.verbs += /client/proc/hunt
	src.verbs += /client/proc/howl
	var/datum/game_mode/ruby/rmode = ticker.mode
	rmode.abomination = src.mind
	return


/client/proc/planar_shift()
	set name = "Planar Shift"
	set category = "Abomination"
	// This is a pretty shitty way to do this. Should use the spell_holder method from Wizard mode
	/*
	if(!usr.incorporeal_move)
		usr.sight |= SEE_MOBS
		usr.sight |= SEE_OBJS
		usr.sight |= SEE_TURFS
		//usr.density = 0
		usr.incorporeal_move = 1
	else
		usr.sight &= ~SEE_MOBS
		usr.sight &= ~SEE_TURFS
		usr.sight &= ~SEE_OBJS
		usr.density = 1
		usr.incorporeal_move = 0
		src.verbs -= /client/proc/planar_shift
		spawn(300) src.verbs += /client/proc/planar_shift
	*/

/client/proc/vile_ressurection()
	set name = "Vile Ressurection"
	set category = "Abomination"
	if(src.mob.stat != 2 || !src.mob)
		return
	if(ticker.mode:respawns > 0)
		// spawn a new body
		ticker.mode:respawns -= 1
	else
		// nope

/client/proc/defile_corpse(var/mob/living/carbon/human/H in view())
	set name = "Defile Corpse"
	set category = "Abomination"
	if(istype(H, /mob/living/carbon/human))
		var/datum/game_mode/ruby/rmode = ticker.mode
		rmode.killed.Add(H)
		ticker.mode:respawns += 1
	var/fluffmessage = pick("\red <B>[usr] rips the flesh from [H]'s corpse and plucks their eyes from their sockets!</B>", "\red <B>[usr] does unspeakable things to [H]'s corpse!</B>", "\red <B>[usr] binds [H]'s corpse with their own entrails!</B>")
	usr.visible_message(fluffmessage)
	// play sound

/client/proc/summon_weapon()
	set name = "Summon Weapon"
	set category = "Abomination"

	for(var/obj/item/weapon/rubyweapon/w in world)
		if(istype(w, /obj/item/weapon/rubyweapon))
			if(istype(w.loc, /mob))
				var/mob/M = w.loc
				M.drop_item()
				w.loc = usr.loc
			else
				w.loc = usr.loc
		src.verbs -= /client/proc/summon_weapon
		spawn(300) src.verbs += /client/proc/summon_weapon
		return

/client/proc/sacrifice_self()
	set name = "Sacrifice Self"
	set category = "Abomination"
	set desc = "Everything must come to an end. After you have freed them, you must free yourself."

	for(var/mob/living/carbon/human/H in player_list)
		if(!H.client || H.client == src)
			continue
		src << "Your work is not done. You will not find release until they are all free."
		return
	usr.gib(1)
	ticker.mode:abominationwins = 1

/client/proc/hunt()
	set name = "Hunt"
	set category = "Abomination"
	set desc = ""

	var/list/candidates = list()

	for(var/mob/living/carbon/human/H in player_list)
		if(!H.client || H.client == src) continue
		//if(!H.client) continue
		candidates.Add(H)

	usr.visible_message(text("\red <B>[usr]'s flesh ripples and parts, revealing dozens of eyes poking from its surface. They all glance wildly around for a few moments before receding again.</B>"))

	var/mob/living/carbon/human/H = pick(candidates)

	if(!H) return

	var/filename="crmap[ckey].tmp"
	var/html="<html><body bgcolor=black><table border=0 cellspacing=0 cellpadding=0>"
	var/denytypes[0]
	var/tilesizex=32
	var/tilesizey=32
	//If the temp. file exists, delete it
	src << browse("<h2>Sensing prey...</h2>", "window=hunt")
	if (fexists(filename)) fdel(filename)

	//Display everything in the world
	for (var/y=H.y-3,y<=H.y+3,y++)
		html+="</tr><tr>"
		text2file(html,filename)
		html=""
		sleep(-1)
		//for (var/x=H.x-5,x<=H.x+5,x++)
		for(var/x=H.x-3, x<=H.x+3, x++)
			//Turfs
			var/turf/T=locate(x,y,H.z)
			if (!T) continue
			var/icon/I=icon(T.icon,T.icon_state)
			var/imgstring=dd_replacetext("[T.type]-[T.icon_state]","/","_")

			//Movable atoms
			for (var/atom/movable/A in T)
				//Make sure it's allowed to be displayed
				var/allowed=1
				for (var/X in denytypes)
					if (istype(A,X))
						allowed=0
						break
				if (!allowed) continue

				if (A.icon) I.Blend(icon(A.icon,A.icon_state,A.dir),ICON_OVERLAY)
				imgstring+=dd_replacetext("__[A.type]_[A.icon_state]","/","_")

			//Output it
			src << browse_rsc(I,"[imgstring].dmi")
			html+="<td><img src=\"[imgstring].dmi\" width=[tilesizex] height=[tilesizey]></td>"

	text2file("</table></body></html>",filename)

	//Display it
	src << browse(file(filename),"window=hunt")



/client/proc/howl()	// This is just a way for the Abomination to make the game more atmospheric periodically.
	set name = "Howl"
	set category = "Abomination"
	set desc = ""

	usr.visible_message(text("\red <B>[usr]'s form warbles and distorts before settling back into its grotesque shape once more.</B>"))
	// Play a random spooky sound - maybe cause some visual, non-mechanical effects to appear at random for a few seconds.

	src.verbs -= /client/proc/howl
	spawn(rand(300,1800)) src.verbs += /client/proc/howl

/obj/item/weapon/rubyweapon
	desc = ""
	name = "wepon"
	icon_state = "wepon"
	w_class = 3.0
	throwforce = 60.0
	throw_speed = 2
	throw_range = 20
	force = 24.0
	var/mob/owner

	proc/check_owner()
		if(!owner)
			sleep(300)
			if(!owner)
				spawn() search_for_new_owner()
		else
			spawn(1800) check_owner()

	proc/search_for_new_owner()
		var/list/possible_owners = list()
		for(var/mob/living/carbon/human/H in mob_list)
			possible_owners.Add(H)

		var/mob/living/carbon/human/H = pick(possible_owners)
		// Send message to H
		// Take a snapshot of the item's location, browse it to H
		spawn(rand(600,1800)) search_for_new_owner()

	attack_self(mob/user as mob)
		// Blow all lights nearby