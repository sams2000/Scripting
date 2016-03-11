#!/bin/bash
substring="404"

if ARGV[0] == nil; then
	echo "Usage: <need url>"
else
	url="#{ARGV[0]}"
	#url=http://stg-shipprsusvc.glb.staging.walmart.com/ship-pricing-rules1/
	
	result=$(curl -Is "$url" | head -n 1)

	if [[ "$result" == *"$substring"* ]]; then
	  echo "$url is NOT accessible"
	else
	  echo "$url is accessible"
	fi
fi
