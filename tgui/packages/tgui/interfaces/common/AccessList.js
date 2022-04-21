import { sortBy } from 'common/collections';
import { useSharedState } from '../../backend';
import { Button, Flex, Section, Tabs } from '../../components';

export const AccessList = (props, context) => {
  const {
    accesses = [],
    wildcardSlots = {},
    selectedList = [],
    accessMod,
    trimAccess = [],
    accessFlags = {},
    accessFlagNames = {},
    wildcardFlags = {},
    extraButtons,
    showBasic,
  } = props;

  const [
    wildcardTab,
    setWildcardTab,
  ] = useSharedState(context, "wildcardSelected", showBasic ? "None" : Object.keys(wildcardSlots)[0]);

  let selectedWildcard;

  if ((wildcardTab !== "None") && !wildcardSlots[wildcardTab]) {
    selectedWildcard = showBasic ? "None" : Object.keys(wildcardSlots)[0];
    setWildcardTab(selectedWildcard);
  }
  else {
    selectedWildcard = wildcardTab;
  }

  const parsedRegions = [];
  const selectedTrimAccess = [];
  accesses.forEach(region => {
    const regionName = region.name;
    const regionAccess = region.accesses;
    const parsedRegion = {
      name: regionName,
      accesses: [],
      hasSelected: false,
      allSelected: true,
    };

    // If we're showing the basic accesses included as part of the trim,
    // we want to figure out how many are selected for later formatting
    // logic.
    if (showBasic) {
      regionAccess.forEach(access => {
        if (trimAccess.includes(access.ref)
          && selectedList.includes(access.ref)
          && !selectedTrimAccess.includes(access.ref)
        ) {
          selectedTrimAccess.push(access.ref);
        }
      });
    }

    // If there's no wildcard selected, grab accesses in
    // the trimAccess list as they require no wildcard.
    if (selectedWildcard === "None") {
      regionAccess.forEach(access => {
        if (!trimAccess.includes(access.ref)) {
          return;
        }
        parsedRegion.accesses.push(access);
        if (selectedList.includes(access.ref)) {
          parsedRegion.hasSelected = true;
        }
        else {
          parsedRegion.allSelected = false;
        }
      });
      if (parsedRegion.accesses.length) {
        parsedRegions.push(parsedRegion);
      }
      return;
    }
    // Otherwise, a trim is selected. We want to grab all
    // accesses not in trimAccess that are compatible with
    // the given wildcard.
    regionAccess.forEach(access => {
      if (trimAccess.includes(access.ref)) {
        return;
      }
      if (accessFlags[access.ref] & wildcardFlags[selectedWildcard]) {
        parsedRegion.accesses.push(access);
        if (selectedList.includes(access.ref)) {
          parsedRegion.hasSelected = true;
        }
        else {
          parsedRegion.allSelected = false;
        }
      }
    });
    if (parsedRegion.accesses.length) {
      parsedRegions.push(parsedRegion);
    }
  });

  return (
    <Section
      title="Access"
      buttons={extraButtons} >
      <Flex wrap="wrap">
        <Flex.Item width="100%">
          <FormatWildcards
            wildcardSlots={wildcardSlots}
            selectedList={selectedList}
            showBasic={showBasic}
            basicUsed={selectedTrimAccess.length}
            basicMax={trimAccess.length} />
        </Flex.Item>
        <Flex.Item>
          <RegionTabList
            accesses={parsedRegions} />
        </Flex.Item>
        <Flex.Item grow={1}>
          <RegionAccessList
            accesses={parsedRegions}
            selectedList={selectedList}
            accessMod={accessMod}
            trimAccess={trimAccess}
            accessFlags={accessFlags}
            accessFlagNames={accessFlagNames}
            wildcardSlots={wildcardSlots}
            showBasic={showBasic} />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const FormatWildcards = (props, context) => {
  const {
    wildcardSlots = {},
    showBasic,
    basicUsed = 0,
    basicMax = 0,
  } = props;

  const [
    wildcardTab,
    setWildcardTab,
  ] = useSharedState(context, "wildcardSelected", showBasic ? "None" : Object.keys(wildcardSlots)[0]);

  let selectedWildcard;

  if ((wildcardTab !== "None") && !wildcardSlots[wildcardTab]) {
    selectedWildcard = showBasic ? "None" : Object.keys(wildcardSlots)[0];
    setWildcardTab(selectedWildcard);
  }
  else {
    selectedWildcard = wildcardTab;
  }

  return (
    <Tabs>
      {showBasic && (
        <Tabs.Tab
          selected={selectedWildcard === "None"}
          onClick={() => setWildcardTab("None")} >
          Trim:<br />{basicUsed + "/" + basicMax}
        </Tabs.Tab>
      )}

      {Object.keys(wildcardSlots).map(wildcard => {
        const wcObj = wildcardSlots[wildcard];
        let wcLimit = wcObj.limit;
        const wcUsage = wcObj.usage.length;
        const wcLeft = wcLimit - wcUsage;
        if (wcLeft < 0) {
          wcLimit = "∞";
        }
        const wcLeftStr = `${wcUsage}/${wcLimit}`;
        return (
          <Tabs.Tab
            key={wildcard}
            selected={selectedWildcard === wildcard}
            onClick={() => setWildcardTab(wildcard)} >
            {wildcard + ":"}<br />{wcLeftStr}
          </Tabs.Tab>
        );
      })}
    </Tabs>
  );
};

const RegionTabList = (props, context) => {
  const {
    accesses = [],
  } = props;

  const [
    selectedAccessName,
    setSelectedAccessName,
  ] = useSharedState(context, 'accessName', accesses[0]?.name);

  return (
    <Tabs vertical>
      {accesses.map(access => {
        const icon = (access.allSelected && "check")
          || (access.hasSelected && "minus")
          || "times";
        return (
          <Tabs.Tab
            key={access.name}
            icon={icon}
            minWidth={"100%"}
            altSelection
            selected={access.name === selectedAccessName}
            onClick={() => setSelectedAccessName(access.name)}>
            {access.name}
          </Tabs.Tab>
        );
      })}
    </Tabs>
  );
};

const RegionAccessList = (props, context) => {
  const {
    accesses = [],
    selectedList = [],
    accessMod,
    trimAccess = [],
    accessFlags = {},
    accessFlagNames = {},
    wildcardSlots = {},
    showBasic,
  } = props;

  const [
    wildcardTab,
    setWildcardTab,
  ] = useSharedState(context, "wildcardSelected", showBasic ? "None" : Object.keys(wildcardSlots)[0]);

  let selWildcard;

  if ((wildcardTab !== "None") && !wildcardSlots[wildcardTab]) {
    selWildcard = showBasic ? "None" : Object.keys(wildcardSlots)[0];
    setWildcardTab(selWildcard);
  }
  else {
    selWildcard = wildcardTab;
  }

  const [
    selectedAccessName,
  ] = useSharedState(context, 'accessName', accesses[0]?.name);

  const selectedAccess = accesses
    .find(access => access.name === selectedAccessName);
  const selectedAccessEntries = sortBy(
    entry => entry.desc,
  )(selectedAccess?.accesses || []);

  const allWildcards = Object.keys(wildcardSlots);
  let wcAccess = {};
  allWildcards.forEach(wildcard => {
    wildcardSlots[wildcard].usage.forEach(access => {
      wcAccess[access] = wildcard;
    });
  });

  const wildcard = wildcardSlots[selWildcard];
  // If there's no wildcard, -1 limit as there's infinite basic slots.
  const wcLimit = wildcard ? wildcard.limit : -1;
  const wcUsage = wildcard ? wildcard.usage.length : 0;
  const wcAvail = wcLimit - wcUsage;

  return (
    selectedAccessEntries.map(entry => {
      const id = entry.ref;
      const disableButton = (
        ((wcAvail === 0) && (wcAccess[id] !== selWildcard))
        || ((wcAvail > 0) && wcAccess[id] && wcAccess[id] !== selWildcard));
      const entryName = (!wcAccess[id] && trimAccess.includes(id))
        ? entry.desc : entry.desc + " (" + accessFlagNames[accessFlags[id]] + ")";

      return (
        <Button.Checkbox
          ml={1}
          fluid
          key={entry.desc}
          content={entryName}
          disabled={disableButton}
          checked={selectedList.includes(entry.ref)}
          onClick={() => accessMod(
            entry.ref,
            (selWildcard === "None") ? null : selWildcard)} />
      );
    })
  );
};
