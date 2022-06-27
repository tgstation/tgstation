import { Component, InfernoNode } from 'inferno';
import { resolveAsset } from '../../assets';
import { fetchRetry } from '../../http';
import { ServerData } from './data';

// Cache response so it's only sent once
let fetchServerData: Promise<ServerData> | undefined;

export class ServerPreferencesFetcher extends Component<
  {
    render: (serverData: ServerData | undefined) => InfernoNode;
  },
  {
    serverData?: ServerData;
  }
> {
  state = {
    serverData: undefined,
  };

  componentDidMount() {
    this.populateServerData();
  }

  async populateServerData() {
    if (!fetchServerData) {
      fetchServerData = fetchRetry(resolveAsset('preferences.json')).then(
        (response) => response.json()
      );
    }

    const preferencesData: ServerData = await fetchServerData;

    this.setState({
      serverData: preferencesData,
    });
  }

  render() {
    return this.props.render(this.state.serverData);
  }
}
