#!/bin/bash

for i in $1*.tsv
do
	base=${i#}
	name=${base%.tsv}
	echo $name
	tail -n +2 $i > tmp.tsv && mv tmp.tsv $name".tsv"
done

cat $1*.tsv > $1"_merge.tsv"
cat hdr.tsv $1"_merge.tsv" > $1"_multivar.tsv"

rm *merge* *multivar*