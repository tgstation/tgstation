import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, ProgressBar, NoticeBox, Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type Data = {
  is_burning: BooleanLike;
  temperature: number;
  own_total_volume: number;
  own_maximum_volume: number;
  own_reagent_color: string;
  beaker: BooleanLike;
  beaker_total_volume: number;
  beaker_maximum_volume: number;
  beaker_reagent_color: string;
};

export const ChemSeparator = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  return (
    <Window width={470} height={130}>
      <Window.Content>
        <Section fill>
          <LabeledList>
            <LabeledList.Item
              label="Separator"
              buttons={
                <Box my={1}>
                  <Button
                    mr={2}
                    width={6}
                    lineHeight={2}
                    align="center"
                    content="Drain"
                    icon="arrow-down"
                    disabled={
                      data.is_burning ||
                      !data.own_total_volume ||
                      !data.beaker ||
                      data.beaker_total_volume >= data.beaker_maximum_volume
                    }
                    onClick={() => act('unload')}
                  />
                  {!data.is_burning ? (
                    <Button
                      width={6}
                      lineHeight={2}
                      align="center"
                      content="Start"
                      icon="filter"
                      color="good"
                      disabled={
                        !data.own_total_volume ||
                        !data.beaker ||
                        data.beaker_total_volume >= data.beaker_maximum_volume
                      }
                      onClick={() => act('start')}
                    />
                  ) : (
                    <Button
                      width={6}
                      lineHeight={2}
                      align="center"
                      content="Stop"
                      icon="ban"
                      color="bad"
                      onClick={() => act('stop')}
                    />
                  )}
                </Box>
              }>
              <ProgressBar
                height={2}
                value={data.own_total_volume}
                minValue={0}
                maxValue={data.own_maximum_volume}
                color={data.own_reagent_color}>
                <Box
                  lineHeight={1.9}
                  style={{
                    'text-shadow': '1px 1px 0 black',
                  }}>
                  {`${Math.ceil(data.own_total_volume)} of ${
                    data.own_maximum_volume
                  } units at ${Math.ceil(data.temperature)}°C`}
                </Box>
              </ProgressBar>
            </LabeledList.Item>
            {data.beaker ? (
              <LabeledList.Item
                label="Container"
                buttons={
                  <Box my={1}>
                    <Button
                      mr={2}
                      width={6}
                      lineHeight={2}
                      align="center"
                      content="Fill"
                      icon="arrow-up"
                      disabled={
                        data.is_burning ||
                        !data.beaker_total_volume ||
                        data.own_total_volume >= data.own_maximum_volume
                      }
                      onClick={() => act('load')}
                    />
                    <Button
                      width={6}
                      lineHeight={2}
                      align="center"
                      icon="eject"
                      content="Eject"
                      disabled={data.is_burning}
                      onClick={() => act('eject')}
                    />
                  </Box>
                }>
                <ProgressBar
                  height={2}
                  value={data.beaker_total_volume}
                  minValue={0}
                  maxValue={data.beaker_maximum_volume}
                  color={data.beaker_reagent_color}>
                  <Box
                    lineHeight={1.9}
                    style={{
                      'text-shadow': '1px 1px 0 black',
                    }}>
                    {`${Math.ceil(data.beaker_total_volume)} of ${
                      data.beaker_maximum_volume
                    } units`}
                  </Box>
                </ProgressBar>
              </LabeledList.Item>
            ) : (
              <LabeledList.Item label="Container">
                <NoticeBox my={0.7}>No container inserted.</NoticeBox>
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
