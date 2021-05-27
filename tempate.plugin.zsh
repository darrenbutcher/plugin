"__${template}_help () {
    printf 'Example usage:
  ${template} help, h           - show help
'
}

${template}_runner() {
  if [[ \$@ == \"help\" || \$@ == \"h\" ]]; then
    __${template}_help
  #elif [[ \$@ == \"something\" || \$@ == \"alias\" ]]; then
  fi
}

alias ${template}='${template}_runner'
"
