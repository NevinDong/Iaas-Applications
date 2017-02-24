#! /bin/bash

KAP_TARFILE=kap-2.2.2-GA-hbase1.x.tar.gz
KAP_FOLDER_NAME="${KAP_TARFILE%.tar.gz*}"
KAP_DOWNLOAD_URI=https://kyligencekeys.blob.core.windows.net/kap-binaries/$KAP_TARFILE
KAP_INSTALL_BASE_FOLDER=/usr/local/kap
KAP_TMPFOLDER=/tmp/kap


KANALYZER_TARFILE=KyAnalyzer-2.1.3.tar.gz
KANALYZER_FOLDER_NAME=kyanalyzer-server
KANALYZER_DOWNLOAD_URI=https://kyligencekeys.blob.core.windows.net/kap-binaries/$KANALYZER_TARFILE

#import helper module.
wget -O /tmp/HDInsightUtilities-v01.sh -q https://hdiconfigactions.blob.core.windows.net/linuxconfigactionmodulev01/HDInsightUtilities-v01.sh && source /tmp/HDInsightUtilities-v01.sh && rm -f /tmp/HDInsightUtilities-v01.sh


downloadAndUnzipKAP() {
    echo "Removing KAP tmp folder"
    rm -rf $KAP_TMPFOLDER
    mkdir $KAP_TMPFOLDER
    
    echo "Downloading KAP tar file"
    wget $KAP_DOWNLOAD_URI -P $KAP_TMPFOLDER
    
    echo "Unzipping KAP"
    mkdir -p $KAP_INSTALL_BASE_FOLDER
    tar -zxvf $KAP_TMPFOLDER/$KAP_TARFILE -C $KAP_INSTALL_BASE_FOLDER

    rm -rf $KAP_TMPFOLDER
}

startKAP() {
    echo "Adding kylin user"
    useradd -r kylin
    chown -R kylin:kylin $KAP_INSTALL_BASE_FOLDER

    echo "Starting KAP with kylin user"
    su kylin
    export KYLIN_HOME=$KAP_INSTALL_BASE_FOLDER/$KAP_FOLDER_NAME

    ## Add index page to auto redirect to KAP 
    mkdir -p $KYLIN_HOME/tomcat/webapps/ROOT
    cat > $KYLIN_HOME/tomcat/webapps/ROOT/index.html <<EOL
<html>
  <head>
    <meta http-equiv="refresh" content="1;url=kylin/index.html"> 
  </head>
</html>
EOL
    
    $KYLIN_HOME/bin/kylin.sh start
    sleep 10

}

downloadAndUnzipKyAnalyzer() {
    rm -rf $KAP_TMPFOLDER
    mkdir $KAP_TMPFOLDER
    
    echo "Downloading KyAnalyzer tar file"
    wget $KANALYZER_DOWNLOAD_URI -P $KAP_TMPFOLDER
    
    echo "Unzipping KyAnalyzer"
    mkdir -p $KAP_INSTALL_BASE_FOLDER
    tar -zxvf $KAP_TMPFOLDER/$KANALYZER_TARFILE -C $KAP_INSTALL_BASE_FOLDER

    rm -rf $KAP_TMPFOLDER
}

startKyAnalyzer() {

    echo "Starting KyAnalyzer with kylin user"
    export KYANALYZER_HOME=$KAP_INSTALL_BASE_FOLDER/$KYANALYZER_FOLDER_NAME
    $KYANALYZER_HOME/start-analyzer.sh
    sleep 10

}

##############################
if [ "$(id -u)" != "0" ]; then
    echo "[ERROR] The script has to be run as root."
    exit 1
fi

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

if [ -e $KAP_INSTALL_BASE_FOLDER/$KAP_FOLDER_NAME ]; then
    echo "KAP is already installed. Exiting ..."
    exit 0
fi

echo "Download and unzip KAP & KyAnalyzer"
downloadAndUnzipKAP
downloadAndUnzipKyAnalyzer
echo "Start KAP & KyAnalyzer"
startKAP
startKyAnalyzer
echo "Start KAP & KyAnalyzer Done!"

