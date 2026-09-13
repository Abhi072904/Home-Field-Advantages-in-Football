# NFL-only version of the home-field-advantage model runner
#
# Adapted for an NFL-only project from the modeling approach used in:
# ThompsonJamesBliss/comprehensive_survey_american_football_home_adv
#
# Expected project structure:
#   code/model/run_model.R
#   code/model/stan/model_1.stan
#   code/model/stan/model_2.stan
#   code/model/stan/model_3.stan
#   data/final/NFL_games.csv
#
# Run this script from the repository root.

library(tidyverse)
library(rstan)

params <- list(
  min_season = 2004,
  models = c("model_1", "model_2", "model_3"),
  seed = 73097,
  chains = 4,
  iter = 2000,
  warmup = 500,
  adapt_delta = 0.95
)

options(mc.cores = params$chains)
rstan_options(auto_write = TRUE)

# -----------------------------
# Load and clean NFL data only
# -----------------------------
nfl <- read_csv("data/final/NFL_games.csv", show_col_types = FALSE) |>
  filter(
    season >= params$min_season,
    satisfies_cutoff,
    !is.na(home_score),
    !is.na(away_score),
    !is.na(home_team),
    !is.na(away_team)
  ) |>
  mutate(
    home_point_diff = home_score - away_score,
    home_game = as.integer(location == "Home"),
    season_index = season - min(season) + 1L,
    home_team_season = paste(season, home_team, sep = "_"),
    away_team_season = paste(season, away_team, sep = "_")
  )

# Give every team-season combination a unique integer code.
team_levels <- sort(unique(c(nfl$home_team_season, nfl$away_team_season)))

nfl <- nfl |>
  mutate(
    home_team_code = match(home_team_season, team_levels),
    away_team_code = match(away_team_season, team_levels)
  )

num_seasons <- max(nfl$season_index)
num_clubs <- length(team_levels)

dir.create("stan_results", showWarnings = FALSE, recursive = TRUE)

# Keep the calendar-year mapping for Model 3.
season_key <- nfl |>
  distinct(season, season_index) |>
  arrange(season_index)

write_csv(season_key, "stan_results/season_key.csv")

# -----------------------------
# Fit the three models
# -----------------------------
fits <- list()

for (model_name in params$models) {
  message("Fitting ", model_name, " ...")

  model_dir <- file.path("stan_results", model_name)
  dir.create(model_dir, showWarnings = FALSE, recursive = TRUE)

  stan_data <- list(
    num_clubs = num_clubs,
    num_games = nrow(nfl),
    home_team_code = nfl$home_team_code,
    away_team_code = nfl$away_team_code,
    h_point_diff = nfl$home_point_diff,
    h_adv = nfl$home_game
  )

  # Models 2 and 3 also use season.
  if (model_name %in% c("model_2", "model_3")) {
    stan_data$num_seasons <- num_seasons
    stan_data$season <- nfl$season_index
  }

  fit <- stan(
    file = file.path("code", "model", "stan", paste0(model_name, ".stan")),
    data = stan_data,
    seed = params$seed,
    chains = params$chains,
    iter = params$iter,
    warmup = params$warmup,
    control = list(adapt_delta = params$adapt_delta)
  )

  fits[[model_name]] <- fit
  saveRDS(fit, file.path(model_dir, "NFL.rds"))

  # Save a general parameter summary.
  summary_df <- as.data.frame(summary(fit)$summary) |>
    rownames_to_column("parameter")

  write_csv(summary_df, file.path(model_dir, "summary.csv"))
}

# -------------------------------------
# Save home-field-advantage estimates
# -------------------------------------
hfa_results <- list()

# Model 1: one constant home-field advantage.
draws_1 <- rstan::extract(fits$model_1, pars = "alpha")$alpha
hfa_results$model_1 <- tibble(
  model = "model_1",
  season = NA_integer_,
  parameter = "alpha",
  mean = mean(draws_1),
  lower_95 = quantile(draws_1, 0.025),
  upper_95 = quantile(draws_1, 0.975)
)

# Model 2: linear home-field-advantage trend over seasons.
draws_2 <- rstan::extract(
  fits$model_2,
  pars = c("alpha_intercept", "alpha_trend")
)

hfa_results$model_2 <- bind_rows(
  tibble(
    model = "model_2",
    season = NA_integer_,
    parameter = "alpha_intercept",
    mean = mean(draws_2$alpha_intercept),
    lower_95 = quantile(draws_2$alpha_intercept, 0.025),
    upper_95 = quantile(draws_2$alpha_intercept, 0.975)
  ),
  tibble(
    model = "model_2",
    season = NA_integer_,
    parameter = "alpha_trend",
    mean = mean(draws_2$alpha_trend),
    lower_95 = quantile(draws_2$alpha_trend, 0.025),
    upper_95 = quantile(draws_2$alpha_trend, 0.975)
  )
)

# Model 3: separate home-field advantage for each season.
draws_3 <- rstan::extract(fits$model_3, pars = "alpha")$alpha

model_3_summary <- map_dfr(seq_len(ncol(draws_3)), function(i) {
  x <- draws_3[, i]

  tibble(
    model = "model_3",
    season_index = i,
    parameter = "alpha",
    mean = mean(x),
    lower_95 = quantile(x, 0.025),
    upper_95 = quantile(x, 0.975)
  )
}) |>
  left_join(season_key, by = "season_index") |>
  select(model, season, parameter, mean, lower_95, upper_95)

hfa_results$model_3 <- model_3_summary

bind_rows(hfa_results) |>
  write_csv("stan_results/home_field_advantage_summary.csv")

message("Done.")
message("Model objects: stan_results/model_*/NFL.rds")
message("Home-field estimates: stan_results/home_field_advantage_summary.csv")
