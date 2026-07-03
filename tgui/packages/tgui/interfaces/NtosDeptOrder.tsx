import { useState } from 'react';
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
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

// 3.5x crate value, 10 minutes
const COST_MODERATE_BOUND = 700;
// 13.5x crate value, 15 minutes
const COST_LONG_BOUND = 2700;
// 40x crate value, 20 minutes
const COST_VERY_LONG_BOUND = 8000;

type typePath = string;

type Pack = {
  name: string;
  desc: string;
  cost: number;
  id: typePath;
  highlight?: boolean;
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
    (cost >= COST_VERY_LONG_BOUND && 'red') ||
    (cost >= COST_LONG_BOUND && 'orange') ||
    (cost >= COST_MODERATE_BOUND && 'yellow') ||
    'green';
  const cooldownText =
    (cost >= COST_VERY_LONG_BOUND && 'Очень долгое') ||
    (cost >= COST_LONG_BOUND && 'Долгое') ||
    (cost >= COST_MODERATE_BOUND && 'Умеренное') ||
    'Недолгое';
  return (
    <Box as="span" textColor={cooldownColor}>
      {cooldownText} время ожидания.
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
              Как сотруднику NanoTrasen, выбор заказов здесь совершенно
              бесплатный, только накладывается отсрочка на обслуживание. Более
              дешевые товары заставят вас ждать меньше времени, прежде чем
              NanoTrasen разрешит повторную покупку, чтобы поощрить чувство
              вкуса.
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
    <NtosWindow title="Заказы отдела" width={620} height={580}>
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
          Готовы к новому заказу через {time_left}...
        </Stack.Item>
        <Stack.Item textAlign="center" color="orange">
          <Button
            width="300px"
            lineHeight={2}
            tooltip={
              (!!can_override &&
                'Это действие требует доступа главы отдела!') ||
              'Ящик уже отправлен! Теперь отмена невозможна!'
            }
            fontSize="14px"
            color="red"
            disabled={!can_override}
            onClick={() => act('override_order')}
          >
            <Box fontSize="22px">Отменить</Box>
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
            Пожалуйста, вставьте серебряный ID главы.
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
                      <Stack.Item className="candystripe" key={pack.name}
              style={{
    backgroundColor: pack.highlight ? 'rgba(255, 255, 0, 0.15)' : undefined,
  }}>
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
                      Заказать
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
