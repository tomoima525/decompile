#!/bin/sh

# decompiler shell script
# Author Tomoaki Imai
# param androidパッケージ package名.apk
# param out_dir 出力先 フルパスで指定する set in full path
# dex2jar-0.0.9.15、jad158g.mac.intel、nkf-2.1.3と同じディレクトリにスクリプトは配置・実行すること 
# put this script in a same directory with dex2jar-0.0.9.15、jad158g.mac.intel、nkf-2.1.3

#check if params exist
if [ $# -lt 2 ]; then
	echo "usage: decompile.sh package.apk out_dir"
	exit 1
fi

package_apk=$1
out_dir=$2
cdir=`pwd`

#check params
if [ ! -e ${cdir}/${package_apk} ]; then
    echo "package ${package_apk} does not exist"
    exit 3
fi

if [ ! -e ${out_dir} ]; then
    echo "output  directory ${out_dir} does not exist"
    exit 3
fi

#check directories
if [ ! -e ${cdir}/dex2jar-0.0.9.15 ]; then
	echo "${cdir}/dex2jar-0.0.9.15 not found"
	exit 2 
fi

if [ ! -e ${cdir}/jad158g.mac.intel ]; then
	echo "${cdir}/jad158g.mac.intel not found"
	exit 2 
fi

if [ ! -e ${cdir}/nkf-2.1.3 ]; then
	echo "${cdir}/nkf-2.1.3 not found"
	exit 2 
fi

package_zip=`echo ${package_apk%.a*}.zip`
cp ${package_apk} ${package_apk%.a*}.zip
#unzip
if [ -e ${cdir}/tmp ]; then
	echo "${cdir}/tmp found" 
else
mkdir ${cdir}/tmp
fi

mv ${cdir}/${package_zip} ${cdir}/tmp 

unzip ${cdir}/tmp/${package_zip} -d ${cdir}/tmp

cd ${cdir}/tmp
#decompile
${cdir}/dex2jar-0.0.9.15/d2j-dex2jar.sh -f ${cdir}/tmp/classes.dex

#unzip classes_dex2jar.jar
mv ${cdir}/tmp/classes-dex2jar.jar ${cdir}/tmp/classes-dex2jar.zip
unzip -o ${cdir}/tmp/classes-dex2jar.zip -d ${cdir}/tmp

#class to java
${cdir}/jad158g.mac.intel/jad -8 -d ${out_dir} -s .java -r ${cdir}/tmp/**/*.class

#unicode to UTF-8
echo "changing unicode to UTF-8. This will take time ..."
cd ${out_dir}
find . -type f |sed -e 's/^\.\/*//g' | while read file;do native2ascii -reverse $file $file;nkf --overwrite -w8 $file;done

#mv files from tmp
mv -n ${cdir}/tmp/* ${out_dir}

#rm package_zip,tmp
rm ${out_dir}/${package_zip}
rm -rf ${cdir}/tmp
echo "Decompile done!"

