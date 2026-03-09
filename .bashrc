# ------- ( CUSTOM PROMPT ) ----------------------------------------------------

if [[ -f ~/.bash_prompt ]]; then
  source ~/.bash_prompt
else
  PS1="(\u@\h) (\w) λ "
fi
