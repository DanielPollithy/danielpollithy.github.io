---
layout: post
published: true
categories:
  - personal
  - python
  - django
mathjax: false
featured: false
comments: false
title: React Login with Django
---
## Example of a React SPA that logs into a Django backend with JWT

A scenario for SPAs is that you might be building it to further use it in a mobile app (maybe react-native). 
To avoid switching from session_ids stored in secure cookies which is the standard way of django doing it you could use a JWT.

Json Web Token is a token standard for authorization and role handling. You can login into one page as "PaidUser" and the signature from the server A proves the server B that you indeed paid for your user account.

## The django backend

I assume you have a django project. If not you can walk through the [Django tutorial](https://docs.djangoproject.com/en/2.0/intro/tutorial01/). 

I used the django-rest-framework ([drf](http://www.django-rest-framework.org/)) to build the API in the backend. 
For the token handling we have to `pip install djangorestframework-simplejwt` which will do all of the "heavy" lifting for us.

Now add the JWTAuthentication to the REST_FRAMEWORK settings:
```
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    )
}
```
... and append the SIMPLE_JWT settings afterwards:

```
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': datetime.timedelta(minutes=14*24*60),
    'REFRESH_TOKEN_LIFETIME': datetime.timedelta(days=30),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,

    'ALGORITHM': 'HS256',
    'SIGNING_KEY': settings.SECRET_KEY,
    'VERIFYING_KEY': None,

    'AUTH_HEADER_TYPES': ('Bearer',),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',

    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'TOKEN_TYPE_CLAIM': 'token_type',

    'SLIDING_TOKEN_REFRESH_EXP_CLAIM': 'refresh_exp',
    'SLIDING_TOKEN_LIFETIME': datetime.timedelta(minutes=5),
    'SLIDING_TOKEN_REFRESH_LIFETIME': datetime.timedelta(days=1),
}
```

The last step is to add the token urls to your urlpatterns:

```
from django.conf.urls import url
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns += [
    ...
    url(r'^api/auth/token/obtain/$', TokenObtainPairView.as_view()),
    url(r'^api/auth/token/refresh/$', TokenRefreshView.as_view())
]
```

## Explanation of the effects

Installing this django module will enable you to obtain and refresh access tokens of the JWT style.

Actually making a POST to `api/auth/token/obtain/` with a body like this `['daniel', '1234password']` will return two tokens. The `access` token usually has a short lifetime. You can renew it with the `refresh` token POSTed to `api/auth/token/obtain/`.

That's about it. To access restricted API endpoints like `api/my_shopping_cart` you only have to set a HTTP Header to your request like so: `Authorization: Bearer <JWT_ACCESS_TOKEN>`.

You can use the online tool [https://jwt.io/](https://jwt.io/) to check expiry date and other information encoded into the token.

## The frontend

In the first step I implemented this with Vue.JS but currently I was trying to get something done with React so here are the important steps to:

1. Obtain a token
2. Check the expiry and refresh
3. Make an authorized `fetch`
4. "Logging out"

Again the "heavy" lifting will be done by a dedicated module: `npm install --save jwt-decode`

All of the following code happens in a global service called **JWTService**.

### Obtain a token

```
login(username, password) {
	return this.fetch(`${this.domain}/api/auth/token/obtain/`, {
	    method: 'POST',
	    body: JSON.stringify({username, password})
	}).then(res => {
	    this.setToken(res.access)
	    this.setRefreshToken(res.refresh)
	    return Promise.resolve(res);
	})
}
```

The tokens are stored in the local storage like so:

```
setToken(idToken) {
	localStorage.setItem('id_token', idToken)
}

setRefreshToken(idTokenRefresh) {
	localStorage.setItem('id_token_refresh', idTokenRefresh)
}

getToken() {
	return localStorage.getItem('id_token')
}

getRefreshToken() {
	return localStorage.getItem('id_token_refresh')
}
```

## Check the expiry and refresh

Let's decode the token and compare its expiry date with the current time.
```
isTokenExpired(token) {
  try {
      if (decode(token).exp < Date.now() / 1000) {
          return true;
      }
      else
          return false;
  }
  catch (err) {
      return false;
  }
}
```

If there is a refresh token in the local storage we can send it to the server and obtain a new access and refresh token. Obtaining both of them with a single refresh is the setting **ROTATE_REFRESH_TOKENS**.

```
refresh() {
  if(this.getRefreshToken() === null) {
      return Promise.reject('No refresh token in memory')
  }

  return this.fetch('${this.domain}/api/auth/token/refresh/', {
      method: 'POST',
      body: JSON.stringify({
          refresh: this.getRefreshToken()
      })
  }).then(res => {
      this.setToken(res.access)
      this.setRefreshToken(res.refresh)
      return Promise.resolve(res);
  }).catch(err => {
     this.logout();
     return err;
  });
}
```

## Make an authorized fetch

React comes with the fetch method similar to the well known XMLHttpRequest.

The first thought would be to build a request like this:

```
const headers = {
	'Accept': 'application/json',
	'Content-Type': 'application/json',
    'Authorization': 'Bearer ' + this.getToken() // <-- that's special
}

fetch(url, {headers}).then(...)
```

But preferably we can bind a new "fetch" method which includes the headers automatically for us:

```
fetch(url, options) {
  const headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json'
  }

  // Setting Authorization header
  // Authorization: Bearer xxxxxxx.xxxxxxxx.xxxxxx
  if (this.loggedIn()) {
      headers['Authorization'] = 'Bearer ' + this.getToken()
  }

  return fetch(url, {headers, ...options})
}
```












