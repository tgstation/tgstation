import { classes } from "common/react";
import { useBackend } from "../backend";
import { Box, Button, Grid, NumberInput } from "../components";
import { createLogger } from "../logging";
import { Fragment, Component } from "inferno";
import { act } from "../byond";

const logger = createLogger('Roulette');

const getNumberColor = number => {
  if (number === 0) {
    return 'green';
  }

  const evenRedRanges = [
    [1, 10],
    [19, 28],
  ];
  let oddRed = true;

  for (let i = 0; i < evenRedRanges.length; i++) {
    let range = evenRedRanges[i];
    if (number >= range[0] && number <= range[1]) {
      oddRed = false;
      break;
    }
  }

  const isOdd = (number % 2 === 0);

  return (oddRed ? isOdd : !isOdd) ? 'red' : 'black';
};

export const RouletteNumberButton = props => {
  const { number } = props;
  const { act } = useBackend(props);

  return (
    <Button
      bold
      content={number}
      color={getNumberColor(number)}
      width="40px"
      height="28px"
      fontSize="20px"
      textAlign="center"
      mb={0}
      className="Roulette__board-extrabutton"
      onClick={() => act('ChangeBetType', { type: number })}
    />
  );
};

export const RouletteBoard = props => {
  const { state } = props;
  const { act } = useBackend(props);

  const firstRow = [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36];
  const secondRow = [2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35];
  const thirdRow = [1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34];

  return (
    <table
      className="Table"
      style={{
        // Setting it to 1 px makes sure it always takes up minimum width
        'width': '1px',
      }}>
      <tr className="Roulette__board-row">
        <td
          rowSpan="3"
          className="Roulette__board-cell">
          <Button
            content="0"
            color="transparent"
            height="88px"
            className="Roulette__board-extrabutton"
            onClick={() => act('ChangeBetType', { type: 0 })}
          />
        </td>
        {firstRow.map(number => (
          <td
            key={number}
            className="Roulette__board-cell Table__cell-collapsing">
            <RouletteNumberButton state={state} number={number} />
          </td>
        ))}
        <td className="Roulette__board-cell">
          <Button
            fluid
            bold
            content="2 to 1"
            color="transparent"
            className="Roulette__board-extrabutton"
            onClick={() => act('ChangeBetType', { type: "s3rd col" })}
          />
        </td>
      </tr>
      <tr>
        {secondRow.map(number => (
          <td
            key={number}
            className="Roulette__board-cell Table__cell-collapsing">
            <RouletteNumberButton state={state} number={number} />
          </td>
        ))}
        <td className="Roulette__board-cell">
          <Button
            fluid
            bold
            content="2 to 1"
            color="transparent"
            className="Roulette__board-extrabutton"
            onClick={() => act('ChangeBetType', { type: "s2nd col" })}
          />
        </td>
      </tr>
      <tr>
        {thirdRow.map(number => (
          <td
            key={number}
            className="Roulette__board-cell Table__cell-collapsing">
            <RouletteNumberButton state={state} number={number} />
          </td>
        ))}
        <td className="Roulette__board-cell">
          <Button
            fluid
            bold
            content="2 to 1"
            color="transparent"
            className="Roulette__board-extrabutton"
            onClick={() => act('ChangeBetType', { type: "s1st col" })}
          />
        </td>
      </tr>
      <tr>
        <td />
        <td colSpan="4" className="Roulette__board-cell">
          <Button
            fluid
            bold
            content="1st 12"
            color="transparent"
            className="Roulette__board-extrabutton"
            onClick={() => act('ChangeBetType', { type: "s1-12" })}
          />
        </td>
        <td colSpan="4" className="Roulette__board-cell">
          <Button
            fluid
            bold
            content="2nd 12"
            color="transparent"
            className="Roulette__board-extrabutton"
            onClick={() => act('ChangeBetType', { type: "s13-24" })}
          />
        </td>
        <td colSpan="4" className="Roulette__board-cell">
          <Button
            fluid
            bold
            content="3rd 12"
            color="transparent"
            className="Roulette__board-extrabutton"
            onClick={() => act('ChangeBetType', { type: "s25-36" })}
          />
        </td>
      </tr>
      <tr>
        <td />
        <td colSpan="2" className="Roulette__board-cell">
          <Button
            fluid
            bold
            content="1-18"
            color="transparent"
            className="Roulette__board-extrabutton"
            onClick={() => act('ChangeBetType', { type: "s1-18" })}
          />
        </td>
        <td colSpan="2" className="Roulette__board-cell">
          <Button
            fluid
            bold
            content="Even"
            color="transparent"
            className="Roulette__board-extrabutton"
            onClick={() => act('ChangeBetType', { type: "even" })}
          />
        </td>
        <td colSpan="2" className="Roulette__board-cell">
          <Button
            fluid
            bold
            content="Black"
            color="black"
            className="Roulette__board-extrabutton"
            onClick={() => act('ChangeBetType', { type: "black" })}
          />
        </td>
        <td colSpan="2" className="Roulette__board-cell">
          <Button
            fluid
            bold
            content="Red"
            color="red"
            className="Roulette__board-extrabutton"
            onClick={() => act('ChangeBetType', { type: "red" })}
          />
        </td>
        <td colSpan="2" className="Roulette__board-cell">
          <Button
            fluid
            bold
            content="Odd"
            color="transparent"
            className="Roulette__board-extrabutton"
            onClick={() => act('ChangeBetType', { type: "odd" })}
          />
        </td>
        <td colSpan="2" className="Roulette__board-cell">
          <Button
            fluid
            bold
            content="19-36"
            color="transparent"
            className="Roulette__board-extrabutton"
            onClick={() => act('ChangeBetType', { type: "s19-36" })}
          />
        </td>
      </tr>
    </table>
  );
};

