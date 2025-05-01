app_name=$1
env=$2
appImage=$3

export PATH=/github-runner/.local/bin:/github-runner/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin

ARGOCD_LOGIN() {
    argocd_ip=$(kubectl get svc -n argocd argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    argocd_password=$(kubectl get secret argocd-initial-admin-secret -n argocd -o=jsonpath='{.data.password}' | base64 --decode)
    argocd login argocd-$env.azdevopsb82.online:443 --insecure --username admin --password ${argocd_password} --grpc-web
}

if [ -z "$app_name" -o -z "$env" ]; then
  echo Input AppName or env is missing
  exit 1
fi

# If not logged in we will login
if [ ! -e ~/.config/argocd/config ]; then
  ARGOCD_LOGIN
fi

current_ip=$(cat ~/.config/argocd/config  | grep ^current-context | awk '{print $NF}')
nc -w 3 -z $current_ip 443 &>/dev/null
if [ $? -ne 0 ]; then ARGOCD_LOGIN ; fi

argocd account list &>/dev/null
if [ $? -ne 0 ]; then
  ARGOCD_LOGIN
fi

argocd app create --upsert ${app_name} --repo https://github.com/raghudevopsb82/roboshop-helm.git --dest-namespace default --dest-server https://kubernetes.default.svc --values env-${env}/${app_name}.yaml  --path . --helm-set appImage=$appImage --grpc-web
argocd app sync ${app_name} --grpc-web
