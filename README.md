# Home-Field-Advantages-in-Football

# Capstone Project: Home Advantage in American Football

## Parent Paper

**Title:** A comprehensive survey of the home advantage in American football
**Authors:** Luke Benz, Thompson Bliss, Michael Lopez
**Link:** https://arxiv.org/abs/2401.16392

## Dataset

This paper does not rely on a single unified dataset — it combines game-level data from three sources, spanning the NFL, NCAA, and U.S. high school football, covering the **2004–2023 seasons** (2020 excluded due to COVID-19 irregularities).

| League | Source | Link | Games Analyzed |
|---|---|---|---|
| NFL | Internal NFL database (publicly replicable via `nflfastR`) | https://github.com/nflverse/nflfastR | 5,395 |
| NCAA (FBS, FCS, Div II, Div III) | MasseyRatings.com | https://masseyratings.com/ranks?s=cf | 64,345 |
| High School (all 50 states) | MaxPreps | https://www.maxpreps.com/football/ | 1,283,531 |

**Brief description:**
- **nflfastR** is an open-source R package that scrapes and packages official NFL play-by-play and game-level data, making it a public substitute for the authors' internal NFL data source.
- **MasseyRatings.com**, created by Kenneth Massey, hosts model-based team ratings and historical scores across nearly every sport, with results cross-checked against multiple independent public sources.
- **MaxPreps** is a news and data platform for U.S. high school sports, where game results are entered directly by team coaches and coaching staff.

Combined, these three sources give the authors a uniform, ~20-year, multi-level view of American football (NFL, four NCAA divisions, and all 50 high school state leagues) totaling roughly 1.35 million games — the largest sample used in this line of research to date.

## Project Goal

*(Fill in: what you plan to reproduce, extend, or analyze from this paper for your capstone.)*

## Repository Structure

*(Fill in as you build it out, e.g. /code, /data, /docs)*

## Original Authors' Code

The authors' full code and data are publicly available at:
https://github.com/ThompsonJamesBliss/comprehensive_survey_american_football_home_adv
