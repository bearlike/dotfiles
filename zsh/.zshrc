# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Common Variables 
export LANG=en_US.UTF-8
export COLORTERM=truecolor
# export ARCHFLAGS="-arch x86_64" # Compilation flags
export PATH=$HOME/bin:/usr/local/bin:/sbin:$PATH
export ZSH="$HOME/.oh-my-zsh"

# ZSH Configuration Variables
ZSH_THEME="powerlevel10k/powerlevel10k" # Set ZSH theme
CASE_SENSITIVE="true" # Use case-sensitive completion?
SH_AUTOSUGGEST_STRATEGY=(completion match_prev_cmd history)
DISABLE_AUTO_TITLE="true"
COMPLETION_WAITING_DOTS="true"
HIST_STAMPS="dd.mm.yyyy"

zstyle ':omz:update' mode auto  # update automatically without asking
zstyle ':omz:update' frequency 15 # Check for updates every 15 days

bindkey $key[Up] up-line-or-history
# up-line-or-search:  Open history menu.
# up-line-or-history: Cycle to previous history line.
bindkey $key[Down] down-line-or-history
# down-line-or-select:  Open completion menu.
# down-line-or-history: Cycle to next history line.
# bindkey $key[Control-Space] list-expand


# Which plugins would you like to load?
plugins=(
	git
	history
	common-aliases
	zsh-autosuggestions
	zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh
# Although zsh-autocomplete is inside oh-my-zsh, I installed it manually
source $ZSH/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load Alias file
if [ -f ~/alias.sh ]; then
    . ~/alias.sh
fi

# Load Enviroinment Variable file
if [ -f ~/env.sh ]; then
    . ~/env.sh
fi

# Local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
	export EDITOR='nano'
	# Display banner on SSH login
	$HOME/.login-banner.sh
else
	export EDITOR='gedit'
fi

# Custom segment for displaying CPU temperature
function prompt_cpu_temp() {
	integer cpu_temp="$(</sys/class/thermal/thermal_zone0/temp) / 1000"
	if (( cpu_temp >= 55 )); then
		p10k segment -s HOT  -f red    -t "${cpu_temp}"$'\uE339' -i $'\uF737'
	elif (( cpu_temp >= 50 )); then
		p10k segment -s WARM -f yellow -t "${cpu_temp}"$'\uE339' -i $'\uF071'
	elif (( cpu_temp < 50 )); then
		p10k segment -s OK -f green -t "${cpu_temp}"$'\uE339' -i $'\uF2CB'
	fi
}

POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=cpu_temp