export class RouletteBetTable extends Component {
  constructor() {
    super();
    this.state = {
      customBet: 500,
    };
  }

  setCustomBet(customBet) {
    this.setState({
      customBet,
    });
  }

  render() {
    const { act, data } = useBackend(this.props);

    let {
      BetType,
    } = data;

    if (BetType.startsWith('s')) {
      BetType = BetType.substring(1, BetType.length);
    }

    return (
      <table className="Roulette__lowertable">
        <tr>
          <th
            className={classes([
              'Roulette',
              'Roulette__lowertable--cell',
              'Roulette__lowertable--header',
            ])}>
          Last Spun:
          </th>
          <th
            className={classes([
              'Roulette',
              'Roulette__lowertable--cell',
              'Roulette__lowertable--header',
            ])}>
          Current Bet:
          </th>
        </tr>
        <tr>
          <td className={classes([
            'Roulette',
            'Roulette__lowertable--cell',
            'Roulette__lowertable--spinresult',
            'Roulette__lowertable--spinresult-' + getNumberColor(data.LastSpin),
          ])}>
            {data.LastSpin}
          </td>
          <td className={classes([
            'Roulette',
            'Roulette__lowertable--cell',
            'Roulette__lowertable--betscell',
          ])}>
            <Box
              bold
              mt={1}
              mb={1}
              fontSize="25px"
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
                      amount: this.state.customBet,
                    })}
                  />
                </Grid.Column>
                <Grid.Column size={0.1}>
                  <NumberInput
                    value={this.state.customBet}
                    minValue={0}
                    maxValue={1000}
                    step={10}
                    stepPixelSize={4}
                    width="40px"
                    onChange={(e, value) => this.setCustomBet(value)}
                  />
                </Grid.Column>
              </Grid>
            </Box>
          </td>
        </tr>
        <tr>
          <td colSpan="2">
            <Box
              bold
              m={1}
              fontSize="14px"
              textAlign="center">
            Swipe an ID card with a connected account to spin!
            </Box>
          </td>
        </tr>
        <tr>
          <td className="Roulette__lowertable--cell">
            <Box inline bold mr={1}>
            House Balance:
            </Box>
            <Box inline>
              {data.HouseBalance ? data.HouseBalance + ' cr': "None"}
            </Box>
          </td>
          <td className="Roulette__lowertable--cell">
            <Button
              fluid
              content={data.IsAnchored ? "Bolted" : "Unbolted"}
              m={1}
              color="transparent"
              textAlign="center"
              onClick={() => act('anchor')}
            />
          </td>
        </tr>
      </table>
    );
  }
}

export const Roulette = props => {
  return (
    <Fragment>
      <RouletteBoard state={props.state} />
      <RouletteBetTable state={props.state} />
    </Fragment>
  );
};
