library(rvest)
library(dplyr)
library(stringr)
library(httr)

# START
header <- add_headers(
  `authority` = 'www.bilbasen.dk',
  `accept` = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
  `accept-encoding` = 'gzip, deflate, br, zstd',
  `accept-language` = 'da-DK,da;q=0.9,en-US;q=0.8,en;q=0.7,zh-CN;q=0.6,zh;q=0.5',
  `cache-control` = 'max-age=0',
  `referer` = 'https://www.bilbasen.dk/brugt/bil/audi?includeengroscvr=true&includeleasing=false',
  `sec-ch-ua` = '"Chromium";v="130", "Google Chrome";v="130", "Not?A_Brand";v="99"',
  `sec-ch-ua-mobile` = '?0',
  `sec-ch-ua-platform` = '"macOS"',
  `sec-fetch-dest` = 'document',
  `sec-fetch-mode` = 'navigate',
  `sec-fetch-site` = 'none',
  `sec-fetch-user` = '?1',
  `upgrade-insecure-requests` = '1',
  `cookie` = '_sp_su=false; GdprConsent-Custom=eyJ2ZW5kb3JJZHMiOnt9fQ==; _cmp_analytics=0; _cmp_personalisation=0; _cmp_marketing=0; _cmp_advertising=0; consentUUID=ffebe013-c841-4962-ab82-15ed6dcd7ed0_29_37; consentDate=2024-11-10T19:03:26.794Z; GdprConsent={"version":"IAB TCF 2.0","consentString":"CQH36sAQH36sAAGABBENBOFgAAAAAAAAAAZQAAAAAAAA.YAAAAAAAAAAA"}; aws-waf-token=a395d947-fddc-4598-8b82-0ea45a222045:CgoAYGVEA1wCAAAA:D8BkpWuYAXk3AfxEN5xIr/p+YJpcF6v9F6CEBNtn8lcPmzgcldShePUsWoo27hf0hjtdHc62byTGOwSYXsCFUrWMGaCJVyy+ySxs8QGLM4YZMGFC3Jd6fHpSydP0yYJrUpcCyCgBTy0nJX7vpTbhDJ6+sSltIIwBoRigtAcfNrLzJ+LqqIiS7FdOs89y6ByQqNc=; bbsession=id=ea1ecefb-219e-4f34-8973-121c7e3bbbd8; bbtracker=id=b4cc424d-eb43-42bd-8bf5-e4e5cc8651b6; mvc.GlobalIdListe=%7b%221%22%3a6332102%2c%222%22%3a6358326%2c%223%22%3a6357481%2c%224%22%3a6271660%2c%225%22%3a6359800%2c%226%22%3a6363703%2c%227%22%3a6271596%2c%228%22%3a6363491%2c%229%22%3a6365594%2c%2210%22%3a6362555%2c%2211%22%3a6355078%2c%2212%22%3a6357435%2c%2213%22%3a6348750%2c%2214%22%3a6348771%2c%2215%22%3a6355313%2c%2216%22%3a6350103%2c%2217%22%3a6352191%2c%2218%22%3a6352201%2c%2219%22%3a6344215%2c%2220%22%3a6350322%2c%2221%22%3a6357304%2c%2222%22%3a6347607%2c%2223%22%3a6357288%2c%2224%22%3a6357259%2c%2225%22%3a6355341%2c%2226%22%3a6350854%2c%2227%22%3a6350289%2c%2228%22%3a6357350%2c%2229%22%3a6350422%2c%2230%22%3a6249039%2c%2231%22%3a6266143%2c%2232%22%3a6313415%7d; __RequestVerificationToken=iMLfm1J7wPII4e245bKgf0GH785WvLbgWXBUOLd2ztZGmT3GOxfkyuzsmI2Lf9Et3-qcGntY7ctmdf9rxuWww_31oD01; __utma=268477166.1350884285.1732014071.1732014071.1732014071.1; __utmc=268477166; __utmz=268477166.1732014071.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); _pulse2data=23ee1435-b78a-455b-94d8-2b8c2d2270a3%2Cv%2C%2C1732694514000%2CeyJpc3N1ZWRBdCI6IjIwMjEtMDgtMjRUMDc6NDM6MTNaIiwiZW5jIjoiQTEyOENCQy1IUzI1NiIsInJlSXNzdWVkQXQiOiIyMDI0LTExLTIwVDA4OjAxOjU0WiIsImFsZyI6ImRpciIsImtpZCI6IjIifQ..duKys-AGP5rBiBxI8gW1uA.rgkSzpJILzKg6kHXlvU0ZtctiuMNmmNKj-T03ychqUSB744h_eyq2tYEHzmhv8KdIVHwr8KfKpOim9teRq6avs0KGg8ngYtA9HkKbe82lvg64WfrmSi6gnGkXAy3RoHHnvodtMU4jufLLOrdiAlVLakF57QTNIo2LZ6XZo9vQDqfZ0WrWdb85QFwF_wMRcrUVGox1t50Q_IRDh2xJcXIWk6ErCDMDfyBQKHaE2U0y7c.PfMZppmvsm5QYCyBeZcI3w%2C%2C0%2Ctrue%2C%2C; _pulsesession=%5B%22sdrn%3Aschibsted%3Asession%3A9723a09f-405b-4e94-b757-bc504ef52010%22%2C1732089711142%2C1732089715036%5D',
  `user-agent` = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'
)

