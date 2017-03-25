//We wrap all procs that sleep so we can monitor how many threads are active
//sadly we can't catch the entry point of input verbs but we should be working to clear those oout where possible

/proc/wrap_sleep(delay)
    Master.SleepBegin()
    sleep(delay)
    Master.SleepEnd()

/proc/wrap_alert(Usr = usr, Message, Title, Button1 = "Ok", Button2, Button3)
    Master.SleepBegin()
    . = alert(Usr,Message,Title,Button1,Button2,Button3) 
    Master.SleepEnd()

//this is the only one that changes syntax because byond
/proc/wrap_input(Usr = usr, Message, Title, Default, nullable, choices, restrict_type, istext, isnum, world_obj, world_turf)
    Master.SleepBegin()
    if(world_obj)
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|obj in world
        else
            . = input(Usr, Message, Title, Default) as obj in world
    if(world_turf)
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|turf in world
        else
            . = input(Usr, Message, Title, Default) as turf in world
    else if(isnum)
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|num
        else
            . = input(Usr, Message, Title, Default) as num
    else if(text)
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|text
        else
            . = input(Usr, Message, Title, Default) as text
    else 
        if(nullable)
            . = input(Usr, Message, Title, Default) as null|anything in choices
        else
            . = input(Usr, Message, Title, Default) in choices
    Master.SleepEnd()

//world proc because fuck off
/world/proc/wrap_shell(command)
    Master.SleepBegin()
    . = shell(command)
    Master.SleepEnd()

/proc/wrap_winexists(player, control_id) 
    Master.SleepBegin()
    . = winexists(player, control_id)
    Master.SleepEnd()

/proc/wrap_winget(player, control_id, params)
    Master.SleepBegin()
    . = winget(player, control_id, params)
    Master.SleepEnd()

/world/proc/wrap_Export(Addr,File,Persist,Clients)
    Master.SleepBegin()
    . = Export(Addr,File,Persist,Clients)
    Master.SleepEnd()

/world/proc/wrap_Import()
    Master.SleepBegin()
    . = Import()
    Master.SleepEnd()

#define sleep wrap_sleep
#define alert wrap_alert
#define input wrap_input
//#define shell world.wrap_shell
//#define winexists wrap_winexists
//#define winget wrap_winget
//#define Export wrap_Export
//#define Import wrap_Import