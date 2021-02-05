import { useBackend } from '../backend';
import { Box, Button, Icon, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const Thermometer = (props, context) => {
  const { act, data } = useBackend(context);
  const style = {};
  style['transform'] = `rotate(${270}deg)`;
  return (
    <Window
      width={90}
      height={480}
      key="Thermometer"
      resizable>
      <Window.Content>
        <Section>
          <Box height={40}>
            <Icon
              mt={60}
              size={5}
              top={30}
              name="circle"
              color="#bd2020" />
            <ProgressBar 
              left={-12.4} 
              top={-20.5} 
              height={2} 
              width={30} 
              maxValue={1000} 
              color="red" 
              style={style} 
              value={data.Temperature}>
              {null}
            </ProgressBar> 
          </Box>
          <Box 
            mt={-16.5} 
            ml={2.5} 
            top={-70.5}>
            {data.Temperature}K
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
