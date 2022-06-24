import { useBackend } from '../backend';
import { Window } from '../layouts';
import { LabeledList, Button } from '../components';
import { AccessConfig } from './common/AccessConfig';
import { BooleanLike } from 'common/react';

type Data = {
  oneAccess: BooleanLike;
  regions: string[];
  accesses: string[];
};

export const CircuitAccessChecker = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { oneAccess, regions = [], accesses = [] } = data;

  return (
    <Window width={420} height={360}>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item label="Access Required">
            <Button
              icon={oneAccess ? 'unlock' : 'lock'}
              content={oneAccess ? 'One' : 'All'}
              onClick={() => act('one_access')}
            />
          </LabeledList.Item>
        </LabeledList>
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
