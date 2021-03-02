import { map } from 'common/collections';
import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { AnimatedNumber, Box, Button, Flex, Input, LabeledList, NumberInput, Section, RoundGauge } from '../components';
import { Window } from '../layouts';
import { round, toFixed } from 'common/math';

export const ChemReactionChamber = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    emptying,
    temperature,
    ph,
    targetTemp,
    isReacting,
    reagentQuantity,
    reagentAcidic,
    reagentAlkaline,
  } = data;
  return (
    <Window
      width={250}
      height={280}>
      <Window.Content scrollable>
        <Section
          title="Conditions"
          buttons={(
            <Flex>
              <Box>
                {"Target:"}
              </Box>
              <NumberInput
                width="65px"
                unit="K"
                step={10}
                stepPixelSize={3}
                value={round(targetTemp)}
                minValue={0}
                maxValue={1000}
                onDrag={(e, value) => act('temperature', {
                  target: value,
                })} />
            </Flex>
          )}>
          <LabeledList>
            <LabeledList.Item label="Current Temperature">
              <AnimatedNumber
                value={temperature}
                format={value => toFixed(value) + ' K'} />
            </LabeledList.Item>
            <LabeledList.Item label="pH">
              <Flex position="relative">
                <AnimatedNumber value={ph}>
                  {(_, value) => (
                    <RoundGauge
                      value={value}
                      minValue={0}
                      maxValue={14}
                      format={value => null}
                      left={-7.5}
                      position="absolute"
                      size={1.50}
                      ranges={{
                        "red": [-0.22, 1.5],
                        "orange": [1.5, 3],
                        "yellow": [3, 4.5],
                        "olive": [4.5, 5],
                        "good": [5, 6],
                        "green": [6, 8.5],
                        "teal": [8.5, 9.5],
                        "blue": [9.5, 11],
                        "purple": [11, 12.5],
                        "violet": [12.5, 14],
                      }} />
                  )}
                </AnimatedNumber>
                <Flex position="relative"
                  top={0.2}>
                  <AnimatedNumber
                    value={ph}
                    format={value => round(value, 3)} />
                </Flex>
              </Flex>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Settings"
          buttons={(
            isReacting && (
              <Box
                inline
                bold
                color={"purple"}>
                {"Reacting"}
              </Box>
            ) || (
              <Box
                inline
                bold
                color={emptying ? "bad" : "good"}>
                {emptying ? "Emptying" : "Filling"}
              </Box>
            )
          )}>
          <LabeledList>
            <tr className="LabledList__row">
              <LabeledList.Item label="Reaction Volume">
                <td
                  className={classes([
                    "LabeledList__buttons",
                    "LabeledList__cell",
                  ])}>
                  <NumberInput
                    value={reagentQuantity}
                    minValue={1}
                    maxValue={200}
                    step={1}
                    stepPixelSize={3}
                    width="39px"
                    onDrag={(e, value) => act('volume', {
                      target: value,
                    })} />

                  <Box inline mr={1} />
                </td>
              </LabeledList.Item>
            </tr>
            <tr className="LabledList__row">
              <LabeledList.Item label="Acidic pH limit">
                <td
                  className={classes([
                    "LabeledList__buttons",
                    "LabeledList__cell",
                  ])}>
                  <NumberInput
                    value={reagentAcidic}
                    minValue={-1000}
                    maxValue={1000}
                    step={1}
                    stepPixelSize={3}
                    width="39px"
                    onDrag={(e, value) => act('acidic', {
                      target: value,
                    })} />
                  <Box inline mr={1} />
                </td>
              </LabeledList.Item>
            </tr>
            <tr className="LabledList__row">
              <LabeledList.Item label="Alkaline pH limit">
                <td
                  className={classes([
                    "LabeledList__buttons",
                    "LabeledList__cell",
                  ])}>
                  <NumberInput
                    value={reagentAlkaline}
                    minValue={-1000}
                    maxValue={1000}
                    step={1}
                    stepPixelSize={3}
                    width="39px"
                    onDrag={(e, value) => act('alkaline', {
                      target: value,
                    })} />
                  <Box inline mr={1} />
                </td>
              </LabeledList.Item>
            </tr>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
