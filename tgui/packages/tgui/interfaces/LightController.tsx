import { useBackend, useLocalState } from '../backend';
import { round } from '../../common/math';
import { classes } from 'common/react';
import { Box, Button, Divider, ProgressBar, Section, Slider, Stack, Tabs } from '../components';
import { Window } from '../layouts';

type LightDetails = {
  name: string;
  color: string;
  power: number;
  range: number;
};

type TemplateID = string;

type LightTemplate = {
  light_info: LightDetails;
  description: string;
  id: TemplateID;
};


interface CategoryList {
  [key: string]: TemplateID[];
}

type Data = {
  on: boolean;
  light_info: LightDetails;
  templates: LightTemplate[];
  default_id: string;
  default_category: string;
  category_ids: CategoryList;
};

export const LightController = (props, context) => {
  const { act, data } = useBackend<Data>(context);
  const { light_info, templates, default_id, default_category, category_ids } = data;
  const [currentTemplate, setCurrentTemplate] = useLocalState<string>(
    context,
    'currentTemplate',
    default_id
  );
  const [currentCategory, setCurrentCategory] = useLocalState<string>(
    context,
    'currentCategory',
    default_category
  );


  return (
    <Window
      title={light_info.name + ": Lighting"}
      width={600}
      height={300}>
      <Window.Content scrollable>
        <Stack fill>
          <Stack.Item>
            <Section fitted fill scrollable width="170px">
              <Tabs>
                {Object.keys(category_ids).map(
                  (category, index) => (
                    <Tabs.Tab
                      key={category}
                      onClick={() => setCurrentCategory(category)}>
                      <Box fontSize="14px" bold textColor={"#eee"}>
                        {category}
                      </Box>
                    </Tabs.Tab>
                  ))}
              </Tabs>
              <Tabs vertical>
                {category_ids[currentCategory].map(
                  (id) => (
                    <Tabs.Tab
                      key={id}
                      onClick={() => setCurrentTemplate(id)}>
                      <Box fontSize="14px" textColor={"#cee"}>
                        {templates[id].light_info.name}
                      </Box>
                      <Box ml={0.1} className={classes(['lights32x32', "light_fantastic_" + id])} />
                    </Tabs.Tab>
                  ))}
              </Tabs>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <LightControl info={light_info} />
            <LightInfo light={templates[currentTemplate]} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type LightControlProps = {
  info : LightDetails;
};

const LightControl = (props : LightControlProps, context) => {
  const { act, data } = useBackend<Data>(context);
  const { on } = data;
  const { info } = props;
  return (
    <Section>
      <Stack vertical justify="space-between" fill>
        <Stack.Item>
          <Stack justify="space-between">
            <Stack.Item>
              <Box fontSize="16px" mt={0.5}>
                {info.name}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                fontSize="16px"
                icon="brush"
                textColor={info.color}
                onClick={() => act("change_color")}
                content={info.color}
                />
              <Button
                fontSize="16px"
                color={on ? "good" : "bad"}
                icon="power-off"
                onClick={() => act("set_on", {
                value: !on,
                })} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item align="end">
          <Slider
            unit="tiles"
            value={info.range}
            color="blue"
            minValue={0}
            maxValue={10}
            onChange={(e, value) => act("set_range", {
              value: value,
            })}
            step={0.1}
            stepPixelSize={5}
            />
          <Slider
            unit="intensity"
            value={info.power}
            color="olive"
            minValue={-1}
            maxValue={5}
            format={(value) => { return round(value, 2); }}
            onChange={(e, value) => act("set_power", {
              value: value,
            })}
            step={0.1}
            stepPixelSize={10}
            />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

type LightInfoProps = {
  light : LightTemplate;
};

const LightInfo = (props : LightInfoProps, context) => {
  const { act } = useBackend(context);
  const { light } = props;
  const { light_info } = light;
  return (
    <Section>
      <Stack vertical justify="space-between" fill>
        <Stack.Item>
          <Stack justify="space-between">
            <Stack.Item>
              <Box fontSize="16px" mt={0.5}>
                {light_info.name}
              </Box>
              <Box fontSize="12px" ml={1} color="#aaaaaa">
                {light.description}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                  fontSize="16px"
                  icon="brush"
                  textColor={light_info.color}
                  content={light_info.color}
                  />
              <Button
                fontSize="16px"
                icon="upload"
                onClick={() => act("mirror_template", {
                  id: light.id,
                })} />
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item align="end">
          <Slider
            unit="tiles"
            value={light_info.range}
            color="blue"
            minValue={0}
            maxValue={10}
            step={0}
            />
          <Slider
            unit="intensity"
            value={light_info.power}
            color="olive"
            minValue={-1}
            maxValue={5}
            step={0}
            />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
