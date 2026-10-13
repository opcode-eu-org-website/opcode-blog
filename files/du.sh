#!/bin/sh

BYTES=$(find "$1" -xdev -type f -exec /sbin/filefrag -e -k {} \; | awk -F': ' '
	{
		total_size += $4
	}
	/shared/ {
		# hard-links and reflinks
		size[$3] = $4
		count[$3]++
	}
	END {
		sum=0
		for (i in count) {
			sum += (count[i]-1) * size[i]
		}
		print (total_size-sum) * 1024
	}
')

echo "Summary disk usage for '$1' (single file system): $(numfmt --to=iec ${BYTES:-0})"
