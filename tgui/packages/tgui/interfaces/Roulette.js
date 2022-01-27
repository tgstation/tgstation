import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Box, Button, Grid, NumberInput, Table } from '../components';
import { Window } from '../layouts';

const getNumberColor = number => {
  const inRedOddRange = (
    (number >= 1 && number <= 10)
    || (number >= 19 && number <= 28)
  );

  if (number % 2 === 1) {
    return inRedOddRange ? 'red' : 'black';
  }
  return inRedOddRange ? 'black' : 'red';
};

export const RouletteNumberCell = (props, context) => {
  const {
    buttonClass = null,
    cellClass = null,
    color,
    colspan = "1",
    rowspan = "1",
    text,
    value,
  } = props;
  const { act } = useBackend(context);

  return (
    <Table.Cell
      className={classes([
        "Roulette__board-cell",
        "Roulette__board-cell-number",
        cellClass,
      ])}
      colspan={colspan}
      rowspan={rowspan}>
      <Button
        color={color}
        className={classes([
          "Roulette__board-button",
          buttonClass,
        ])}
        onClick={() => act('ChangeBetType', { type: value })}
      >
        <span className="Roulette__board-button-text">{text}</span>
      </Button>
    </Table.Cell>
  );
};

export const RouletteBoard = () => {
  const firstRow = [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36];
  const secondRow = [2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35];
  const thirdRow = [1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34];
  const fourthRow = {
    "s1-12": "1st 12",
    "s13-24": "2nd 12",
    "s25-36": "3rd 12",
  };
  const fifthRow = [
    { color: "transparent", text: "1-18", value: "s1-18" },
    { color: "transparent", text: "Even", value: "even" },
    { color: "black", text: "Black", value: "black" },
    { color: "red", text: "Red", value: "red" },
    { color: "transparent", text: "Odd", value: "odd" },
    { color: "transparent", text: "19-36", value: "s19-36" },
  ];

  return (
    <Box className="Roulette__container">
      <Table collapsing ml="auto" mr="auto">
        <Table.Row>
          <RouletteNumberCell
            buttonClass="Roulette__board-button--rowspan-3"
            color="transparent"
            rowspan="3"
            text="0"
            value="0"
          />
          {firstRow.map(number => (
            <RouletteNumberCell
              color={getNumberColor(number)}
              key={number}
              text={number.toString()}
              value={number.toString()}
            />
          ))}
          <RouletteNumberCell
            color="transparent"
            text="2 to 1"
            value="s3rd col"
          />
        </Table.Row>
        <Table.Row>
          {secondRow.map(number => (
            <RouletteNumberCell
              color={getNumberColor(number)}
              key={number}
              text={number.toString()}
              value={number.toString()}
            />
          ))}
          <RouletteNumberCell
            color="transparent"
            text="2 to 1"
            value="s2nd col"
          />
        </Table.Row>
        <Table.Row>
          {thirdRow.map(number => (
            <RouletteNumberCell
              color={getNumberColor(number)}
              key={number}
              text={number.toString()}
              value={number.toString()}
            />
          ))}
          <RouletteNumberCell
            color="transparent"
            text="2 to 1"
            value="s1st col"
          />
        </Table.Row>
        <Table.Row>
          <Table.Cell />
          {Object.entries(fourthRow).map(([value, text]) => (
            <RouletteNumberCell
              cellClass="Roulette__board-cell-number--colspan-4"
              color="transparent"
              colspan="4"
              key={value}
              text={text}
              value={value}
            />
          ))}
        </Table.Row>
        <Table.Row>
          <Table.Cell />
          {fifthRow.map(cell => (
            <RouletteNumberCell
              cellClass="Roulette__board-cell-number--colspan-2"
              color={cell.color}
              colspan="2"
              key={cell.value}
              text={cell.text}
              value={cell.value}
            />
          ))}
        </Table.Row>
      </Table>
    </Box>
  );
};

export const RouletteBetTable = (props, context) => {
  const { act, data } = useBackend(context);

  const [
    customBet,
    setCustomBet,
  ] = useLocalState(context, 'customBet', 500);

  let {
    BetType,
  } = data;

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
          ])}>
          Last Spin:
        </Table.Cell>
        <Table.Cell
          className={classes([
            'Roulette',
            'Roulette__lowertable--cell',
            'Roulette__lowertable--header',
          ])}>
          Current Bet:
        </Table.Cell>
      </Table.Row>
      <Table.Row>
        <Table.Cell className={classes([
          'Roulette',
          'Roulette__lowertable--cell',
          'Roulette__lowertable--spinresult',
          'Roulette__lowertable--spinresult-' + getNumberColor(data.LastSpin),
        ])}>
          {data.LastSpin}
        </Table.Cell>
        <Table.Cell className={classes([
          'Roulette',
          'Roulette__lowertable--cell',
          'Roulette__lowertable--betscell',
        ])}>
          <Box
            bold
            mt={1}
            mb={1}
            fontSize="20px"
            textAlign="center">
            {data.BetAmount} cr on {BetType}
          </Box>
          <Box ml={1} mr={1}>
            <Button
              fluid
              content="Bet 10 cr"
              onClick={() => act('ChangeBetAmount', {
                amount: 10,
              })}
            />
            <Button
              fluid
              content="Bet 50 cr"
              onClick={() => act('ChangeBetAmount', {
                amount: 50,
              })}
            />
            <Button
              fluid
              content="Bet 100 cr"
              onClick={() => act('ChangeBetAmount', {
                amount: 100,
              })}
            />
            <Button
              fluid
              content="Bet 500 cr"
              onClick={() => act('ChangeBetAmount', {
                amount: 500,
              })}
            />
            <Grid>
              <Grid.Column>
                <Button
                  fluid
                  content="Bet custom amount..."
                  onClick={() => act('ChangeBetAmount', {
                    amount: customBet,
                  })}
                />
              </Grid.Column>
              <Grid.Column size={0.1}>
                <NumberInput
                  value={customBet}
                  minValue={0}
                  maxValue={1000}
                  step={10}
                  stepPixelSize={4}
                  width="40px"
                  onChange={(e, value) => setCustomBet(value)}
                />
              </Grid.Column>
            </Grid>
          </Box>
        </Table.Cell>
      </Table.Row>
      <Table.Row>
        <Table.Cell colSpan="2">
          <Box
            bold
            m={1}
            fontSize="14px"
            textAlign="center">
            Swipe an ID card with a connected account to spin!
          </Box>
        </Table.Cell>
      </Table.Row>
      <Table.Row>
        <Table.Cell className="Roulette__lowertable--cell">
          <Box inline bold mr={1}>
            House Balance:
          </Box>
          <Box inline>
            {data.HouseBalance ? data.HouseBalance + ' cr': "None"}
          </Box>
        </Table.Cell>
        <Table.Cell className="Roulette__lowertable--cell">
          <Button
            fluid
            content={data.IsAnchored ? "Bolted" : "Unbolted"}
            m={1}
            color="transparent"
            textAlign="center"
            onClick={() => act('anchor')}
          />
        </Table.Cell>
      </Table.Row>
    </Table>
  );
};

export const Roulette = (props, context) => {
  return (
    <Window
      width={570}
      height={520}
      theme="cardtable">
      <Window.Content>
        <RouletteBoard />
        <RouletteBetTable />
      </Window.Content>
    </Window>
  );
};
