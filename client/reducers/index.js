import { combineReducers } from 'redux';

function recentPackages(state = [], action) {
  if (action.type === 'RECEIVED_NEWEST_PACKAGES') {
    return action.packages;
  }

  return state;
}

function loginState(state = {}, action) {
  if (action.type === 'LOGIN_SUCCEEDED') {
    return {
      token: action.token,
    };
  }

  return state;
}

export default combineReducers({
  recentPackages,
  loginState,
});
