library(shiny)
library(shinythemes)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)
library(shinyBS)
library(ggplot2)
library(scales)

source("damage_calculation.R")

# Frontend ----

ui <- fluidPage(
  theme = "flatly",
  useShinyjs(),
  tags$style(type = "text/css", ".irs-grid-pol.small {height: 0px;}"),
  
  titlePanel("Splittermond Waffenschadenrechner"),
  
  ## Side-Panel ----
  sidebarLayout(
    sidebarPanel(
      id = "side-panel",
      conditionalPanel(
        condition = "input.weapon_toggle%2 == 0",
        fluidRow(
          pickerInput(
            "select_weapon_1",
            "Waffe auswählen:",
            choices = data[, name],
            multiple = TRUE,
            options = pickerOptions(maxOptions = 1)
          ),
          column(4,
                 numericInput(
                   "d6",
                   "Anzahl W6",
                   min = 0,
                   max = 8,
                   value = 0
                 )),
          column(4,
                 numericInput(
                   "d10",
                   "Anzahl W10",
                   min = 0,
                   max = 5,
                   value = 0
                 )),
          column(4,
                 numericInput("flat",
                              "Modifikator",
                              value = 0))
        ),
        
        numericInput(
          "speed",
          "Waffengeschwindigkeit inkl. weiterer Modifikatoren (z.B. +3 Ticks bei Fernkampf)",
          min = 1,
          value = 1
        ),
        
        ## Textoutput ----
        br(),
        textOutput("weapon"),
        # br(),
        textOutput("mean_dmg"),
        # br(),
        textOutput("mean_dmg_per_tick"),
        # br(),
        textOutput("sd_dmg"),
        br(),
        
        ## Waffenmerkmale ----
        h4("Waffenmerkmale:"),
        fluidRow(
          column(
            6,
            sliderInput(
              "exact",
              "Exakt",
              min = 0,
              max = 3,
              value = 0
            ),
            bsTooltip(
              id = "exact",
              title = "Bei einem Schadenswurf mit dieser Waffe werden so viele Würfel zusätzlich geworfen, wie die Stufe des Merkmals beträgt. Die höchsten Ergebnisse zählen für den Schadenswurf.",
              trigger = "hover"
            ),
            sliderInput(
              "critical",
              "Kritisch",
              min = 0,
              max = 5,
              value = 0
            ),
            bsTooltip(
              id = "critical",
              title = "Der Schaden eines Angriffs einer Waffe mit diesem Merkmal erhöht sich für jeden Schadenswürfel, der die maximale Augenzahl würfelt, um die Stufe des Merkmals.",
              trigger = "hover"
            ),
            materialSwitch("massive",
                           "Wuchtig",
                           value = FALSE,
                           status = "primary"),
            bsTooltip(
              id = "massive",
              title = "Bei Waffen mit diesem Merkmal verursacht das freie Manöver Wuchtangriff 2 statt 1 zusätzlichen Punkt Schaden pro eingesetzten Erfolgsgrad.",
              trigger = "hover"
            )
          ),
          column(
            6,
            sliderInput(
              "penetration",
              "Durchdringung",
              min = 0,
              max = 6,
              value = 0
            ),
            bsTooltip(
              id = "penetration",
              title = "Für jede Stufe dieses Merkmals kann 1 Punkt der gegnerischen Schadensreduktion ignoriert werden, egal aus welcher Quelle diese stammt.",
              trigger = "hover"
            ),
            sliderInput(
              "sharp",
              "Scharf",
              min = 0,
              max = 5,
              value = 0
            ),
            bsTooltip(
              id = "sharp",
              title = "Alle Schadenswürfel einer Waffe mit diesem Merkmal werden immer als mindestens der Wert der Stufe des Merkmals gewertet, egal was eigentlich gewürfelt wurde.",
              trigger = "hover"
            ),
            materialSwitch(
              "versatile",
              "Vielseitig",
              value = FALSE,
              status = "primary"
            ),
            bsTooltip(
              # FIXME
              id = "wield",
              title = "Bei vielseitigen Waffen kann zwischen einhändiger und zweihändiger Führung gewechselt werden. In zweihändiger Führung erhöht sich ihr
Schaden um 3 Punkte.",
trigger = "hover"
            ),
radioGroupButtons(
  inputId = "wield",
  choices = c("Einhändig" = FALSE, "Zweihändig" = TRUE),
  status = "primary"
)


          )
        ),
br(),
      ),
conditionalPanel(
  condition = "input.weapon_toggle%2  == 1",
  fluidRow(
    pickerInput(
      "select_weapon_2",
      "Waffe auswählen:",
      choices = data[, name],
      multiple = TRUE,
      options = pickerOptions(maxOptions = 1)
    ),
    column(4,
           numericInput(
             "d6_2",
             "Anzahl W6",
             min = 0,
             max = 8,
             value = 0
           )),
    column(4,
           numericInput(
             "d10_2",
             "Anzahl W10",
             min = 0,
             max = 5,
             value = 0
           )),
    column(4,
           numericInput("flat_2",
                        "Modifikator",
                        value = 0))
  ),
  
  numericInput(
    "speed_2",
    "Waffengeschwindigkeit inkl. weiterer Modifikatoren (z.B. +3 Ticks bei Fernkampf)",
    min = 1,
    value = 1
  ),
  
  ## Textoutput ----
  br(),
  textOutput("weapon_2"),
  # br(),
  textOutput("mean_dmg_2"),
  # br(),
  textOutput("mean_dmg_per_tick_2"),
  # br(),
  textOutput("sd_dmg_2"),
  br(),
  
  ## Waffenmerkmale ----
  h4("Waffenmerkmale:"),
  fluidRow(
    column(
      6,
      sliderInput(
        "exact_2",
        "Exakt",
        min = 0,
        max = 3,
        value = 0
      ),
      bsTooltip(
        id = "exact_2",
        title = "Bei einem Schadenswurf mit dieser Waffe werden so viele Würfel zusätzlich geworfen, wie die Stufe des Merkmals beträgt. Die höchsten Ergebnisse zählen für den Schadenswurf.",
        trigger = "hover"
      ),
      sliderInput(
        "critical_2",
        "Kritisch",
        min = 0,
        max = 5,
        value = 0
      ),
      bsTooltip(
        id = "critical_2",
        title = "Der Schaden eines Angriffs einer Waffe mit diesem Merkmal erhöht sich für jeden Schadenswürfel, der die maximale Augenzahl würfelt, um die Stufe des Merkmals.",
        trigger = "hover"
      ),
      materialSwitch("massive_2",
                     "Wuchtig",
                     value = FALSE,
                     status = "danger"),
      bsTooltip(
        id = "massive_2",
        title = "Bei Waffen mit diesem Merkmal verursacht das freie Manöver Wuchtangriff 2 statt 1 zusätzlichen Punkt Schaden pro eingesetzten Erfolgsgrad.",
        trigger = "hover"
      )
    ),
    column(
      6,
      sliderInput(
        "penetration_2",
        "Durchdringung",
        min = 0,
        max = 6,
        value = 0
      ),
      bsTooltip(
        id = "penetration_2",
        title = "Für jede Stufe dieses Merkmals kann 1 Punkt der gegnerischen Schadensreduktion ignoriert werden, egal aus welcher Quelle diese stammt.",
        trigger = "hover"
      ),
      sliderInput(
        "sharp_2",
        "Scharf",
        min = 0,
        max = 5,
        value = 0
      ),
      bsTooltip(
        id = "sharp_2",
        title = "Alle Schadenswürfel einer Waffe mit diesem Merkmal werden immer als mindestens der Wert der Stufe des Merkmals gewertet, egal was eigentlich gewürfelt wurde.",
        trigger = "hover"
      ),
      materialSwitch(
        "versatile_2",
        "Vielseitig",
        value = FALSE,
        status = "danger"
      ),
      bsTooltip(
        # FIXME
        id = "wield_2",
        title = "Bei vielseitigen Waffen kann zwischen einhändiger und zweihändiger Führung gewechselt werden. In zweihändiger Führung erhöht sich ihr Schaden um 3 Punkte.",
        trigger = "hover"
      ),
      radioGroupButtons(
        inputId = "wield_2",
        choices = c("Einhändig" = FALSE, "Zweihändig" = TRUE),
        status = "primary"
      )
    )
  ),
  br()
),
actionButton("weapon_toggle", "➕ Weitere Waffe hinzufügen"),
br(),

# Schadensreduktion ----
conditionalPanel(
  condition = "input.tab_selected == 1",
  h4("Weitere Parameter:"),
  sliderInput(
    "dmg_reduction",
    "Simulierte Schadensreduktion",
    min = 0,
    max = 10,
    value = 0
  ),
  bsTooltip(
    id = "dmg_reduction",
    title = "Die Schadensreduktion einer Rüstung wird von dem Schaden jedes erfolgreichen Angriffs gegen den Träger abgezogen.",
    trigger = "hover"
  ),
  sliderInput(
    "success_lvl",
    "Für Wuchtangriff genutzte Erfolgsgrade",
    min = 0,
    max = 10,
    value = 0
  ),
  bsTooltip(
    id = "success_lvl",
    title = "Für jeden aufgewendeten Erfolgsgrad richtet der Angriff einen zusätzlichen Punkt Schaden an.",
    trigger = "hover"
  )
),

conditionalPanel(
  condition = "input.tab_selected == 2",
  h4("Grenzen der Schadensreduktion/Erfolgsgrade:"),
  column(
    6,
    numericInput(
      "lower_bound",
      "Untere Grenze",
      min = 0,
      max = 9,
      value = 0
    )
  ),
  column(
    6,
    numericInput(
      "upper_bound",
      "Obere Grenze",
      min = 1,
      max = 25,
      value = 10
    )
  )
),

br(),
actionButton("reset_input", "Eingabe zurücksetzen"),
    ),


## Main-Panel ----
# Show a plot of the generated distribution
mainPanel(tabsetPanel(
  tabPanel(
    "Wahrscheinlichkeiten",
    value = 1,
    plotOutput("dist_plot", height = "320px"),
    br(),
    selectInput(
      "y_axis",
      "Darstellung der kumulierten Grafik",
      choices = list(
        "mindestens x oder höher" = "cum_prob_min",
        "maximal x oder niedriger" = "cum_prob_max"
      )
    ),
    plotOutput("cum_dist_plot", height = "320px")
  ),
  tabPanel(
    "Schadensreduktion",
    value = 2,
    plotOutput("dmgred_plot", height = "320px"),
    br(),
    plotOutput("slvls_plot", height = "320px"),
    selectInput(
      "y_axis_dr",
      "Art des durchschnittlichen Schadens",
      choices = list(
        "Durchschnittlicher Schaden" = "total",
        "Durchschnittlicher Schaden pro Tick" = "norm"
      ),
      selected = "norm"
    )
  ),
  id = "tab_selected"
))
  )
)


