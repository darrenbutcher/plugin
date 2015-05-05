# Create custom zsh plugins
#

# Custom plugins location
# Default uses the default zsh custom plugins location
# Customize the location if needed.
# Default: $HOME/.oh-my-zsh/custom/plugins
custom_plugins_location="$HOME/.oh-my-zsh/custom/plugins"

# External file to store and isntall 
# zsh plugins 
plugins_install_location="$HOME/.zsh-plugins"

__plugin_help () {
    printf "Example usage:                 

  plugin list, ls           - show custom plugins
  plugin directory, dir, d  - show plugins location
  plugin create, c [name]   - create plugin
  plugin init,              - boilerplate plugin template
  plugin install [plugin]   - install plugin
  plugin uninstall [plugin] - uninstall plugin
  plugin edit [plugin]      - edit plugin
  plugin config             - edit plugins config: .zsh-plugins
  plugin config show [s]    - display plugins config: .zsh-plugins            
  plugin help, h            - show help 
"
}

__plugin_template () {
# Plugin boilerplate template name
template_name=$1

# Plugin boilerplate template
printf "__${template_name}_help () {
    printf 'Example usage:                     
  ${template_name} help, h           - show help 
'
}

${template_name}_runner() {
  if [[ \$@ == \"help\" || \$@ == \"h\" ]]; then 
    __${template_name}_help
  #elif [[ \$@ == \"something\" || \$@ == \"alias\" ]]; then 
  fi
}

alias ${template_name}='${template_name}_runner'
" >> $2
}

__plugin_init(){
  current_dir=`pwd`
  plugin_name=$1
  plugin_dir=$2
  plugin_file="$plugin_dir/$plugin_name.plugin.zsh"
  touch $plugin_file
  __plugin_template $plugin_name $plugin_file
  subl $plugin_file
}

__plugin_error(){
  code=$1
  plugin_name=$2
  if [[ $code == 404 ]];
  then
    echo "plugin: no such plugin exist."
  elif [[ $code == 403 ]];
  then
    echo "plugin: $plugin_name already exist."
  elif [[ $code == 405 ]];
  then
    echo "plugin: $plugin_name already installed."
  elif [[ $code == 406 ]];
  then
    echo "plugin: $plugin_name does not exist or not installed - plugin config show"
  elif [[ $code == 500 ]];
  then
    echo "plugin: check usage - plugin help."
  fi
}

plugin_runner() {
  if [[ $@ == "list" || $@ == "ls" ]]; then
    ls $custom_plugins_location

  elif [[ $@ == "directory" || $@ == "dir" || $@ == "d" ]]; then 
    echo $custom_plugins_location

  elif [[ $1 == "create" || $1 == "c" ]]; then
    plugin_name=$2

    if [[ ! $plugin_name == "" ]]; then
      plugins_dir=$custom_plugins_location
      plugin_dir=$plugins_dir/$plugin_name
      
      if [[ ! -d $plugin_file ]]; then
        mkdir $plugin_dir
        __plugin_init $plugin_name $plugin_dir 
      else
        echo "plugin: $plugin already exist."
      fi
    else
      __plugin_error 500
    fi

  elif [[ $1 == "install" || $1 == "i" ]]; then
    plugin_name=$2

    if [[ ! $plugin_name == "" ]]; then
      plugin_file=$custom_plugins_location/$plugin_name/"$plugin_name.plugin.zsh"
      
      if [[ -f $plugin_file ]]; then
        plugin_config=$plugins_install_location

        if ! grep -q $plugin_name "$plugin_config"; then
          
          # replace ) with new plugin
          # reference .zsh-plugins for easy install
          sed -i -e "s/)/ $plugin_name)/g" $plugin_config
          source $HOME/.zshrc
          echo "plugin: $plugin_name successfully installed."
        else
          __plugin_error 405 $plugin_name
        fi
      else
        __plugin_error 404
      fi
    else
      __plugin_error 500
    fi

  elif [[ $1 == "uninstall" || $1 == "un" ]]; then
    plugin_name=$2
    
    if [[ ! $plugin_name == "" ]]; then
      plugin_file=$custom_plugins_location/$plugin_name/"$plugin_name.plugin.zsh"

      if [[ -f $plugin_file ]]; then
        if grep -q $plugin_name "$plugin_config"; then
          # replace plugin with empty "" string
          # reference .zsh-plugins for easy uninstall
          sed -i -e "s/$plugin_name//g" $plugins_install_location
          echo "plugin: $plugin_name uninstalled."

          # Reload .zshrc
          source $HOME/.zshrc
        else
          __plugin_error 406 $plugin_name
        fi
       else
        __plugin_error 404
      fi
    else
      __plugin_error 500
    fi

  elif [[ $1 == "configure" || $1 == "edit" || $1 == "e" ]]; then 
    plugin_name=$2

    if [[ ! $plugin_name == "" ]]; then
      plugin_file=$custom_plugins_location/$plugin_name/"$plugin_name.plugin.zsh"
      
      if [[ -f $plugin_file ]]; then
        subl $plugin_file
      else
        __plugin_error 404
      fi
    else
      __plugin_error 500
    fi

  elif [[ $@ == "config" ]]; then 
    subl $plugins_install_location

  elif [[ $1 == "config" && $2 == "show" || $2 == "s"  ]]; then 
    less $plugins_install_location

  elif [[ $@ == "help" || $@ == "h" ]]; then 
    __plugin_help
  else
    __plugin_error 500
  fi
}

alias plu='plugin_runner'
alias plugin='plugin_runner'