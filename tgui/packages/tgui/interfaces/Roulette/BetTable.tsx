import { useState } from 'react';
import { Box, Button, NumberInput, Stack, Table } from 'tgui-core/components';
import { type BooleanLike, classes } from 'tgui-core/react';

import { useBackend } from '../../backend';
import { getNumberColor } from './helpers';

type Data = {
  IsAnchored: BooleanLike;
  BetAmount: number;
  BetType: string;
  HouseBalance: number;
  LastSpin: number;
  Spinning: BooleanLike;
  AccountBalance: number;
  CanUnbolt: BooleanLike;
};

export function RouletteBetTable(props) {
  const { act, data } = useBackend<Data>();
  const { LastSpin, HouseBalance, BetAmount, IsAnchored } = data;

  const [customBet, setCustomBet] = useState(500);

  let BetType = data.BetType;

  if (BetType.startsWith('s')) {
    BetType = BetType.substring(1, BetType.length);
  }

  return (
    <Table className="Roulette__lowertable" collapsing>
      <Table.Row>
        <Table.Cell
          className={classes([
            'Roulette',
            'Roulette__lowertable--cell',
            'Roulette__lowertable--header',
          ])}
        >
          Last Spin:
        </Table.Cell>
        <Table.Cell
          className={classes([
            'Roulette',
            'Roulette__lowertable--cell',
            'Roulette__lowertable--header',
          ])}
        >
          Current Bet:
        </Table.Cell>
      </Table.Row>
      <Table.Row>
        <Table.Cell
          className={classes([
            'Roulette',
            'Roulette__lowertable--cell',
            'Roulette__lowertable--spinresult',
            `Roulette__lowertable--spinresult-${getNumberColor(LastSpin)}`,
          ])}
        >
          {LastSpin}
        </Table.Cell>
        <Table.Cell
          className={classes([
            'Roulette',
            'Roulette__lowertable--cell',
            'Roulette__lowertable--betscell',
          ])}
        >
          <Box bold mt={1} mb={1} fontSize="20px" textAlign="center">
            {BetAmount} cr on {BetType}
          </Box>
          <Box ml={1} mr={1}>
            <Button
              fluid
              onClick={() =>
                act('ChangeBetAmount', {
                  amount: 10,
                })
              }
            >
              Bet 10 cr
            </Button>
            <Button
              fluid
              onClick={() =>
                act('ChangeBetAmount', {
                  amount: 50,
                })
              }
            >
              Bet 50 cr
            </Button>
            <Button
              fluid
              onClick={() =>
                act('ChangeBetAmount', {
                  amount: 100,
                })
              }
            >
              Bet 100 cr
            </Button>
            <Button
              fluid
              onClick={() =>
                act('ChangeBetAmount', {
                  amount: 500,
                })
              }
            >
              Bet 500 cr
            </Button>
            <Stack>
              <Stack.Item grow>
                <Button
                  fluid
                  onClick={() =>
                    act('ChangeBetAmount', {
                      amount: customBet,
                    })
                  }
                >
                  Bet custom amount...
                </Button>
              </Stack.Item>
              <Stack.Item>
                <NumberInput
                  value={customBet}
                  minValue={0}
                  maxValue={1000}
                  step={10}
                  stepPixelSize={4}
                  width="40px"
                  onChange={(value) => setCustomBet(value)}
                />
              </Stack.Item>
            </Stack>
          </Box>
        </Table.Cell>
      </Table.Row>
      <Table.Row>
        <Table.Cell colSpan={2}>
          <Box bold m={1} fontSize="14px" textAlign="center">
            Swipe an ID card with a connected account to spin!
          </Box>
        </Table.Cell>
      </Table.Row>
      <Table.Row>
        <Table.Cell className="Roulette__lowertable--cell">
          <Box inline bold mr={1}>
            House Balance:
          </Box>
          <Box inline>{HouseBalance ? `${HouseBalance} cr` : 'None'}</Box>
        </Table.Cell>
        <Table.Cell className="Roulette__lowertable--cell">
          <Button
            fluid
            m={1}
            color="transparent"
            textAlign="center"
            onClick={() => act('anchor')}
          >
            {IsAnchored ? 'Bolted' : 'Unbolted'}
          </Button>
        </Table.Cell>
      </Table.Row>
    </Table>
  );
}
