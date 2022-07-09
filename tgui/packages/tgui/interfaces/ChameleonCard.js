import { useBackend } from '../backend';
import { AccessList } from './common/AccessList';
import { Window } from '../layouts';

export const ChameleonCard = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    accesses,
    selectedList,
    wildcardFlags,
    wildcardSlots,
    trimAccess,
    accessFlags,
    accessFlagNames,
    showBasic,
    ourAccess,
    theftAccess,
    ourTrimAccess,
  } = data;

  const parsedAccess = accesses.flatMap((region) => {
    const regionName = region.name;
    const regionAccess = region.accesses;
    const parsedRegion = {
      name: regionName,
      accesses: [],
    };
    parsedRegion.accesses = regionAccess.filter((access) => {
      // Snip everything that's part of our trim.
      if (ourTrimAccess.includes(access.ref)) {
        return false;
      }
      // Add anything not part of our trim that's an access (assumed wildcard)
      // Also add any access on the ID card we're stealing from.
      if (ourAccess.includes(access.ref) || theftAccess.includes(access.ref)) {
        return true;
      }
      return false;
    });
    if (parsedRegion.accesses.length) {
      return parsedRegion;
    }
    return [];
  });

  return (
    <Window width={500} height={620}>
      <Window.Content scrollable>
        <AccessList
          accesses={parsedAccess}
          selectedList={selectedList}
          wildcardFlags={wildcardFlags}
          wildcardSlots={wildcardSlots}
          trimAccess={trimAccess}
          accessFlags={accessFlags}
          accessFlagNames={accessFlagNames}
          showBasic={!!showBasic}
          accessMod={(ref, wildcard) =>
            act('mod_access', {
              access_target: ref,
              access_wildcard: wildcard,
            })
          }
        />
      </Window.Content>
    </Window>
  );
};
