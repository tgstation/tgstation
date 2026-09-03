import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  Section,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';
import type { CargoData } from './types';

type CargoStatusProps = {
  act: any;
} & CargoStatusData;

type CargoStatusData = Pick<
  CargoData,
  | 'department'
  | 'grocery'
  | 'away'
  | 'docked'
  | 'loan'
  | 'loan_dispatched'
  | 'location'
  | 'message'
  | 'points'
  | 'requestonly'
  | 'can_send'
  | 'displayed_currency_full_name'
>;

export function CargoStatus(props: CargoStatusProps) {
  const {
    act,
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
    displayed_currency_full_name,
  } = props;

  return (
    <Section
      title={department}
      buttons={
        <Box inline bold verticalAlign="middle">
          <AnimatedNumber
            value={points}
            format={(value) => formatMoney(value)}
          />
          {displayed_currency_full_name}
        </Box>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Shuttle">
          {docked && !requestonly && can_send ? (
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
