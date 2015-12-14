#!/bin/sh

#############################################################################################################
#
#  Usage:
#     please configure environment and conf first
#     thre are two mode to run this regresion: regression script in a dir or a single script file
#    
#############################################################################################################

### source ENV 
source ./environment.conf
### source public function
source ./lib/public.func
### validaty check,  create report and logs dir
if [[ -z "$1" || -n $2 ]]; then
   echo " Usage: There're two modes to run this tools."
   echo "        Regression  Mode:  $0 Script_List_Diri"
   echo "                           such as: $0 ./caseList"
   echo "        Single file Mode:  $0 Script_Case_File"
   echo "                           such as: $0 ./caseList/xx.sh"
   exit 1
elif [[ ! -x $1 ]]; then
   echo "please make sure $1 has executale right."
   exit 1
else
   createReport
   echo "please find report at $reportDir/testReport.txt"
   echo "please find detail case log under $reportDir/logs/"
fi
### write report tile, including begin date
writeReportTitle 
if [[ -d $1 ]]; then
   for caseScript in `ls $1/`   
   do
      if [[ ! -x $1/$caseScript  ]]; then
         echo "please make sure $1/$caseScript has executale right."
      else
          $1/$caseScript $reportDir 1> $reportDir/logs/$caseScript.stdout 2>$reportDir/logs/$caseScript.stderr
#         $1/$caseScript $reportDir 1>>stdout 2>>stderr
      fi
   done
elif [[ -f $1 ]]; then
   $1 $reportDir
else
   echo "please make sure $1 exists."
   exit 1
fi
# Statistic Case Result
writeReportStatistic

exit 0
