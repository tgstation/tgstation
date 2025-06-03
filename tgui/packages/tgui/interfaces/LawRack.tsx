import { Button, Flex, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

enum SlotSecurity {
  NONE = 0,
  SCREWED = 1,
  WELDED = 2,
}

type SlotData = {
  name: string;
  security: SlotSecurity;
  ioned: BooleanLike;
  empty: BooleanLike;
};

type Data = {
  slots: SlotData[];
  holding_module: BooleanLike;
  holding_screwdriver: BooleanLike;
  holding_welder: BooleanLike;
  holding_multitool: BooleanLike;
  linked: string | null;
};

function getSlotColor(slot: SlotData, index: number): string {
  if (slot.empty) return index === 0 ? 'lightsteelblue' : 'lightslategray';
  if (slot.ioned) return 'darkred';
  return index === 0 ? 'navy' : 'green';
}

export const LawRack = () => {
  const { act, data } = useBackend<Data>();
  const {
    slots,
    holding_module,
    holding_screwdriver,
    holding_welder,
    holding_multitool,
    linked,
  } = data;

  return (
    <Window title="Law Rack" width={350} height={600}>
      <Window.Content>
        <Section>
          <Stack vertical>
            {slots.map((slot, index) => (
              <Stack.Item
                key={index}
                backgroundColor={getSlotColor(slot, index)}
                p={1}
                style={{
                  borderRadius: '4px',
                }}
              >
                <Flex>
                  <Flex.Item pr={0.5} width="100%">
                    <Button
                      fluid
                      disabled={
                        (!holding_module && slot.empty) ||
                        slot.security !== SlotSecurity.NONE
                      }
                      onClick={() =>
                        act(
                          holding_module && slot.empty
                            ? 'insert_module'
                            : 'remove_module',
                          { slot: index + 1 },
                        )
                      }
                    >
                      {slot.name}
                    </Button>
                  </Flex.Item>
                  <Flex.Item pr={0.5}>
                    <Button
                      icon="screwdriver"
                      color={
                        slot.security === SlotSecurity.SCREWED ||
                        slot.security === SlotSecurity.WELDED
                          ? 'yellow'
                          : undefined
                      }
                      disabled={
                        !holding_screwdriver ||
                        slot.empty ||
                        slot.security === SlotSecurity.WELDED
                      }
                      onClick={() => act('screw_module', { slot: index + 1 })}
                    />
                  </Flex.Item>
                  <Flex.Item pr={0.5}>
                    <Button
                      icon="fire"
                      color={
                        slot.security === SlotSecurity.WELDED
                          ? 'yellow'
                          : undefined
                      }
                      disabled={
                        !holding_welder ||
                        slot.empty ||
                        slot.security === SlotSecurity.NONE
                      }
                      onClick={() => act('weld_module', { slot: index + 1 })}
                    />
                  </Flex.Item>
                  <Flex.Item pr={0.5}>
                    <Button
                      icon="bug"
                      color={slot.ioned ? 'yellow' : undefined}
                      disabled={!holding_multitool || slot.empty || !slot.ioned}
                      onClick={() =>
                        act('multitool_module', { slot: index + 1 })
                      }
                    />
                  </Flex.Item>
                </Flex>
              </Stack.Item>
            ))}
            <Stack.Divider />
            <Stack.Item>Linked to {linked || 'nothing'}</Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
