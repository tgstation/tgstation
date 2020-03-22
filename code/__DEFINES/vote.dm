#define PLURALITY_VOTING 0
#define APPROVAL_VOTING 1

GLOBAL_LIST_INIT(vote_type_names,list(\
"Plurality (can only vote one option)" = PLURALITY_VOTING,\
"Approval (can vote any amount)" = APPROVAL_VOTING,\
))
