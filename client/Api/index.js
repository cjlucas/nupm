export default class Api {
  constructor(authToken) {
    this.authToken = authToken;
  }
  _buildUrl(endpoint, params) {
    const query =
      Object.keys(params)
      .map(key => `${key}=${params[key]}`)
      .join('&');

    return `${endpoint}?${encodeURI(query)}` 
  }

  _fetch(method, endpoint, params, headers, body) {
    if (!params) params = {};
    if (!headers) headers = {};

    if (this.authToken) {
      headers['Authorization'] = `Bearer ${this.authToken}`;
    }

    return fetch(this._buildUrl(endpoint, params), {
      method: method,
      headers: headers,
      body: JSON.stringify(body),
    });
  }

  getPackages(limit, cursor) {
    return this._fetch('GET', '/api/packages', {
      limit: limit,
      cursor: cursor,
    });
  }

  login(email, password) {
    const headers = {
      Authorization: `Basic ${window.btoa(`${email}:${password}`)}`,
    };
    return this._fetch('POST', '/api/sessions', null, headers);
  }
}
