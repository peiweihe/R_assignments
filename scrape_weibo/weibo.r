weibo_oauth = function (endpoint, app, redirect_uri) {
  authorize_url <- modify_url(endpoint$authorize, 
                              query = list(client_id = app$key, redirect_uri = redirect_uri, response_type = "code"))
  code <- oauth_exchanger(authorize_url)$code

  req_params <- list(client_id = app$key, redirect_uri = redirect_uri, grant_type = "authorization_code", 
                     code = code, client_secret = app$secret)
  req <- POST(endpoint$access, encode = "form", body = req_params)
  
  stop_for_status(req, task = "get an access token")
  content(req, as="parsed", type="application/json")
}

weibo_get <- function(token, path, ...) {
  url = paste0("https://api.weibo.com/2/", path, ".json")
  query = c(list(access_token=token$access_token), list(...))
  res = httr::GET(url, query=query)
  stop_for_status(res, task = paste("Query weibo:", url))
  content(res)
}

library(httr)

APP_KEY = "2132356176"
APP_SECRET = "e0df9a11bd3cd5bf267109bffe533c02"
REDIRECT_URI = "http://vanatteveldt.com/"

weibo_endpoint = oauth_endpoint(base_url = 'https://api.weibo.com/oauth2/', authorize = "authorize", access = "access_token")
app = oauth_app(weibo_endpoint, key = APP_KEY , secret = APP_SECRET)
token = weibo_oauth(weibo_endpoint, app, REDIRECT_URI)

x = weibo_get(token, "users/show", uid=6150188739)

t = weibo_get(token, "statuses/friends_timeline", uid=6150188739)

status = t$statuses[[1]]
status$user$screen_name
weibo_get(token, 'comments/show', id=status$id)
