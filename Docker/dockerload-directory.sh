#/bin/bash
echo "Grabbing current working directory..."
wkdir=$PWD
echo
echo "current working directory is ${wkdir}"
echo
echo "dockerizing the tars!"
echo "............."
echo "whatever that means..."
echo "loading first image, standby..."
for filename in ${wkdir}/*.tar.gz ; 
	do docker load -i "$filename" ; 
done
exit
