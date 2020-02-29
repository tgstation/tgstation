import { multiline } from 'common/string';
import { Fragment } from 'inferno';
import { act } from '../byond';
import { Section, LabeledList, Button, NumberInput, Box, Grid } from '../components';

export const Bepis = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    amount,
  } = data;
  return (
    <Section title="Business Exploration Protocol Incubation Sink">
      <Section 
        title="Information"
        backgroundColor="#450F44"
        buttons={(
          <Button
            icon="power-off"
            content={data.manual_power ? 'Off' : 'On'}
            selected={!data.manual_power}
            onClick={() => act(ref, 'toggle_power')} />
        )}>
        All you need to know about the B.E.P.I.S. and you!
        The B.E.P.I.S. performs hundreds of tests a second
        using electrical and financial resources to invent
        new products, or discover new technologies otherwise
        overlooked for being too risky or too niche to produce!
      </Section>
      <Section 
        title="Payer's Account"
        buttons={(
          <Button
            icon="redo-alt"
            content="Reset Account"
            onClick={() => act(ref, 'account_reset')} />
        )}>
        Console is currently being operated
        by {data.account_owner ? data.account_owner : 'no one'}.
      </Section>
      <Grid>
        <Grid.Column size={1.5}>
          <Section title="Stored Data and Statistics">
            <LabeledList>
              <LabeledList.Item label="Deposited Credits">
                {data.stored_cash}
              </LabeledList.Item>
              <LabeledList.Item label="Investment Variability">
                {data.accuracy_percentage}%
              </LabeledList.Item>
              <LabeledList.Item label="Innovation Bonus">
                {data.positive_cash_offset}
              </LabeledList.Item>
              <LabeledList.Item label="Risk Offset"
                color="bad">
                {data.negative_cash_offset}
              </LabeledList.Item>
              <LabeledList.Item label="Deposit Amount">
                <NumberInput
                  value={amount}
                  unit="Credits"
                  minValue={100}
                  maxValue={30000}
                  step={100}
                  stepPixelSize={2}
                  onChange={(e, value) => act(ref, 'amount', {
                    amount: value,
                  })} />
              </LabeledList.Item>
            </LabeledList>
          </Section>
          <Box>
            <Button
              icon="donate"
              content="Deposit Credits"
              disabled={data.manual_power === 1 || data.silicon_check === 1}
              onClick={() => act(ref, 'deposit_cash')}
            />
            <Button
              icon="eject"
              content="Withdraw Credits"
              disabled={data.manual_power === 1}
              onClick={() => act(ref, 'withdraw_cash')} />
          </Box>
        </Grid.Column>
        <Grid.Column>
          <Section title="Market Data and Analysis">
            <Box>
              Average technology cost: {data.mean_value}
            </Box>
            <Box>
              Current chance of Success: Est. {data.success_estimate}%
            </Box>
            {data.error_name && (
              <Box color="bad">
                Previous Failure Reason: Deposited cash value too low.
                Please insert more money for future success.
              </Box>
            )}
            <Box m={1} />
            <Button
              icon="microscope"
              disabled={data.manual_power === 1}
              onClick={() => act(ref, 'begin_experiment')}
              content="Begin Testing" />
          </Section>
        </Grid.Column>
      </Grid>
    </Section>
  );
};
