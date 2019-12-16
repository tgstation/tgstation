# GOAP (Goal Oriented Action Planning)

Goal oriented action planning is an artificial intelligence system for agents that allows them to plan a sequence of actions to satisfy a particular goal.

# Actions

These decides what the AI will do, there are five general procs for actions

* Advanced Preconditions - Checks if the conditions to do the action are still viable.
* RequiresInRange - Return true if you want the AI to path before performing, otherwise return false.
* Perform - What the action itself does, for example: this is when you would chop the tree down if that was the action.
* CheckDone - Checks to see if the action is completed before moving on to the next one, return TRUE when completed or FALSE otherwise
* PerformWhileMoving - Only relevant when RequiresInRange is true, will do the action defined every step
* PathingFailed - Used for pathfinding, also relevant when RequiresInRange is true. What action to take if the AI has failed to path in a certain amount of movements should be used for finding a new target in a non-blacklisted turf, return TRUE to continue attempting to path or return FALSE to allow the agent to replan

What actions the AI will do and when depends on the cost and worldstate.

* Preconditions, what state the world has to be in to consider performing the action. If you want the AI to consider grabbing an axe a precondition to consider is to make sure it doesn't have an axe already by defining a precondition.
* Effects, what goal does the action work towards? Getting an item or Killing an enemy. Eg: if you want the AI to get an axe you would want to make the effects for the action to grab axe.

These two variables are fed to the agent through the worldstate, which determines which preconditions are already met and which effects will be desired.

# Info Provider

This feeds the agent the worldstate and goals, this is where you decide what the AI sees and what it will attempt to do

* GetWorldState - Provides the AI with its current state, the syntax is usually .["STATE NAME"] for example if it has an axe you would write .["HasAxe"] = TRUE. otherwise you would make .["HasAxe"] = FALSE
* GetGoal - Provides the AI with goals and helps decide what actions it will do, this is where you would look for an axe and if one is spotted you would make the AIs goal to get that axe, this uses the same syntax as GetWorldState

# Planner

This is what decides the actions and weighs them by how many goals they would complete and which ones would be the lowest cost. The AI will usually try to complete all the goals it can while still choosing the lowest cost actions to do so. If there are two ways to achieve a goal it will go for the cheaper one.

The code for the planner should not be touched unless you're planning to improve it, creating new AIs will still use the planner as it's universal.
