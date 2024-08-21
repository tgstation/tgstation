import { Button, LabeledList } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { AccessConfig, Region } from './common/AccessConfig';

type Data = {
  oneAccess: BooleanLike;
  regions: Region[];
  accesses: string[];
};

export const CircuitAccessChecker = (props) => {
  const { act, data } = useBackend<Data>();
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
