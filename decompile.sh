#!/bin/sh -x

# decompiler shell script
# Author Tomoaki Imai
# param androidパッケージ package名.apk
# param 出力先 フルパスで指定する set in full path
# dex2jar-0.0.9.15、jad158g.mac.intel、nkf-2.1.3と同じディレクトリにスクリプトは配置・実行すること 
# put this script in a same directory with dex2jar-0.0.9.15、jad158g.mac.intel、nkf-2.1.3

package_apk=$1
out_dir=$2
cdir=`pwd`

#rename
#for fname in package_apk do
#	package_zip=`mv ${fname} ${fname%.a*}.zip`
#done

package_zip=`echo ${package_apk%.a*}.zip`
cp ${package_apk} ${package_apk%.a*}.zip
echo $package_zip
#unzip
if [ -e ${cdir}/tmp ]; then
	`echo ${cdir}/tmp found` 
else
mkdir ${cdir}/tmp
fi

mv ${cdir}/${package_zip} ${cdir}/tmp 

unzip ${cdir}/tmp/${package_zip} -d ${cdir}/tmp

cd ${cdir}/tmp
#decompile
${cdir}/dex2jar-0.0.9.15/d2j-dex2jar.sh ${cdir}/tmp/classes.dex

#unzip classes_dex2jar.jar
mv ${cdir}/tmp/classes-dex2jar.jar ${cdir}/tmp/classes-dex2jar.zip
unzip ${cdir}/tmp/classes-dex2jar.zip -d ${cdir}/tmp

#class to java
${cdir}/jad158g.mac.intel/jad -8 -d ${out_dir} -s .java -r ${cdir}/tmp/**/*.class

#unicode to UTF-8
cd ${out_dir}
find . -type f |sed -e 's/^\.\/*//g' | while read file;do native2ascii -reverse $file $file;nkf --overwrite -w8 $file;done

#mv files from tmp
mv ${cdir}/tmp/* ${out_dir}

#rm package_zip
rm ${out_dir}/${package_zip}
