import { map } from 'common/collections';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Dimmer, Icon, LabeledList, Section, Tabs } from '../components';

const CraftingList = props => {
  const {
    craftables = [],
  } = props;
  const { act, data } = useBackend(props);
  const {
    craftability = {},
    display_compact,
    display_craftable_only,
  } = data;
  return craftables.map(craftable => {
    if (display_craftable_only && !craftability[craftable.ref]) {
      return null;
    }
    // Compact display
    if (display_compact) {
      return (
        <LabeledList.Item
          key={craftable.name}
          label={craftable.name}
          className="candystripe"
          buttons={(
            <Button
              icon="cog"
              content="Craft"
              disabled={!craftability[craftable.ref]}
              tooltip={craftable.tool_text && (
                'Tools needed: ' + craftable.tool_text
              )}
              tooltipPosition="left"
              onClick={() => act('make', {
                recipe: craftable.ref,
              })} />
          )}>
          {craftable.req_text}
        </LabeledList.Item>
      );
    }
    // Full display
    return (
      <Section
        key={craftable.name}
        title={craftable.name}
        level={2}
        buttons={(
          <Button
            icon="cog"
            content="Craft"
            disabled={!craftability[craftable.ref]}
            onClick={() => act('make', {
              recipe: craftable.ref,
            })} />
        )}>
        <LabeledList>
          {!!craftable.req_text && (
            <LabeledList.Item label="Required">
              {craftable.req_text}
            </LabeledList.Item>
          )}
          {!!craftable.catalyst_text && (
            <LabeledList.Item label="Catalyst">
              {craftable.catalyst_text}
            </LabeledList.Item>
          )}
          {!!craftable.tool_text && (
            <LabeledList.Item label="Tools">
              {craftable.tool_text}
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
    );
  });
};

export const PersonalCrafting = props => {
  const { state } = props;
  const { act, data } = useBackend(props);
  const {
    busy,
    display_craftable_only,
    display_compact,
  } = data;

  const craftingRecipes = map((subcategory, category) => {
    const hasSubcats = ('has_subcats' in subcategory);
    const firstSubcatName = Object.keys(subcategory)
      .find(name => name !== 'has_subcats');
    return {
      category,
      subcategory,
      hasSubcats,
      firstSubcatName,
    };
  })(data.crafting_recipes || {});

  // Shows an overlay when crafting an item
  const busyBox = !!busy && (
    <Dimmer
      fontSize="40px"
      textAlign="center">
      <Box mt={30}>
        <Icon name="cog" spin={1} />
        {' Crafting...'}
      </Box>
    </Dimmer>
  );

  return (
    <Fragment>
      {busyBox}
      <Section
        title="Personal Crafting"
        buttons={(
          <Fragment>
            <Button
              icon={display_compact ? "check-square-o" : "square-o"}
              content="Compact"
              selected={display_compact}
              onClick={() => act('toggle_compact')} />
            <Button
              icon={display_craftable_only ? "check-square-o" : "square-o"}
              content="Craftable Only"
              selected={display_craftable_only}
              onClick={() => act('toggle_recipes')} />
          </Fragment>
        )}>
        <Tabs>
          {craftingRecipes.map(recipe => (
            <Tabs.Tab
              key={recipe.category}
              label={recipe.category}
              onClick={() => act('set_category', {
                category: recipe.category,
                // Backend expects "0" or "" to indicate no subcategory
                subcategory: recipe.firstSubcatName,
              })}>
              {() => !recipe.hasSubcats && (
                <CraftingList
                  craftables={recipe.subcategory}
                  state={state} />
              ) || (
                <Tabs vertical>
                  {map((value, name) => {
                    if (name === "has_subcats") {
                      return;
                    }
                    return (
                      <Tabs.Tab
                        label={name}
                        onClick={() => act('set_category', {
                          subcategory: name,
                        })}>
                        {() => (
                          <CraftingList
                            craftables={value}
                            state={state} />
                        )}
                      </Tabs.Tab>
                    );
                  })(recipe.subcategory)}
                </Tabs>
              )}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Section>
    </Fragment>
  );
};
