import { sortBy } from 'es-toolkit';
import { Box, Button, Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { EMAG_SHUTTLE_NOTICE } from './constants';
import { type CommsConsoleData, type Shuttle, ShuttleState } from './types';

function sortShuttles(shuttles: CommsConsoleData['shuttles']) {
  return sortBy(shuttles, [
    (shuttle) => !shuttle.emagOnly,
    (shuttle) => shuttle.initial_cost,
  ]);
}

export function PageBuyingShuttle(props) {
  const { act, data } = useBackend<CommsConsoleData>();
  const { budget, shuttles } = data;

  return (
    <Box>
      <Section>
        <Stack fill align="center" justify="space-between">
          <Button
            icon="chevron-left"
            onClick={() => act('setState', { state: ShuttleState.MAIN })}
          >
            Back
          </Button>

          <div>
            <Box as="span" bold color="good">
              {budget.toString()} cr
            </Box>{' '}
            <Icon name="coins" color="gold" />
          </div>
        </Stack>
      </Section>

      {sortShuttles(shuttles).map((shuttle) => (
        <ShuttleCard key={shuttle.ref} shuttle={shuttle} />
      ))}
    </Box>
  );
}

type ShuttleCardProps = {
  shuttle: Shuttle;
};

function ShuttleCard(props: ShuttleCardProps) {
  const { shuttle } = props;

  const { act, data } = useBackend<CommsConsoleData>();
  const {
    budget,
    displayed_currency_name,
    displayed_currency_full_name,
    emagged,
  } = data;

  const isButtonDisabled = budget < shuttle.creditCost;

  let buttonTooltip: string | undefined;
  if (budget < shuttle.creditCost) {
    buttonTooltip = `You need ${shuttle.creditCost - budget} more ${displayed_currency_full_name}.`;
  } else if (shuttle.department_locked) {
    buttonTooltip = `Requires ${shuttle.department_name} Department to have the highest employees count.`;
  } else if (shuttle.emagOnly) {
    buttonTooltip = EMAG_SHUTTLE_NOTICE;
  }

  return (
    <Section
      title={
        <span
          style={{
            display: 'inline-block',
            width: '70%',
          }}
        >
          {shuttle.name}
        </span>
      }
      buttons={
        <Button
          color={
            shuttle.department_locked
              ? 'danger'
              : shuttle.emagOnly
                ? 'red'
                : 'default'
          }
          disabled={isButtonDisabled}
          onClick={() =>
            act('purchaseShuttle', {
              shuttle: shuttle.ref,
            })
          }
          tooltip={buttonTooltip}
          tooltipPosition="left"
        >
          {shuttle.department_locked
            ? 'Locked'
            : shuttle.emagOnly && !emagged
              ? 'Buy'
              : `${shuttle.creditCost} ${displayed_currency_name}`}
        </Button>
      }
    >
      <Box>{shuttle.description}</Box>
      <Box color="teal" fontSize="10px" italic>
        Occupancy Limit: {shuttle.occupancy_limit}
      </Box>
      <Box color="violet" fontSize="10px" bold>
        {shuttle.prerequisites && <b>Prerequisites: {shuttle.prerequisites}</b>}
      </Box>
      {!!shuttle.department_locked && (
        <Box
          color="red"
          style={{ marginTop: '4px', fontSize: '10px', fontWeight: 'bold' }}
        >
          This shuttle can only be purchased if {shuttle.department_name}{' '}
          Department has biggest number of employees!
        </Box>
      )}
    </Section>
  );
}
