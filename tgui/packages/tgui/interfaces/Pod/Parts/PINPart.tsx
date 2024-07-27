import { BooleanLike, classes } from 'common/react';
import { useBackend } from '../../../backend';
import { Button, Box, Stack, Dropdown } from '../../../components';
import { DropdownEntry } from '../../../components/Dropdown';
import { NukeKeypad } from '../../NuclearBomb';
type Data = {
  partUIData: string[];
};

const KEYPAD = [
  ['1', '4', '7', 'C'],
  ['2', '5', '8', '0'],
  ['3', '6', '9', 'E'],
] as const;

export default function PINPart(_props: any): JSX.Element {
  const { act, data } = useBackend<{
    partUIData: string[];
    ourData: Data;
  }>();
  const { partUIData } = data;
  const ourData = partUIData['PINPart'];
  return (
    <Box>
      <Stack>
        <Stack.Item>
          <Stack>
            {KEYPAD.map((keyColumn) => (
              <Stack.Item key={keyColumn[0]}>
                {keyColumn.map((key) => (
                  <Button
                    fluid
                    bold
                    key={key}
                    mb={1}
                    textAlign="center"
                    fontSize="25px"
                    lineHeight={1.25}
                    width="40px"
                    className={classes([
                      'NuclearBomb__Button',
                      'NuclearBomb__Button--keypad',
                      key != '1' && 'NuclearBomb__Button--' + key,
                    ])}
                    onClick={() => act('keypad', { digit: key })}
                  >
                    {key}
                  </Button>
                ))}
              </Stack.Item>
            ))}
          </Stack>
        </Stack.Item>
        <Stack.Divider />
        <Stack.Item>
          <Box
            mb={1}
            width="100%"
            fontSize="1.8em"
            className="NuclearBomb__displayBox"
          >
            NOT SET
          </Box>
          <Box textAlign="center" mb={1} className="NuclearBomb__displayBox">
            0000
          </Box>
        </Stack.Item>
      </Stack>
    </Box>
  );
}