server <- function(input, output, session) {
  # Tab 1 ----
  
  ## Update elements ----
  
  observeEvent(input$weapon_toggle, {
    updateActionButton(session,
                       "weapon_toggle",
                       label = ifelse((input$weapon_toggle %% 2) == 0,
                                      "Waffe 2 anpassen",
                                      "Waffe 1 anpassen"
                       ))
  })
  
  hide("wield")
  hide("wield_2")
  
  ## Create objects ----
  
  sel_weapon_1 <- reactive({
    data[name == input$select_weapon_1]
  })
  
  sel_weapon_2 <- reactive({
    data[name == input$select_weapon_2]
  })
  
  comb_1 <-
    reactive({
      req(any(c(input$d6, input$d10) != 0))
      combine_dice(
        n_d6 = input$d6,
        n_d10 = input$d10,
        att_exact = input$exact,
        att_sharp = input$sharp,
        att_critical = input$critical
      )
    })
  
  comb_2 <-
    reactive({
      req(any(c(input$d6_2, input$d10_2) != 0))
      combine_dice(
        n_d6 = input$d6_2,
        n_d10 = input$d10_2,
        att_exact = input$exact_2,
        att_sharp = input$sharp_2,
        att_critical = input$critical_2
      )
    })
  
  prob_table <- reactive({
    if (isTruthy(any(c(input$d6, input$d10) != 0))) {
      create_prob_table(
        comb_1(),
        flat_mod = input$flat,
        att_penetration = input$penetration,
        damage_reduction = input$dmg_reduction,
        success_level = input$success_lvl,
        att_massive = input$massive,
        att_versatile = input$wield
      )[, weapon := "Waffe 1"]
    } else {
      req(any(c(input$d6, input$d10) != 0))
    }
  })
  
  prob_table_2 <- reactive({
    if (isTruthy(any(c(input$d6_2, input$d10_2) != 0))) {
      create_prob_table(
        comb_2(),
        flat_mod = input$flat_2,
        att_penetration = input$penetration_2,
        damage_reduction = input$dmg_reduction,
        success_level = input$success_lvl,
        att_massive = input$massive_2,
        att_versatile = input$wield_2
      )[, weapon := "Waffe 2"]
    } else {
      req(any(c(input$d6_2, input$d10_2) != 0))
    }
  })
  
  prob_tables <- reactive({
    req(isTruthy(prob_table()) && isTruthy(prob_table_2()))
    rbindlist(list("Waffe 1" = prob_table(), "Waffe 2" = prob_table_2()))
  })
  
  ## Textoutput ----
  # FIXME Print like sd_damage (in one)
  # Print Selected Weapon
  print_weapon_txt <-
    reactive(paste(
      "Ausgewählte Waffe:",
      create_weapon_txt(input$d6, input$d10, input$flat)
    ))
  output$weapon <- renderText({
    print_weapon_txt()
  })
  
  print_weapon_txt_2 <-
    reactive(paste(
      "Ausgewählte Waffe:",
      create_weapon_txt(input$d6_2, input$d10_2, input$flat_2)
    ))
  output$weapon_2 <- renderText({
    print_weapon_txt_2()
  })
  
  # Calculate Average Damage
  mean_damage <-
    reactive(round(prob_table()[, sum(damage * probability)], 2))
  # Print Average Damage
  print_mean_damage <-
    reactive(paste("Durchschn. Schaden:",
                   mean_damage()))
  output$mean_dmg <- renderText({
    print_mean_damage()
  })
  
  mean_damage_2 <-
    reactive(round(prob_table_2()[, sum(damage * probability)], 2))
  # Print Average Damage
  print_mean_damage_2 <-
    reactive(paste("Durchschn. Schaden:",
                   mean_damage_2()))
  output$mean_dmg_2 <- renderText({
    print_mean_damage_2()
  })
  
  # Print Average Damage per Tick
  print_mean_damage_per_tick <-
    reactive(paste(
      "Durchschn. Schaden pro Tick:",
      fifelse(
        input$speed != 0,
        # FIXME
        yes =
          round(prob_table()[, sum(damage * probability)] / input$speed, 2),
        no = 0
      )
    ))
  output$mean_dmg_per_tick <- renderText({
    print_mean_damage_per_tick()
  })
  
  print_mean_damage_per_tick_2 <-
    reactive(paste(
      "Durchschn. Schaden pro Tick:",
      fifelse(
        input$speed_2 != 0,
        # FIXME
        yes =
          round(prob_table_2()[, sum(damage * probability)] / input$speed_2, 2),
        no = 0
      )
    ))
  output$mean_dmg_per_tick_2 <- renderText({
    print_mean_damage_per_tick_2()
  })
  
  # Print Damage Standard Deviation
  sd_damage <-
    reactive(paste("Durchschnittliche Abweichung:",
                   round(prob_table()
                         [, sqrt(sum((damage - sum(
                           damage * probability
                         ))
                         ^ 2 * probability))], 2)))
  output$sd_dmg <- renderText({
    sd_damage()
  })
  
  
  sd_damage_2 <-
    reactive(paste("Durchschnittliche Abweichung:",
                   round(prob_table_2()
                         [, sqrt(sum((damage - sum(
                           damage * probability
                         ))
                         ^ 2 * probability))], 2)))
  output$sd_dmg_2 <- renderText({
    sd_damage_2()
  })
  
  ## Plots ----
  # Plot Probability Distribution
  output$dist_plot <- renderPlot({
    x <- tryCatch(
      prob_tables(),
      error = function(e)
        prob_table()
    )
    x_axis_labels <- min(x[, damage]):max(x[, damage])
    ggplot(data = x, aes(x = damage, y = probability, fill = weapon)) +
      geom_bar(
        stat = "identity",
        color = "black",
        position = position_dodge2(preserve = "single")
      ) +
      scale_fill_manual(values = c("#56B4E9", "#D55E00")) +
      geom_text(aes(label = round(probability * 100, 1)),
                vjust = -0.3,
                position = position_dodge(width = 0.9)) + # FIXME In DT
      ggtitle("Wahrscheinlichkeitsverteilung des Schadens") +
      xlab("Schaden") +
      ylab("Wahrscheinlichkeit in %") +
      scale_x_continuous(labels = x_axis_labels, breaks = x_axis_labels) +
      scale_y_continuous(
        labels = function(x)
          paste0(x * 100, "%"),
        breaks = pretty_breaks(n = 10)
      ) +
      theme_classic(base_size = 20) +
      theme(legend.position = "none")
  })
  
  # Plot Cumulative Probability Distribution
  output$cum_dist_plot <- renderPlot({
    x <- tryCatch(
      prob_tables(),
      error = function(e)
        prob_table()
    )
    x_axis_labels <- min(x[, damage]):max(x[, damage])
    ggplot(data = x, aes(x = damage, y = switch(
      input$y_axis,
      cum_prob_min = cum_prob_min,
      cum_prob_max = cum_prob_max
    ), fill = weapon)) +
      geom_bar(
        stat = "identity",
        color = "black",
        position = position_dodge2(preserve = "single")
      ) +
      scale_fill_manual(values = c("#56B4E9", "#D55E00")) +
      geom_text(aes(label = switch(
        input$y_axis,
        cum_prob_min = round(cum_prob_min * 100, 1),
        # FIXME In DT
        cum_prob_max = round(cum_prob_max * 100, 1) # FIXME In DT
      )),
      vjust = -0.3,
      position = position_dodge(width = 0.9)) +
      ggtitle(switch(
        input$y_axis,
        cum_prob_min = "Kumulierte Wahrscheinlichkeiten (Mindestschaden)",
        cum_prob_max = "Kumulierte Wahrscheinlichkeiten (Maximalschaden)"
      )) +
      xlab("Schaden") +
      ylab("Wahrscheinlichkeit in %") +
      scale_x_continuous(labels = x_axis_labels, breaks = x_axis_labels) +
      scale_y_continuous(
        labels = function(x)
          paste0(x * 100, "%"),
        breaks = pretty_breaks(n = 10)
      ) +
      theme_classic(base_size = 20) +
      theme(legend.position = "none")
  })
  
  observe({
    if (all(c(input$d6, input$d10, input$d6_2, input$d10_2) == 0)) {
      hide("weapon")
      hide("mean_dmg")
      hide("dist_plot")
      hide("y_axis")
    } else {
      show("weapon")
      show("mean_dmg")
      show("dist_plot")
      show("y_axis")
    }
  })
  
  observe({
    if (all(c(input$d6_2, input$d10_2) == 0)) {
      hide("weapon_2")
      hide("mean_dmg_2")
    } else {
      show("weapon_2")
      show("mean_dmg_2")
    }
  })
  
  # Tab 2 ----
  
  observe(updateSliderInput(session, "lower_bound", max = input$upper_bound - 1))
  
  dmgred_table <- reactive({
    if (isTruthy(any(c(input$d6, input$d10) != 0))) {
      create_dmgred_table(
        comb_1(),
        flat_mod = input$flat,
        weapon_speed = input$speed,
        att_penetration = input$penetration,
        success_level = input$success_lvl,
        att_massive = input$massive,
        att_versatile = input$wield,
        lower_bound = input$lower_bound,
        upper_bound = input$upper_bound
      )[, weapon := "Waffe 1"]
    } else {
      req(any(c(input$d6, input$d10) != 0))
    }
  })
  
  dmgred_table_2 <- reactive({
    if (isTruthy(any(c(input$d6_2, input$d10_2) != 0))) {
      create_dmgred_table(
        comb_2(),
        flat_mod = input$flat_2,
        weapon_speed = input$speed_2,
        att_penetration = input$penetration_2,
        success_level = input$success_lvl,
        att_massive = input$massive_2,
        att_versatile = input$wield_2,
        lower_bound = input$lower_bound,
        upper_bound = input$upper_bound
      )[, weapon := "Waffe 2"]
    } else {
      req(any(c(input$d6_2, input$d10_2) != 0))
    }
  })
  
  dmgred_tables <- reactive({
    req(isTruthy(dmgred_table()) && isTruthy(dmgred_table_2()))
    rbindlist(list("Waffe 1" = dmgred_table(), "Waffe 2" = dmgred_table_2()))
  })
  
  
  slvls_table <- reactive({
    if (isTruthy(any(c(input$d6, input$d10) != 0))) {
      create_slvls_table(
        comb_1(),
        flat_mod = input$flat,
        weapon_speed = input$speed,
        damage_reduction = input$dmg_reduction,
        att_penetration = input$penetration,
        att_massive = input$massive,
        att_versatile = input$wield,
        lower_bound = input$lower_bound,
        upper_bound = input$upper_bound
      )[, weapon := "Waffe 1"]
    } else {
      req(any(c(input$d6, input$d10) != 0))
    }
  })
  
  slvls_table_2 <- reactive({
    if (isTruthy(any(c(input$d6_2, input$d10_2) != 0))) {
      create_slvls_table(
        comb_2(),
        flat_mod = input$flat_2,
        weapon_speed = input$speed_2,
        damage_reduction = input$dmg_reduction,
        att_penetration = input$penetration_2,
        att_massive = input$massive_2,
        att_versatile = input$wield_2,
        lower_bound = input$lower_bound,
        upper_bound = input$upper_bound
      )[, weapon := "Waffe 2"]
    } else {
      req(any(c(input$d6_2, input$d10_2) != 0))
    }
  })
  
  slvls_tables <- reactive({
    req(isTruthy(slvls_table()) && isTruthy(slvls_table_2()))
    rbindlist(list("Waffe 1" = slvls_table(), "Waffe 2" = slvls_table_2()))
  })
  
  ## Plots ----
  
  output$dmgred_plot <- renderPlot({
    x <- tryCatch(
      dmgred_tables(),
      error = function(e)
        dmgred_table()
    )
    x_axis_labels <-
      min(x[, damage_reduction]):max(x[, damage_reduction])
    ggplot(data = x, aes(x = damage_reduction, y = switch(
      input$y_axis_dr,
      total = means,
      norm = means_per_tick
    ), fill = weapon)) +
      geom_bar(
        stat = "identity",
        color = "black",
        position = position_dodge2(preserve = "single")
      ) +
      scale_fill_manual(values = c("#56B4E9", "#D55E00")) +
      geom_text(aes(label = switch(
        input$y_axis_dr,
        total = round(means, 1),
        # FIXME In DT
        norm = round(means_per_tick, 1)
      )),
      vjust = -0.3,
      position = position_dodge(width = 0.9)) + # FIXME In DT
      ggtitle("Durchschn. Schaden nach Schadensreduktion des Gegners") +
      xlab("Schadensreduktion") +
      ylab(switch(input$y_axis_dr,
                  total = "Durchschn. Schaden",
                  norm = "D. Schaden / Tick")) +
      scale_x_continuous(breaks = x$damage_reduction) +
      scale_y_continuous(breaks = pretty_breaks(n = 10)) +
      theme_classic(base_size = 20) +
      theme(legend.position = "none")
  })
  
  output$slvls_plot <- renderPlot({
    x <- tryCatch(
      slvls_tables(),
      error = function(e)
        slvls_table()
    )
    x_axis_labels <-
      min(x[, success_lvls]):max(x[, success_lvls])
    ggplot(data = x, aes(x = success_lvls, y = switch(
      input$y_axis_dr,
      total = means,
      norm = means_per_tick
    ), fill = weapon)) +
      geom_bar(
        stat = "identity",
        color = "black",
        position = position_dodge2(preserve = "single")
      ) +
      scale_fill_manual(values = c("#56B4E9", "#D55E00")) +
      geom_text(aes(label = switch(
        input$y_axis_dr,
        total = round(means, 1),
        # FIXME In DT
        norm = round(means_per_tick, 1)
      )),
      vjust = -0.3,
      position = position_dodge(width = 0.9)) + # FIXME In DT
      ggtitle("Durchschn. Schaden nach für 'Wuchtangriff' eingesetzten EG") +
      xlab("Für Wuchtangriff eingesetzte EG") +
      ylab(switch(input$y_axis_dr,
                  total = "Durchschn. Schaden",
                  norm = "D. Schaden / Tick")) +
      scale_x_continuous(breaks = x$success_lvls) +
      scale_y_continuous(breaks = pretty_breaks(n = 10)) +
      theme_classic(base_size = 20) +
      theme(legend.position = "none")
  })
  
  # Update / Reset inputs ----
  
  ## Weapon 1 ----
  
  observeEvent(
    input$select_weapon_1,
    updateNumericInput(session, "d6", value = sel_weapon_1()$n_d6)
  )
  
  observeEvent(
    input$select_weapon_1,
    updateNumericInput(session, "d10", value = sel_weapon_1()$n_d10)
  )
  
  observeEvent(
    input$select_weapon_1,
    updateNumericInput(session, "flat", value = sel_weapon_1()$flat_mod)
  )
  
  observeEvent(
    input$select_weapon_1,
    updateNumericInput(session, "speed", value = sel_weapon_1()$speed)
  )
  
  observeEvent(
    input$select_weapon_1,
    updateNumericInput(session, "exact", value = sel_weapon_1()$exakt)
  )
  
  observeEvent(
    input$select_weapon_1,
    updateNumericInput(session, "critical", value = sel_weapon_1()$kritisch)
  )
  
  observeEvent(
    input$select_weapon_1,
    updateNumericInput(session, "penetration", value = sel_weapon_1()$durchdringung)
  )
  
  observeEvent(
    input$select_weapon_1,
    updateNumericInput(session, "sharp", value = sel_weapon_1()$scharf)
  )
  
  observeEvent(
    input$select_weapon_1,
    updateCheckboxInput(session, "massive", value = sel_weapon_1()$wuchtig)
  )
  
  observe(if (input$versatile == FALSE) {
    hide("wield")
    updateRadioGroupButtons(session, "wield", selected = FALSE)
  } else {
    show("wield")
    updateRadioGroupButtons(session, "wield", selected = TRUE)
  })
  
  observeEvent(
    input$select_weapon_1,
    updateMaterialSwitch(session, "versatile", value = sel_weapon_1()$vielseitig)
  )
  
  ## Weapon 2 ----
  
  observeEvent(
    input$select_weapon_2,
    updateNumericInput(session, "d6_2", value = sel_weapon_2()$n_d6)
  )
  
  observeEvent(
    input$select_weapon_2,
    updateNumericInput(session, "d10_2", value = sel_weapon_2()$n_d10)
  )
  
  observeEvent(
    input$select_weapon_2,
    updateNumericInput(session, "flat_2", value = sel_weapon_2()$flat_mod)
  )
  
  observeEvent(
    input$select_weapon_2,
    updateNumericInput(session, "speed_2", value = sel_weapon_2()$speed)
  )
  
  observeEvent(
    input$select_weapon_2,
    updateNumericInput(session, "exact_2", value = sel_weapon_2()$exakt)
  )
  
  observeEvent(
    input$select_weapon_2,
    updateNumericInput(session, "critical_2", value = sel_weapon_2()$kritisch)
  )
  
  observeEvent(
    input$select_weapon_2,
    updateNumericInput(session, "penetration_2", value = sel_weapon_2()$durchdringung)
  )
  
  observeEvent(
    input$select_weapon_2,
    updateNumericInput(session, "sharp_2", value = sel_weapon_2()$scharf)
  )
  
  observeEvent(
    input$select_weapon_2,
    updateCheckboxInput(session, "massive_2", value = sel_weapon_2()$wuchtig)
  )
  
  observe(if (input$versatile_2 == FALSE) {
    hide("wield_2")
    updateRadioGroupButtons(session, "wield_2", selected = FALSE)
  } else {
    show("wield_2")
    updateRadioGroupButtons(session, "wield_2", selected = TRUE)
  })
  
  observeEvent(
    input$select_weapon_2,
    updateMaterialSwitch(session, "versatile_2", value = sel_weapon_2()$vielseitig)
  )
  
  
  observeEvent(input$reset_input, {
    reset("side-panel")
    reset("weapon_toggle") # FIXME Not working
  })
  
}

# Run the application
shinyApp(ui = ui, server = server)
