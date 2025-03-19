
get_pred_summary_data <- function(path) {
    pred_summary <- read_excel(path, sheet = 2, col_types = c("date", rep("guess", 15))) %>%
        remove_empty(which = "cols") %>%
        remove_empty(which = "rows")

    # have to split into two DFs because there is a second 
    # set of columns when two pred species were present at a site

    preds_pt1 <- pred_summary %>%
        filter(is.na(Fish_Spot2)) %>%
        select(!contains("2"))

    preds_pt2 <- pred_summary %>%
        filter(!is.na(Fish_Spot2)) %>%
        select(!c(Number_of_, Fish_Spott, Habitat_Ty, Unit_Numbe)) %>%
        rename(
            Fish_Spott = Fish_Spot2,
            Number_of_ = Number_of2,
            Habitat_Ty = Habitat_T2,
            Unit_Numbe = Unit_Numb2
            )

    bind_rows(preds_pt1, preds_pt2) %>%
        mutate(
            Fish_Spott = str_replace_all(
                        tolower(Fish_Spott), c(
                            "\\(probably res follow up\\)" = "", # could also lump this in with red-eared sliders ("res")
                            '"' = "",
                            "trout >=16" = "trout_over_16",
                            "trout <=16" = "trout_under_16",
                            "trout>=16" = "trout_over_16",
                            "trout<=16" = "trout_under_16",
                            " " = "_",
                            "-" = "_",
                            "large_mouth" = "largemouth",
                            "small_mouth" = "smallmouth")
                )
        ) %>%
        pivot_wider(names_from = "Fish_Spott", values_from = "Number_of_") %>%
        rename_with(tolower) %>%
        rename(date = datetime, site = side_chann, habitat = habitat_ty, unit_num = unit_numbe) %>%
        mutate(across(pikeminnow:pond_turtle, ~replace_na(.x, 0)))
}

read_snorkel_data <- function(path) {
    data <- read_excel(path) %>%
        rename_with(tolower) %>%
        select(
            date, 
            contains("site"),
            contains("length"),
            contains("mile"),
            contains("weather"),
            contains("temp"),
            visibility_meters,
            contains("flow")
            )

    # IMPORTANT!!!!!!!!!!!!!!!
    # some data sheets had two temperature values "top" and "bottom"
    # one value was always 0 and the other was a value consistent with those
    # seen in other sheets.
    # there was no consistency between whether top or bottom was 0, so I just added them...
    # maybe dig into this further
    if (any(grepl("top", names(data)))) {
        data <- data %>%
            rename(temp_top = contains("top"), temp_bottom = contains("bottom")) %>%
            mutate(water_temp = temp_top + temp_bottom) %>%
            select(-c(temp_top, temp_bottom))
    }

    names(data) <- c("date", "site_number", "site", "channel_length_m", 
    "river_mile", "weather_code", "water_temp_f", "visibility_m", "flow_cfs")

    data %>%
        mutate(
            weather_code = as.character(weather_code),
            weather_code = case_when(
                weather_code == "1" ~ "Clear",
                weather_code == "2" ~ "Partly Cloudy",
                weather_code == "3" ~ "Cloudy",
                weather_code == "4" ~ "Rain",
                weather_code == "5" ~ "Snow",
                weather_code == "6" ~ "Fog",
                .default = weather_code,

            )
        )
}

get_snorkel_data <- function(path_list) {
    map(path_list, read_snorkel_data) %>%
        bind_rows()
}