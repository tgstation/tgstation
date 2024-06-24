import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Box, Divider, Button, NoticeBox } from '../components';
import { Window } from '../layouts';

export const ArmamentStation = (props) => {
  const [category, setCategory] = useLocalState('category', '');
  const [weapon, setArmament] = useLocalState('weapon');
  const { act, data } = useBackend();
  const { armaments_list = [], card_inserted, card_points, card_name } = data;
  return (
    <Window theme="armament" title="Armament Station" width={1000} height={600}>
      <Window.Content>
        <Section grow height="100%" title="Armaments Station">
          {card_inserted ? (
            <Stack>
              <Stack.Item grow fill>
                <Box>
                  <b>Inserted Card:</b> {card_name}
                </Box>
                <Box>
                  <b>Remaining Points:</b> {card_points}
                </Box>
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="eject"
                  fontSize="20px"
                  content="Eject Card"
                  onClick={() => act('eject_card')}
                />
              </Stack.Item>
            </Stack>
          ) : (
            <NoticeBox color="bad">No card inserted.</NoticeBox>
          )}
          <Divider />
          <Stack fill grow>
            <Stack.Item mr={1}>
              <Section title="Categories">
                <Stack vertical>
                  {armaments_list.map((armament_category) => (
                    <Stack.Item key={armament_category.category}>
                      <Button
                        width="100%"
                        content={
                          armament_category.category +
                          ' (Pick ' +
                          armament_category.category_limit +
                          ')'
                        }
                        selected={category === armament_category.category}
                        onClick={() => setCategory(armament_category.category)}
                      />
                    </Stack.Item>
                  ))}
                </Stack>
              </Section>
            </Stack.Item>
            <Divider vertical />
            <Stack.Item grow mr={1}>
              <Section title={category} scrollable fill height="480px">
                {armaments_list.map(
                  (armament_category) =>
                    armament_category.category === category &&
                    armament_category.subcategories.map((subcat) => (
                      <Section
                        key={subcat.subcategory}
                        title={subcat.subcategory}>
                        <Stack vertical>
                          {subcat.items.map((item) => (
                            <Stack.Item key={item.ref}>
                              <Button
                                fontSize="15px"
                                textAlign="center"
                                selected={weapon === item.ref}
                                color={
                                  item.purchased >= item.quantity
                                    ? 'bad'
                                    : 'default'
                                }
                                width="100%"
                                key={item.ref}
                                onClick={() => setArmament(item.ref)}>
                                <img
                                  src={`data:image/jpeg;base64,${item.icon}`}
                                  style={{
                                    'vertical-align': 'middle',
                                    'horizontal-align': 'middle',
                                  }}
                                />
                                &nbsp;{item.name}
                              </Button>
                            </Stack.Item>
                          ))}
                        </Stack>
                      </Section>
                    ))
                )}
              </Section>
            </Stack.Item>
            <Divider vertical />
            <Stack.Item width="20%">
              <Section title="Selected Armament">
                {armaments_list.map((armament_category) =>
                  armament_category.subcategories.map((subcat) =>
                    subcat.items.map(
                      (item) =>
                        item.ref === weapon && (
                          <Stack vertical>
                            <Stack.Item>
                              <Box key={item.ref}>
                                <img
                                  height="100%"
                                  width="100%"
                                  src={`data:image/jpeg;base64,${item.icon}`}
                                  style={{
                                    'vertical-align': 'middle',
                                    'horizontal-align': 'middle',
                                    '-ms-interpolation-mode':
                                      'nearest-neighbor',
                                  }}
                                />
                              </Box>
                            </Stack.Item>
                            <Stack.Item>{item.description}</Stack.Item>
                            <Stack.Item
                              textColor={
                                item.quantity - item.purchased <= 0
                                  ? 'red'
                                  : 'green'
                              }>
                              {'Quantity Remaining: ' +
                                (item.quantity - item.purchased)}
                            </Stack.Item>
                            <Stack.Item
                              textColor={
                                item.cost > card_points || !card_inserted
                                  ? 'red'
                                  : 'green'
                              }>
                              {'Cost: ' + item.cost}
                            </Stack.Item>
                            {!!item.buyable_ammo && (
                              <Stack.Item
                                textColor={
                                  item.magazine_cost > card_points ||
                                  !card_inserted
                                    ? 'red'
                                    : 'green'
                                }>
                                {'Ammo Cost: ' + item.magazine_cost}
                              </Stack.Item>
                            )}
                            <Stack.Item>
                              <Button
                                content="Buy"
                                textAlign="center"
                                width="100%"
                                disabled={
                                  item.cost > card_points ||
                                  item.purchased >= item.quantity
                                }
                                onClick={() =>
                                  act('equip_item', {
                                    armament_ref: item.ref,
                                  })
                                }
                              />
                            </Stack.Item>
                            {!!item.buyable_ammo && (
                              <Stack.Item>
                                <Button
                                  content="Buy Ammo"
                                  textAlign="center"
                                  width="100%"
                                  disabled={item.magazine_cost > card_points}
                                  onClick={() =>
                                    act('buy_ammo', {
                                      armament_ref: item.ref,
                                    })
                                  }
                                />
                              </Stack.Item>
                            )}
                          </Stack>
                        )
                    )
                  )
                )}
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
