#!/bin/bash
# Frase random en inglés para el lockscreen (hyprlock.conf)
# Se elige una nueva cada vez que hypridle re-ejecuta este cmd.

QUOTES=(
    "Simplicity is the ultimate sophistication."
    "Stay hungry, stay foolish."
    "Make it work, make it right, make it fast."
    "The best way to predict the future is to invent it."
    "Done is better than perfect."
    "Code is read more often than it is written."
    "First, solve the problem. Then, write the code."
    "Complexity is the enemy of reliability."
    "Talk is cheap. Show me the code."
    "Any fool can write code that a computer can understand."
    "Premature optimization is the root of all evil."
    "A good programmer looks both ways before crossing a one-way street."
)

echo "${QUOTES[RANDOM % ${#QUOTES[@]}]}"
