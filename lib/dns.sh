update_dns () {
  cat <<-EOF | nsupdate
  server ${1} ${2}
    ${3}
  send
EOF
  return ${?}
}
