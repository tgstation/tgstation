import { sortBy } from 'common/collections';
import { useLocalState } from '../../backend';
import { Box, Button, Flex, Section, Tabs } from '../../components';
import { createLogger } from '../../logging';

const logger = createLogger("Ass")

const diffMap = {
  0: {
    icon: 'times-circle',
    color: 'bad',
  },
  1: {
    icon: 'stop-circle',
    color: null,
  },
  2: {
    icon: 'check-circle',
    color: 'good',
  },
};

export const AccessList = (props, context) => {
  const {
    accesses = [],
    selectedList = [],
    accessMod,
    terminateEmployment,
    wildcardSlots = {},
    wildcardFlags = {},
    trimAccess = [],
    accessFlags = {},
    accessFlagNames = {},
  } = props;
  const [
    selectedAccessName,
    setSelectedAccessName,
  ] = useLocalState(context, 'accessName', accesses[0]?.name);
  const selectedAccess = accesses
    .find(access => access.name === selectedAccessName);
  const selectedAccessEntries = sortBy(
    entry => entry.desc,
  )(selectedAccess?.accesses || []);

  const checkAccessIcon = accesses => {
    let oneAccess = false;
    let oneInaccess = false;
    for (let element of accesses) {
      if (selectedList.includes(element.ref)) {
        oneAccess = true;
      }
      else {
        oneInaccess = true;
      }
    }
    if (!oneAccess && oneInaccess) {
      return 0;
    }
    else if (oneAccess && oneInaccess) {
      return 1;
    }
    else {
      return 2;
    }
  };

  const allWildcards = Object.keys(wildcardSlots)
  let wildcardUsage = {}
  let combinedWildcardBitflags = 0
  allWildcards.forEach(wildcard => {
    if((wildcardSlots[wildcard].limit - wildcardSlots[wildcard].usage.length) != 0) {
      combinedWildcardBitflags |= wildcardFlags[wildcard]
    }
    wildcardSlots[wildcard].usage.forEach(access => {
      wildcardUsage[access] = wildcard
    })
  })

  return (
    <Section
      title="Access"
      buttons={
        <Button.Confirm
          content="Terminate Employment"
          confirmContent="Fire Employee?"
          color="bad"
          onClick={() => terminateEmployment()}/>
      }>
      <Flex wrap="wrap">
        <Flex.Item width="100%">
          <FormatWildcards
            wildcardSlots={wildcardSlots} />
        </Flex.Item>
        <Flex.Item>
          <Tabs
            vertical>
            {accesses.map(access => {
              const entries = access.accesses || [];
              const icon = diffMap[checkAccessIcon(entries)].icon;
              const color = diffMap[checkAccessIcon(entries)].color;
              return (
                <Tabs.Tab
                  key={access.name}
                  minWidth={"100%"}
                  altSelection
                  color={color}
                  icon={icon}
                  selected={access.name === selectedAccessName}
                  onClick={() => setSelectedAccessName(access.name)}>
                  {access.name}
                </Tabs.Tab>
              );
            })}
          </Tabs>
        </Flex.Item>
        <Flex.Item grow={1}>
          {selectedAccessEntries.map(entry => {
            if (selectedList.includes(entry.ref) || trimAccess.includes(entry.ref)) {
              return (
                <Button.Checkbox
                  ml={1}
                  fluid
                  key={entry.desc}
                  content={wildcardUsage[entry.ref] ? entry.desc + " (W " + wildcardUsage[entry.ref] + ")" : entry.desc}
                  checked={selectedList.includes(entry.ref)}
                  onClick={() => accessMod(entry.ref)} />
              )
            } else if((accessFlags[entry.ref] & combinedWildcardBitflags)) {
              return (
                <Button.Checkbox
                  ml={1}
                  fluid
                  color="average"
                  key={entry.desc}
                  content={wildcardUsage[entry.ref] ? entry.desc : entry.desc + " (W " + accessFlagNames[accessFlags[entry.ref]] + ")"}
                  checked={selectedList.includes(entry.ref)}
                  onClick={() => accessMod(entry.ref)} />
              )}
              else {
                return (
                  <Button.Checkbox
                    ml={1}
                    fluid
                    disabled
                    key={entry.desc}
                    content={wildcardUsage[entry.ref] ? entry.desc : entry.desc + " (W " + accessFlagNames[accessFlags[entry.ref]] + ")"}
                    checked={selectedList.includes(entry.ref)}
                    onClick={() => accessMod(entry.ref)} />
                )
              }
          })}
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const FormatWildcards = (props, context) => {
  const {
    wildcardSlots = {},
  } = props;

  return (
    <Section title="Wildcards">
        {Object.keys(wildcardSlots).map(wildcard => (
          <Box>
            {wildcard + ": " +
              (((wildcardSlots[wildcard].limit - wildcardSlots[wildcard].usage.length) >= 0 && (wildcardSlots[wildcard].limit - wildcardSlots[wildcard].usage.length).toString())
              || "Infinite")}
          </Box>
        ))}
    </Section>
  );
};
