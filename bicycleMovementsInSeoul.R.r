library(tidyverse)
library(data.table)
library(lubridate)
library(rebus)
library(visdat)


data <- fread('seoulBicycleRentInfo_22.06.csv')
colnames(data) <- c('bicycle.id', 'b.time', 'b.station.id', 'b.station',
                    'b.hold', 'r.time', 'r.station.id', 'r.station', 'r.hold',
                    'used.time', 'used.distance')

# 01. 대여소 간 이동 - 건수


# 필요한 열만 남기기
df.1 <- data %>% 
  select(b.station.id, b.station, r.station.id, r.station)

# 출빌 -> 도착 (건수)
df.2 <- df.1 %>% 
  group_by(across()) %>% 
  count() %>% 
  arrange(desc(n))

df.3 <- df.2 %>% 
  filter(n >= 15) %>%  #61664 obs -> # 14925 obs
  filter(!(b.station.id == r.station.id)) # 59326 obs -> 14419 obs

# 위경도 데이터 붙여주기
coords <- fread('bikeShareRentLocations(2022.06).csv') 
coords <- coords %>% 
  select(id, name, gu, lat, long)

# 대여장소(prefix is b.)
df.4 <- df.3 %>% 
  left_join(coords, 
            by = c('b.station.id' = 'id'),
            suffix = c("", ".b"))

sum(is.na(df.4$name)) # 78
df.4 <- df.4 %>% 
  drop_na()
vis_miss(df.4) # 14341 obs


# 같은 id 인데 정류소 이름이 다른 경우 
# whitespace, 괄호 안에 있는 내용 drop 그래도 불일치하는 곳들은 drop
pattern <- '\\(' %R% zero_or_more(WRD) %R% zero_or_more('\\)')

df.5 <- df.4 %>% 
  ungroup() %>% 
  mutate(b.station = str_replace_all(b.station, pattern = fixed(" "), replacement = "")) 

df.5 <-  df.5 %>%  
  mutate(b.station = str_replace_all(b.station, pattern = pattern, replacement =  "")) 

df.5 <- df.5 %>% 
  mutate(name = str_replace_all(name, pattern = fixed(" "), replacement = ""))

df.5 <- df.5 %>% 
  mutate(name = str_replace_all(name, pattern = pattern, replacement = "")) 

weird <- df.5 %>% 
  filter(b.station != name) # 265 (오타 등 -> 데이터에서 제외하겠음)

df.6 <- df.5 %>% 
  filter(b.station == name)

df.6 <- df.6 %>% 
  select(-name) %>% 
  rename('b.gu' = 'gu',
         'b.lat' = 'lat',
         'b.long' = 'long')

# 반남장소 (prefix = r.)
df.7 <- df.6 %>% 
  left_join(coords, 
            by = c('r.station.id' = 'id')) # 14076

sum(is.na(df.7$name)) # 72
df.7 <- df.7 %>% 
  drop_na()
vis_miss(df.7) # 14004 obs

# 같은 id 인데 정류소 이름이 다른 경우 
# whitespace, 괄호 안에 있는 내용 drop 그래도 불일치하는 곳들은 drop
df.8 <- df.7 %>% 
  ungroup() %>% 
  mutate(r.station = str_replace_all(r.station, pattern = fixed(" "), replacement = "")) 

df.8 <-  df.8 %>%  
  mutate(r.station = str_replace_all(r.station, pattern = pattern, replacement =  "")) 

df.8 <- df.8 %>% 
  mutate(name = str_replace_all(name, pattern = fixed(" "), replacement = ""))

df.8 <- df.8 %>% 
  mutate(name = str_replace_all(name, pattern = pattern, replacement = "")) 

weird <- df.8 %>% 
  filter(r.station != name) # 142

df.9 <- df.8 %>%
  filter(r.station == name) # 13862

df.9 <- df.9 %>% 
  select(-name) %>% 
  rename('r.gu' = 'gu',
         'r.lat' = 'lat',
         'r.long' = 'long')

final <- df.9 %>% 
  select(n, b.gu, b.lat, b.long, r.gu, r.lat, r.long)

write_csv(final, "bicycleMovementsInSeoul.csv")

