# Library ----
require(tidyverse)
require(shiny)
require(shinyWidgets)
require(ggiraph)
require(ggpubr)
require(htmltools)

# Data ----
hrData <- read_csv("WA_Fn-UseC_-HR-Employee-Attrition.csv")
hrData$rowID <- 1:nrow(hrData)

## Select Columns ----
selectedData <- hrData %>%
  select(rowID, Age, Attrition, PercentSalaryHike, Department, TotalWorkingYears, YearsAtCompany, PerformanceRating)

## Set x limits ----
xAxisLimits <- range(c(selectedData$TotalWorkingYears, selectedData$YearsAtCompany), na.rm = TRUE)

## Set y limits ----
yAxisLimtes <- range(selectedData$PercentSalaryHike, na.rm = TRUE)

## Set cicle limits ----
circleLimits <- range(selectedData$PerformanceRating, na.rm = TRUE)


# User Interface ----

userInterface <- fluidPage(
  
  ## Page Tile
  titlePanel(h1("HR DASHBOARD DEMO", style = 'text-align: center;')),
  
  fluidRow(h2("Years of Working, Salary Hike, Age, and Attrition", style = 'text-align: center;')),
  
  column(4, style = 'background: #f1f1f1;',
         h3("WHAT MAKE SALRY HIKE?"),
         p(style = 'margin: 10px; font-size: 14px; text-align: justify;', "The bubble charts on the right show the relationship between employee's Years of Working 
         against Percentage of Salary Hike. Two bubble charts are positioned side-by-side to allow relationship comparison. The one on the left
           present the relationship between Total Years of Working and Percentage of Salary Hike, while the one on the right
           present the relationship between Years at Company and Percentage of Salary Hike. The bubbles are color-coded based on 
           Attrition, where red indicate 'yes' and blue indicate 'no', and sized by Performance Rating.
           The visualisation display infromation segmented by age,
           which can be change using slider bar. The default view show information of individuals at specific age from all department."),
         p(style = 'margin: 10px; font-size: 14px; text-align: justify;', "Based on these chart, we can observe the influence of 
           different aspect of working years on salary hike in percentage. We can also detect pattern and trends of attrition based on
           the observed relationships, age, performance rating, and department. For instance, employees,
           who are 18 years old and have less than one year of experience, 
           received low salary increase and more than half of them have already quit."),
         p(style = 'margin: 10px; font-size: 14px; text-align: justify;', "Data Source: Bhanupratap Biswas. (2023). 
           HR Analytics: Case Study [Data set]. Kaggle. 10.34740/kaggle/dsv/5905686")
         ),
  
  column(8, 
         wellPanel(
         pickerInput("pickerDepartment", "Department: ",
                     choices = c("All department"="", unique(selectedData$Department)),
                     options = list(`live-search` = TRUE)),
         sliderInput("sliderAge", "Age:",
                     min = min(selectedData$Age), max = max(selectedData$Age), step = 1, value = min(selectedData$Age), width = "100%",
         animate = TRUE)),
         
         fluidRow(girafeOutput("BubbleChart")))
)


# Server ----
server <- function(input, output, session) {
  
  ## Bubble chart ----
  output$BubbleChart <- renderGirafe({
    
    ### Input ----
    departmentSelect <- input$pickerDepartment
    ageSelect <- input$sliderAge
    
    ### filter data ----
    filterData <- selectedData %>%
      filter(Age == ageSelect) %>%
      filter(if(!is.null(departmentSelect) && nchar(departmentSelect) > 0) Department == departmentSelect else TRUE)
    
    ### Set color ----
    attritionColor <- c("Yes" = "red", "No" = "blue")
    
    ### Create tooltips ----
    TotalYears <- paste("<b>Age:</b>", filterData$Age,
                           "<br><b>Total Working Years:</b>", filterData$TotalWorkingYears,
                           "<br><b>Attrition:</b>", filterData$Attrition,
                           "<br><b>Department:</b>", filterData$Department,
                           "<br><b>Performance Rating:</b>", filterData$PerformanceRating)
    YearsAtCom <- paste("<b>Age:</b>", filterData$Age,
                        "<br><b>Years At Company:</b>", filterData$YearsAtCompany,
                        "<br><b>Attrition:</b>", filterData$Attrition,
                        "<br><b>Department:</b>", filterData$Department,
                        "<br><b>Performance Rating:</b>", filterData$PerformanceRating)
    
    
    ### Create bubble charts ----
    
    #### plot1 ----
    Plot1 <- ggplot(filterData, aes(x = TotalWorkingYears, y = PercentSalaryHike, color = Attrition,
                                    size = PerformanceRating, alpha = 0.95)) + 
      geom_point_interactive(aes(data_id = rowID, tooltip = TotalYears)) +
      scale_color_manual(values = attritionColor) +
      scale_x_continuous(limits = xAxisLimits) +
      scale_y_continuous(limits = yAxisLimtes) +
      scale_size_continuous(range = c(2,5), limits = circleLimits) +
      labs(title = "Total Working Years vs. \nPercentage Salary Hike",
           x = "Total Working Years",
           y = "Percentage Salary Hike",
           size = "Performance Rating") +
      theme_minimal() +
      guides(alpha = "none") +
      theme(legend.position = "none",
            plot.title = element_text(size = 9.5, face = "bold", hjust = 0.5),
            axis.title = element_text(size = 7, face = "bold", color = "black"),
            axis.text = element_text(size = 7, color = "black"),
            legend.text = element_text(size = 7, color = "black"),
            legend.title = element_text (size = 7, color = "black", face = "bold"),
            legend.key.size = unit(0.7, "cm"),
            legend.box = "vertical")
    
    #### plot2 ----
    Plot2 <- ggplot(filterData, aes(x = YearsAtCompany, y = PercentSalaryHike, color = Attrition,
                                    size = PerformanceRating, alpha = 0.95)) + 
      geom_point_interactive(aes(data_id = rowID, tooltip = YearsAtCom)) +
      scale_color_manual(values = attritionColor) +
      scale_x_continuous(limits = xAxisLimits) +
      scale_y_continuous(limits = yAxisLimtes) +
      scale_size_continuous(range = c(2,5), limits = circleLimits) +
      labs(title = "Years At Company vs. \nPercentage Salary Hike",
           x = "Years At Company",
           y = "Percentage Salary Hike",
           size = "Performance Rating") +
      theme_minimal() +
      guides(alpha = "none") +
      theme(legend.position = "none",
            plot.title = element_text(size = 9.5, face = "bold", hjust = 0.5),
            axis.title = element_text(size = 7, face = "bold", color = "black"),
            axis.text = element_text(size = 7, color = "black"),
            legend.text = element_text(size = 7, color = "black"),
            legend.title = element_text (size = 7, color = "black", face = "bold"),
            legend.key.size = unit(0.7, "cm"),
            legend.box = "vertical")
      
    
    combineBubblePlot <- ggiraph(ggobj = ggarrange(Plot1, Plot2, nrow = 1, common.legend = TRUE, legend = "bottom"),
                                 width_svg = 7, height_svg = 4,
                                 options = list(opts_hover(css = ""),
                                                opts_hover_inv(css = "opacity: 0.4;"),
                                                opts_sizing(rescale = FALSE)),
                                 hover_css = "fill-opacity: 1; r:8px; stroke: black; stroke-width: 2px;", 
                                 selected_css= "fill-opacity: 1; stroke: black; stroke-width: 2px;")
    
  })
  
}

# Run app ----
shinyApp(userInterface, server)


