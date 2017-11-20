# NuPM

A Javascript package manager similar to NPM.

## Client Instructions

```
$ cd client
$ yarn install
$ webpack
```

The generated html/js/css files will be placed in client/dist and be served
by the server.

## Server Instructions

### Requirements

The system utilizes a Postgres database as its only external requirement. (And Elixir, of course.)

### To Launch

#### Create database

`$ mix ecto.create && mix ecto.migrate`

**NOTE**: The db user specified in the config (config/dev.exs) must have
database creation privileges.

#### Start Phoenix

`$ mix phx.server`

This will start Phoenix on `0.0.0.0:4001`

### Prime the database

`$ mix run scripts/primer.exs`

To prime the database with some data, I created a primer script which scrapes
the local NPM cache directory (~/.npm/) by looking for a few hardcoded packages
and inserting those into the database, it also traverses package dependencies
recursively and inserts those as well.

This was mainly just a quick and dirty way to get data into the system when
I was developing the HTTP APIs.

**NOTE**: Your milage may very with this script depending on your local cache.

### To Test

`$ mix test`

## HTTP API

I divided the HTTP API into two components, REST and non-REST, where REST endpoints
are placed under the /api/ namespace.

Note that packages are not created through the REST endpoint, but are instead
created by uploading a valid archive file to `/upload`.

### REST Endpoints

#### `POST /api/users`

Create a user.

Request Body:
```
{
    "email": "foo@bar.com",
    "password": "foobarbaz"
}
```

Response Body:
```
{
	"updated_at": "2017-11-20T16:44:09.615292",
	"inserted_at": "2017-11-20T16:44:09.615277",
	"id": "309bc74c-ae37-409e-8efb-7b847b145df3",
	"email": "foo@bar.com"
}
```

#### `POST /api/sessions`

Create a session. All endpoints under the `/api/packages` namespace require
authentication using a simple Basic/Bearer authorization scheme.

To create a session, one must provide the user email and password using
the Authorization header.

Response Body:
```
{
	"token": "5e1ceb69-0756-4b19-89a9-7dfceb5dfc38",
	"email": "foobar@baz.com"
}
```

The token can then be used as a Bearer token on further API calls.

#### `GET /api/packages`

Get all packages.

I decided to go with a cursor-based pagination model for this endpoint, where
the cursor is an opaque data structure that represents the last element in the
result. This cursor is then specified in further requests to fetch the succeeding
elements.

Example:
`http://home.cjlucas.net:4001/api/packages?limit=10`

Response Body:
```
{
    "page_info": {
		"total_results": 305,
		"next_url": "http://home.cjlucas.net:4001/api/packages?after=aW5zZXJ0ZWRfYXQ6MjAxNy0xMS0xOVQyMDoyODo1Ny4xOTU0Mzk%3D&limit=10&order=inserted_at"
	},
	"data": [
		{
            		"versions": [
                		"0.5.1"
            		],
			"updated_at": "2017-11-19T20:29:07.175034",
			"title": "mkdirp",
			"inserted_at": "2017-11-19T20:29:07.175027",
			"id": "5caa7d86-425a-4a20-8f7e-5e79b9a0aff1"
		},
        	{...}
    ]
}
```

By providing the URL to the next page directly, the cursor becomes an implementation
detail and the user can simply call the URL provided at `page_info.next_url`.

#### `GET /api/packages/<name>`

Get info about a package.

Example:
`http://home.cjlucas.net:4001/api/packages/lodash`

Response Body:
```
{
	"versions": [
		"3.10.1",
		"1.0.2",
		"3.7.0",
		"2.4.2",
		"4.17.4"
	],
	"updated_at": "2017-11-19T19:06:53.521853",
	"title": "lodash",
	"inserted_at": "2017-11-19T19:06:53.521847",
	"id": "3ab5d7a6-4847-4ea9-a076-bda73910b538"
}
```

#### `GET /api/packages/<name>/<version>`

Get info about a specific version of a package.

**NOTE**: `latest` can be used as a psuedo version for convencience.

Example:
`http://home.cjlucas.net:4001/api/packages/lodash/1.0.2`

Response Body:
```
{
	"website": "https://lodash.com/",
	"version": "1.0.2",
	"updated_at": "2017-11-19T19:06:53.529560",
	"repository": null,
	"readme": "# Lo-Dash v1.0.2\n\nA utility library delivering...",
	"package": "lodash",
	"license": "MIT",
	"inserted_at": "2017-11-19T19:06:53.529555",
	"description": "A utility library delivering consistency, customization, performance, and extras.",
	"author_email": "john.david.dalton@gmail.com",
	"author": "John-David Dalton"
}
```


### Non-REST Endpoints

#### `GET /downloads/<name>/<version>`

Download the uploaded version of a package.

Example:
`http://home.cjlucas.net:4001/downloads/express/4.15.2`

#### `POST /upload`

Upload a package.

**NOTE:** This endpoint requires a .tar.gz archive containing a valid javascript
project (the package must contain a package.json).

The server expects an HTML form where archive is specified under the `file` field.

## Thoughts and Reflections

### Plans for search functionality

Search functionality would have been exposed through a REST endpoint similar
to `/api/packages` where a paginated result would be returned.

In terms of implementation, a simple SQL lookup for a package name would
have sufficed, but this tends to lead to uninteresting results, where the result
set is either zero or one elements (package was found or not found). Ideally,
the search system would account for package name, but also other data, such as
its description and keywords into account. For instance, if a user was interested
in looking for web frameworks, the user could simply search for "web frameworks"
and get a list of frameworks back. Given the time constraints, I would have
gone for a simple augmented trie approach, where each package name, keyword,
and word in a description is treated as a distinct token that references the
package. The user's query would then be broken down into tokens. In the above
example, two seperate queries would be issued into the trie, one for "web" and
one for "frameworks" where a set of packages is returned from each query. The
ultimate result would then simply a union of these results.

I love building event driven systems in Elixir. I would have implemented this
feature by adding a `Repo.EventManager` GenServer that would allow other processes
to subscribe to events such as a "package created" or "user deleted". I would
then have a event listener process that would update the tree whenever a
package is created in the repo.


### Areas to Improve

Overall, I'm pleased with how the server turned out, but a few things can
be improved.

Testing and documentation can be improved dramatically. Elixir provides excellent
tooling in these areas with ExDoc and ExUnit and I've found them invaluable in the
past.

Currently, the authentication server (`NuPM.Auth.Server`) is simply a process
that manages an ETS table without any redundancy, meaning if the process crashes
for whatever reason, any existing sessions would be forgotten. As Elixir/Erlang
systems should be designed to recover from faults gracefully, a persistent
storage option such as DETS should be used.

Uploaded packages are currently stored locally in a configuration-specified
directory. In a production system, it would be better to store these on an
external storage service such as S3 that can provide redundancy as well as offload
traffic from the core API servers.
