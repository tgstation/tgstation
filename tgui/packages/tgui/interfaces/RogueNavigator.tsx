import { Box, Button, LabeledList, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  motto: string;
  handler_fee_percent: number;
  duty_rate: number;
  levy_rate: number;
  pay_taxes: BooleanLike;
  pay_merchant_share: BooleanLike;
  duty_collected: number;
  duty_evaded: number;
  levy_collected: number;
  next_airlift_seconds: number;
  is_proprietor: BooleanLike;
};

/** Navigator: the trading balloons' toll (Ratwood Navigator.tsx, without the market pools). */
export const RogueNavigator = () => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={420} height={330}>
      <Window.Content>
        <Section title={data.motto}>
          <Box mb={1}>
            Leave goods on the tiles around the machine. The next balloon comes
            in {data.next_airlift_seconds} seconds and pays in coin on the tile
            it took them from.
          </Box>
          <LabeledList>
            {data.handler_fee_percent > 0 && (
              <LabeledList.Item label="Handler's fee">
                {data.handler_fee_percent}%
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Crown export duty">
              {data.pay_taxes
                ? `${Math.round(data.duty_rate * 100)}%`
                : 'not paid'}
            </LabeledList.Item>
            <LabeledList.Item label="Merchant's levy">
              {data.pay_merchant_share ? `${data.levy_rate}%` : 'waived'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!!data.is_proprietor && (
          <Section title="Toll clasp">
            <Button.Checkbox
              checked={!!data.pay_taxes}
              onClick={() => act('toggle_duty')}
            >
              Pay the Crown's duty
            </Button.Checkbox>
            <Button.Checkbox
              checked={!!data.pay_merchant_share}
              onClick={() => act('toggle_levy')}
            >
              Collect the Merchant's levy
            </Button.Checkbox>
            <Box mt={1} color="label">
              Duty paid here: {data.duty_collected}m, dodged:{' '}
              {data.duty_evaded}m. Levy collected: {data.levy_collected}m.
            </Box>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
