GLOBAL_LIST_EMPTY(client_images)

#define CI_ADD 1
#define CI_OR 2
#define CI_REMOVE 3

/proc/ModifyClientOrMobImage(mob_or_client, images, action, is_mob)
    if(isnull(images))
        return
    
    if(!islist(images))
        images = list(images)

    var/ckey
    var/client/C
    var/mob/M

    if(ismob(mob_or_client))
        M = mob_or_client
        ckey = M.ckey
        C = M.client
    else    //client
        C = mob_or_client
        M = C.mob
        ckey = C.ckey

    
    var/list/current_client_images
    if(ckey)
        current_client_images = GLOB.client_images[ckey]
        if(!current_client_images)
            current_client_images = list()
            GLOB.client_images[ckey] = current_client_images
    var/list/current_mob_images = M.client_images
    
    var/list/modifying = is_mob ? current_mob_images : current_client_images
    
    switch(action)
        if(CI_ADD)
            modifying += images
        if(CI_OR)
            modifying |= images
        if(CI_REMOVE)
            modifying -= images
        else
            CRASH("Invalid client image action")

    if(C)
        C.images = current_client_images + current_mob_images

/proc/AddClientImage(mob_or_client, image)
    return ModifyClientImage(mob_or_client, image, CI_ADD, FALSE)

/proc/OrClientImage(mob_or_client, image)
    return ModifyClientImage(mob_or_client, image, CI_OR, FALSE)

/proc/RemoveClientImage(mob_or_client, image)
    return ModifyClientImage(mob_or_client, image, CI_REMOVE, FALSE)

/proc/AddMobImage(mob_or_client, image)
    return ModifyClientImage(mob_or_client, image, CI_ADD, TRUE)

/proc/OrMobImage(mob_or_client, image)
    return ModifyClientImage(mob_or_client, image, CI_OR, TRUE)

/proc/RemoveMobImage(mob_or_client, image)
    return ModifyClientImage(mob_or_client, image, CI_REMOVE, TRUE)


#undef CI_ADD
#undef CI_OR
#undef CI_REMOVE