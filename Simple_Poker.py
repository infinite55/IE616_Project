#!/usr/bin/env python
# coding: utf-8

# In[1]:


import random

suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades']
ranks = ['Ace', 'King', 'Queen', 'Jack', '10', '9', '8', '7', '6', '5', '4', '3', '2']

deck = []

for suit in suits:
    for rank in ranks:
        deck.append((rank, suit))

random.shuffle(deck)

player1_hand = []
player2_hand = []

for i in range(5):
    player1_hand.append(deck.pop())
    player2_hand.append(deck.pop())

print("Player 1's hand: ", player1_hand)
print("Player 2's hand: ", player2_hand)

player1_rank_count = {}
player2_rank_count = {}

for card in player1_hand:
    rank = card[0]
    if rank in player1_rank_count:
        player1_rank_count[rank] += 1
    else:
        player1_rank_count[rank] = 1

for card in player2_hand:
    rank = card[0]
    if rank in player2_rank_count:
        player2_rank_count[rank] += 1
    else:
        player2_rank_count[rank] = 1

player1_score = max(player1_rank_count.values())
player2_score = max(player2_rank_count.values())

if player1_score > player2_score:
    print("Player 1 wins with a score of ", player1_score)
elif player2_score > player1_score:
    print("Player 2 wins with a score of ", player2_score)
else:
    print("It's a tie!")


# In[ ]:




