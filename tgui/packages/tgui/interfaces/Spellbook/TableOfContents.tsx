import { useAtom } from 'jotai';
import { Box, Button, Divider } from 'tgui-core/components';
import { tabAtom } from '.';
import { Tab } from './types';

export const lineHeightToc = '30.6px';

export function TableOfContents(props) {
  const [_tabIndex, setTabIndex] = useAtom(tabAtom);

  return (
    <Box textAlign="center">
      <Button lineHeight={lineHeightToc} fluid icon="pen" disabled>
        Смена имени
      </Button>

      <Button lineHeight={lineHeightToc} fluid icon="clipboard" disabled>
        Содержание
      </Button>

      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="fire"
        onClick={() => setTabIndex(Tab.Defensive)}
      >
        Смертельные заклинания
      </Button>

      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="shield-alt"
        onClick={() => setTabIndex(Tab.Defensive)}
      >
        Защитные заклинания
      </Button>
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="globe-americas"
        onClick={() => setTabIndex(Tab.Assistance)}
      >
        Магическое перемещение
      </Button>
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="users"
        onClick={() => setTabIndex(Tab.Assistance)}
      >
        Помощь и призыв
      </Button>
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="crown"
        onClick={() => setTabIndex(Tab.Rituals)}
      >
        Испытания
      </Button>
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="magic"
        onClick={() => setTabIndex(Tab.Rituals)}
      >
        Ритуалы
      </Button>
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="thumbs-up"
        onClick={() => setTabIndex(Tab.Randomize)}
      >
        Одобренные наборы волшебника
      </Button>
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="dice"
        onClick={() => setTabIndex(Tab.Randomize)}
      >
        Мистический рандомайзер
      </Button>
      <Divider />
      <Button
        lineHeight={lineHeightToc}
        fluid
        icon="cog"
        onClick={() => setTabIndex(Tab.TableOfContents2)}
      >
        Перки
      </Button>
    </Box>
  );
}
