library(rvest)

test = read_html("http://i.amcat.nl/test/test.html")
class(test)

html_text(test)

paras = html_nodes(test, "p")
html_text(paras)


links = html_nodes(paras, "a")
html_attr(links, "href")
html_text(links)


#pipelining
test = read_html("http://i.amcat.nl/test/test.html")
paras = html_nodes(test, "p")
links = html_nodes(paras, "a")
html_attr(links, "href")


  
url = "http://i.amcat.nl/test/test.html"
read_html(url) %>% html_nodes("p") %>% html_nodes("a") %>% html_attr("href")


read_html(url) %>% html_nodes("p a") %>% html_attr("href")





test2 = read_html("http://i.amcat.nl/test/test_css.html")
html_structure(test2)

test2 %>% html_nodes("a") %>% html_attr("href")

test2 %>% html_nodes(".main a") %>% html_attr("href")


test2 %>% html_nodes(".main") %>% html_nodes("a") %>% html_attr("href")


test2 %>% html_nodes(".main p a") %>% html_attr("href")

test2 %>% html_nodes(".main h1") %>% html_text

# xpath

url = "https://en.wikipedia.org/wiki/Hong_Kong"

r = read_html(url)
html_structure(r)
subheaders = r %>% html_nodes("h3")
edu = subheaders[html_text(subheaders) == "Education"]

siblings = html_nodes(edu, xpath = "following-sibling::*")

next_h3 = which(html_name(siblings) == "h3")[1]
edu_nodes = siblings[1:(next_h3-1)]
html_text(edu_nodes)

links = html_nodes(edu_nodes, "a") %>% html_attr("href")

img = html_node(r, "img")
a = html_attrs(img)
names(a)

a["src"]

imgs = html_nodes(r, "img")[1:5]
a = html_attrs(imgs)

html_attr(imgs, "src")


r = read_html("http://i.amcat.nl/test/test_table.html")

header = r %>% html_nodes("th") %>% html_text
data = r %>% html_nodes("td") %>% html_text

write_html(r, file="/tmp/test.html")

t = as.data.frame(matrix(data, ncol = length(header), byrow = T))
colnames(t) = header
t


t = r %>% html_node("table") %>% html_table
colnames(t)
class(t$ID)
class(t$Gender)
t


r = read_html("https://en.wikipedia.org/wiki/List_of_monarchs_of_the_Netherlands")
t = r %>% html_node("table")
View(html_table(t))


# forms

session = html_session("https://en.wikipedia.org/wiki/Special:Search")
f = (session %>% html_form)[[1]]
f = set_values(f, search="Obama")
r = submit_form(session, f)

r %>% html_nodes("ul.mw-search-results a") %>% html_attr("href")

r2 = follow_link(r, i="next 20")
r2 %>% html_nodes("ul.mw-search-results a") %>% html_attr("href")

# manipulating urls
url = "https://en.wikipedia.org/w/index.php?title=Special:Search&limit=20&offset=0&profile=default&search=Trump"
p = read_html(url)
info = html_nodes(p, ".results-info strong") %>% html_text
nhits = as.numeric(gsub(",", "", info[2]))
npages = floor(nhits  / 100)
npages = 3
query = "Trump"
urls = NULL
for (page in 1:npages) {
  template = "https://en.wikipedia.org/w/index.php?title=Special:Search&limit=100&offset=%s&profile=default&search=%s"
  offset = page * 100
  url = sprintf(template, offset, query)
  message(url)
  p = read_html(url)
  refs = p %>% html_nodes("ul.mw-search-results a") %>% html_attr("href")
  urls = c(urls, refs)
}
length(urls)


# sprintf function

template = "Hello, %s, from %s"
sprintf(template, "John", "Mary")

url = "https://en.wikipedia.org/w/index.php?title=Special:Search&limit=100&offset=400&profile=default&search=Trump"
p = read_html(url)
head(p %>% html_nodes("ul.mw-search-results a") %>% html_attr("href"))

# login form

r = html_session("https://github.com/login")
f = html_form(r)[[1]]
f = set_values(f, login="vanatteveldt", password=password)
s = submit_form(r, f)

r = jump_to(s, "https://github.com/settings/emails")
emails = r %>% html_nodes("ul#settings-emails li") %>% html_text

stringi::stri_extract_first(emails, regex="[\\w\\.]+@[\\w\\.]+")


# adding info to atable

t = data.frame(id=11:13, names=c("John","Mary","Pete"))
#for (i in 1 : nrow(t))
for (i in seq_along(t$id)) {
  # get existing values
  id = t$id[i]
  # compute new value
  code = sprintf("code for %i", id)
  # store new value
  t$code[i] = code
}
knitr::kable(t)

t
