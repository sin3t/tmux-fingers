#!/usr/bin/env bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $CURRENT_DIR/utils.sh

match_lookup_table=$(fingers_tmp)
pane_output_temp=$(fingers_tmp)
flushed_input=0

# exporting them so they can be properly deleted at fingers.sh handle_exit trap
export match_lookup_table
export pane_output_temp

function lookup_match() {
  local input=$1
  echo "$(cat $match_lookup_table | grep "^$input:" | sed "s/^$input://" | uniq)"
}

function get_stdin() {
  if [[ $(cat $pane_output_temp | wc -l) -gt 0 ]]; then
    cat $pane_output_temp
  else
    flushed_input="1"
    tee $pane_output_temp
  fi
}

function show_hints() {
  local fingers_pane_id=$1
  local compact_hints=$2

  clear_screen "$fingers_pane_id"
  get_stdin | COMPACT_HINTS=$compact_hints FINGER_PATTERNS=$PATTERNS __awk__ -f $CURRENT_DIR/hinter.awk 3> $match_lookup_table
}

function show_hints_and_swap() {
  current_pane_id=$1
  fingers_pane_id=$2
  compact_state=$3

  pane_was_zoomed=$(is_pane_zoomed "$current_pane_id")

  if [[ $pane_was_zoomed == "1" ]]; then
      tmux swap-pane -s "$current_pane_id" -t "$fingers_pane_id" \; resize-pane -Z
  else
      tmux swap-pane -s "$current_pane_id" -t "$fingers_pane_id"
  fi
  show_hints "$fingers_pane_id" $compact_state
}
