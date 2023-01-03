import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Stack } from '../components';
import { Window } from '../layouts';

type BasketballPanelData = {
  voters: number;
  voters_required: number;
  voted: BooleanLike;
};

export const BasketballPanel = (props, context) => {
  const { act, data } = useBackend<BasketballPanelData>(context);

  return (
    <Window title="Basketball Panel" width={700} height={600}>
      <Window.Content scrollable>
        <Stack fill align="center" justify="center" vertical>
          <Stack.Item mb={5}>
            <Box fontSize="90px" textAlign="center">
              {data.voters}/{data.voters_required}
            </Box>
            <br />
            <Box fontSize="30px" textAlign="center">
              Basketball voters
            </Box>
          </Stack.Item>

          <Stack.Item>
            <Button
              fontSize="24px"
              color={data.voted ? 'bad' : 'good'}
              onClick={() => {
                if (data.voted) {
                  act('unvote');
                } else {
                  act('vote');
                }
              }}>
              {data.voted ? 'Unvote for Basketball' : 'Vote for Basketball'}
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
