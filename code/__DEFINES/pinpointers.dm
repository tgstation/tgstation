//I would rather have these in pinpointer.dm, but Malf_Modules.dm is loaded before that file so they need to be here.
#define TRACK_NUKE_DISK 1 //We track the nuclear authentication disk, either to protect it or steal it
#define TRACK_MALF_AI 2 //We track the malfunctioning AI, so we can prevent it from blowing us all up
#define TRACK_INFILTRATOR 3 //We track the Syndicate infiltrator, so we can get back to ship when the nuke's armed
#define TRACK_OPERATIVES 4 //We track the closest operative, so we can regroup when we need to
#define TRACK_ATOM 5 //We track a specified atom, so admins can make us function for events
#define TRACK_COORDINATES 6 //We point towards the specified coordinates on our z-level, so we can navigate