starturl <- "https://www.bilbasen.dk/brugt/bil/audi?fuel=3&includeengroscvr=true&includeleasing=false&page=2"
rawres <- GET(url=starturl, header)
rawres$status_code
rawcontent <- httr::content(rawres,as="text")
page <- read_html(rawcontent)
carlist <- page %>% html_elements("data-clickout-event")

# tag-liste
ptag=".Listing_price__6B3kE"
proptag=".Listing_properties___ptWv"
mmtag="[class^='Listing_makeModel']"
dettag="[class^='Listing_details']"
dettagitem="[class^='ListingDetails_listItem']"
desctag="[class^='Listing_description']"
loctag="[class^='Listing_location']"

# til dataframe
carheader <- c("price","property","model","detailitems","description","location","link","carid","scrapedate")
df <- as.data.frame(matrix(data=NA,nrow=0,ncol = 9))
colnames(df) <- carheader

# til en side
for (car in carlist) {
  tryCatch({
    price <- car %>% html_element(ptag) %>% html_text()
    props <- car %>% html_element(proptag) %>% html_text()
    makemodel <- car %>% html_element(mmtag) %>% html_text()
    details1 <- car %>% html_element(dettag) %>% html_text()
    details <- car %>% html_elements(dettagitem) %>% html_text() %>% paste0(collapse = "_")
    description <- car %>% html_elements(desctag) %>% html_text()
    location <- car %>% html_elements(loctag) %>% html_text()
    link <- car %>% html_element("a") %>% html_attr("href") 
    carid <- link %>% str_extract("[0-9]{7}")
    tmpdf <- data.frame(price,details,makemodel,props,description,location,link,carid,Sys.time())
    df <- rbind(df,tmpdf)
  },
  error = function(cond) {
    print(makemodel)
  }
  )
}

# Df for alle sider

carheader <- c("price","property","model","detailitems","description","location","link","carid","scrapedate")
adf <- as.data.frame(matrix(data=NA,nrow=0,ncol = 9))
colnames(adf) <- carheader


for (i in 1:37) {
  url <- paste0("https://www.bilbasen.dk/brugt/bil/audi?fuel=3&includeengroscvr=true&includeleasing=false&page=",i)
  rwres <- GET(url=url, header)
  rwcontent <- httr::content(rwres,as="text")
  pge <- read_html(rwcontent)
  cars <- pge %>% html_elements("article")
  for (car in cars) {
    tryCatch({
      price <- car %>% html_element(ptag) %>% html_text()
      props <- car %>% html_element(proptag) %>% html_text()
      makemodel <- car %>% html_element(mmtag) %>% html_text()
      details1 <- car %>% html_element(dettag) %>% html_text()
      details <- car %>% html_elements(dettagitem) %>% html_text() %>% paste0(collapse = "_")
      description <- car %>% html_elements(desctag) %>% html_text()
      location <- car %>% html_elements(loctag) %>% html_text()
      link <- car %>% html_element("a") %>% html_attr("href") 
      carid <- link %>% str_extract("[0-9]{7}")
      tmpdf <- data.frame(price,details,makemodel,props,description,location,link,carid,Sys.time())
      adf <- rbind(adf,tmpdf)
    },
    error = function(cond) {
      print(makemodel)
    }
    )
  }
}



# forhandler tag liste
fortag <- "[class^='bas-MuiTypography-root bas-MuiTypography-h3']"
idtag <- "[class^='bas-MuiTypography-root bas-MuiLink-root bas-MuiLink-underlineHover bas-MuiTypography-colorPrimary']"
alttag <- "[class^='bas-MuiTypography-root.bas-MuiLink-root.bas-MuiLink-underlineNone.bas-MuiSellerInfoComponent-address.bas-MuiTypography-colorPrimary']"
cvrtag <- "[class^='bas-MuiSellerInfoComponent-cvr']"


# loop der kører igennem hvert link fra webscrab af biler
# inde på hver side websraber den efter hvert af ovenstående tag
forheader <- c("forhandler", "id", "adresse", "cvr")
fordf <- as.data.frame(matrix(data=NA,nrow=0,ncol = 4))
colnames(fordf)=forheader

