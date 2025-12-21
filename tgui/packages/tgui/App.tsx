import { Provider } from 'jotai';
import { store } from './events/store';
import { IconProvider } from './Icons';
import { RoutedComponent } from './routes';

export function App() {
  return (
    <Provider store={store}>
      <RoutedComponent />
      <IconProvider />
    </Provider>
  );
}
