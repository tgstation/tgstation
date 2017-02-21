/datum/stat/woodcutting // buying willow logs 200gp
	xpToLevel = 83
	statMax = 99
	statCurr = 1
	statMin = 1
	lvl_up_sound = 'sound/effects/woodcutting_lvl.ogg'

/datum/stat/fishing // fishing lvls?
	xpToLevel = 83
	statMax = 99
	statCurr = 1
	statMin = 1
	lvl_up_sound = 'sound/effects/fishing_lvl.ogg'

/datum/stat/firemaking // yes sir game master the swastika made out of yew log fires is totally coincidental
	xpToLevel = 83
	statMax = 99
	statCurr = 1
	statMin = 1
	lvl_up_sound = 'sound/effects/firemaking_lvl.ogg'

/datum/stat/cooking // free cooked lobbys just put your password in backward in the chat
	xpToLevel = 83
	statMax = 99
	statCurr = 1
	statMin = 1
	lvl_up_sound = 'sound/effects/cooking_lvl.ogg'


/datum/stat/firemaking/New(var/name = "error", var/id = "", var/limit=FALSE, var/cur=1, var/min=1, var/max=99, var/staticon = "")
	..()
	change(1)

/datum/stat/fishing/New(var/name = "error", var/id = "", var/limit=FALSE, var/cur=1, var/min=1, var/max=99, var/staticon = "")
	..()
	change(1)

/datum/stat/woodcutting/New(var/name = "error", var/id = "", var/limit=FALSE, var/cur=1, var/min=1, var/max=99, var/staticon = "")
	..()
	change(1)

/datum/stat/cooking/New(var/name = "error", var/id = "", var/limit=FALSE, var/cur=1, var/min=1, var/max=99, var/staticon = "")
	..()
	change(1)