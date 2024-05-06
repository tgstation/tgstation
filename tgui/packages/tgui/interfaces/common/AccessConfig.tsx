import { sortBy } from 'common/collections';
import { useState } from 'react';

import { Button, Section, Stack, Tabs } from '../../components';

type BaseProps = {
  accessMod: (ref: string) => void;
  denyDep: (ref: string) => void;
  grantDep: (ref: string) => void;
};

type ConfigProps = {
  accesses: Region[];
  denyAll: () => void;
  grantAll: () => void;
  selectedList: string[];
} & BaseProps;

type AccessButtonProps = {
  selectedAccess: Region;
  selectedAccessEntries: Area[];
  selectedList: string[];
} & BaseProps;

export type Region = {
  accesses: Area[];
  name: string;
};

export type Area = {
  desc: string;
  ref: string;
};

enum ACCESS {
  Denied = 0,
  Partial = 1,
  Granted = 2,
}

const DIFFMAP = [
  {
    icon: 'times-circle',
    color: 'bad',
  },
  {
    icon: 'stop-circle',
    color: null,
  },
  {
    icon: 'check-circle',
    color: 'good',
  },
] as const;

export function AccessConfig(props: ConfigProps) {
  const {
    accesses = [],
    selectedList = [],
    accessMod,
    grantAll,
    denyAll,
    grantDep,
    denyDep,
  } = props;

  const [selectedAccessName, setSelectedAccessName] = useState(
    accesses[0]?.name,
  );

  const selectedAccess =
    accesses.find((access) => access.name === selectedAccessName) ||
    accesses[0];

  const selectedAccessEntries = sortBy(
    selectedAccess?.accesses || [],
    (entry: Area) => entry.desc,
  );

  function checkAccessIcon(accesses: Area[]) {
    let oneAccess = false;
    let oneInaccess = false;
    for (let element of accesses) {
      if (selectedList.includes(element.ref)) {
        oneAccess = true;
      } else {
        oneInaccess = true;
      }
    }
    if (!oneAccess && oneInaccess) {
      return ACCESS.Denied;
    } else if (oneAccess && oneInaccess) {
      return ACCESS.Partial;
    } else {
      return ACCESS.Granted;
    }
  }

  return (
    <Section
      fill
      title="Access"
      buttons={
        <>
          <Button icon="check-double" color="good" onClick={grantAll}>
            Grant All
          </Button>
          <Button icon="undo" color="bad" onClick={denyAll}>
            Deny All
          </Button>
        </>
      }
    >
      <Stack fill>
        <Stack.Item>
          <Tabs vertical>
            {accesses.map((access) => {
              const entries = access.accesses || [];
              const icon = DIFFMAP[checkAccessIcon(entries)].icon;
              const color = DIFFMAP[checkAccessIcon(entries)].color;
              return (
                <Tabs.Tab
                  key={access.name}
                  color={color as string}
                  icon={icon}
                  selected={access.name === selectedAccessName}
                  onClick={() => setSelectedAccessName(access.name)}
                >
                  {access.name}
                </Tabs.Tab>
              );
            })}
          </Tabs>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item grow>
          <AccessButtons // lil bit of props drill here
            selectedAccessEntries={selectedAccessEntries}
            selectedList={selectedList}
            accessMod={accessMod}
            grantDep={grantDep}
            denyDep={denyDep}
            selectedAccess={selectedAccess}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
}

function AccessButtons(props: AccessButtonProps) {
  const {
    selectedAccessEntries,
    selectedList,
    accessMod,
    grantDep,
    denyDep,
    selectedAccess,
  } = props;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Stack fill>
          <Stack.Item grow>
            <Button
              fluid
              icon="check"
              color="good"
              onClick={() => grantDep(selectedAccess.name)}
            >
              Grant Region
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              fluid
              icon="times"
              color="bad"
              onClick={() => denyDep(selectedAccess.name)}
            >
              Deny Region
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item grow>
        <Section fill scrollable>
          {selectedAccessEntries.map((entry) => (
            <Button.Checkbox
              fluid
              key={entry.desc}
              checked={selectedList.includes(entry.ref)}
              onClick={() => accessMod(entry.ref)}
            >
              {entry.desc}
            </Button.Checkbox>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
}
