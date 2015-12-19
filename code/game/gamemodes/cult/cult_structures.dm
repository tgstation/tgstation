/obj/structure/constructshell/large
	name = "large empty shell"
	icon = 'icons/obj/cult_large.dmi'
	icon_state = "shell_narsie_grey"
	desc = "An oversized construct shell, fit for an elder god. Only a lunatic would even dream of such a crazed contraption."
	pixel_x = -16
	pixel_y = -16
	density = 1
	layer = 4.5
	anchored = 0
	var/maxhealth = 200
	var/health = 200
	var/image/black_overlay = null
	var/orbs = 0
	var/orbs_needed = 1
	var/time_to_win = 1800 //3 minutes
	var/timer_id = null

/obj/structure/constructshell/large/New()
	..()
	if(ticker.mode.name == "cult")
		var/datum/game_mode/cult/cult = ticker.mode
		orbs_needed = cult.orbs_needed
	black_overlay = image('icons/obj/cult_large.dmi', "shell_narsie_black")

/obj/structure/constructshell/large/Destroy()
	priority_announce("The extra-dimensional flow has ceased. All personnel should return to their routine activities.","Central Command Higher Dimensions Affairs")
	if(get_security_level() == "delta")
		set_security_level("red")
	if(ticker.mode.name == "cult")
		var/datum/game_mode/cult/cult = ticker.mode
		cult.large_shell_summoned = 0
	black_overlay = null
	if(timer_id)
		deltimer(timer_id)
	..()

/obj/structure/constructshell/large/examine(mob/user)
	..()
	user << "<span class='cult'>You see a number of round holes on the surface of the shell. They number [orbs_needed], and [orbs ? orbs : "none"] of them [orbs > 1 ? "are" : "is"] filled.</span>"

/obj/structure/constructshell/large/update_icon()
	var/new_alpha = round((orbs/orbs_needed)*255)
	if(new_alpha)
		overlays -= black_overlay
		black_overlay.alpha = new_alpha
		overlays += black_overlay

/obj/structure/constructshell/large/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/summoning_orb) && (orbs < orbs_needed))
		if(!iscultist(user))
			return
		visible_message("<span class='cult'>\The [src] glows.</span>")
		orbs++
		qdel(O)
		update_icon()
		if(orbs >= orbs_needed)
			start_takeover()
		return

	if( (O.flags&NOBLUDGEON) || !O.force )
		return
	add_fingerprint(user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	playsound(src, 'sound/weapons/smash.ogg', 50, 1)
	visible_message("<span class='danger'>[user] has hit \the [src] with [O].</span>")
	if(O.damtype == BURN || O.damtype == BRUTE)
		damaged(O.force)

//this stuff is mostly copy-pasted from gang dominators, with some changes
/obj/structure/constructshell/large/proc/start_takeover()
	anchored = 1
	overlays -= black_overlay
	icon_state = "shell_narsie_active"
	flick("shell_narsie_activation", src)
	set_security_level("delta")
	var/area/A = get_area(src)
	var/locname = initial(A.name)
	priority_announce("Figments from an eldritch god have begun pouring into [locname] from an unknown dimension. Eliminate its vessel before it reaches a critical point.","Central Command Higher Dimensions Affairs")
	timer_id = addtimer(src, "summon_narnar", time_to_win)

/obj/structure/constructshell/large/proc/damaged(damage)
	health -= damage
	if(health <= 0)
		new /obj/item/stack/sheet/plasteel(get_turf(src))
		qdel(src)

/obj/structure/constructshell/large/bullet_act(obj/item/projectile/P)
	if(P.damage)
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		visible_message("<span class='danger'>[src] was hit by [P].</span>")
		damaged(P.damage)

/obj/structure/constructshell/large/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	playsound(src, 'sound/effects/bang.ogg', 50, 1)
	user.visible_message("<span class='danger'>[user] smashes against [src] with its claws.</span>",\
	"<span class='danger'>You smash against [src] with your claws.</span>")
	damaged(15)

/obj/structure/constructshell/large/attack_animal(mob/living/user)
	if(!isanimal(user))
		return
	var/mob/living/simple_animal/M = user
	M.do_attack_animation(src)
	if(M.melee_damage_upper <= 0)
		return
	damaged(M.melee_damage_upper)

/obj/structure/constructshell/large/mech_melee_attack(obj/mecha/M)
	if(M.damtype == "brute")
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		visible_message("<span class='danger'>[M.name] has hit [src].</span>")
		damaged(M.force)

/obj/structure/constructshell/large/attack_hulk(mob/user)
	playsound(src, 'sound/effects/bang.ogg', 50, 1)
	user.visible_message("<span class='danger'>[user] smashes [src].</span>",\
	"<span class='danger'>You punch [src].</span>")
	damaged(5)

/obj/structure/constructshell/large/ex_act()
	return //nope

/obj/structure/constructshell/large/singularity_pull()
	return //nope

/obj/structure/constructshell/large/singularity_act(current_size, obj/singularity/S)
	var/atom/target = get_edge_target_turf(src, get_dir(src, S))
	S.throw_at(target, 5, 1) //aaand nope

/obj/structure/constructshell/large/proc/summon_narnar()
	if(ticker.mode.name != "cult")
		visible_message("<span class='warning'>\The [src] glows brightly once, then falls dark. It looks strangely dull and lifeless...</span>")
		log_game("Summon Nar-Sie rune failed - gametype is not cult")
		return
	var/datum/game_mode/cult/cult_mode = ticker.mode
	if(cult_mode.eldergod)
		return //this should never happen, so we don't need any special fluff
	world << 'sound/effects/dimensional_rend.ogg'
	world << "<span class='cultitalic'><b>Rip... <span class='big'>Rrrip...</span> <span class='reallybig'>RRRRRRRRRR--</span></b></span>"
	var/turf/target_turf = get_turf(src)
	spawn(40)
		new /obj/singularity/narsie/large(target_turf) //Causes Nar-Sie to spawn even if the rune has been removed
		cult_mode.eldergod = 1
		if(src)
			qdel(src)


/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'

/obj/structure/cult/talisman
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie"
	icon_state = "talismanaltar"

/obj/structure/cult/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie"
	icon_state = "forge"

/obj/structure/cult/pylon
	name = "pylon"
	desc = "A floating crystal that hums with an unearthly energy"
	icon_state = "pylon"
	luminosity = 5

/obj/structure/cult/tome
	name = "desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl"
	icon_state = "tomealtar"
	luminosity = 1

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back"
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1
