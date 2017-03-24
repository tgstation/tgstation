//We wrap all procs that sleep so we can monitor how many threads are active

/proc/wrap_sleep(delay)
    Master.SleepBegin()
    . = sleep(delay)
    Master.SleepEnd()

/proc/wrap_alert(Usr=usr,Message,Title,Button1="Ok",Button2,Button3)
    Master.SleepBegin()
    . = alert(Usr,Message,Title,Button1,Button2,Button3) 
    Master.SleepEnd()

/proc/wrap_input(Usr=usr,Message,Title,Default,nullable,choices)
    Master.SleepBegin()
    if(nullable)
        . = input(Usr,Message,Title,Default) as null|anything in choices
    else
        . = input(Usr,message,Title,Default) in choices
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
#define shell world.wrap_shell
#define winexists wrap_winexists
#define winget wrap_winget
#define Export wrap_Export
#define Import wrap_Import