#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(terra)
library(sf)
library(tidyverse)
library(tidyterra)
library(ggnewscale)
library(viridis)
stackmask = rast("stackmask.tif")
dfjoin = readRDS("dfjoin.rds")
names(dfjoin) = gsub(x = names(dfjoin), pattern = "\\-", replacement = "_")
names(stackmask) = gsub(x = names(stackmask), pattern = "\\-", replacement = "_")
bufmasksf = readRDS("bufmasksf.rds")
cols = names(dfjoin)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Cass Onion Rings"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
      sidebarPanel(
        sliderInput("smoothdem", "Elevation", min = round(min(dfjoin$smoothdem)), max = round(max(dfjoin$smoothdem)), value = c(600,650)),
        sliderInput("slope", "Slope", min = round(min(dfjoin$slope)), max = round(max(dfjoin$slope)), value = c(round(min(dfjoin$slope)),round(max(dfjoin$slope)))),
        sliderInput("bufs", "Buffer Size",  min= 2, max = 10, value = 2),
        checkboxInput("add_buffer", "Add buffer to map", value = FALSE),
        selectInput("y_variable", "Y Variable", cols, selected = "zmax")
        
      ),
      
      # Show a plot with configurable axes
      mainPanel(
        plotOutput("boxplot"),
        plotOutput("map")
      )
    ),
    tags$hr()

)
    


# Define server logic required to draw a histogram
server <- function(input, output) {

    
    output$boxplot = renderPlot({
     #dfplot = dfjoin[dfjoin$smoothdem >= input$smoothdem[1] & dfjoin$smoothdem <= input$smoothdem[2],]
      dfplot = dfjoin %>%
        filter(smoothdem >= input$smoothdem[1] & smoothdem <= input$smoothdem[2] & slope >= input$slope[1] & slope <= input$slope)%>%
        mutate(distanceclass = cut(distance, breaks = seq(1,100,input$bufs))
        )
    
     dfplot$distancef = NA
     dfplot$distancef = factor(dfplot$distance)

        ggplot(data = dfplot)+
        geom_boxplot(aes_string(x = dfplot$distanceclass, y =input$y_variable))+
        xlab("Distance from stream")+
        theme_minimal()
        
        
    })
    output$map = renderPlot({
      #plot(stackmask, col = viridis(n = 100))
      r = stackmask %>%
                  select(input$y_variable)
      b = bufmasksf %>%
        mutate(distanceclass = cut(distance, breaks = seq(1,100,input$bufs)))%>%
        group_by(distanceclass)%>%
        summarise()%>%
        vect()
      ggplot()+
        geom_spatraster(data = r)+
        scale_fill_viridis_c(na.value = NA) +
        labs(fill = input$y_variable)+
        new_scale_fill()+
        theme_minimal()+
        new_scale_fill()+
        geom_spatvector(data = b, fill = NA, col = "red")+
      #geom_spatvector(data = b,aes(fill = distanceclass, col = distanceclass), alpha = 0.25)+
        #scale_fill_brewer(palette = "Reds")+
        #scale_color_brewer(palette = "Reds")+
        #labs(fill = "Distance from Stream", col = "Distance from Stream")+
        theme_minimal()

    })
    observeEvent(input$add_buffer,{
      if(input$add_buffer){
        output$map = renderPlot({
          #plot(stackmask, col = viridis(n = 100))
          r = stackmask %>%
            select(input$y_variable)
          b = bufmasksf %>%
            mutate(distanceclass = cut(distance, breaks = seq(1,100,input$bufs)))%>%
            group_by(distanceclass)%>%
            summarise()%>%
            vect()
          ggplot()+
            geom_spatraster(data = r)+
            scale_fill_viridis_c(na.value = NA) +
            labs(fill = input$y_variable)+
            new_scale_fill()+
            theme_minimal()+
            new_scale_fill()+
            geom_spatvector(data = b, fill = NA, col = "red")+
            #geom_spatvector(data = b,aes(fill = distanceclass, col = distanceclass), alpha = 0.25)+
            #scale_fill_brewer(palette = "Reds")+
            #scale_color_brewer(palette = "Reds")+
            #labs(fill = "Distance from Stream", col = "Distance from Stream")+
            theme_minimal()
        
      })
      } else{
        output$map = renderPlot({
          #plot(stackmask, col = viridis(n = 100))
          r = stackmask %>%
            select(input$y_variable)
          b = bufmasksf %>%
            mutate(distanceclass = cut(distance, breaks = seq(1,100,input$bufs)))%>%
            group_by(distanceclass)%>%
            summarise()%>%
            vect()
          ggplot()+
            geom_spatraster(data = r)+
            scale_fill_viridis_c(na.value = NA) +
            labs(fill = input$y_variable)+
            new_scale_fill()+
            theme_minimal()+
            new_scale_fill()
      })
      }
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
