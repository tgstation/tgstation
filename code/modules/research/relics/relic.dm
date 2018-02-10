/obj/item/relic
	name = "strange object"
	desc = "What mysteries could this hold?"
	icon = 'icons/obj/assemblies.dmi'
	var/realName = "defined object"
	var/revealed = FALSE
	var/realProc
	var/cooldownMax = 60
	var/cooldown

/obj/item/relic/Initialize()
	. = ..()
	icon_state = pick("shock_kit","armor-igniter-analyzer","infra-igniter0","infra-igniter1","radio-multitool","prox-radio1","radio-radio","timer-multitool0","radio-igniter-tank")
	realName = "[pick("broken","twisted","spun","improved","silly","regular","badly made")] [pick("device","object","toy","illegal tech","weapon")]"


/obj/item/relic/proc/reveal()
	if(revealed) //Re-rolling your relics seems a bit overpowered, yes?
		return
	revealed = TRUE
	name = realName
	cooldownMax = rand(60,300)
	realProc = pick("teleport","explode","rapidDupe","petSpray","flash","clean","corgicannon")

/obj/item/relic/attack_self(mob/user)
	if(revealed)
		if(cooldown)
			to_chat(user, "<span class='warning'>[src] does not react!</span>")
			return
		else if(loc == user)
			cooldown = TRUE
			call(src,realProc)(user)
			addtimer(CALLBACK(src, .proc/cd), cooldownMax)
	else
		to_chat(user, "<span class='notice'>You aren't quite sure what to do with this yet.</span>")

/obj/item/relic/proc/cd()
	cooldown = FALSE

//////////////// RELIC PROCS /////////////////////////////

/obj/item/relic/proc/rapidDupe(mob/user)
	audible_message("[src] emits a loud pop!")
	var/list/dupes = list()
	var/counter
	var/max = rand(5,10)
	for(counter = 1; counter < max; counter++)
		var/obj/item/relic/R = new type(get_turf(src))
		R.name = name
		R.desc = desc
		R.realName = realName
		R.realProc = realProc
		R.revealed = TRUE
		dupes |= R
		R.throw_at(pick(oview(7,get_turf(src))),10,1)
	counter = 0
	QDEL_LIST_IN(dupes, rand(10, 100))
	warn_admins(user, "Rapid duplicator", 0)

//Admin Warning proc for relics
/obj/item/relic/proc/warn_admins(mob/user, RelicType, priority = 1)
	var/turf/T = get_turf(src)
	var/log_msg = "[RelicType] relic used by [key_name(user)] in ([T.x],[T.y],[T.z])"
	if(priority) //For truly dangerous relics that may need an admin's attention. BWOINK!
		message_admins("[RelicType] relic activated by [ADMIN_LOOKUPFLW(user)] in [ADMIN_COORDJMP(T)]",0,1)
	log_game(log_msg)
	investigate_log(log_msg, "experimentor")
