#!/usr/bin/env nu

const app_path = "app"
const infra_path = "infra"

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
    cd $infra_path
    rm -rf .terraform*
    rm -rf *.tfstate*
}

def deploy-app [] {
    echo "deploying app..."
}

def deploy-infra [auto_approve: bool = false] {
    echo "deploying infra..."
    cd $infra_path
    terraform init

    let command = ["terraform", "apply"]

    if $auto_approve {
        command = ($command | append "-auto-approve" )
    }

    do $command
}

def "main build" [] {
    build-app
}

def "main clean" [] {
    clean-app
}


def "main deploy" [--infra (-i)] {
    if $infra {
        main deploy-infra
    }

    main deploy-app
}

def "main deploy-app" [] {
    deploy-app
}

def "main deploy-infra" [--auto-approve (-a)] {
    deploy-infra $auto_approve
}

def "main serve" [] {
    cd $app_path
    hugo server -D
}

def main [] {}
