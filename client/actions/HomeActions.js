import Api from '../Api';

export function getNewestPackages() {
  return (dispatch, getState) => {
    const api = new Api(getState().loginState.token);
    return api.getPackages(10)
      .then(resp => resp.json())
      .then(data => dispatch({
        type: 'RECEIVED_NEWEST_PACKAGES',
        packages: data['data'],
      }));
  };
}

export function attemptLogin(email, password) {
  return (dispatch, getState) => {
    const api = new Api();
    return api.login(email, password)
      .then(resp => resp.json())
      .then(data => dispatch({
        type: 'LOGIN_SUCCEEDED',
        token: data['token'],
      }));
  }
}
