import { BlockQuote, Button, Flex, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  locked: BooleanLike;
  stated_laws: string[];
  all_laws: string[];
};

export const StateLawUi = () => {
  const { data, act } = useBackend<Data>();
  const { locked, stated_laws, all_laws } = data;

  return (
    <Window
      title="State Laws"
      width={400}
      height={Math.max(1, all_laws.length) * 55 + 150}
    >
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Section
          title="Which laws do you want to include when stating them for the crew?"
          scrollable
        >
          <Stack vertical>
            {all_laws.length === 0 ? (
              <Stack.Item>
                <BlockQuote>No laws available!</BlockQuote>
              </Stack.Item>
            ) : (
              <>
                {all_laws.map((law, index) => (
                  <Stack.Item key={index} className="candystripe">
                    <Flex align="center" p={0.5}>
                      <Flex.Item mr={0.5}>
                        <Button.Checkbox
                          iconSize={2}
                          checked={stated_laws.includes(law)}
                          onClick={() => act('toggle_stated', { law: law })}
                        />
                      </Flex.Item>
                      <Flex.Item grow={1}>
                        <BlockQuote>{law}</BlockQuote>
                      </Flex.Item>
                    </Flex>
                  </Stack.Item>
                ))}
              </>
            )}
          </Stack>
        </Section>
        <Section>
          <Button.Confirm
            width="100%"
            textAlign="center"
            fontSize="20px"
            color="blue"
            confirmColor="green"
            disabled={locked}
            onClick={() => act('state_laws')}
          >
            {locked ? 'On Cooldown' : 'State Laws'}
          </Button.Confirm>
        </Section>
      </Window.Content>
    </Window>
  );
};
