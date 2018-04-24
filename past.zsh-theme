# *- mode: zsh -*-
# vi: set ft=zsh :

# Past Zsh theme
# Fork from https://github.com/pastleo/zsh-theme-past, who has amazing themes
# for both zsh and fish

_PROMPT_CACHE_FILE="$HOME/.zsh_prompt_cache"
_PROMPT_CACHE_TIMEOUT="40"

function _time_to_color_level
{
	(( inteval = ( $1 + $2 ) % 48 ))
	if [[ $inteval -ge 24 ]]; then
		inteval=$(( 48 - $inteval ))
	fi
	if [[ $inteval -ge 14 ]]; then
		echo 1
	elif [[ $inteval -ge 8 ]]; then
		echo 2
	elif [[ $inteval -ge 4 ]]; then
		echo 3
	elif [[ $inteval -ge 1 ]]; then
		echo 4
	else
		echo 5
	fi
}

function _color_code
{
	local time_value=$(( $1 * 2 + $2 / 30 ))
	echo $(( $(_time_to_color_level $time_value 0) * 36 + $(_time_to_color_level $time_value 16) * 6 + $(_time_to_color_level $time_value 32) + 16 ))
}

function _time_color_code
{
	echo $(_color_code $(date +%H) $(date +%M))
}

function _gen_cache_file
{
	local last_seconds
	if [ "$1" = "init" ]; then # _gen_cache_file init
		last_seconds="-$_PROMPT_CACHE_TIMEOUT"
	else
		last_seconds=$SECONDS
	fi

	local time_color_code=$(_time_color_code)
	echo "last_seconds=$last_seconds time_color_code=$time_color_code" > "$_PROMPT_CACHE_FILE"
}

function _print_prompt
{
	if [[ $(( SECONDS - last_seconds )) -ge $_PROMPT_CACHE_TIMEOUT ]]; then
		_gen_cache_file
	fi
	if [ "x$VIRTUAL_ENV" = "x" ]; then
		PVENV=""
	else
		PVENV="| venv: ${VIRTUAL_ENV##*/} "
	fi
	eval $(cat "$_PROMPT_CACHE_FILE") # read cache value
	local prompt="%{\\033[48;5;0;38;5;${time_color_code}m%}\
 %c $(git_prompt_info)%{\\033[48;5;0;38;5;${time_color_code}m%}${PVENV}\
%{\\033[38;5;0;48;5;${time_color_code}m%}\
 %D{%H:%M} %{$reset_color%(0?.$fg[${time_color_code}].$fg[white])%}\
 %(!.#.>) "
	echo $prompt
}

_gen_cache_file init

# secondary prompt
if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

# output
PROMPT='$(_print_prompt)'
PROMPT2="%{$fg[red]%}\ %{$reset_color%}"
RPS1="${return_code}"

ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_bold[yellow]%}*%{$fg[%{$time_color_code}]%}"
ZSH_THEME_GIT_PROMPT_PREFIX="| git: "
ZSH_THEME_GIT_PROMPT_SUFFIX=" %{$reset_color%}"
