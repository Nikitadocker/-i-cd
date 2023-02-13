#!/bin/bash

#$1 ${bamboo.username}
#$2 ${bamboo.planRepository.name} 
#$3 ${bamboo.planRepository.branch} 
#$4 ${bamboo.buildNumber}
#$5 artefactory
#$6 secret
#7 sreda okryzheniya
git config user.email "$1@stream.ru" # конфигурация почты пользователя для git
git config user.name "$1" # конфигурация  пользователя для git


git checkout $3
if [ $? != 0 ];
  then git checkout develop && git checkout -b $3  > /dev/null 2>&1;
fi

echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

branch=`git branch`
echo "current branch: "${branch} 
branch_low="$(tr [A-Z] [a-z] <<< "$3")"
sed -i "/arti/c arti: $5" $2/$7/values.yaml
sed -i "/b_$2/c b_$2: $branch_low" $2/$7/values.yaml
sed -i "/t_$2/c t_$2: $4" $2/$7/values.yaml
sed -i "/appVersion/c appVersion: $3-$4" $2/$7/Chart.yaml
sed -i -E "s/ns-pmc-production-artifactory-.*/$6/" $2/$7/templates/$2_deployment.yaml
sed -i -E "s/ns-pmc-production-artifactory-.*/$6/" $2/$7/templates/statistic_deployment.yaml
sed -i -E "s/ns-pmc-production-artifactory-.*/$6/" $2/$7/templates/statistic_deployment_metrics.yaml
sed -i -E "s/ns-pmc-production-artifactory-.*/$6/" $2/$7/templates/router_deployment.yaml
git add $2/$7/values.yaml
git add $2/$7/Chart.yaml
git add $2/$7/templates/$2_deployment.yaml
git add $2/$7/templates/statistic_deployment.yaml
git add $2/$7/templates/statistic_deployment_metrics.yaml
git add $2/$7/templates/router_deployment.yaml
git commit -m "Change $2/$3:$4 in values.yaml"
#git push origin $3
git push origin $3


