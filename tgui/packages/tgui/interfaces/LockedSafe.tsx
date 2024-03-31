import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Flex } from '../components';
import { Window } from '../layouts';
import { NukeKeypad } from './NuclearBomb';

type Data = {
  input_code: string;
  locked: BooleanLike;
  lock_set: BooleanLike;
  lock_code: BooleanLike;
};

export const LockedSafe = (props) => {
  const { act, data } = useBackend<Data>();
  const { input_code, locked, lock_code } = data;
  return (
    <Window width={195} height={430} theme="retro">
      <Window.Content>
        <Flex direction="column" justify="center" width={'170px'} m="6px">
          <Flex.Item className="NuclearBomb__displayBox">
            {input_code}
          </Flex.Item>
          <Flex.Item className="NuclearBomb__displayBox">
            {!lock_code && 'No password set.'}
            {!!lock_code && (!locked ? 'Unlocked' : 'Locked')}
          </Flex.Item>
          <Flex.Item ml="3px">
            <NukeKeypad />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