links <- adf$link

for (i in links) {
  url <- i
  rlres <- GET(url=url, header)
  rlcontent <- httr::content(rlres,as="text")
  pgl <- read_html(rlcontent)
  linkss <- pgl %>% html_elements("article")
  for (l in linkss) {
    tryCatch({
      forhandler <- l %>% html_element(fortag) %>% html_text()
      id <- l %>% html_element(idtag) %>% html_text()
      link <- id %>% html_element("a") %>% html_attr("href")
      forid <- link %>% str_extract("[0-9]{4}")
      adresse <- l %>% html_element(alttag) %>% html_text()
      cvr <- l %>% html_element(cvrtag) %>% html_text()
      cvrnr <- cvr %>% str_extract("[0-9]{8}")
      fdf <- data.frame(forhandler, id, adresse, cvrnr)
      fordf <- rbind(fordf,fdf)
      Sys.sleep(2)
    },
    error = function(cond) {
    })
  }
}

print(links)

for (i in links) {
  df <- rbind(df, data.frame(url = i, stringsAsFactors = FALSE))
}



fortag <- ".bas-MuiTypography-root.bas-MuiTypography-h3"
idtag <- ".bas-MuiTypography-root.bas-MuiLink-root.bas-MuiLink-underlineHover.bas-MuiTypography-colorPrimary"
alttag <- ".bas-MuiTypography-root.bas-MuiLink-root.bas-MuiLink-underlineNone.bas-MuiSellerInfoComponent-address.bas-MuiTypography-colorPrimary"
cvrtag <- ".bas-MuiSellerInfoComponent-cvr"

for (i in links) {
  tryCatch({
    # Hent siden
    rlres <- GET(url=i, header)
    Sys.sleep(runif(1, 0.2, 0.7))
    # Vent 2 sekunder mellem hver request
    
    #Check om request var succesfuld
    if(status_code(rlres) == 200) {
      # Parse HTML
      pgl <- read_html(httr::content(rlres, "text"))
      
      #Forsøg at ekstrahere data direkte uden at loope gennem artikler
      forhandler <- pgl %>% html_element(fortag) %>% html_text(trim=TRUE)
      id <- pgl %>% html_element(idtag) %>% html_text(trim=TRUE)
      adresse <- pgl %>% html_element(alttag) %>% html_text(trim=TRUE)
      cvr <- pgl %>% html_element(cvrtag) %>% html_text(trim=TRUE)
      cvrnr <- str_extract(cvr, "[0-9]{8}")
      
      #Hvis vi har data, tilføj til dataframe
      if(!is.na(forhandler) && !is.na(id) && !is.na(adresse) && !is.na(cvrnr)) {
        fdf <- data.frame(
          forhandler = forhandler,
          id = id,
          adresse = adresse,
          cvr = cvrnr,
          stringsAsFactors = FALSE
        )
        fordf <- rbind(fordf, fdf)
        print(paste("Behandlet link:", i))
      }
    }
  }, error = function(e) {
    print(paste("Fejl ved behandling af link:", i))
    print(e)
  })
}






####################
### FOR TYSKLAND ###
####################
headerT <- add_headers(
  `authority` = 'a.tribalfusion.com',
  `accept` = 'image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8',
  `accept-encoding` = 'gzip, deflate, br, zstd',
  `accept-language` = 'da-DK,da;q=0.9,en-US;q=0.8,en;q=0.7',
  `cookie` = 'ANON_ID=aGnQgMoNIvapmVrFI3OCcLpIdf733gZdfGPS2XPPWQRX9joA43ZaGTVXZaB6ZdoDrdCVZch1UZbPj7aF5pmcXA76yVJjAZafXkvyiFYJJk5Va5J1wZaZcRbxZbeXf8p3PikunBLeeQVukZdb28RZaZcsERt3rFsJxCN117S4AB3oXllZaDicWoC5kMbZddXMZc8FfoN5x5RWJZd2UruHCyek1',
  `priority` = 'i',
  `referer` = 'https://pagead2.googlesyndication.com/',
  `sec-ch-ua` = '"Chromium";v="130", "Google Chrome";v="130", "Not?A_Brand";v="99"',
  `sec-ch-ua-mobile` = '?0',
  `sec-ch-ua-platform` = '"macOS"',
  `sec-fetch-dest` = 'image',
  `sec-fetch-mode` = 'no-cors',
  `sec-fetch-site` = 'cross-site',
  `user-agent` = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'
)

starturlT <- "https://www.12gebrauchtwagen.de/kraftstoff/elektro/audi"
rawresT <- GET(url=starturlT, headerT)
rawresT$status_code
rawcontentT <- httr::content(rawresT,as="text")
pageT <- read_html(rawcontentT)
carlistT <- page %>% html_elements("row search-results")





