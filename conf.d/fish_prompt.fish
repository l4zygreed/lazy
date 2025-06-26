# name: lazy

# ----------------------------------------------------------------------------
# Utils
# ----------------------------------------------------------------------------

# set -g __lazy_display_rprompt 0

function toggle_right_prompt -d "Toggle the right prompt of the lazy theme"
  if test $__lazy_display_rprompt -eq 0
    echo "enable right prompt"
    set __lazy_display_rprompt 1
  else
    echo "disable right prompt"
    set __lazy_display_rprompt 0
  end
end

function __lazy_git_branch_name -d "Return the current branch name"
  echo (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
end

function __lazy_git_repo_name -d "Return the current repository name"
  echo (command basename (git rev-parse --show-toplevel 2> /dev/null))
end

function __lazy_git_repo_base -d "Return the current repository name"
  echo (command git rev-parse --show-toplevel 2> /dev/null)
end

function __lazy_git_status -d "git status command"
  git status -b -s --ignore-submodules=dirty
end

function __lazy_unpushed_commit_count -d "Return the number of unpushed commits"
  echo $argv[1] | rg -o "ahead [0-9]+" | awk '{print $2}'
end

function __lazy_unmerged_commit_count -d "Return the number of unmerged commits"
  echo $argv[1] | rg -o "behind [0-9]+" | awk '{print $2}'
end

# ----------------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------------

alias trp toggle_right_prompt

# ----------------------------------------------------------------------------
# Prompts
# ----------------------------------------------------------------------------

function fish_prompt -d "Write out the left prompt of the lazy theme"
  set -l last_status $status
  set -l basedir_name (basename (prompt_pwd))
  set -l git_branch_name (__lazy_git_branch_name)
  set -l delim (echo -e \uE0C6)

  set -l f black
  set -l b blue

  set -l ps_status ""
  if test $last_status -ne 0 
    set ps_status (set_color -b red -o black)" $last_status "(set_color red -b blue)$delim
  end

  set -l ps_pwd ""
  set -l ps_repo ""
  set -l depth (pwd | string split -n "/" | wc -l)
  set -l in_home (pwd | rg ~)

  if test -n "$git_branch_name"
    set -l git_repo_name (__lazy_git_repo_name)
    if test "$basedir_name" != "$git_repo_name"
      set -l basedir_depth (__lazy_git_repo_base | string split -n "/" | wc -l)
      set depth (math $depth - $basedir_depth)
      set ps_repo "$git_repo_name:"
    else if test "$basedir_name" = "$git_repo_name"
      set depth 0
    end
  else
    if test -n "$in_home"
      set depth (math $depth - 2)
    end
  end

  set ps_pwd (set_color -o $f -b $b)' '$ps_repo$basedir_name
  if test $depth -gt 0
    set ps_pwd $ps_pwd'['$depth']'
  end
  set ps_pwd $ps_pwd' '

  set f blue



  set -l ps_git ""
  if test -n "$git_branch_name"
    set -l git_info ""
    set -l git_status (__lazy_git_status)
    set -l colbranch green
    if echo $git_status | rg "\s\?\?\s|\sM\s|\sD\s" > /dev/null
      set colbranch brred
    end

    set b $colbranch
    set ps_git (set_color -o $f -b $b)$delim
    set f black
    set ps_git $ps_git(set_color -o $f -b $b)


    if echo $git_status | rg ahead > /dev/null
      set git_info "[↑"(__lazy_unpushed_commit_count $git_status)"]"
    end
    if echo $git_status | rg behind > /dev/null
      set git_info $git_info"[↓"(__lazy_unmerged_commit_count $git_status)"]"
    end
    set ps_git $ps_git' '\ueba1" $git_branch_name$git_info "
    set f $colbranch
  end
      
  set -l ps_ranger ""
  if test "$RANGER_LEVEL" != ""
    set b yellow
    set ps_ranger (set_color -o $f -b $b)$delim
    set f black
    set ps_ranger $ps_ranger(set_color -o $f -b $b)

    set ps_ranger $ps_ranger" "(string repeat \uf41c" " -n $RANGER_LEVEL)

    set f yellow
  end

  set -l ps_yazi ""
  if test "$YAZI_LEVEL" != ""
    set b yellow
    set ps_yazi (set_color -o $f -b $b)$delim
    set f black
    set ps_yazi $ps_yazi(set_color -o $f -b $b)

    set ps_yazi $ps_yazi" "(string repeat \uf41c" " -n $YAZI_LEVEL)

    set f yellow
  end

  # Left Prompt

  echo -n -s $ps_status $ps_pwd $ps_git $ps_ranger $ps_yazi (set_color $f -b normal) $delim $colnormal ' '
end
