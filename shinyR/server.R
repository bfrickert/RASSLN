library(shiny)
library(ggplot2)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  set.seed(666)
  test <- reactive({get.test(input$Wrestler)})
  my.Logit <- reactive({ 
    set.seed(666)
    return(glm(win.loss~.,data=get.train(input$Wrestler),family=binomial(link='logit')))
  })
  fitted.results <- reactive({
    #get.fitted.results(input$Wrestler)
    set.seed(666)
    myLogit <- my.Logit()
    fitted.results <- predict(myLogit,newdata=select(test(), -win.loss),type='response')
    return(ifelse(fitted.results > 0.5,1,0))
    })
  
  output$distPlot <- renderPlot({
    f.lost <- select(filter(full, loser.name == input$Wrestler & 
                              is.na(winner.wgt)==F & is.na(winner.hgt)==F &
                              winner.wgt != 0 & winner.hgt != 0), winner.wgt,winner.hgt)
    names(f.lost) <- c('wgt','hgt')
    f.lost$result <- 'lost'
    f.won <- select(filter(full, winner.name == input$Wrestler & 
                             is.na(loser.wgt)==F & is.na(loser.hgt)==F &
                             loser.wgt != 0 & loser.hgt != 0),loser.wgt, loser.hgt)
    names(f.won) <- c('wgt','hgt')
    f.won$result <- 'won'
    
    f <- rbind(f.lost,f.won)

    p <- ggplot(f, aes(wgt, hgt))
    p + geom_point(aes(colour = factor(result))) + geom_point(position = position_jitter(w = 0.1, h = 0.1)) + 
      geom_smooth(aes(group=result,colour = factor(result)), method="lm") + theme_bw()
    
  })
  output$graphPlot <- renderPlot(({
    
    graph.f(input$Wrestler)
  }), height = 550, width = 550)
  
  output$Record <- renderText({
    paste('Record:', round(mean(c(rep(1, nrow(filter(full, winner.name==input$Wrestler))), 
                                  rep(0, nrow(filter(full, loser.name == input$Wrestler))))), 
                           3))
    
  })
  
  output$Wins <- renderTable({
    wins <- get.wins(input$Wrestler)
    
    beatens <- data.frame(sort(table(wins$loser.name),decreasing=T)[2:5])
    names(beatens) <- 'count'
    beatens
  })

  output$Accuracy <- renderText({
    misClasificError <- mean(fitted.results() != test()$win.loss)
    
    paste('Accuracy:',round(1-misClasificError,3))
  })
  
  output$Losses <- renderTable({
    losses <- get.losses(input$Wrestler)
    
    beatens.by <- data.frame(sort(table(losses$winner.name),decreasing=T)[2:5])
    names(beatens.by) <- 'count'
    beatens.by
  })
  
  output$Xtable <- renderTable({
    df <- data.frame(matrix(table(fitted.results(),test()$win.loss), ncol=2, byrow=T))
    names(df) <- c('predicted wins', 'predicted losses')
    row.names(df) <- c('actual wins', 'actual losses')
    df
      })
  
  output$perf <- renderPlot({
    pr <- prediction(fitted.results(), test()$win.loss)
    prf <- performance(pr, measure = "tpr", x.measure = "fpr")
    plot(prf)
  })
  
  output$area.under.curve <- renderText({
    pr <- prediction(fitted.results(), test()$win.loss)
    auc <- performance(pr, measure = "auc")
    auc <- auc@y.values[[1]]
    paste('Area Under Curve:', auc)
  })
  
  output$strong.moves <- renderTable({
    coefs <- data.frame(summary(my.Logit())$coef)
    coefs$name <- row.names(coefs)
    names(coefs) <- c('estimate','se','t.val','p.val', 'name')
    head(rbind(coefs[1,],arrange(coefs[2:nrow(coefs),],desc(estimate))))
  })
  
  output$danger.moves <- renderTable({
    coefs <- data.frame(summary(my.Logit())$coef)
    coefs$name <- row.names(coefs)
    names(coefs) <- c('estimate','se','t.val','p.val', 'name')
    rbind(coefs[1,],tail(arrange(coefs[2:nrow(coefs),],desc(estimate))))
  })
})