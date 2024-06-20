import { BooleanLike } from 'common/react';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Blink,
  Box,
  Button,
  Dimmer,
  Icon,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from '../components';
import { NtosWindow } from '../layouts';

// 15x crate value
const COST_UPPER_BOUND = 3000;

type typePath = string;

type Pack = {
  name: string;
  desc: string;
  cost: number;
  id: typePath;
};

type Category = {
  name: string;
  packs: Pack[];
};

type Info = {
  can_override: BooleanLike;
  time_left: string | null;
  supplies: Category[];
  no_link: BooleanLike;
  id_inside: BooleanLike;
};

const CooldownEstimate = (props) => {
  const { cost } = props;
  const cooldownColor =
    (cost > COST_UPPER_BOUND * 0.75 && 'red') ||
    (cost > COST_UPPER_BOUND * 0.25 && 'orange') ||
    'green';
  const cooldownText =
    (cost > COST_UPPER_BOUND * 0.75 && 'long') ||
    (cost > COST_UPPER_BOUND * 0.25 && 'moderate') ||
    'short';
  return (
    <Box as="span" textColor={cooldownColor}>
      {cooldownText} cooldown.
    </Box>
  );
};

export const DepartmentOrderContent = (props) => {
  const { data } = useBackend<Info>();
  const { no_link, time_left } = data;
  if (!data) {
    return null;
  }

  if (no_link) {
    return <NoLinkDimmer />;
  }
  if (time_left) {
    return <CooldownDimmer />;
  }

  return (
    <Stack vertical fill>
      <Stack.Item grow>
        <Stack fill vertical>
          <Stack.Item>
            <NoticeBox info>
              As employees of Nanotrasen, the selection of orders here are
              completely free of charge, only incurring a cooldown on the
              service. Cheaper items will make you wait for less time before
              Nanotrasen allows another purchase, to encourage tasteful
              spending.
            </NoticeBox>
          </Stack.Item>
          <Stack.Item grow>
            <DepartmentCatalog />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

export const NtosDeptOrder = () => {
  return (
    <NtosWindow title="Department Orders" width={620} height={580}>
      <NtosWindow.Content>
        <DepartmentOrderContent />
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const CooldownDimmer = () => {
  const { act, data } = useBackend<Info>();
  const { can_override, time_left } = data;
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item textAlign="center">
          <Icon color="bug" name="route" size={20} />
        </Stack.Item>
        <Stack.Item fontSize="18px" color="orange">
          Ready for another order in {time_left}...
        </Stack.Item>
        <Stack.Item textAlign="center" color="orange">
          <Button
            width="300px"
            lineHeight={2}
            tooltip={
              (!!can_override &&
                'This action requires Head of Staff access!') ||
              'Crate already shipped! No cancelling now!'
            }
            fontSize="14px"
            color="red"
            disabled={!can_override}
            onClick={() => act('override_order')}
          >
            <Box fontSize="22px">Override</Box>
          </Button>
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const NoLinkDimmer = () => {
  const { act, data } = useBackend<Info>();
  const { id_inside } = data;
  return (
    <Dimmer>
      <Stack vertical>
        <Stack.Item textAlign="center">
          <Blink>
            <Icon color="red" name="exclamation" size={16} opacity={0.8} />
          </Blink>
        </Stack.Item>
        <Stack.Item textAlign="center" fontSize="22px" color="red">
          Unlinked!
        </Stack.Item>
        <Stack.Item textAlign="center" fontSize="14px" color="red">
          <Button disabled={!id_inside} onClick={() => act('link')}>
            Please insert a silver Head of Staff ID and press to continue.
          </Button>
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const DepartmentCatalog = () => {
  const { act, data } = useBackend<Info>();
  const { supplies } = data;
  const [tabCategory, setTabCategory] = useState(supplies[0]);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Tabs textAlign="center" fluid>
          {supplies.map((cat) => (
            <Tabs.Tab
              key={cat.name}
              selected={tabCategory === cat}
              onClick={() => setTabCategory(cat)}
            >
              {cat.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        <Section fill scrollable>
          <Stack vertical>
            {tabCategory.packs.map((pack) => (
              <Stack.Item className="candystripe" key={pack.name}>
                <Stack fill>
                  <Stack.Item grow>
                    <Tooltip content={pack.desc}>
                      <Box
                        as="span"
                        style={{
                          borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
                        }}
                      >
                        {pack.name}
                      </Box>
                    </Tooltip>
                  </Stack.Item>
                  <Stack.Item>
                    <CooldownEstimate cost={pack.cost} />
                    &ensp;
                    <Button
                      onClick={() =>
                        act('order', {
                          id: pack.id,
                        })
                      }
                    >
                      Order
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
