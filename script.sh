#!/bin/bash

# Getting the target URL from user input
read -p "Enter the target URL (e.g., google.com): " target_url

# Validating the input
if [ -z "$target_url" ]; then
    echo "Error: The target URL cannot be empty. Exiting."
    exit 1
fi

# Extracting the domain name from the target URL
domain=$(echo "$target_url" | cut -d '.' -f 1)

# URLs for crt.sh --> %.domain.com + domain.%
first_url="https://crt.sh/?q=%25.$target_url"
second_url="https://crt.sh/?q=$domain.%25"

# Sending requests and extracting subdomains using wget and grep
first_subdomains=$(wget -qO- --timeout=10 "$first_url" | grep "<TD>" | cut -d '>' -f 2 | cut -d '<' -f 1 | grep "$domain" | grep -v "@" | grep -v " ")
wget_exit_code=$?

# Checking if wget timed out
if [[ $wget_exit_code -eq 124 ]]; then
    echo "Request timed out for $first_url"
    exit 1
fi

second_subdomains=$(wget -qO- --timeout=10 "$second_url" | grep "<TD>" | cut -d '>' -f 2 | cut -d '<' -f 1 | grep "$domain" | grep -v "@" | grep -v " ")
wget_exit_code=$?

# Checking if wget timed out
if [[ $wget_exit_code -eq 124 ]]; then
    echo "Request timed out for $second_url"
    exit 1
fi

third_subdomains=$(wget -qO- --timeout=10 "$first_url" | grep "BR>" | cut -d '>' -f 2 | cut -d '<' -f 1 | grep "$domain" | grep -v "@" | grep -v " ")
wget_exit_code=$?

# Checking if wget timed out
if [[ $wget_exit_code -eq 124 ]]; then
    echo "Request timed out for $first_url"
    exit 1
fi

fourth_subdomains=$(wget -qO- --timeout=10 "$second_url" | grep "BR>" | cut -d '>' -f 2 | cut -d '<' -f 1 | grep "$domain" | grep -v "@" | grep -v " ")
wget_exit_code=$?

# Checking if wget timed out
if [[ $wget_exit_code -eq 124 ]]; then
    echo "Request timed out for $second_url"
    exit 1
fi

# Combining and removing duplicates from subdomains
all_subdomains=$(echo -e "$first_subdomains\n$second_subdomains\n$third_subdomains\n$fourth_subdomains" | sort -u)

# The listing of subdomains in an HTML table
html_output="<html><body><h1>Subdomains for $domain</h1><table border='1'><tr><th>Subdomain</th></tr>"

for subdomain in $all_subdomains; do
    html_output+="<tr><td>$subdomain</td></tr>"
done

html_output+="</table></body></html>"

# Creation of output file in HTML format
output_file="$domain.html"

# Saving subdomains to the output file
echo -e "$html_output" > "$output_file"

# Checking the number of subdomains and displaying appropriate messages
num_subdomains=$(echo -e "$all_subdomains" | wc -l)
if [[ $num_subdomains -gt 1 ]]; then
    echo -e "\n[+] Found: $num_subdomains domains related to $domain"
    echo "[+] Output file name: $output_file"
else
    if [[ $num_subdomains -eq 0 ]]; then
        echo -e "\n[-] There are no subdomains related to: $domain"
    else
        echo -e "\n[-] No additional subdomains found!"
    fi
fi
