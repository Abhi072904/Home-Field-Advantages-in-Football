# Home Advantage in American Football

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

This project investigates the specific factors that drive variation in home field advantage across NFL venues — such as crowd size, travel distance, altitude, weather, and surface type. We aim to develop a model that ranks NFL venues by the magnitude of home field advantage they confer, then validate this ranking against real-time results from the current ongoing NFL season to test whether our findings hold up out-of-sample.

## Repository Structure

```
capstone-home-advantage-football/
├── README.md
├── requirements.txt / environment.yml    # Python/R dependencies
│
├── data/
│   ├── raw/                              # Untouched pulls (nflfastR, weather, stadium metadata)
│   ├── processed/                        # Cleaned, merged, model-ready datasets
│   └── external/                         # Reference tables (stadium altitude, surface type, lat/long, etc.)
│
├── notebooks/                            # Exploratory analysis, scratch work, plots
│   ├── 01_eda.ipynb
│   └── 02_feature_exploration.ipynb
│
├── src/
│   ├── data_ingestion/
│   │   ├── fetch_nfl_data.py             # Pull play-by-play / game data (e.g. nflfastR)
│   │   ├── fetch_weather_data.py         # Historical/current game-day weather
│   │   └── fetch_stadium_metadata.py     # Altitude, surface, crowd capacity, travel distance
│   │
│   ├── features/
│   │   └── build_features.py             # Engineer variables (travel dist., altitude, crowd size, etc.)
│   │
│   ├── models/
│   │   ├── train_model.py                # Fit home-advantage model per venue
│   │   └── rank_venues.py                # Produce venue ranking from model output
│   │
│   └── validation/
│       └── validate_current_season.py    # Compare rankings vs. live 2026 season results
│
├── results/
│   ├── figures/                          # Plots (posterior distributions, rankings, etc.)
│   ├── tables/                           # Final ranked venue tables
│   └── model_outputs/                    # Saved model objects / posterior samples
│
├── reports/
│   └── capstone_report.pdf               # Written report drafts / final submission
│
└── tests/
    └── test_features.py                  # Sanity checks on data pipeline
```

**Notes on structure:**
- `data/raw` should never be edited directly — treat it as a locked snapshot of source pulls.
- `src/validation/` is the key folder tying back to your project goal — it's where you'll compare model-predicted venue rankings against actual outcomes as the current season unfolds.
- Keep large raw data files out of git (use a `.gitignore` for `data/raw/` and `data/processed/` if they get large) and instead document how to regenerate them via the ingestion scripts.

## Original Authors' Code

The authors' full code and data are publicly available at:
https://github.com/ThompsonJamesBliss/comprehensive_survey_american_football_home_adv
