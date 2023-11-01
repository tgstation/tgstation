## Title: <!--Title of your addition-->

<!-- uppercase, underscore_connected name of your module, that you use to mark files-->
MODULE ID: STORYTELLERS 

### Description:

This PR adds adds on to the current dynamic system by having events be guided by storytellers, this also caches the events ran last round and depending on severity cuts their weights by x % to make rounds not repeat as often.


<!-- Here, try to describe what your PR does, what features it provides and any other directly useful information -->

### TG Proc/File Changes:

<!-- If you had to edit, or append to any core procs in the process of making this PR, list them here. APPEND: Also, please include any files that you've changed. .DM files that is. -->
	- N/A

### Defines:

<!-- If you needed to add any defines, mention the files you added those defines in -->
	- code\__DEFINES\~monkestation\storytellers.dm

### Master file additions

- code\modules\events\_event.dm
- code\modules\admin\topic.dm
- code\controllers\subsystem\ticker.dm
- code\controllers\subsystem\statpanel.dm
- all event files

<!-- Any master file changes you've made to existing master files or if you've added a new master file. Please mark either as #NEW or #CHANGE -->

### Included files that are not contained in this module:

- N/A
<!-- Likewise, be it a non-modular file or a modular one that's not contained within the folder belonging to this specific module, it should be mentioned here -->

### Credits:

<!-- Here go the credits to you, dear coder, and in case of collaborative work or ports, credits to the original source of the code -->
<!-- Orignal Coders -->
Made by Unknown Coders on Horizon (Horizon's Repo atleast as of 10/14/2023 no longer exists if this changes please let me know on discord #Borbop)
<!-- Orignal Coders -->
Ported by Dwasint
