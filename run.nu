#!/usr/bin/env nu

const app_path = "app"
const infra_path = "infra"

const env_path = "env.json"
mut mut_env_vars = {}

if ($env_path | path exists) {
    $mut_env_vars = (open env.json)
}

let env_vars = $mut_env_vars

def build-app [] {
    echo "building app..."
    cd $app_path
    hugo
}

def clean-app [] {
    echo "cleaning up app..."
    rm -rf $"($app_path)/public"
}

def clean-infra [] {
    echo "cleaning up terraform..."
    rm -rf $"($infra_path)/**/*.tfstate*"
}

def deploy-app [] {
    echo "deploying app..."
    cd $app_path

    const dist_path = "public"
    const ssm_path = "/oliviervanaken.com"

    let bucket_name = (aws ssm get-parameter --name "/oliviervanaken.com/bucket-name" --no-cli-pager) | from json | get Parameter.Value

    aws s3 sync $dist_path $"s3://($bucket_name)" --exclude "*.txt" --cache-control "max-age=604800"
}

def deploy-infra [approve: bool = false] {
    echo "deploying infra..."

    cd $infra_path

    terraform init

    mut options = {
        approve: ""
    }

    if $approve {
        $options.approve = "-auto-approve"
    }

    run-external terraform apply $options.approve
}

def init-infra [] {
    echo "initializing infra..."
    cd $infra_path
    terraform init
}

def load-env-vars [] {
    echo "loading env vars..."
    load-env $env_vars
}

def try-infra [] {
    echo "trying infra..."
    cd $infra_path
    terraform plan
}

def "main build" [] {
    build-app
}

def "main try-infra" [] {
    with-env $env_vars {
        init-infra
        try-infra
    }
}

def "main clean" [] {
    clean-app
    clean-infra
}

def "main deploy" [--infra (-i)] {
    with-env $env_vars {
        if $infra {
            main deploy-infra --approve
        }

        main deploy-app
    }
}

def "main deploy-app" [] {
    with-env $env_vars {
        deploy-app
    }
}

def "main deploy-infra" [--approve (-a)] {
    with-env $env_vars {
        deploy-infra $approve
    }
}

def "main serve" [] {
    cd $app_path
    hugo server -D
}

def main [] {}
