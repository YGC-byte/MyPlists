#!/bin/bash
echo "================================================================"
echo "请确保ipa已在当前目录下"
echo "注意⚠️: 一次只能部署一种环境，请不要放多个ipa到当前目录下"
echo "================================================================"
release_version=`/usr/libexec/PlistBuddy -c 'Print :items:0:metadata:bundle-version' ./manifest.plist`
debug_version=`/usr/libexec/PlistBuddy -c 'Print :items:0:metadata:bundle-version' ./manifest_test.plist`
release_bundleId=`/usr/libexec/PlistBuddy -c 'Print :items:0:metadata:bundle-identifier' ./manifest.plist`
debug_bundleId=`/usr/libexec/PlistBuddy -c 'Print :items:0:metadata:bundle-identifier' ./manifest_test.plist`

if [ ! -f "./app.ipa" ]; then
   echo "当前目录下未检测到ipa文件"
   exit 1
fi

read -p "部署Release环境（y/n）:      " env
if [[ -n "$env" ]]; then
	 if [[ "$env"="y" ]]; then
	 	echo "******************************"
	 	echo "已选择Release环境"
	 	echo "当前release版本为: $release_version"
		echo "当前release bundleId为: $release_bundleId"
	 	echo "******************************"
	 else
	 	echo "******************************"
	 	echo "已选择Debug环境"
	 	echo "当前debug版本为: $debug_version"
		echo "当前debug bundleId为: $debug_bundleId"
	 	echo "******************************"
	 fi
else
	echo "******************************"
	echo "默认为Release环境"
	echo "当前release版本为: $release_version"
	echo "当前release bundleId为: $release_bundleId"
	echo "******************************"
	env="y"
fi

read -p "版本号(版本号为必填项): " version
if [[ -n "$version" ]]; then
	echo $version
else
   if [[ "$env" = "y" ]]; then
	 version=$release_version  
   else
   	 version=$debug_version
   fi
fi

read -p "应用的BundleId(不填写则默认不修改): " bundleId
if [[ -n "$bundleId" ]]; then
	echo "${bundleId}"
else
  	if [[ "$env" = "y" ]]; then
  	  bundleId=$release_bundleId
  	else
  	  bundleId=$debug_bundleId
 	fi
fi

read -p "部署版本描述信息: " commit_message
if [[ -n "$commit_message" ]]; then
	echo "$commit_message"
else
	commit_message="🚀update~"
fi
 
 
if [[ "$env" = "y" ]]; then
  /usr/libexec/PlistBuddy -c 'Set :items:0:metadata:bundle-version string $version' ./manifest.plist
  /usr/libexec/PlistBuddy -c 'Set :items:0:metadata:bundle-identifier string $bundleId' ./manifest.plist
  sudo cp -f ./*ipa  /Library/WebServer/Documents/app/ipa/release/app.ipa
else
  /usr/libexec/PlistBuddy -c 'Set :items:0:metadata:bundle-version string $version' ./manifest_test.plist
  /usr/libexec/PlistBuddy -c 'Set :items:0:metadata:bundle-identifier string $bundleId' ./manifest_test.plist
  sudo cp -f ./*ipa  /Library/WebServer/Documents/app/ipa/debug/app.ipa
fi

echo "🎉🎉🎉 部署成功！！！"
echo "确保手机连上ZQun-5G的WiFi"
echo "手机Safari浏览器打开 http://192.168.1.166/app/index.html 即可食用~"	

open /Library/WebServer/Documents/app/ipa

rm -rf *.ipa #移除记录 

echo "🚀🚀🚀提交代码"

git add .
git commit -am  "$commit_message"
git push origin master 


