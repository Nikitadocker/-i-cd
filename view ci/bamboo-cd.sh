#!/bin/bash
for i in $(cat deploy.list)
  do
  echo "start get status"
    if $(helm status $i -n $1 > /dev/null 2>&1)
      then
      echo "STATUS: OK!"
        if $(grep -rn "b_$i" $i/$5/values.yaml | grep "$4" > /dev/null 2>&1)
        echo "find branch in values"
          then
          rel=$(helm list -n $1 | grep $i | awk '{print $10}')
          echo "rel: $rel"
          conf=$(grep appVersion $i/$5/Chart.yaml | cut -d' ' -f 2 )
          echo "conf: $conf"
          if [ $conf != $rel ]
          echo "HAS DIFF!!!"
            then helm lint $i/$5/
            helm upgrade --wait --atomic --timeout 4m --set domain=$2 $i $i/$5/ -n $1
            helm history $i -n $1 --max 3
            sleep 5
          elif [ $conf == $rel ]
            then echo "NO DiFFERENCE"
          fi
        fi
      else
      echo "EXCEPTION!!!!!"
        helm lint $i/$5/
        helm install --wait --atomic --timeout 4m --set domain=$2 $i $i/$5/ -n $1
        helm history $i -n $1 --max 1
        sleep 5
    fi

  done

# Scale

kubectl -n $1 scale deployment --all --replicas=$3
kubectl -n pmc-production scale deployment pmc-statistic --replicas=1
kubectl -n pmc-production scale deployment pmc-statistic-metrics --replicas=1
helm list -n $1
sleep 5
kubectl get deployment -n $1