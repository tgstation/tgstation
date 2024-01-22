import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Button, NoticeBox, Section, Stack } from '../components';
import { Window } from '../layouts';

type Data = {
  interior_door: string;
  exterior_door: string;
  interior_door_closed: BooleanLike;
  exterior_door_closed: BooleanLike;
  busy: BooleanLike;
};

export const AirlockButtonController = (props) => {
  const { data } = useBackend<Data>();
  const { interior_door, exterior_door } = data;
  return (
    <Window width={500} height={170}>
      <Window.Content>
        <Section title="Airlock Controller" textAlign="center">
          {!interior_door && !exterior_door ? (
            <NoticeBox danger>No doors detected</NoticeBox>
          ) : (
            <Stack>
              {interior_door && (
                <Stack.Item grow textAlign="center">
                  <RetrieveButton airlockType={interior_door} />
                </Stack.Item>
              )}
              {exterior_door && (
                <Stack.Item grow textAlign="center">
                  <RetrieveButton airlockType={exterior_door} />
                </Stack.Item>
              )}
            </Stack>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};

const RetrieveButton = (props) => {
  const { act, data } = useBackend<Data>();
  const { interior_door, interior_door_closed, exterior_door_closed, busy } =
    data;
  const { airlockType } = props;
  const our_door_closed =
    airlockType === interior_door ? interior_door_closed : exterior_door_closed;
  const opposite_door_closed =
    airlockType === interior_door ? exterior_door_closed : interior_door_closed;

  return (
    <Button
      mt={2}
      icon={our_door_closed ? 'lock-open' : 'lock'}
      color="green"
      fontSize={1.5}
      textAlign="center"
      lineHeight="1.5"
      disabled={busy}
      onClick={() => {
        if (!our_door_closed) {
          act('close', {
            requested_door: airlockType,
          });
        } else {
          act('open', {
            requested_door: airlockType,
          });
        }
      }}
    >
      {!our_door_closed
        ? `Close ${
            airlockType === interior_door ? 'interior door' : 'exterior door'
          }`
        : opposite_door_closed
          ? `Open ${
              airlockType === interior_door ? 'interior door' : 'exterior door'
            }`
          : `Cycle to ${
              airlockType === interior_door ? 'interior door' : 'exterior door'
            }`}
    </Button>
  );
};
