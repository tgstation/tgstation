import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';

import { useBackend } from '../../backend';
import { CargoData } from './types';

export function CargoStatus(props) {
  const { act, data } = useBackend<CargoData>();
  const {
    department,
    grocery,
    away,
    docked,
    loan,
    loan_dispatched,
    location,
    message,
    points,
    requestonly,
    can_send,
  } = data;

  return (
    <Section
      title={department}
      buttons={
        <Box inline bold verticalAlign="middle">
          <AnimatedNumber
            value={points}
            format={(value) => formatMoney(value)}
          />
          {' credits'}
        </Box>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Shuttle">
          {!!docked && !requestonly && !!can_send ? (
            <Button
              color={grocery ? 'orange' : 'green'}
              tooltip={
                grocery
                  ? 'The kitchen is waiting for their grocery supply delivery!'
                  : ''
              }
              tooltipPosition="right"
              onClick={() => act('send')}
            >
              {location}
            </Button>
          ) : (
            String(location)
          )}
        </LabeledList.Item>
        <LabeledList.Item label="CentCom Message">{message}</LabeledList.Item>
        {!!loan && !requestonly && (
          <LabeledList.Item label="Loan">
            {!loan_dispatched ? (
              <Button disabled={!(away && docked)} onClick={() => act('loan')}>
                Loan Shuttle
              </Button>
            ) : (
              <Box color="bad">Loaned to Centcom</Box>
            )}
          </LabeledList.Item>
        )}
      </LabeledList>
    </Section>
  );
}
