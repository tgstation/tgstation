import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Button, Input, LabeledList, Section, Stack } from '../components';
import { Window } from '../layouts';
import { AccessConfig, Region } from './common/AccessConfig';

type Data = {
  accesses: string[];
  oneAccess: BooleanLike;
  passedCycleId: number;
  passedName: string;
  regions: Region[];
  shell: BooleanLike;
  unres_direction: number;
};

export function AirlockElectronics(props) {
  return (
    <Window width={420} height={485}>
      <Window.Content>
        <AirLockMainSection />
      </Window.Content>
    </Window>
  );
}

export function AirLockMainSection(props) {
  const { act, data } = useBackend<Data>();
  const {
    accesses = [],
    oneAccess,
    passedName,
    passedCycleId,
    regions = [],
    unres_direction,
    shell,
  } = data;

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Section fill>
          <LabeledList>
            <LabeledList.Item label="Integrated Circuit Shell">
              <Button.Checkbox
                checked={shell}
                onClick={() => {
                  act('set_shell', { on: !shell });
                }}
                tooltip="Whether this airlock can have an integrated circuit placed inside of it or not."
              >
                Shell
              </Button.Checkbox>
            </LabeledList.Item>
            <LabeledList.Item label="Access Required">
              <Button
                icon={oneAccess ? 'unlock' : 'lock'}
                onClick={() => act('one_access')}
              >
                {oneAccess ? 'One' : 'All'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Unrestricted Access">
              <Button
                icon={unres_direction & 1 ? 'check-square-o' : 'square-o'}
                selected={unres_direction & 1}
                onClick={() =>
                  act('direc_set', {
                    unres_direction: '1',
                  })
                }
              >
                North
              </Button>
              <Button
                icon={unres_direction & 2 ? 'check-square-o' : 'square-o'}
                selected={unres_direction & 2}
                onClick={() =>
                  act('direc_set', {
                    unres_direction: '2',
                  })
                }
              >
                South
              </Button>
              <Button
                icon={unres_direction & 4 ? 'check-square-o' : 'square-o'}
                selected={unres_direction & 4}
                onClick={() =>
                  act('direc_set', {
                    unres_direction: '4',
                  })
                }
              >
                East
              </Button>
              <Button
                icon={unres_direction & 8 ? 'check-square-o' : 'square-o'}
                selected={unres_direction & 8}
                onClick={() =>
                  act('direc_set', {
                    unres_direction: '8',
                  })
                }
              >
                West
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Airlock Name">
              <Input
                fluid
                maxLength={30}
                value={passedName}
                onChange={(e, value) =>
                  act('passedName', {
                    passedName: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Cycling Id">
              <Input
                fluid
                maxLength={30}
                value={passedCycleId}
                onChange={(e, value) =>
                  act('passedCycleId', {
                    passedCycleId: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <AccessConfig
          accesses={regions}
          selectedList={accesses}
          accessMod={(ref) =>
            act('set', {
              access: ref,
            })
          }
          grantAll={() => act('grant_all')}
          denyAll={() => act('clear_all')}
          grantDep={(ref) =>
            act('grant_region', {
              region: ref,
            })
          }
          denyDep={(ref) =>
            act('deny_region', {
              region: ref,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
}
