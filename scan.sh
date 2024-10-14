#!/bin/sh
# mirakc channel scan (using mirakc docker container image)
# by uru (https://twitter.com/uru_2)
#
# require:
#   docker
#   jq
set -eu
export LANG=C.UTF-8

readonly EXTRACT_SID="${EXTRACT_SID:-0}"

readonly OUTPUT_FILE='channels.yml'

# record command template
# must be ts stream output to stdout
# if empty setting, then skip channel scan
#   <channel> : channel
readonly RECORD_COMMAND_GR='dvbv5-zap -a 1 -s -r -P <channel> -t 10 -o -'
readonly RECORD_COMMAND_BS='dvbv5-zap -a 0 -s -r -P <channel> -t 20 -o -'
readonly RECORD_COMMAND_CS='dvbv5-zap -a 0 -s -r -P <channel> -t 10 -o -'

# scan target channels: GR
CHANNELS_GR="$(cat << EOT
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62

C13
C14
C15
C16
C17
C18
C19
C20
C21
C22
C23
C24
C25
C26
C27
C28
C29
C30
C31
C32
C33
C34
C35
C36
C37
C38
C39
C40
C41
C42
C43
C44
C45
C46
C47
C48
C49
C50
C51
C52
C53
C54
C55
C56
C57
C58
C59
C60
C61
C62
C63

EOT
)"
readonly CHANNELS_GR=$(echo "${CHANNELS_GR}" | grep -e '^[^#]')

# scan target channels: BS
CHANNELS_BS="$(cat << EOT
BS01_0
BS01_1
BS01_2
BS01_3
#BS01_4
#BS01_5
#BS01_6
#BS01_7

BS03_0
BS03_1
BS03_2
BS03_3
#BS03_4
#BS03_5
#BS03_6
#BS03_7

BS05_0
BS05_1
BS05_2
BS05_3
#BS05_4
#BS05_5
#BS05_6
#BS05_7

#BS07_0
#BS07_1
#BS07_2
#BS07_3
#BS07_4
#BS07_5
#BS07_6
#BS07_7

BS09_0
BS09_1
BS09_2
BS09_3
#BS09_4
#BS09_5
#BS09_6
#BS09_7

BS11_0
BS11_1
BS11_2
BS11_3
#BS11_4
#BS11_5
#BS11_6
#BS11_7

BS13_0
BS13_1
BS13_2
BS13_3
#BS13_4
#BS13_5
#BS13_6
#BS13_7

BS15_0
BS15_1
BS15_2
BS15_3
#BS15_4
#BS15_5
#BS15_6
#BS15_7

#BS17_0
#BS17_1
#BS17_2
#BS17_3
#BS17_4
#BS17_5
#BS17_6
#BS17_7

BS19_0
BS19_1
BS19_2
BS19_3
#BS19_4
#BS19_5
#BS19_6
#BS19_7

BS21_0
BS21_1
BS21_2
BS21_3
#BS21_4
#BS21_5
#BS21_6
#BS21_7

BS23_0
BS23_1
BS23_2
BS23_3
#BS23_4
#BS23_5
#BS23_6
#BS23_7

EOT
)"
readonly CHANNELS_BS=$(echo "${CHANNELS_BS}" | grep -e '^[^#]')

# scan target channels: CS
CHANNELS_CS="$(cat << EOT
CS2
CS4
CS6
CS8
CS10
CS12
CS14
CS16
CS18
CS20
CS22
CS24

EOT
)"
readonly CHANNELS_CS=$(echo "${CHANNELS_CS}" | grep -e '^[^#]')


# find require tools
if [ ! "$(which docker)" ]; then
  echo 'require docker' >&2
  return 1
fi
if [ ! "$(which jq)" ]; then
  echo 'require jq' >&2
  return 1
fi

all_lists=''

# scan GR
if [ -n "${RECORD_COMMAND_GR}" ]; then
  list=''
  type='GR'
  channels="${CHANNELS_GR}"
  cmd_base="${RECORD_COMMAND_GR}"

  for ch in ${channels}; do
    echo "[type: ${type}, channel: ${ch}]" >&2

    # generate record command
    rec_cmd="$(echo "${cmd_base}" | sed -e "s/<channel>/${ch}/")"

    # execute command
    json=$(docker compose run --rm --entrypoint= mirakc sh -c "${rec_cmd} 2> /dev/null | /usr/local/bin/mirakc-arib scan-services 2> /dev/null" \
      | jq -M -c || printf '')
    if [ -z "${json}" ]; then
      continue
    fi

    # extract .name (first service only)
    sname=$(echo "${json}" | jq -M -r '.[0] | .name')

    # extract all service .sid
    sid=$(echo "${json}" | jq -M -r '.[] | .sid' | jq -M -s . | jq -M -r 'join(",")')

    list=$(printf '%s\n%s\t%s\t%s\t%s' "${list}" "${type}" "${ch}" "${sname}" "${sid}" | sed '/^$/d')
  done

  # append all lists
  if [ -n "${list}" ]; then
    all_lists=$(printf '%s\n%s' "${all_lists}" "${list}" | sed '/^$/d')
  fi
