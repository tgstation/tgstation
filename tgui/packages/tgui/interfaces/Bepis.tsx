import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Grid, LabeledList, NumberInput, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  amount: number;
  account_owner: string;
  manual_power: BooleanLike;
  stored_cash: number;
  accuracy_percentage: number;
  positive_cash_offset: number;
  negative_cash_offset: number;
  silicon_check: BooleanLike;
  success_estimate: number;
  mean_value: number;
  error_name: string;
};

const BEPIS_SLOGAN = `All you need to know about the B.E.P.I.S. and you! The
B.E.P.I.S. performs hundreds of tests a second using
electrical and financial resources to invent new products,
or discover new technologies otherwise overlooked for being
too risky or too niche to produce!`;

export const Bepis = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const {
    amount,
    account_owner,
    manual_power,
    stored_cash,
    accuracy_percentage,
    positive_cash_offset,
    negative_cash_offset,
    silicon_check,
    success_estimate,
    mean_value,
    error_name,
  } = data;

  return (
    <Window width={500} height={480}>
      <Window.Content>
        <Section title="Business Exploration Protocol Incubation Sink">
          <Section
            title="Information"
            backgroundColor="#450F44"
            buttons={
              <Button
                icon="power-off"
                content={manual_power ? 'Off' : 'On'}
                selected={!manual_power}
                onClick={() => act('toggle_power')}
              />
            }>
            {BEPIS_SLOGAN}
          </Section>
          <Section
            title="Payer's Account"
            buttons={
              <Button
                icon="redo-alt"
                content="Reset Account"
                onClick={() => act('account_reset')}
              />
            }>
            Console is currently being operated by{' '}
            {account_owner ? account_owner : 'no one'}.
          </Section>
          <Grid>
            <Grid.Column size={1.5}>
              <Section title="Stored Data and Statistics">
                <LabeledList>
                  <LabeledList.Item label="Available Credits">
                    {stored_cash}
                  </LabeledList.Item>
                  <LabeledList.Item label="Investment Variability">
                    {accuracy_percentage}%
                  </LabeledList.Item>
                  <LabeledList.Item label="Innovation Bonus">
                    {positive_cash_offset}
                  </LabeledList.Item>
                  <LabeledList.Item label="Risk Offset" color="bad">
                    {negative_cash_offset}
                  </LabeledList.Item>
                  <LabeledList.Item label="Deposit Amount">
                    <NumberInput
                      value={amount}
                      unit="Credits"
                      minValue={100}
                      maxValue={30000}
                      step={100}
                      stepPixelSize={2}
                      onChange={(e, value) =>
                        act('amount', {
                          amount: value,
                        })
                      }
                    />
                  </LabeledList.Item>
                </LabeledList>
              </Section>
              <Box>
                <Button
                  icon="donate"
                  content="Deposit Credits and Start"
                  disabled={manual_power === 1 || silicon_check === 1}
                  onClick={() => act('begin_experiment')}
                />
              </Box>
            </Grid.Column>
            <Grid.Column>
              <Section title="Market Data and Analysis">
                <Box>Average technology cost: {mean_value}</Box>
                <Box>Current chance of Success: Est. {success_estimate}%</Box>
                {error_name && (
                  <Box color="bad">
                    Previous Failure Reason: Deposited cash value too low.
                    Please insert more money for future success.
                  </Box>
                )}
              </Section>
            </Grid.Column>
          </Grid>
        </Section>
      </Window.Content>
    </Window>
  );
};
