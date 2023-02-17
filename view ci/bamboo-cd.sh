#!/bin/bash
for i in $(cat deploy.list) # перебираем циклом for cписок наших deployment
  do
  echo "start get status"
    if $(helm status $i -n $1 > /dev/null 2>&1) #  выводим статус релиза в нашем namespace
      then
      echo "STATUS: OK!"
        if $(grep -rn "b_$i" $i/$5/values.yaml | grep "$4" > /dev/null 2>&1) # ищем с помощью grep имя ветки
        echo "find branch in values"
          then
          rel=$(helm list -n $1 | grep $i | awk '{print $10}') # присваиваем значение APP VERSION из helm list 
          echo "rel: $rel"
          conf=$(grep appVersion $i/$5/Chart.yaml | cut -d' ' -f 2 ) # ищем с помощью grep значение APP VERSION в Сhart и присваем это значение
          echo "conf: $conf"
          if [ $conf != $rel ] # если значение  APP VERSION не равны 
          echo "HAS DIFF!!!"
            then helm lint $i/$5/
            helm upgrade --wait --atomic --timeout 4m --set domain=$2 $i $i/$5/ -n $1 # то выполнить ugrade
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