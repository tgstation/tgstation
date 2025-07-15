import { useBackend } from '../../backend';
import { GenericUplink, type Item } from '../Uplink/GenericUplink';

type Category = {
  name: string;
  items: MalfItem[];
};
/* This is shitcode, but someone used normal uplink so i feel justified */
type MalfItem = Item & {
  minimum_apcs: number;
};

type Data = {
  processingTime: string;
  hackedAPCs: number;
  categories: Category[];
};

/** Common ui for selecting malf ai modules */
export function MalfAiModules(props) {
  const { act, data } = useBackend<Data>();
  const { processingTime, hackedAPCs, categories = [] } = data;

  const categoriesList: string[] = [];
  const items: MalfItem[] = [];

  for (let idx = 0; idx < categories.length; idx++) {
    const category = categories[idx];
    categoriesList.push(category.name);

    for (let itemIndex = 0; itemIndex < category.items?.length; itemIndex++) {
      const item = category.items[itemIndex];
      items.push({
        category: category.name,
        cost: `${item.cost} PT`,
        desc:
          item.desc +
          (item.minimum_apcs > 0
            ? ` Requires at least ${item.minimum_apcs} APCs hacked.`
            : ''),
        disabled: processingTime < item.cost || hackedAPCs < item.minimum_apcs,
        icon_state: item.icon_state,
        icon: item.icon,
        id: item.name,
        name: item.name,
        population_tooltip: '',
        insufficient_population: false,
        minimum_apcs: item.minimum_apcs || 0, // Handle the case where minimum_apcs is not defined
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
