library(gtree)
game = org.game = new_game(
  gameId = "KuhnPoker",
  params = list(numPlayers=2),
  options = make_game_options(verbose=FALSE),
  stages = list(
    stage("dealCards",
      nature = list(
        # Player 1 gets a random card 1, 2, or 3
        natureMove("card1", 1:3),
        # Draw from remaining cards for player 2
        natureMove("card2", ~setdiff(1:3, card1))
      )
    ),
    stage("pl1CheckBet",
      player=1,
      observe = "card1",
      actions = list(
        action("cb1",c("check","bet"))
      )
    ),
    stage("pl2CheckBet",
      player=2,
      condition = ~ cb1 == "check",
      observe = c("card2","cb1"),
      actions = list(
        action("cb2",c("check","bet"))
      )
    ),
    stage("pl2FoldCall",
      player=2,
      condition = ~ cb1 == "bet",
      observe = c("card2","cb1"),
      actions = list(
        action("fc2",c("fold","call"))
      )
    ),
    stage("pl1FoldCall",
      player=1,
      condition = ~ is_true(cb1 == "check" & cb2=="bet"),
      observe = "cb2",
      actions = list(
        action("fc1",c("fold","call"))
      )
    ),
    stage("PayoffStage",
      player=1:2,
      compute=list(
        # Which player folds?
        folder ~ case_distinction(
          is_true(fc1 == "fold"),1,
          is_true(fc2 == "fold"),2,
          0 # 0 means no player folds
        ),
        
        # Which player wins?
        winner ~ case_distinction(
          folder == 1,2,
          folder == 2,1,
          folder == 0, (card2 > card1) +1
        ),
        
        # How much gave each player to the pot?
        gave1 ~ 1 + 1*is_true((cb1 == "bet") | (fc1 == "call")),
        gave2 ~ 1 + 1*is_true((cb2 == "bet") | (fc2 == "call")),
        pot ~ gave1 + gave2,
        
        # Final payoffs
        payoff_1 ~ (winner == 1)*pot - gave1,
        payoff_2 ~ (winner == 2)*pot - gave2
      )
    )
  )
) 

# print the outcomes

game %>% get_outcomes() %>% head(6)

# print the game size
game %>%
  game_print_size_info()

# solve the game using the gambit-logit solver, 
# which is the default solver for finding a mixed strategy equilibrium:

game %>%
  game_gambit_solve(mixed=TRUE)

# expected equilibrium outcomes:

game %>% 
  eq_expected_outcomes() %>% 
  select(payoff_1,payoff_2, cb1, fc1, cb2,fc2)

# To get better insight into the equilibria let us show the 
# conditional expected outcomes in the case that player 1 gets as card either 1,2 or 3:

game %>%
  eq_cond_expected_outcomes("card1") %>%
  select(card1, payoff_1,payoff_2, cb1, fc1, cb2,fc2)

# consider the cases that player 1 has the highest card and either bets or checks:

game %>%
  eq_cond_expected_outcomes(card1=3, cb1=c("bet","check")) %>%
  select(card1, payoff_1,payoff_2, cb1, fc1, cb2,fc2)

game %>%
  eq_cond_expected_outcomes("card2") %>%
  select(card2, payoff_1,payoff_2,cb2,fc2, cb1, fc1)

game %>%
  eq_cond_expected_outcomes(card2=1, cb2=c("bet","check")) %>%
  select(card2, payoff_1,payoff_2,cb2,fc2, cb1, fc1)

game %>%
  game_prefer_outcomes(player1 =~ case_distinction(
    card1 == 1 & cb1 == "check", 1000,
    card1 == 3 & cb1 == "bet", 1000,
    0
  ))

game$pref$utils

# resulting equilibrium outcomes

game %>%
  game_gambit_solve(mixed=TRUE) %>%
  eq_expected_outcomes()  %>%
  select(payoff_1,payoff_2, cb1, fc1, cb2,fc2)

#  conditional expected outcomes:

game %>%
  eq_cond_expected_outcomes("card1","cb1") %>%
  select(card1, payoff_1,payoff_2, cb1, fc1, cb2,fc2, is.eqo)  
