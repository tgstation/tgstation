import React from 'react';
import { useBackend } from 'tgui/backend';
import { BotControl, BotSettings } from 'tgui/interfaces/SimpleBot';
import { Window } from 'tgui/layouts';
import {
  Button,
  DmIcon,
  Flex,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

type Data = {
  can_hack: BooleanLike;
  custom_controls: Record<string, number>;
  emagged: BooleanLike;
  has_access: BooleanLike;
  locked: BooleanLike;
  settings: Settings;
  repairbot_materials: RepairbotMaterials[];
};

type RepairbotMaterials = {
  material_ref: string;
  material_name: string;
  material_icon: string;
  material_icon_state: string;
};

type Settings = {
  airplane_mode: BooleanLike;
  allow_possession: BooleanLike;
  has_personality: BooleanLike;
  maintenance_lock: BooleanLike;
  pai_inserted: boolean;
  patrol_station: BooleanLike;
  possession_enabled: BooleanLike;
  power: BooleanLike;
};

export function RepairBot(props) {
  const { data } = useBackend<Data>();
  const { can_hack, locked } = data;
  const access = !locked || !!can_hack;

  return (
    <Window width={450} height={415}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <BotSettings />
          </Stack.Item>
          {!!access && (
            <>
              <Stack.Item grow>
                <BotControl />
              </Stack.Item>
              <Stack.Item grow>
                <RepairBotMats />
              </Stack.Item>
            </>
          )}
        </Stack>
      </Window.Content>
    </Window>
  );
}

function RepairBotMats(props) {
  const { act, data } = useBackend<Data>();
  const { repairbot_materials } = data;

  return (
    <Section title="Materials" minHeight="100px">
      {repairbot_materials.length === 0 && <NoticeBox>No Materials!</NoticeBox>}
      <Flex style={{ padding: '0% 25%' }}>
        {repairbot_materials.map((mat) => (
          <Flex.Item grow key={mat.material_ref}>
            <Button
              color="transparent"
              onClick={() =>
                act('remove_item', {
                  item_reference: mat.material_ref,
                })
              }
            >
              <DmIcon
                icon={mat.material_icon}
                icon_state={mat.material_icon_state}
                height="48px"
                width="48px"
              />
            </Button>
          </Flex.Item>
        ))}
      </Flex>
    </Section>
  );
}
