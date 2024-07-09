#!/bin/bash

# Declare an associative array to store sensor data
declare -A sensor_data

# Initialize index for the array
index=1

# Read lines from ipmitool sensor output
while read -r line; do
  # Ignore lines starting with "IANA" or "Received"
  if [[ "$line" =~ ^IANA|^Received ]]; then
    continue
  fi

  # Extract name, value, and unit from the line
  name=$(echo "$line" | cut -d'|' -f1 | tr -d ' ')
  value=$(echo "$line" | cut -d'|' -f2 | tr -d ' ')
  unit=$(echo "$line" | cut -d'|' -f3 | tr -d ' ')

  # Ignore lines with "na" in the value
  if [[ "$value" =~ na ]]; then
    continue
  fi

  # Remove ".000" from the value if present
  value="${value/\.000/}"

  # Store the name:value:unit in the associative array with the index as the key
  sensor_data[$index]="$name: $value: $unit"

  # Increment the index for the next line
  index=$((index + 1))
done < <(ipmitool sensor)

# Construct the XML output without loops
output="<prtg>
"
for i in $(seq 1 "$((index - 1))"); do
  sensor_value="${sensor_data[$i]}"
  name=$(echo "$sensor_value" | cut -d':' -f1 | tr -d ' ')
  value=$(echo "$sensor_value" | cut -d':' -f2 | tr -d ' ')
  unit=$(echo "$sensor_value" | cut -d':' -f3 | tr -d ' ') 

  # Check if the value has a decimal part
  if [[ "$value" =~ "." ]]; then
    output="$output<result>
<channel>$name</channel>
<value>$value</value>
<float>1</float>
<unit>custom</unit>
<customunit>$unit</customunit>
</result>"
  elif [[ "$unit" =~ "degreesC" ]]; then
    output="$output<result>
<channel>$name</channel>
<value>$value</value>
<unit>Temperature</unit>
</result>"
  else
    output="$output<result>
<channel>$name</channel>
<value>$value</value>
<unit>custom</unit>
<customunit>$unit</customunit>
</result>"
  fi
done
output="$output</prtg>"

# Echo the entire XML output in one command
echo "$output"