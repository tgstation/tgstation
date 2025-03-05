import { Box, Flex } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
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
    <Window width={300} height={400} theme="ntos">
      <Window.Content>
        <Box m="6px">
          <Box mb="6px" className="NuclearBomb__displayBox">
            {input_code}
          </Box>
          <Box className="NuclearBomb__displayBox">
            {!lock_code && 'No password set.'}
            {!!lock_code && (!locked ? 'Unlocked' : 'Locked')}
          </Box>
          <Flex ml="3px">
            <Flex.Item>
              <NukeKeypad />
            </Flex.Item>
          </Flex>
        </Box>
      </Window.Content>
    </Window>
  );
};
