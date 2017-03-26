//We wrap all procs that sleep so we can monitor how many threads are active
//sadly we can't catch the entry point of input verbs but we should be working to clear those oout where possible

/proc/wrap_sleep(delay)
    world.SleepBegin()
    sleep(delay)
    world.SleepEnd()

/proc/wrap_alert(Usr = usr, Message, Title, Button1 = "Ok", Button2, Button3)
    world.SleepBegin()
    . = alert(Usr,Message,Title,Button1,Button2,Button3) 
    world.SleepEnd()

//this is the only one that changes syntax because byond
//its such a pain in the fucking ass
/proc/wrap_input(Usr = usr, Message, Title, Default, nullable, choices, restrict_type, istext, ismessage, isnum, isicon, iscolor, isfile, type_obj, type_turf, type_mob)
    world.SleepBegin()
    if(type_obj)
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|obj in choices
        else
            . = input(Usr, Message, Title, Default) as obj in choices
    else if(type_turf)
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|turf in choices
        else
            . = input(Usr, Message, Title, Default) as turf in choices
    else if(type_mob)
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|mob in choices
        else
            . = input(Usr, Message, Title, Default) as mob in choices
    else if(iscolor)
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|color
        else
            . = input(Usr, Message, Title, Default) as color
    else if(isicon)
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|icon
        else
            . = input(Usr, Message, Title, Default) as icon
    else if(isnum)
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|num
        else
            . = input(Usr, Message, Title, Default) as num
    else if(istext)
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|text
        else
            . = input(Usr, Message, Title, Default) as text
    else if(ismessage)
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|message
        else
            . = input(Usr, Message, Title, Default) as message
    else if(isfile)
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|file
        else
            . = input(Usr, Message, Title, Default) as file
    else 
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|anything in choices
        else
            . = input(Usr, Message, Title, Default) in choices
    world.SleepEnd()

//world proc because fuck off
/world/proc/wrap_shell(command)
    world.SleepBegin()
    . = shell(command)
    world.SleepEnd()

/proc/wrap_winexists(player, control_id) 
    world.SleepBegin()
    . = winexists(player, control_id)
    world.SleepEnd()

/proc/wrap_winget(player, control_id, params)
    world.SleepBegin()
    . = winget(player, control_id, params)
    world.SleepEnd()

/world/proc/wrap_Export(Addr,File,Persist,Clients)
    world.SleepBegin()
    . = Export(Addr,File,Persist,Clients)
    world.SleepEnd()

/world/proc/wrap_Import()
    world.SleepBegin()
    . = Import()
    world.SleepEnd()

#define sleep wrap_sleep
#define alert wrap_alert
#define input wrap_input
#define shell world.wrap_shell
#define winexists wrap_winexists
#define winget wrap_winget
#define Export wrap_Export
#define Import wrap_Import