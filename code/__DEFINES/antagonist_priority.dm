//Contains priority defines for antagonist datums. Higher numbers are more important than lower ones.

#define ANTAGONIST_PRIORITY_NONE 0 //No special allegiances. Essentially a normal crewman.
#define ANTAGONIST_PRIORITY_SYNDICATE 1 //You're a member of the Syndicate coalition or some other faction. This is entirely voluntary, so it doesn't have much loyalty attached.
#define ANTAGONIST_PRIORITY_SECEDER 2 //You've defected from the crew and joined a faction vying for control. This involves minor brainwashing, so it can be problematic but not impossible.
#define ANTAGONIST_PRIORITY_CULTIST 3 //You serve a powerful deity with intense zeal. This involves intense brainwashing or conditioning and is difficult to remove fully.
#define ANTAGONIST_PRIORITY_NONHUMAN 4 //You aren't human, so you aren't susceptible to human conditioning. You're immune to most conversion methods.
#define ANTAGONIST_PRIORITY_IMMUNE INFINITY //You physically can't be converted by anything. This has no canonical explanation and exists for gameplay purposes.