fi

# scan BS
if [ -n "${RECORD_COMMAND_BS}" ]; then
  list=''
  type='BS'
  channels="${CHANNELS_BS}"
  cmd_base="${RECORD_COMMAND_BS}"

  for ch in ${channels}; do
    echo "[type: ${type}, channel: ${ch}]" >&2

    # generate record command
    rec_cmd="$(echo "${cmd_base}" | sed -e "s/<channel>/${ch}/")"

    # execute command
    json=$(docker compose run --rm --entrypoint= mirakc sh -c "${rec_cmd} 2> /dev/null | /usr/local/bin/mirakc-arib scan-services 2> /dev/null" \
        | jq -M -c || printf '')
    if [ -z "${json}" ]; then
      continue
    fi

    # extract .name (first service only)
    sname=$(echo "${json}" | jq -M -r '.[0] | .name')

    # extract all service .sid
    sid=$(echo "${json}" | jq -M -r '.[] | .sid' | jq -M -s . | jq -M -r 'join(",")')

    # duplicate sid skip
    # (may return first slot(=slot 0) information, if slot not used)
    append='1'
    if [ -n "${list}" ]; then
      for line in ${list}; do
        line_sid=$(echo "${line}" | cut -f 4)

        if [ "${line_sid}" = "${sid}" ]; then
          append='0'
          break
        fi
      done
    fi
    if [ "${append}" = '0' ]; then
      continue
    fi

    list=$(printf '%s\n%s\t%s\t%s\t%s' "${list}" "${type}" "${ch}" "${sname}" "${sid}" | sed '/^$/d')
  done

  # append all lists
  if [ -n "${list}" ]; then
    all_lists=$(printf '%s\n%s' "${all_lists}" "${list}" | sed '/^$/d')
  fi
fi

# scan CS
if [ -n "${RECORD_COMMAND_CS}" ]; then
  list=''
  type='CS'
  channels="${CHANNELS_CS}"
  cmd_base="${RECORD_COMMAND_CS}"

  for ch in ${channels}; do
    echo "[type: ${type}, channel: ${ch}]" >&2

    # generate record command
    rec_cmd="$(echo "${cmd_base}" | sed -e "s/<channel>/${ch}/")"

    # execute command
    json=$(docker compose run --rm --entrypoint= mirakc sh -c "${rec_cmd} 2> /dev/null | /usr/local/bin/mirakc-arib scan-services 2> /dev/null" \
        | jq -M -c || printf '')
    if [ -z "${json}" ]; then
      continue
    fi

    if [ "${EXTRACT_SID}" = "1" ]; then
      # each all services
      for i in $(awk "BEGIN { for (i = 0; i < $(echo "${json}" | jq -M -r 'length'); i++) { print i } }"); do
        service_json=$(echo "${json}" | jq -M -c ".[${i}]")

        # extract .name
        sname=$(echo "${service_json}" | jq -M -r '.name')

        # extract .sid
        sid=$(echo "${service_json}" | jq -M -r '.sid')

        list=$(printf '%s\n%s\t%s\t%s\t%s' "${list}" "${type}" "${ch}" "${sname}" "${sid}" | sed '/^$/d')
      done
    else
      # service name = channel
      sname="${ch}"

      # extract all service .sid
      sid=$(echo "${json}" | jq -M -r '.[] | .sid' | jq -M -s . | jq -M -r 'join(",")')

      list=$(printf '%s\n%s\t%s\t%s\t%s' "${list}" "${type}" "${ch}" "${sname}" "${sid}" | sed '/^$/d')
    fi
  done

  # append all lists
  if [ -n "${list}" ]; then
    all_lists=$(printf '%s\n%s' "${all_lists}" "${list}" | sed '/^$/d')
  fi
fi

# generate mirakc channels configuration
# see: https://github.com/mirakc/mirakc/blob/release/docs/config.md#channels
if [ -n "${all_lists}" ]; then
  echo 'channels:' > "${OUTPUT_FILE}"

  echo "${all_lists}" | awk -F "\t" -v "EXTRACT_SID=${EXTRACT_SID}" '
{
  printf("  - name: '\''%s'\''\n", $3);
  printf("    type: '\''%s'\''\n", $1);
  printf("    channel: '\''%s'\''\n", $2);
  printf("    extra-args: '\'''\''\n");
  if (EXTRACT_SID == "1") {
    printf("    services: [%s]\n", $4);
  }
  printf("    disabled: false\n");
  printf("\n");
}' >> "${OUTPUT_FILE}"
fi

echo "channel scan finished, output to ${OUTPUT_FILE}" >&2
return 0
