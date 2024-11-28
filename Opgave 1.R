library(rvest)
library(dplyr)
library(stringr)
library(httr)
library(dplyr)


# Sammensæt headers med kun de vigtigste cookies
header <- add_headers(
  `cookie` = 'aws-waf-token=6bd332cb-b984-4d98-8bc9-bf3a66778c46:CgoAh10ys7eFAAAA:LG+sJxuoGu1L5bj6lkuF8vEFjP1Km2YAfmx6PYpq2BCp6igUSdjEl8wrz7u8S7IPOGhridca1hGAN2RjBFpRw/OzO9+cPmz5iaERhEEsl0sdQs9+pKVb2PcDyTPXO5GVzCUGwFTwaYTD73s1V3nHYHW42150PFXMrBOHaIz19x8g6PS/u9CVuVDvJJ2RwPqFadA=;_cmp_analytics=0;_cmp_personalisation=0;GdprConsent={"version":"IAB TCF 2.0","consentString":"CQH36sAQH36sAAGABBENBOFgAAAAAAAAAAZQAAAAAAAA.YAAAAAAAAAAA"};_pulse2data=23ee1435-b78a-455b-94d8-2b8c2d2270a3%2Cv%2C%2C1733396799000%2CeyJpc3N1ZWRBdCI6IjIwMjEtMDgtMjRUMDc6NDM6MTNaIiwiZW5jIjoiQTEyOENCQy1IUzI1NiIsInJlSXNzdWVkQXQiOiIyMDI0LTExLTI4VDExOjA2OjM5WiIsImFsZyI6ImRpciIsImtpZCI6IjIifQ..BD-GwVk9pm0ckXZFcgtB5w.eYa2FIKM2_CoJo_r8GOhSxW-Dr-CouCPU2xrTYUDZGPg6IciIRuXCdQuXvuDgNnXsS3CQeFA1ufRGw3XGPO3GAuUC2AL-ZEofPFdpGSBw_I7dmOg4Gxj8iiy8HVqJtWTHyw8W4wcMnn-6rSaKECcJ4lIWn70VVZpOEu7BQmVqGNE2GzbxbZgpV8gW2Qij4z0uRz3t3OmgmUJanrB1MeglW0JuWbT_AQUqaDeZRcTvA0.ENenqiYKJTaDuhtWFJhWlg%2C%2C0%2Ctrue%2C%2C;_cmp_advertising=0;_sp_su=false;__utma=268477166.1350884285.1732014071.1732098456.1732136361.3;_cmp_marketing=0;_pulsesession=%5B%22sdrn%3Aschibsted%3Asession%3Ae35104ce-f96d-43f4-8442-0a7148a3f65e%22%2C1732791999026%2C1732791999026%5D;bbsession=id=cea38d12-7f5c-4f1b-b07f-2a6ce4ab39cb;bbtracker=id=b4cc424d-eb43-42bd-8bf5-e4e5cc8651b6;consentDate=2024-11-10T19:03:26.794Z;consentUUID=ffebe013-c841-4962-ab82-15ed6dcd7ed0_29_37;GdprConsent-Custom=eyJ2ZW5kb3JJZHMiOnt9fQ==',
  `user-agent` = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'
)

starturl <- "https://www.bilbasen.dk/brugt/bil/audi?fuel=3&includeengroscvr=true&includeleasing=false"
rawres <- GET(url=starturl, header)
rawres$status_code
rawcontent <- httr::content(rawres,as="text")
page <- read_html(rawcontent)
carlist <- page %>% html_elements("article")

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

# for første side
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

