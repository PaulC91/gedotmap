library(tidyverse)
library(readxl)

raw <- read.csv("voting-full.csv", stringsAsFactors = F)
parties <- c("Con", "Lab", "LD", "UKIP", "Green", "SNP")

ge2017 <- raw %>%
  select(-party_name, -firstname:-former_mp, -share:-change) %>%
  filter(party_abbreviation %in% parties, country_name != "Northern Ireland") %>%
  spread(party_abbreviation, votes)

ge2017_winner <- raw %>%
  filter(country_name != "Northern Ireland") %>%
  group_by(ons_id) %>%
  filter(votes == max(votes)) %>%
  ungroup() %>%
  select(Winner = party_abbreviation)

ge2017_second <- raw %>%
  filter(country_name != "Northern Ireland") %>%
  group_by(ons_id) %>%
  #filter (row_number() == 1) %>%
  filter(votes == sort(votes, TRUE)[2]) %>%
  ungroup() %>%
  select(Second = party_abbreviation)

ge2017_margin <- raw %>%
  filter(country_name != "Northern Ireland") %>%
  group_by(ons_id) %>%
  mutate(Margin = max(votes) - sort(votes, TRUE)[2]) %>%
  filter (row_number() == 1) %>%
  ungroup() %>%
  select(Margin)

final <- bind_cols(ge2017, ge2017_winner, ge2017_second, ge2017_margin) %>%
  select(PCONCODE = ons_id, CON_2017 = Con, LAB_2017 = Lab, LD_2017 = LD, UKP_2017 = UKIP,
         GREEN_2017 = Green, SNP_2017 = SNP, WINNER_2017 = Winner, SECOND_2017 = Second, MAJ_2017 = Margin)
final[is.na(final)] <- 0

write.csv(final, "ge2017.csv")
