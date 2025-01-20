import { useBackend } from '../../backend';
import { GenericUplink, Item } from '../Uplink/GenericUplink';

type Category = {
  name: string;
  items: Item[];
};

type Data = {
  processingTime: string;
  categories: Category[];
};

/** Common ui for selecting malf ai modules */
export function MalfAiModules(props) {
  const { act, data } = useBackend<Data>();
  const { processingTime, categories = [] } = data;

  const categoriesList: string[] = [];
  const items: Item[] = [];

  for (let idx = 0; idx < categories.length; idx++) {
    const category = categories[idx];
    categoriesList.push(category.name);

    for (let itemIndex = 0; itemIndex < category.items?.length; itemIndex++) {
      const item = category.items[itemIndex];
      items.push({
        category: category.name,
        cost: `${item.cost} PT`,
        desc: item.desc,
        disabled: processingTime < item.cost,
        icon_state: item.icon_state,
        icon: item.icon,
        id: item.name,
        name: item.name,
      });
    }
  }

  return (
    <GenericUplink
      categories={categoriesList}
      items={items}
      currency={`${processingTime} PT`}
      handleBuy={(item) => act('buy', { name: item.name })}
    />
  );
}
