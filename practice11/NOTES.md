# Practice 11 - A Real Server (users_api)

API: https://jsonplaceholder.typicode.com

## Level 1 — Postman first

GET /users: status 200, Content-Type `application/json; charset=utf-8`,
body is a JSON **array** of **10** users (no envelope, no `data` key).
GET /users/1: status 200, a single **object**.

Keys: id, name, username, email, address, phone, website, company.
Nested objects: address, company. Nested twice: address.geo.

### User
| field    | JSON type | Dart type        | nullable?                      |
| -------- | --------- | ---------------- | ------------------------------ |
| id       | number    | int              | no                             |
| name     | string    | String           | no                             |
| username | string    | String           | no                             |
| email    | string    | String           | no                             |
| phone    | string    | String           | no (raw, getter phoneDigits)   |
| website  | string    | String?          | yes (the only optional field)  |
| address  | object    | Address          | no                             |
| company  | object    | Company (record) | no                             |

### address
| field   | JSON type | Dart type | nullable? |
| ------- | --------- | --------- | --------- |
| street  | string    | String    | no        |
| suite   | string    | String    | no        |
| city    | string    | String    | no        |
| zipcode | string    | String    | no        |
| geo     | object    | Geo       | no        |

### address.geo
| field | JSON type               | Dart type | nullable? |
| ----- | ----------------------- | --------- | --------- |
| lat   | string ("-37.3159")     | double    | no (double.parse) |
| lng   | string ("81.1496")      | double    | no (double.parse) |

### company
| field       | JSON type | Dart type | nullable? |
| ----------- | --------- | --------- | --------- |
| name        | string    | String    | no        |
| catchPhrase | string    | String    | no        |
| bs          | string    | not used  | -         |

### Errors and POST
| request                       | status    | body                                          |
| ----------------------------- | --------- | --------------------------------------------- |
| GET /users/999                | 404       | `{}`                                          |
| POST /users (application/json)| 201       | what I sent + `"id": 11` (not really saved)  |
| GET /users?id=3               | 200       | a list of one user, not an object             |

Mapping in `_check`: 401 → UnauthorizedException, 404 → NotFoundException,
>= 500 → ServerException(status), other 4xx → BadResponseException;
no answer (SocketException / TimeoutException) → NoConnectionException;
body is not JSON → BadResponseException.

## Level 5 — Two kinds of "no network"

Both tests were done in Chrome (Flutter web) with DevTools → Network throttling,
a stopwatch started when I pressed reload and stopped when the Offline view appeared.

| test                                                             | time until the Offline view |
| ---------------------------------------------------------------- | --------------------------- |
| Airplane mode equivalent (throttling = Offline)                  | about 1 s                   |
| Wi-Fi that leads nowhere (custom profile "Dead", latency 30000 ms) | about 10 s                |

Both end on the same `Offline` view with Retry: `SocketException`, `TimeoutException`
and `http.ClientException` are all turned into `NoConnectionException`.
Offline fails immediately (the browser knows there is no route), the dead
connection hangs until the 10-second timeout in `ApiClient._send` fires.

DevTools (Chrome → Network):

- `screenshot_timeout.png` — the `/users` row with no status, about 10 s
- `screenshot_200.png` — a `200` row with the response body opened

POST from the UI: one tap on Save = one `POST /users`, status `201`
(the button is disabled while the request is in flight).