# for første side da den er unik
for (i in 1:39) {
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

#######################################################################################
# hente data til forhandler

links <- adf$link
forheader <- c("forhandler", "id", "adresse", "cvr","carid", "scrape_date")
fordf <- as.data.frame(matrix(data=NA,nrow=0,ncol = 6))
colnames(fordf)=forheader

# taglist
fortag <- "[class^='bas-MuiTypography-root bas-MuiTypography-h3']"
#fortag1 <- "h2.bas-MuiTypography-root bas-MuiVipSectionComponent-sectionHeader bas-MuiTypography-h3"
#fortag2 <- "h2.f"
idtag <- "a.bas-MuiTypography-root.bas-MuiLink-root:contains('Se forhandlerens')"
alttag <- ".bas-MuiTypography-root.bas-MuiLink-root.bas-MuiLink-underlineNone.bas-MuiSellerInfoComponent-address.bas-MuiTypography-colorPrimary"
cvrtag <- ".bas-MuiSellerInfoComponent-cvr"

# den her virker
for (i in links) {
  tryCatch({
    print(paste("Behandler link:", i))  # Debug print
    rlres <- GET(url=i, header)
    Sys.sleep(runif(1, 0.2, 0.7))
    if(status_code(rlres) == 200) {
      pgl <- read_html(httr::content(rlres, "text"))
      # Sikker element extraction med NULL check
      for_element <- pgl %>% html_element(fortag)
      forhandler <- if(!is.null(for_element)) html_text(for_element, trim=TRUE) else NA
      id_element <- pgl %>% html_element(idtag)
      id <- if(!is.null(id_element)) {
        href <- html_attr(id_element, "href")
        str_extract(href, "[0-9]{4}")
      } else NA
      # Hent carid direkte fra URL'en
      carid <- str_extract(i, "[0-9]{7}")
      adr_element <- pgl %>% html_element(alttag)
      adresse <- if(!is.null(adr_element)) html_text(adr_element, trim=TRUE) else NA
      cvr_element <- pgl %>% html_element(cvrtag)
      cvr <- if(!is.null(cvr_element)) html_text(cvr_element, trim=TRUE) else NA
      cvrnr <- if(!is.na(cvr)) str_extract(cvr, "[0-9]{8}") else NA
      if(!is.na(forhandler) && !is.na(id) && !is.na(adresse) && !is.na(cvrnr) && !is.na(carid)) {
        fdf <- data.frame(
          forhandler = forhandler,
          id = id,
          adresse = adresse,
          cvr = cvrnr,
          carid = carid,
          scrape_date = Sys.time(),
          stringsAsFactors = FALSE
        )
        fordf <- rbind(fordf, fdf)
        print(paste("Succesfuldt behandlet:", i))
      } else {
        print(paste("Manglende data for link:", i))
        print(paste("forhandler:", !is.na(forhandler)))
        print(paste("id:", !is.na(id)))
        print(paste("adresse:", !is.na(adresse)))
        print(paste("cvr:", !is.na(cvrnr)))
        print(paste("carid:", !is.na(carid)))
      }
    } else {
      print(paste("Fejl status code:", status_code(rlres), "for link:", i))
    }
  }, error = function(e) {
    print(paste("Fejl ved behandling af link:", i))
    print(e)
  })
}

######################################
# Hvorfor er der færre forhandlere?

missing_carids <- data.frame(setdiff(adf$carid, fordf$carid))

##################################################
# merge adf og fordf
merged_df <- merge(adf,fordf, by = "carid") # hvorfor kommer der 10 ekstra obs.???

#############################################################
# OPG.1.2
###############################

# merge details column
merged_df <- merged_df[,-5]

# merge decription column
# fjerne alle emoji
emoji_pattern <- "[\U0001F300-\U0001F9FF]|[\\x{2600}-\\x{26FF}]"
merged_df$description <- merged_df$description %>%
  str_replace_all(emoji_pattern, "") %>%  
  str_replace_all("[^\x01-\x7FæøåÆØÅ]", "")

# fjerne special tegn
special_chars <- '[\\*\\/\\-\\_\\;\\:\\!\\@\\#\\$\\%\\^\\&\\+\\=\\"]'
merged_df$description <- merged_df$description %>% 
  str_replace_all(special_chars,"")

# fjerne multiple mellemrum
merged_df$description <- merged_df$description %>% 
  str_squish()

# fjerne .,.
merged_df$description <- merged_df$description %>%
  str_replace_all("^[\\s\\.\\,]+", "")

# erstatte newline
merged_df$description <- merged_df$description %>%
  str_replace_all("\\n", ".")

# pris til numeric
merged_df$price <- gsub("[kr.]", "", merged_df$price)  # Fjerner kr og punktum
merged_df$price <- gsub("\\s", "", merged_df$price)    # Fjerner mellemrum
merged_df$price <- gsub("[^0-9]", "", merged_df$price) # Beholder kun tal
merged_df$price <- as.numeric(merged_df$price)

merged_df <- merged_df[,-8]

d_pattern <- '(\\d{1,2}/\\d{4}).(\\S+).*(\\d{3})'
details <- data.frame(str_match(merged_df$details,d_pattern))
d_kol <- c("details", "reg_date", "driven", "range")
colnames(details) <- d_kol

m_pattern <- "(Audi)\\s+([A-Za-z0-9\\-\\s]+)\\s+(\\d)"
makemodel <- data.frame(str_match(merged_df$makemodel,m_pattern))
m_kol <- c("makemodel", "make", "model", "doors")
colnames(makemodel) <- m_kol

l_pattern <- "(\\w+(?: \\w+)*),*(.*)"
location <- data.frame(str_match(merged_df$location,l_pattern))
l_kol <- c("location", "city", "area")
colnames(location) <- l_kol

a_pattern <- "^(.+?)\\s+(\\d+(?:\\s*[A-Za-z])?(?:-\\d+(?:\\s*[A-Za-z])?)?),?\\s+(\\d{4})\\s+(.+)$"
adress <- data.frame(str_match(merged_df$adresse,a_pattern))
a_kol <- c("adress", "for_street", "for_street_nr", "for_postcode", "for_city")
colnames(adress) <- a_kol

# Indsæt i merged_df
merged_df_final <- cbind(merged_df[, 1:2], 
                         details[, c("reg_date", "driven", "range")], 
                         makemodel[, c("make", "model", "doors")],
                         merged_df[,5],
                         location[, c("city", "area")],
                         merged_df[,7:9],
                         adress[, c("for_street", "for_street_nr", "for_postcode", "for_city")],
                         merged_df[, 11:12])

merged_df_final[, c(4, 5, 8)] <- lapply(merged_df_final[, c(4, 5, 8)], function(x) {
  as.numeric(gsub("[^0-9]", "", as.character(x)))  # Fjern ikke-numeriske tegn
})

colnames(merged_df_final)[9] <- "description"

# merged_df_final <- na.omit(merged_df_final)

########################################
# visualisering via DKMAP PAKKE - hvor er der flest biler er til salg
library(mapDK)

merged_df_final_2 <- merged_df_final

kommune_mapping <- c(
  'Nordborg' = 'Sønderborg',
  'Aalborg' = 'Aalborg',
  'Risskov' = 'Aarhus',
  'Skærbæk' = 'Tønder',
  'Ballerup' = 'Ballerup',
  'Kolding' = 'Kolding',
  'Kastrup' = 'Tårnby',
  'Hobro' = 'Mariagerfjord',
  'Dragør' = 'Dragør',
  'Næstved' = 'Næstved',
  'Varde' = 'Varde',
  'Haderslev' = 'Haderslev',
  'Kokkedal' = 'Fredensborg',
  'Storvorde' = 'Aalborg',
  'Frederikshavn' = 'Frederikshavn',
  'Sønderborg' = 'Sønderborg',
  'Fredericia' = 'Fredericia',
  'Hammel' = 'Favrskov',
  'Odense V' = 'Odense',
  'Søborg' = 'Gladsaxe',
  'Køge' = 'Køge',
  'Holbæk' = 'Holbæk',
  'Ringsted' = 'Ringsted',
  'Odense N' = 'Odense',
  'Frederiksværk' = 'Halsnæs',
  'Silkeborg' = 'Silkeborg',
  'Hjørring' = 'Hjørring',
  'Nykøbing M' = 'Morsø',
  'Højbjerg' = 'Aarhus',
  'Egå' = 'Aarhus',
  'Herning' = 'Herning',
  'Allerød' = 'Allerød',
  'Rask Mølle' = 'Hedensted',
  'Viborg' = 'Viborg',
  'Odense SV' = 'Odense',
  'Taastrup' = 'Høje-Taastrup',
  'Bramming' = 'Esbjerg',
  'Ringe' = 'Faaborg-Midtfyn',
  'Hillerød' = 'Hillerød',
  'Aarhus V' = 'Aarhus',
  'Roskilde' = 'Roskilde',
  'Svinninge' = 'Holbæk',
  'Agerskov' = 'Tønder',
  'Give' = 'Vejle',
  'Sulsted' = 'Aalborg',
  'Ry' = 'Skanderborg',
  'Ribe' = 'Esbjerg',
  'Ringkøbing' = 'Ringkøbing-Skjern',
  'Låsby' = 'Skanderborg',
  'Aars' = 'Vesthimmerland',
  'Tilst' = 'Aarhus',
  'Birkerød' = 'Rudersdal',
  'Slagelse' = 'Slagelse',
  'Kjellerup' = 'Silkeborg',
  'Glostrup' = 'Glostrup',
  'Ørbæk' = 'Nyborg',
  'Viby J' = 'Aarhus',
  'Vodskov' = 'Aalborg',
  'Daugård' = 'Hedensted',
  'Albertslund' = 'Albertslund',
  'Nykøbing F' = 'Guldborgsund',
  'Gentofte' = 'Gentofte',
  'Randers SV' = 'Randers',
  'Esbjerg Ø' = 'Esbjerg',
  'Lystrup' = 'Aarhus',
  'Blommenslyst' = 'Odense',
  'Holte' = 'Rudersdal',
  'Holstebro' = 'Holstebro',
  'Brønderslev' = 'Brønderslev',
  'Horsens' = 'Horsens',
  'Herlev' = 'Herlev',
  'København N' = 'København',
  'Haarby' = 'Assens',
  'Nørresundby' = 'Aalborg',
  'Grenaa' = 'Norddjurs',
  'Grindsted' = 'Billund',
  'Randers SØ' = 'Randers',
  'Skanderborg' = 'Skanderborg',
  'Vejen' = 'Vejen',
  'Sæby' = 'Frederikshavn',
  'Vejle' = 'Vejle',
  'Vejle Øst' = 'Vejle',
  'Esbjerg N' = 'Esbjerg',
  'Esbjerg V' = 'Esbjerg',
  'Rødovre' = 'Rødovre',
  'Hundested' = 'Halsnæs',
  'Lunderskov' = 'Kolding',
  'Bredebro' = 'Tønder',
  'Stenløse' = 'Egedal',
  'Hørsholm' = 'Hørsholm',
  'Hadsund' = 'Mariagerfjord',
  'Thisted' = 'Thisted',
  'Rødekro' = 'Aabenraa',
  'Ølstykke' = 'Egedal',
  'Odense NV' = 'Odense',
  'Tønder' = 'Tønder',
  'Hinnerup' = 'Favrskov',
  'Måløv' = 'Ballerup',
  'Farum' = 'Furesø',
  'Værløse' = 'Furesø',
  'Vanløse' = 'København',
  'Brøndby' = 'Brøndby',
  'Valby' = 'København',
  'København S' = 'København',
  'København Ø' = 'København',
  'København V' = 'København',
  'København NV' = 'København',
  'Frederiksberg' = 'Frederiksberg',
  'Aarhus N' = 'Aarhus',
  'Aarhus C' = 'Aarhus',
  'Brabrand' = 'Aarhus',
  'Tranbjerg J' = 'Aarhus',
  'Odense C' = 'Odense',
  'Odense M' = 'Odense',
  'Odense Ø' = 'Odense',
  'Svendborg' = 'Svendborg',
  'Esbjerg' = 'Esbjerg',
  'Randers' = 'Randers',
  'Ishøj' = 'Ishøj',
  'Karlslunde' = 'Greve',
  'Hedehusene' = 'Høje-Taastrup'
)
merged_df_final_2$kommune <- kommune_mapping[merged_df_final_2$city]

city_counts <- merged_df_final_2 %>%
  group_by(kommune) %>%
  summarize(
    antal = n(),
    Gns_price = round(mean(price, na.rm = TRUE), digits = 0)
  )

mapDK(values = "antal", id = "kommune", data = city_counts)
sum(city_counts$antal)

###############################
# OPG. 1.3

sim_df <- merged_df_final[,-9]
testmdf <- merge(df,fordf, by="carid")
testmdf <- testmdf[-c(3:12),-c(5,6,9)]

# merge
testmdf$price <- gsub("[kr.]", "", testmdf$price)  # Fjerner kr og punktum
testmdf$price <- gsub("\\s", "", testmdf$price)    # Fjerner mellemrum
testmdf$price <- gsub("[^0-9]", "", testmdf$price) # Beholder kun tal
testmdf$price <- as.numeric(testmdf$price)
testmdf$details <- gsub("_"," ",testmdf$details)

d_pattern <- '(\\d{1,2}/\\d{4}).(\\S+).*(\\d{3})'
details <- str_match(testmdf$details, d_pattern)
d_kol <- c("details", "reg_date", "driven", "range")
colnames(details) <- d_kol

m_pattern <- "(Audi)\\s+([A-Za-z0-9\\-\\s]+)\\s+(\\d)"
makemodel <- str_match(testmdf$makemodel, m_pattern)
m_kol <- c("makemodel", "make", "model", "doors")
colnames(makemodel) <- m_kol

l_pattern <- "(\\w+(?: \\w+)*),*(.*)"
location <- str_match(testmdf$location, l_pattern)
l_kol <- c("location", "city", "area")
colnames(location) <- l_kol

a_pattern <- "^(.+?)\\s+(\\d+(?:\\s*[A-Za-z])?(?:-\\d+(?:\\s*[A-Za-z])?)?),?\\s+(\\d{4})\\s+(.+)$"
adress <- str_match(testmdf$adresse, a_pattern)
a_kol <- c("adress", "for_street", "for_street_nr", "for_postcode", "for_city")
colnames(adress) <- a_kol

# Indsæt i testmdf
testmdf_final <- cbind(testmdf[, 1:2], 
                       details[, c("reg_date", "driven", "range")], 
                       makemodel[, c("make", "model", "doors")],
                       location[, c("city", "area")],
                       testmdf[,6:8],
                       adress[, c("for_street", "for_street_nr", "for_postcode", "for_city")],
                       testmdf[, 10:11])

testmdf_final[, c(4, 5, 8)] <- lapply(testmdf_final[, c(4, 5, 8)], function(x) {
  as.numeric(gsub("[^0-9]", "", as.character(x)))  # Fjern ikke-numeriske tegn
})

sim_df <- sim_df[, -11]
testmdf_final <- testmdf_final[, -11]

sim_df <- rbind(sim_df,testmdf_final)
sim_df$scrape_date <- gsub("2024-11-20", "2024-11-21", sim_df$scrape_date)
sim_df$price[688] <- "427900"
sim_df$price[689] <- "389500"
sim_df$price[690] <- "409800"

sim_df <- sim_df[-c(345,397,434,239,194),]


#########################
# OPG. 1.4
#########################

# header
tysk_header <- add_headers(
  `cookie`= 'ahoy_visit=68ea9346-34f0-4e6b-9bd5-818d73bf2519;_ga=GA1.2.1475023591.1732102095;_gid=GA1.2.69485836.1732614851;panoramaId_expiry=1732706896334;_gat_UA-1955428-8=1;ahoy_visitor=65ef5bda-766c-4e33-aafd-7073e093b69f;_gcl_au=1.1.946098488.1732102095;cconsent-v2=%7B%22purpose%22%3A%7B%22legitimateInterests%22%3A%5B25%5D%2C%22consents%22%3A%5B26%5D%7D%2C%22vendor%22%3A%7B%22legitimateInterests%22%3A%5B10218%2C10441%5D%2C%22consents%22%3A%5B10007%2C10034%2C10211%2C10217%2C10218%2C10549%5D%7D%7D;_ga_F67CJ22KDE=GS1.1.1732614850.6.1.1732614915.55.0.0;_cc_id=f510f7a85c71e8682626d6a58bc4b90c;_OneTwoAuto_session=EAHh%2BLUzlxZBs7CW36y72R9LuhbHFf9VJrz2yrdJuPT2UhEe96dL8fNw4REcs1tpg4tcGxJRGPs6A4QxWcUGKtG%2BW1zWnFqay38QJbburPAjhIn4OkFm8l3r0Sow%2FAuD2WxHE1FxBgA%2BjwwWDOSAl8k6ck0WGHZMPYeEZJc2LgHn2zN%2FnKF05MHRDDwj1khDEfZ0R8P7kXZbEiHv0FJl1JmmYLCyO9FBgua0bSuZm9xg7jfiYdxcEeJGZ3UeCJoJDQ%2Fqzm3kbd9XrLDcG2R%2FgbTkZwfvhyq7Zeqj--7XygLzKVMi3TkF2Y--P7FnK6z%2F1EZ9U%2FkP4ymRIA%3D%3D;addtl_consent=1~7.70.89.93.108.122.149.196.259.311.317.323.338.415.482.486.494.495.540.574.820.864.981.1051.1095.1097.1201.1205.1276.1284.1301.1365.1415.1449.1570.1577.1651.1765.1870.1878.1889.2072.2253.2299.2357.2526.2568.2571.2575.2577.2677.2822;as24-cmp-signature=bOGzN9%2BkqJGZvaI374geTf7EW14JsUN2nmRHjCjj8wlnWCi97cNe42aEAjXtGTk1Pr2htr2oJB9jOULznKNEaO%2B5KcV67nG4cbPk5gwKCKLTR7rxtMqFD1tgD0FdNuldV2hs%2BwJUcFyaMMwXg3OVvuWoohbgpGQ83x22qy8hZvY%3D;euconsent-v2=CQIY4EAQIY4EAGNAEBDEA6EsAP_gAEPgAAAAIQtR5C5VbWlBYXpxYNsAWI1T19AhJkQBBBaAA6AFADKQcAgEkWAwNAygBAACABAEgBBBAQFFDAAAAQAAAAgBAACMIgAEAAAIIABEgEMAQAJIAAAKCAAAAQAIgAAlEEAAmAiAAJLkTEgAAIAABgAAAAAAAAABAAIAAAAYABIAAAAAACAAAAIIQgBgChUQAlAQUhBIEEACAFQVhABAAAAAASAAgAAABAQYAgAEWAiAAAAAAAAAAAAgAABAAAJAAAAAAAAAAAAAAAIAAAAAAAIAABAAAAAQAAAAAAKAAAAAQAAAAAEAEAAgAhQABAASEAAAAAABgAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAQAIB46BGAAsACoAHAAQQAvADQAHgARAAmABTACqAF0AMQAbwA_QCGAIkATQAowBhgDRAHtAPwA_QCLAElAOoAi8BIgCZAFDgKPAWwAuQBkgDLAGrgOLJQEgAFgAcAB4AEQAJgAVQAxQCGAIkARwAowB-AHUAReAkQBR4C2AGSAQhKQGwAFgAVAA4ACCAGQAaAA8ACIAEwAKQAVQAxAB-gEMARIAowBowD8AP0AiwBJQDqAIvASIAocBbAC5AGSAMsAhCEAEgAbABIAEcAaQA5wCDgE7AX-AyEJAgAAWABUADgAHgAQQAvADQAHgARAAmABVADeAH4AQkAhgCJAEcAJoAYYAywB3AD2gH4AfoBJQEiAKHAUeApEBbAC5AGSAMzAauBCEMAEAFGAOcA6gChxAAUAEgA0gBzgERAUOOAHgAkACOAFAAc4A7oCDgIQAREAnYBmQFSgL_AYIAyEBlQDMyIAEAIRQAaAAqAEQASAAtACOAFsARwA5wB3AEHAJ2Af8BUoDBCEAQARwA7gDqALkIABABzgGZAVKAwQkAFACOAO4Ag4BmQF_loAYAjgB3AMzLAAgBlgEcA.YAAAAAAAA4CA;field_test=59705c3c-4c1e-4f04-ace2-f14d55b6a7a6;panoramaId=36a5e9b988df086b064c39cb02bb185ca02cd2af2d902f58d6210314bb5166e5;panoramaIdType=panoDevice',
  `user-agent` = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'
)

# test på en side
turl <- "https://www.12gebrauchtwagen.de/kraftstoff/elektro/audi?page=2"
rtres <- GET(url=turl, tysk_header)
rtcontent <- httr::content(rtres,as="text")
pgt <- read_html(rtcontent)
tcars <- pgt %>% html_elements("div.row.search-results")

# taglist
# For model navn (finder links med bil-titler)
model_tag <- "div.font-bold a.provider-link"
price_tag <- "div.purchase-price"
km_tag <- "div.column.medium-4.text-md.mt-half.mileage"
year_tag <- "div.column.medium-4.text-md.mt-half.reg_year"
address_tag <- "a[href*='google.de/maps']"
link_tag <- "a.provider-link.click-out"  # Selector for bil-links

# Udtræk data
models <- pgt %>% html_elements(model_tag) %>% html_text()
prices <- pgt %>% html_elements(price_tag) %>% html_text()
kilometers <- pgt %>% html_elements(km_tag) %>% html_text() 
kilometers <- kilometers[seq(1, length(kilometers), 2)]
years <- pgt %>% html_elements(year_tag) %>% html_text()
years <- years[seq(1, length(years), 2)]
addresses <- pgt %>% html_elements(address_tag) %>% html_text()
addresses <- addresses[seq(1, length(addresses), 2)]
tlinks <- pgt %>% html_elements(link_tag) %>% html_attr("href")
tlinks <- tlinks[seq(1, length(tlinks), 3)]

# test
tysk_testdf <- data.frame(
  model = models,
  price = prices,
  kilometers = kilometers,
  year = years,
  address = addresses,
  link = paste0("https://www.12gebrauchtwagen.de", tlinks)
)

# træk 708 biler fra hjemside
tcarheader <- c("model","price","kilometer","year","location", "carid","link","scrapedate")
tysk_df <- as.data.frame(matrix(data=NA,nrow=0,ncol = 8))
colnames(tysk_df) <- tcarheader

for (i in 1:121) {
  tturl <- paste0("https://www.12gebrauchtwagen.de/kraftstoff/elektro/audi?page=",i)
  rttres <- GET(url=tturl, tysk_header)
  rttcontent <- httr::content(rttres,as="text")
  pgtt <- read_html(rttcontent)
  ttcar <- pgtt %>% html_elements("div.row.search-results")
  Sys.sleep(runif(1, 0.2, 0.7))
  for (car in ttcar) {
    tryCatch({
      modelst <- car %>% html_elements(model_tag) %>% html_text()
      pricest <- car %>% html_elements(price_tag) %>% html_text()
      kilometerst <- car %>% html_elements(km_tag) %>% html_text() 
      kilometerst <- kilometerst[seq(1, length(kilometerst), 2)]
      yearst <- car %>% html_elements(year_tag) %>% html_text()
      yearst <- yearst[seq(1, length(yearst), 2)]
      addressest <- car %>% html_elements(address_tag) %>% html_text()
      addressest <- addressest[seq(1, length(addressest), 2)]
      tlinkst <- car %>% html_elements(link_tag) %>% html_attr("href")
      tlinkst <- tlinkst[seq(1, length(tlinkst), 3)]
      carid <- str_extract(tlinkst, "[0-9]{10}")
      ttmpdf <- data.frame(modelst,carid,pricest,kilometerst,yearst,addressest,tlinkst,Sys.time())
      tysk_df <- rbind(tysk_df,ttmpdf)
    },
    error = function(cond) {
      print(modelst)
    }
    )
  }
}

m_pattern_tysk <- "(Audi)\\s+([A-Za-z0-9\\-\\s]+)"
# (Audi): Matcher "Audi" som mærke.
# ([A-Za-z0-9\\-\\s]+): Matcher modelnavnet, der kan bestå af alfanumeriske tegn, bindestreger og mellemrum (det fanger for eksempel "Q4 e-tron40 S-line Sportback").
# (\\d+)d: Matcher antallet af døre (f.eks. "5d").
modelst <- str_match(tysk_df$modelst, m_pattern_tysk)
m_tysk_kol <- c("modelt", "make", "model")
colnames(modelst) <- m_tysk_kol

tysk_df$pricest <- gsub("[€.]", "", tysk_df$pricest)  # Fjerner € og punktummer
tysk_df$pricest <- gsub("\\s", "", tysk_df$pricest)   # Fjerner mellemrum
tysk_df$pricest <- as.numeric(tysk_df$pricest)

# Konverter til DKK (gang med 7.46)
tysk_df$pricest <- round(tysk_df$pricest * 7.46, digits = 0)
# tilføj afgift 11.427 hvis prisen er over 436.500 kr.
tysk_df <- tysk_df %>%
  mutate(new_price = ifelse(pricest > 436500, pricest + 11427, pricest))

tysk_df$kilometerst <- gsub("[km.]", "", tysk_df$kilometerst)
tysk_df$kilometerst <- tysk_df$kilometerst %>% str_squish()
tysk_df$kilometerst <- as.numeric(tysk_df$kilometerst)

tysk_df <- tysk_df %>%
  select(modelst,carid, pricest, new_price, everything())

tysk_df_final <- cbind(modelst[, c("make", "model")], 
                   tysk_df[, 2:ncol(tysk_df)])

####################################################
# træk audi Q8
# dansk
q8df_dansk <- merged_df_final[str_detect(merged_df_final$model, "Q8.*e-tron"), ]
rownames(q8df_dansk) <- 1:nrow(q8df_dansk)
q8df_dansk$pris_km <- round(q8df_dansk$price/q8df_dansk$range, digits = 0)

# tysk
q8df_tysk <- tysk_df_final[str_detect(tysk_df_final$model, "Q8.*e-tron"), ]
rownames(q8df_tysk) <- 1:nrow(q8df_tysk)
q8df_tysk$pris_km <- round(q8df_tysk$pricest / q8df_tysk$kilometerst, digits = 0)

sammenligning_q8 <- round(data.frame(
  gns_pris_DK = mean(q8df_dansk$price),
  gns_pris_DE = mean(q8df_tysk$new_price),
  gns_kørt_DK = mean(q8df_dansk$driven),
  gns_kørt_DE = mean(q8df_tysk$kilometerst)
), digits = 0)

# træk audi Q4
# dansk
q4df_dansk <- merged_df_final[str_detect(merged_df_final$model, "Q4.*e-tron"), ]
rownames(q4df_dansk) <- 1:nrow(q4df_dansk)
q4df_dansk$pris_km <- round(q4df_dansk$price/q4df_dansk$range, digits = 0)

# tysk
q4df_tysk <- tysk_df_final[str_detect(tysk_df_final$model, "Q4.*e-tron"), ]
rownames(q4df_tysk) <- 1:nrow(q4df_tysk)
q4df_tysk$pris_km <- round(q4df_tysk$pricest / q4df_tysk$kilometerst, digits = 0)

sammenligning_q4 <- round(data.frame(
  gns_pris_DK = mean(q4df_dansk$price),
  gns_pris_DE = mean(q4df_tysk$new_price),
  gns_kørt_DK = mean(q4df_dansk$driven),
  gns_kørt_DE = mean(q4df_tysk$kilometerst)
), digits = 0)

######################################
# indlæse nyest data

merged_df_final_2 <- readRDS("~/Documents/da-1s/da1-projekt/Merged_df_final.rds")

bil_11_21 <- anti_join(merged_df_final_2,merged_df_final, by = "carid")

nyebiler <- merged_df_final %>%
  mutate(solgt = ifelse(carid %in% Retailers$carid, 0, 1))

nyebiler <- nyebiler[,-9]

merged_df_final <- merged_df_final %>%
  mutate(solgt = ifelse(carid %in% sim_df$carid, 0, 1))

nyebiler$solgt[c(345,397,434,239,194)] <- 1



