library("rvest")

# (1) download page
url = "https://en.wikipedia.org/wiki/89th_Academy_Awards"
r = read_html(url)


# (2) extract table

h = r %>% html_nodes("h3")

h = h[html_text(h) == "Films with multiple nominations[edit]"]

h = h[grepl("multiple nominations", html_text(h))]
t = html_node(h[[1]], xpath="following-sibling::*") %>% html_node("table")

table = html_table(t)

# (3) extract links

links = t %>% html_nodes("a") %>% html_attr("href")
links = paste("https://en.wikipedia.org", links, sep = "")
table$link = links

#(4) get extra information

for (i in seq_along(links)) {
  link = links[i]
  message(link)
  detail = read_html(link) %>% html_node("table.infobox") %>% html_table
  colnames(detail) <- c("name", "values")
  country = detail$values[detail$name == "Country"]
  table$Country[i] = country
}

detail = read_html(link) %>% html_node("table.infobox.vevent") %>% html_table


l = list(3,5,7)
l[[2]]


# with function

get_country = function(page) {
  details = page %>% html_node("table.infobox") %>% html_table
  colnames(details) <- c("name", "value")
  details$value[details$name == "Country"]
}
get_language = function(page) {
  details = page %>% html_node("table.infobox") %>% html_table
  colnames(details) <- c("name", "value")
  details$value[details$name == "Language"]
}


table$Country = ""
table$Language = ""
for (i in seq_along(links)) {
  message(i)
  page = read_html(links[i])
  table$Country[i] = get_country(page)
  table$Language[i] = get_language(page)
}


# with heneric function

get_fact = function(page, key) {
  details = page %>% html_node("table.infobox") %>% html_table
  colnames(details) <- c("name", "value")
  details$value[details$name == key]
}


extra_info <- function(link) {
  page = read_html(link)
  language = get_fact(page, "Language")
  country = get_fact(page, "Country")
  return(data.frame(link=link, language=language, country=country))
}

extra_info(link)

extra = ldply(links, extra_info)
table = merge(table, extra, all.x=T)
