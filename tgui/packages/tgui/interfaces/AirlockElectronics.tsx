import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Button, Input, LabeledList, Section } from '../components';
import { Window } from '../layouts';
import { AccessConfig } from './common/AccessConfig';

type Data = {
  oneAccess: BooleanLike;
  unres_direction: number;
  passedName: string;
  passedCycleId: number;
  regions: string[];
  accesses: string[];
  shell: BooleanLike;
};

export const AirlockElectronics = (props, context) => {
  const { act, data } = useBackend<Data>(context);
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
    <Window width={420} height={485}>
      <Window.Content>
        <Section title="Main">
          <LabeledList>
            <LabeledList.Item label="Integrated Circuit Shell">
              <Button.Checkbox
                content="Shell"
                checked={shell}
                onClick={() => {
                  act('set_shell', { on: !shell });
                }}
                tooltip="Whether this airlock can have an integrated circuit placed inside of it or not."
              />
            </LabeledList.Item>
            <LabeledList.Item label="Access Required">
              <Button
                icon={oneAccess ? 'unlock' : 'lock'}
                content={oneAccess ? 'One' : 'All'}
                onClick={() => act('one_access')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Unrestricted Access">
              <Button
                icon={unres_direction & 1 ? 'check-square-o' : 'square-o'}
                content="North"
                selected={unres_direction & 1}
                onClick={() =>
                  act('direc_set', {
                    unres_direction: '1',
                  })
                }
              />
              <Button
                icon={unres_direction & 2 ? 'check-square-o' : 'square-o'}
                content="South"
                selected={unres_direction & 2}
                onClick={() =>
                  act('direc_set', {
                    unres_direction: '2',
                  })
                }
              />
              <Button
                icon={unres_direction & 4 ? 'check-square-o' : 'square-o'}
                content="East"
                selected={unres_direction & 4}
                onClick={() =>
                  act('direc_set', {
                    unres_direction: '4',
                  })
                }
              />
              <Button
                icon={unres_direction & 8 ? 'check-square-o' : 'square-o'}
                content="West"
                selected={unres_direction & 8}
                onClick={() =>
                  act('direc_set', {
                    unres_direction: '8',
                  })
                }
              />
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
      </Window.Content>
    </Window>
  );
};
