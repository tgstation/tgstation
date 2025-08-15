import { Box, Table } from 'tgui-core/components';

import { getNumberColor } from './helpers';
import { RouletteNumberCell } from './NumberCell';

const firstRow = [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36] as const;
const secondRow = [2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35] as const;
const thirdRow = [1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34] as const;
const fourthRow = {
  's1-12': '1st 12',
  's13-24': '2nd 12',
  's25-36': '3rd 12',
} as const;
const fifthRow = [
  { color: 'transparent', text: '1-18', value: 's1-18' },
  { color: 'transparent', text: 'Even', value: 'even' },
  { color: 'black', text: 'Black', value: 'black' },
  { color: 'red', text: 'Red', value: 'red' },
  { color: 'transparent', text: 'Odd', value: 'odd' },
  { color: 'transparent', text: '19-36', value: 's19-36' },
] as const;

export function RouletteBoard(props) {
  return (
    <Box className="Roulette__container">
      <Table collapsing ml="auto" mr="auto">
        <Table.Row>
          <RouletteNumberCell
            buttonClass="Roulette__board-button--rowspan-3"
            color="transparent"
            rowspan={3}
            text="0"
            value="0"
          />
          {firstRow.map((number) => (
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
          {secondRow.map((number) => (
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
          {thirdRow.map((number) => (
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
              colspan={4}
              key={value}
              text={text}
              value={value}
            />
          ))}
        </Table.Row>
        <Table.Row>
          <Table.Cell />
          {fifthRow.map((cell) => (
            <RouletteNumberCell
              cellClass="Roulette__board-cell-number--colspan-2"
              color={cell.color}
              colspan={2}
              key={cell.value}
              text={cell.text}
              value={cell.value}
            />
          ))}
        </Table.Row>
      </Table>
    </Box>
  );
}
